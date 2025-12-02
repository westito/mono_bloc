/// Types of bank account transactions
enum TransactionType { deposit, withdrawal, transfer }

/// Represents a single bank transaction with metadata
class Transaction {
  const Transaction({
    required this.type,
    required this.amount,
    required this.timestamp,
    this.recipient,
  });

  /// Type of transaction (deposit, withdrawal, transfer)
  final TransactionType type;

  /// Transaction amount in currency units
  final double amount;

  /// When the transaction occurred
  final DateTime timestamp;

  /// Recipient account (for transfers only)
  final String? recipient;

  /// Human-readable transaction description
  String get description {
    switch (type) {
      case TransactionType.deposit:
        return 'Deposited \$${amount.toStringAsFixed(2)}';
      case TransactionType.withdrawal:
        return 'Withdrew \$${amount.toStringAsFixed(2)}';
      case TransactionType.transfer:
        return 'Transferred \$${amount.toStringAsFixed(2)} to $recipient';
    }
  }
}

/// State for bank account operations demonstrating sequential processing
/// Used with @MonoBloc(sequential: true) to prevent race conditions
class BankAccountState {
  const BankAccountState({
    required this.balance,
    this.lastTransaction,
    this.error,
    this.isLoading = false,
  });

  /// Current account balance
  final double balance;

  /// Most recent transaction for display
  final Transaction? lastTransaction;

  /// Error message from failed operations
  final String? error;

  /// Loading state for async operations
  final bool isLoading;

  BankAccountState copyWith({
    double? balance,
    Transaction? lastTransaction,
    String? error,
    bool? isLoading,
  }) {
    return BankAccountState(
      balance: balance ?? this.balance,
      lastTransaction: lastTransaction ?? this.lastTransaction,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
