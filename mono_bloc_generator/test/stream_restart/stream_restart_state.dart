class StreamRestartState {
  const StreamRestartState({required this.items});

  final List<String> items;

  StreamRestartState copyWith({List<String>? items}) {
    return StreamRestartState(items: items ?? this.items);
  }
}
