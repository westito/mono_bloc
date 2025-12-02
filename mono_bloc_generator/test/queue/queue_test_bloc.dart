import 'package:mono_bloc/mono_bloc.dart';

import 'queue_state.dart';

part 'queue_test_bloc.g.dart';

const queue1 = 'queue1';
const queue2 = 'queue2';
const queue3 = 'queue3';
const queue4 = 'queue4';

@MonoBloc()
class QueueTestBloc extends _$QueueTestBloc<QueueState> {
  static final _queuesConfig = <String, EventTransformer<dynamic>>{
    queue1: MonoEventTransformer.sequential,
    queue2: MonoEventTransformer.droppable,
    queue3: MonoEventTransformer.restartable,
    queue4: MonoEventTransformer.concurrent,
  };

  QueueTestBloc() : super(const IdleState(), queues: _queuesConfig);

  List<String> get _currentItems {
    if (state is IdleState) {
      return (state as IdleState).items;
    } else if (state is ProcessingState) {
      return (state as ProcessingState).items;
    }
    return [];
  }

  @MonoEvent.queue(queue1)
  Future<QueueState> _onEvent1(_Emitter emit, String item) async {
    final currentItems = _currentItems;
    emit(ProcessingState(item: item, queue: queue1, items: currentItems));

    for (var i = 0; i <= 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      emit(
        ProcessingState(item: '$item-$i', queue: queue1, items: currentItems),
      );
    }

    final updatedItems = [...currentItems, item];
    return IdleState(items: updatedItems);
  }

  @MonoEvent.queue(queue1)
  Future<QueueState> _onEvent2(_Emitter emit, String item) async {
    final currentItems = _currentItems;
    emit(ProcessingState(item: item, queue: queue1, items: currentItems));

    await Future<void>.delayed(const Duration(milliseconds: 500));

    final updatedItems = [...currentItems, item];
    return IdleState(items: updatedItems);
  }

  @MonoEvent.queue(queue2)
  Future<QueueState> _onEvent3(_Emitter emit) async {
    final currentItems = _currentItems;
    emit(
      ProcessingState(item: 'refreshing', queue: queue2, items: currentItems),
    );

    await Future<void>.delayed(const Duration(seconds: 2));

    return IdleState(items: currentItems);
  }

  @MonoEvent.queue(queue2)
  Future<QueueState> _onEvent4(_Emitter emit) async {
    final currentItems = _currentItems;
    emit(ProcessingState(item: 'syncing', queue: queue2, items: currentItems));

    await Future<void>.delayed(const Duration(milliseconds: 1500));

    final syncedItems = [...currentItems, 'synced_item'];
    return IdleState(items: syncedItems);
  }

  @MonoEvent.queue(queue3)
  Future<QueueState> _onEvent5(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (query.isEmpty) {
      return IdleState(items: _currentItems);
    }

    final results = _currentItems
        .where((f) => f.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return SearchingState(query: query, results: results);
  }

  @MonoEvent.queue(queue3)
  Future<QueueState> _onEvent6() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final sortedItems = [..._currentItems]..sort();

    return IdleState(items: sortedItems);
  }

  @MonoEvent.queue(queue4)
  Future<QueueState> _onEvent7(_Emitter emit, String item) async {
    final currentItems = _currentItems;
    emit(ProcessingState(item: item, queue: queue4, items: currentItems));

    await Future<void>.delayed(const Duration(milliseconds: 500));

    return IdleState(items: currentItems);
  }

  @event
  QueueState _onEvent8() {
    return IdleState(items: _currentItems);
  }

  @event
  QueueState _onEvent9(String item) {
    return IdleState(items: [..._currentItems, item]);
  }

  @event
  QueueState _onEvent10() {
    return const IdleState();
  }
}
