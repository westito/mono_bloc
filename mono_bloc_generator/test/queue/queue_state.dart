sealed class QueueState {
  const QueueState();
}

class IdleState extends QueueState {
  const IdleState({this.items = const []});
  final List<String> items;
}

class ProcessingState extends QueueState {
  const ProcessingState({
    required this.item,
    required this.queue,
    this.items = const [],
  });
  final String item;
  final String queue;
  final List<String> items;
}

class SearchingState extends QueueState {
  const SearchingState({required this.query, required this.results});
  final String query;
  final List<String> results;
}
