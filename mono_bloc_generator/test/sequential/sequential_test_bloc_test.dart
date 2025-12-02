import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

import 'sequential_state.dart';
import 'sequential_test_bloc.dart';

void main() {
  group('SequentialTestBloc - Sequential Processing', () {
    late SequentialTestBloc bloc;

    setUp(() {
      bloc = SequentialTestBloc();
    });

    tearDown(() async {
      await bloc.close();
    });

    test('initial state has zero balance', () {
      expect(bloc.state.balance, 0.0);
      expect(bloc.state.lastTransaction, isNull);
      expect(bloc.state.error, isNull);
    });

    blocTest<SequentialTestBloc, SequentialState>(
      'event1 increases balance',
      build: SequentialTestBloc.new,
      act: (bloc) => bloc.event1(100),
      wait: const Duration(milliseconds: 150),
      expect: () => [
        predicate<SequentialState>((state) {
          return state.balance == 100.0 &&
              state.lastTransaction?.type == TransactionType.type1 &&
              state.lastTransaction?.amount == 100.0;
        }),
      ],
    );

    blocTest<SequentialTestBloc, SequentialState>(
      'event2 decreases balance',
      build: SequentialTestBloc.new,
      seed: () => const SequentialState(balance: 100),
      act: (bloc) => bloc.event2(30),
      wait: const Duration(milliseconds: 150),
      expect: () => [
        predicate<SequentialState>((state) {
          return state.balance == 70.0 &&
              state.lastTransaction?.type == TransactionType.type2 &&
              state.lastTransaction?.amount == 30.0;
        }),
      ],
    );

    blocTest<SequentialTestBloc, SequentialState>(
      'event2 with insufficient funds returns error',
      build: SequentialTestBloc.new,
      seed: () => const SequentialState(balance: 50),
      act: (bloc) => bloc.event2(100),
      wait: const Duration(milliseconds: 150),
      expect: () => [
        predicate<SequentialState>((state) {
          return state.balance == 50.0 &&
              state.error != null &&
              state.error!.contains('Insufficient funds');
        }),
      ],
    );

    blocTest<SequentialTestBloc, SequentialState>(
      'event3 reduces balance and records recipient',
      build: SequentialTestBloc.new,
      seed: () => const SequentialState(balance: 200),
      act: (bloc) => bloc.event3(75, 'Alice'),
      wait: const Duration(milliseconds: 200),
      expect: () => [
        predicate<SequentialState>((state) {
          return state.balance == 125.0 &&
              state.lastTransaction?.type == TransactionType.type3 &&
              state.lastTransaction?.amount == 75.0 &&
              state.lastTransaction?.recipient == 'Alice';
        }),
      ],
    );

    blocTest<SequentialTestBloc, SequentialState>(
      'event3 with insufficient funds returns error',
      build: SequentialTestBloc.new,
      seed: () => const SequentialState(balance: 30),
      act: (bloc) => bloc.event3(50, 'Bob'),
      wait: const Duration(milliseconds: 200),
      expect: () => [
        predicate<SequentialState>((state) {
          return state.balance == 30.0 &&
              state.error != null &&
              state.error!.contains('Insufficient funds');
        }),
      ],
    );

    blocTest<SequentialTestBloc, SequentialState>(
      'event4 sets balance to zero',
      build: SequentialTestBloc.new,
      seed: () => const SequentialState(balance: 500),
      act: (bloc) => bloc.event4(),
      expect: () => [const SequentialState(balance: 0)],
    );

    blocTest<SequentialTestBloc, SequentialState>(
      'event5 sets loading flag',
      build: SequentialTestBloc.new,
      seed: () => const SequentialState(balance: 100),
      act: (bloc) => bloc.event5(),
      wait: const Duration(milliseconds: 600),
      expect: () => [
        predicate<SequentialState>(
          (state) => state.isLoading && state.balance == 100.0,
        ),
        predicate<SequentialState>(
          (state) => !state.isLoading && state.balance == 100.0,
        ),
      ],
    );

    group('Sequential Processing - Race Condition Prevention', () {
      blocTest<SequentialTestBloc, SequentialState>(
        'multiple event1 are processed sequentially',
        build: SequentialTestBloc.new,
        act: (bloc) {
          bloc.event1(50);
          bloc.event1(30);
          bloc.event1(20);
        },
        wait: const Duration(milliseconds: 350),
        verify: (bloc) {
          expect(bloc.state.balance, 100.0);
        },
      );

      blocTest<SequentialTestBloc, SequentialState>(
        'mixed operations are processed sequentially',
        build: SequentialTestBloc.new,
        seed: () => const SequentialState(balance: 100),
        act: (bloc) {
          bloc.event1(50);
          bloc.event2(30);
          bloc.event1(20);
          bloc.event2(10);
        },
        wait: const Duration(milliseconds: 450),
        verify: (bloc) {
          expect(bloc.state.balance, 130.0);
        },
      );

      blocTest<SequentialTestBloc, SequentialState>(
        'event3 after event1 uses updated balance',
        build: SequentialTestBloc.new,
        act: (bloc) {
          bloc.event1(100);
          bloc.event3(50, 'Alice');
        },
        wait: const Duration(milliseconds: 300),
        verify: (bloc) {
          expect(bloc.state.balance, 50.0);
          expect(bloc.state.error, isNull);
        },
      );

      blocTest<SequentialTestBloc, SequentialState>(
        'event2 after event1 uses updated balance',
        build: SequentialTestBloc.new,
        seed: () => const SequentialState(balance: 20),
        act: (bloc) {
          bloc.event1(50);
          bloc.event2(60);
        },
        wait: const Duration(milliseconds: 250),
        verify: (bloc) {
          expect(bloc.state.balance, 10.0);
          expect(bloc.state.error, isNull);
        },
      );

      blocTest<SequentialTestBloc, SequentialState>(
        'rapid operations maintain consistency',
        build: SequentialTestBloc.new,
        seed: () => const SequentialState(balance: 1000),
        act: (bloc) {
          for (var i = 0; i < 5; i++) {
            bloc.event1(10);
            bloc.event2(5);
          }
        },
        wait: const Duration(milliseconds: 1100),
        verify: (bloc) {
          expect(bloc.state.balance, 1025.0);
        },
      );
    });

    group('Independent Operations', () {
      blocTest<SequentialTestBloc, SequentialState>(
        'event5 runs independently of sequential queue',
        build: SequentialTestBloc.new,
        seed: () => const SequentialState(balance: 100),
        act: (bloc) {
          bloc.event1(50);
          bloc.event5();
          bloc.event2(30);
        },
        wait: const Duration(milliseconds: 700),
        verify: (bloc) {
          expect(bloc.state.balance, 120.0);
          expect(bloc.state.isLoading, false);
        },
      );
    });
  });
}
