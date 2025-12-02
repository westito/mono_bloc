import 'package:mono_bloc_example/bank/bank_account_state.dart';
import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';

part 'bank_account_bloc.g.dart';

/// BankAccountBloc demonstrates sequential processing using @MonoBloc(sequential: true)
/// All simple events (@event annotation) are processed sequentially in order
/// to prevent race conditions in critical operations like deposits and withdrawals.
/// Events with explicit concurrency (@restartableEvent) bypass the sequential queue.
@MonoBloc(sequential: true)
class BankAccountBloc extends _$BankAccountBloc<BankAccountState> {
  BankAccountBloc() : super(const BankAccountState(balance: 0));

  @event
  Future<BankAccountState> _deposit(double amount) async {
    // Simulate async operation (e.g., API call)
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final newBalance = state.balance + amount;

    return BankAccountState(
      balance: newBalance,
      lastTransaction: Transaction(
        type: TransactionType.deposit,
        amount: amount,
        timestamp: DateTime.now(),
      ),
    );
  }

  @event
  Future<BankAccountState> _onWithdraw(double amount) async {
    // Simulate async operation
    await Future<void>.delayed(const Duration(milliseconds: 100));

    if (amount > state.balance) {
      return state.copyWith(
        error:
            'Insufficient funds. Balance: \$${state.balance.toStringAsFixed(2)}',
      );
    }

    final newBalance = state.balance - amount;

    return BankAccountState(
      balance: newBalance,
      lastTransaction: Transaction(
        type: TransactionType.withdrawal,
        amount: amount,
        timestamp: DateTime.now(),
      ),
    );
  }

  @event
  Future<BankAccountState> _onTransfer(double amount, String recipient) async {
    // Simulate async operation
    await Future<void>.delayed(const Duration(milliseconds: 150));

    if (amount > state.balance) {
      return state.copyWith(
        error:
            'Insufficient funds for transfer. Balance: \$${state.balance.toStringAsFixed(2)}',
      );
    }

    final newBalance = state.balance - amount;

    return BankAccountState(
      balance: newBalance,
      lastTransaction: Transaction(
        type: TransactionType.transfer,
        amount: amount,
        timestamp: DateTime.now(),
        recipient: recipient,
      ),
    );
  }

  @event
  BankAccountState _onReset() {
    return const BankAccountState(balance: 0);
  }

  // This event has an explicit transformer, so it runs independently
  // and doesn't wait in the sequential queue
  @restartableEvent
  Stream<BankAccountState> _onCheckBalance() async* {
    yield state.copyWith(isLoading: true);

    // Simulate checking balance from server
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Return current state with loading flag off
    yield state.copyWith(isLoading: false);
  }
}
