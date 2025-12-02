import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mono_bloc_example/bank/bank_account_bloc.dart';
import 'package:mono_bloc_example/bank/bank_account_state.dart';

void main() {
  group('BankAccountBloc - Sequential Processing', () {
    late BankAccountBloc bloc;

    setUp(() {
      bloc = BankAccountBloc();
    });

    tearDown(() async {
      await bloc.close();
    });

    test('initial state has zero balance', () {
      expect(bloc.state.balance, 0.0);
      expect(bloc.state.lastTransaction, isNull);
      expect(bloc.state.error, isNull);
    });

    blocTest<BankAccountBloc, BankAccountState>(
      'deposit increases balance',
      build: BankAccountBloc.new,
      act: (bloc) => bloc.deposit(100),
      wait: const Duration(milliseconds: 150),
      expect: () => [
        predicate<BankAccountState>((state) {
          return state.balance == 100.0 &&
              state.lastTransaction?.type == TransactionType.deposit &&
              state.lastTransaction?.amount == 100.0;
        }),
      ],
    );

    blocTest<BankAccountBloc, BankAccountState>(
      'withdraw decreases balance',
      build: BankAccountBloc.new,
      seed: () => const BankAccountState(balance: 100),
      act: (bloc) => bloc.withdraw(30),
      wait: const Duration(milliseconds: 150),
      expect: () => [
        predicate<BankAccountState>((state) {
          return state.balance == 70.0 &&
              state.lastTransaction?.type == TransactionType.withdrawal &&
              state.lastTransaction?.amount == 30.0;
        }),
      ],
    );

    blocTest<BankAccountBloc, BankAccountState>(
      'withdraw with insufficient funds returns error',
      build: BankAccountBloc.new,
      seed: () => const BankAccountState(balance: 50),
      act: (bloc) => bloc.withdraw(100),
      wait: const Duration(milliseconds: 150),
      expect: () => [
        predicate<BankAccountState>((state) {
          return state.balance == 50.0 &&
              state.error != null &&
              state.error!.contains('Insufficient funds');
        }),
      ],
    );

    blocTest<BankAccountBloc, BankAccountState>(
      'transfer reduces balance and records recipient',
      build: BankAccountBloc.new,
      seed: () => const BankAccountState(balance: 200),
      act: (bloc) => bloc.transfer(75, 'Alice'),
      wait: const Duration(milliseconds: 200),
      expect: () => [
        predicate<BankAccountState>((state) {
          return state.balance == 125.0 &&
              state.lastTransaction?.type == TransactionType.transfer &&
              state.lastTransaction?.amount == 75.0 &&
              state.lastTransaction?.recipient == 'Alice';
        }),
      ],
    );

    blocTest<BankAccountBloc, BankAccountState>(
      'transfer with insufficient funds returns error',
      build: BankAccountBloc.new,
      seed: () => const BankAccountState(balance: 30),
      act: (bloc) => bloc.transfer(50, 'Bob'),
      wait: const Duration(milliseconds: 200),
      expect: () => [
        predicate<BankAccountState>((state) {
          return state.balance == 30.0 &&
              state.error != null &&
              state.error!.contains('Insufficient funds');
        }),
      ],
    );

    blocTest<BankAccountBloc, BankAccountState>(
      'reset sets balance to zero',
      build: BankAccountBloc.new,
      seed: () => const BankAccountState(balance: 500),
      act: (bloc) => bloc.reset(),
      expect: () => [const BankAccountState(balance: 0)],
    );

    blocTest<BankAccountBloc, BankAccountState>(
      'checkBalance sets loading flag',
      build: BankAccountBloc.new,
      seed: () => const BankAccountState(balance: 100),
      act: (bloc) => bloc.checkBalance(),
      wait: const Duration(milliseconds: 600),
      expect: () => [
        predicate<BankAccountState>(
          (state) => state.isLoading && state.balance == 100.0,
        ),
        predicate<BankAccountState>(
          (state) => !state.isLoading && state.balance == 100.0,
        ),
      ],
    );

    group('Sequential Processing - Race Condition Prevention', () {
      blocTest<BankAccountBloc, BankAccountState>(
        'multiple deposits are processed sequentially',
        build: BankAccountBloc.new,
        act: (bloc) {
          // Fire multiple deposits at once
          bloc.deposit(50);
          bloc.deposit(30);
          bloc.deposit(20);
        },
        wait: const Duration(milliseconds: 350),
        verify: (bloc) {
          // All deposits should be processed sequentially
          // Final balance should be 50 + 30 + 20 = 100
          expect(bloc.state.balance, 100.0);
        },
      );

      blocTest<BankAccountBloc, BankAccountState>(
        'mixed operations are processed sequentially',
        build: BankAccountBloc.new,
        seed: () => const BankAccountState(balance: 100),
        act: (bloc) {
          // Fire multiple operations at once
          bloc.deposit(50); // 100 + 50 = 150
          bloc.withdraw(30); // 150 - 30 = 120
          bloc.deposit(20); // 120 + 20 = 140
          bloc.withdraw(10); // 140 - 10 = 130
        },
        wait: const Duration(milliseconds: 450),
        verify: (bloc) {
          // All operations processed sequentially
          expect(bloc.state.balance, 130.0);
        },
      );

      blocTest<BankAccountBloc, BankAccountState>(
        'transfer after deposit uses updated balance',
        build: BankAccountBloc.new,
        act: (bloc) {
          bloc.deposit(100);
          bloc.transfer(50, 'Alice');
        },
        wait: const Duration(milliseconds: 300),
        verify: (bloc) {
          // Transfer should use balance after deposit (100 - 50 = 50)
          expect(bloc.state.balance, 50.0);
          expect(bloc.state.error, isNull);
        },
      );

      blocTest<BankAccountBloc, BankAccountState>(
        'withdrawal after deposit uses updated balance',
        build: BankAccountBloc.new,
        seed: () => const BankAccountState(balance: 20),
        act: (bloc) {
          bloc.deposit(50); // 20 + 50 = 70
          bloc.withdraw(60); // 70 - 60 = 10 (should succeed)
        },
        wait: const Duration(milliseconds: 250),
        verify: (bloc) {
          // Withdrawal should succeed with updated balance
          expect(bloc.state.balance, 10.0);
          expect(bloc.state.error, isNull);
        },
      );

      blocTest<BankAccountBloc, BankAccountState>(
        'rapid operations maintain consistency',
        build: BankAccountBloc.new,
        seed: () => const BankAccountState(balance: 1000),
        act: (bloc) {
          // Fire 10 operations rapidly
          for (var i = 0; i < 5; i++) {
            bloc.deposit(10);
            bloc.withdraw(5);
          }
        },
        wait: const Duration(milliseconds: 1100),
        verify: (bloc) {
          // 1000 + (5 * 10) - (5 * 5) = 1000 + 50 - 25 = 1025
          expect(bloc.state.balance, 1025.0);
        },
      );
    });

    group('Independent Operations', () {
      blocTest<BankAccountBloc, BankAccountState>(
        'checkBalance runs independently of sequential queue',
        build: BankAccountBloc.new,
        seed: () => const BankAccountState(balance: 100),
        act: (bloc) {
          // Fire sequential operations and checkBalance
          bloc.deposit(50);
          bloc.checkBalance(); // This should run independently
          bloc.withdraw(30);
        },
        wait: const Duration(milliseconds: 700),
        verify: (bloc) {
          // Sequential operations should complete correctly
          // 100 + 50 - 30 = 120
          expect(bloc.state.balance, 120.0);
          expect(bloc.state.isLoading, false);
        },
      );
    });
  });
}
