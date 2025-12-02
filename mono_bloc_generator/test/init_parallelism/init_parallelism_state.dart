/// State for tracking @onInit method execution order
class InitParallelismState {
  const InitParallelismState({this.executionOrder = const [], this.value = 0});

  /// Records the order in which @onInit methods completed
  final List<String> executionOrder;

  /// A simple value that can be modified
  final int value;

  InitParallelismState copyWith({List<String>? executionOrder, int? value}) {
    return InitParallelismState(
      executionOrder: executionOrder ?? this.executionOrder,
      value: value ?? this.value,
    );
  }

  @override
  String toString() =>
      'InitParallelismState(order: $executionOrder, value: $value)';
}
