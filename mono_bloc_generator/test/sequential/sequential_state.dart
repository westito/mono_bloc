enum TransactionType { type1, type2, type3 }

class Transaction {
  const Transaction({
    required this.type,
    required this.amount,
    required this.timestamp,
    this.recipient,
  });

  final TransactionType type;
  final double amount;
  final DateTime timestamp;
  final String? recipient;
}

class SequentialState {
  const SequentialState({
    required this.balance,
    this.lastTransaction,
    this.error,
    this.isLoading = false,
  });

  final double balance;
  final Transaction? lastTransaction;
  final String? error;
  final bool isLoading;

  SequentialState copyWith({
    double? balance,
    Transaction? lastTransaction,
    String? error,
    bool? isLoading,
  }) {
    return SequentialState(
      balance: balance ?? this.balance,
      lastTransaction: lastTransaction ?? this.lastTransaction,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
