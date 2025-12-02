import 'package:mono_bloc/mono_bloc.dart';

import 'sequential_state.dart';

part 'sequential_test_bloc.g.dart';

@MonoBloc(sequential: true)
class SequentialTestBloc extends _$SequentialTestBloc<SequentialState> {
  SequentialTestBloc() : super(const SequentialState(balance: 0));

  @event
  Future<SequentialState> _onEvent1(double amount) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final newBalance = state.balance + amount;

    return SequentialState(
      balance: newBalance,
      lastTransaction: Transaction(
        type: TransactionType.type1,
        amount: amount,
        timestamp: DateTime.now(),
      ),
    );
  }

  @event
  Future<SequentialState> _onEvent2(double amount) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    if (amount > state.balance) {
      return state.copyWith(
        error:
            'Insufficient funds. Balance: \$${state.balance.toStringAsFixed(2)}',
      );
    }

    final newBalance = state.balance - amount;

    return SequentialState(
      balance: newBalance,
      lastTransaction: Transaction(
        type: TransactionType.type2,
        amount: amount,
        timestamp: DateTime.now(),
      ),
    );
  }

  @event
  Future<SequentialState> _onEvent3(double amount, String recipient) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));

    if (amount > state.balance) {
      return state.copyWith(
        error:
            'Insufficient funds for transfer. Balance: \$${state.balance.toStringAsFixed(2)}',
      );
    }

    final newBalance = state.balance - amount;

    return SequentialState(
      balance: newBalance,
      lastTransaction: Transaction(
        type: TransactionType.type3,
        amount: amount,
        timestamp: DateTime.now(),
        recipient: recipient,
      ),
    );
  }

  @event
  SequentialState _onEvent4() {
    return const SequentialState(balance: 0);
  }

  @restartableEvent
  Stream<SequentialState> _onEvent5() async* {
    yield state.copyWith(isLoading: true);

    await Future<void>.delayed(const Duration(milliseconds: 500));

    yield state.copyWith(isLoading: false);
  }
}
