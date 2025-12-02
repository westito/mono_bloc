import 'package:mono_bloc/mono_bloc.dart';

import 'item_model.dart';
import 'item_repository.dart';

part 'async_test_bloc.g.dart';

@AsyncMonoBloc()
class AsyncTestBloc extends _$AsyncTestBloc<List<Item>> {
  AsyncTestBloc({ItemRepository? repository})
    : _repository = repository ?? ItemRepository(),
      super(const MonoAsyncValue.withData([]));

  final ItemRepository _repository;

  @event
  Future<List<Item>> _onEvent1() async {
    final response = await _repository.fetchAllItems();
    return response.items;
  }

  @restartableEvent
  Stream<_State> _onEvent2(String query) async* {
    if (query.isEmpty) {
      final response = await _repository.fetchAllItems();
      yield withData(response.items);
      return;
    }

    yield loading();

    final allItems = <Item>[];
    for (final source in ItemSource.values) {
      final items = await _repository.searchInSource(source, query);
      allItems.addAll(items);

      yield withData(allItems);
    }
  }

  @event
  Future<void> _onEvent3(
    _Emitter emit,
    String title, {
    String? description,
    ItemPriority priority = ItemPriority.medium,
  }) async {
    emit.loading();

    final item = Item(
      id: '',
      title: title,
      description: description,
      priority: priority,
    );

    await _repository.addItem(ItemSource.source1, item);

    final response = await _repository.fetchAllItems();
    emit(response.items);
  }

  @event
  Future<void> _onEvent4(_Emitter emit) async {
    emit.loadingClearData();

    await Future<void>.delayed(const Duration(seconds: 1));

    final response = await _repository.fetchAllItems();
    emit(response.items);
  }

  @event
  List<Item> _onEvent5(ItemPriority priority) {
    final currentData = state.dataOrNull ?? [];
    return currentData.where((t) => t.priority == priority).toList();
  }

  @event
  void _onEvent6(_Emitter emit) {
    final currentData = state.dataOrNull ?? [];
    emit(currentData);
  }

  @onEvent
  bool _onEvents(_Event event) {
    if (state.isLoading) {
      return false;
    }
    return true;
  }
}
