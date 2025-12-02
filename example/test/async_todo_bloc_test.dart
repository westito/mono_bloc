import 'package:flutter_test/flutter_test.dart';
import 'package:mono_bloc_example/async/async_todo_bloc.dart';
import 'package:mono_bloc_example/todo/todo_model.dart';
import 'package:mono_bloc_example/todo/todo_repository.dart';
import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';

void main() {
  group('AsyncTodoBloc Manual Test', () {
    late AsyncTodoBloc bloc;
    late TodoRepository repository;

    setUp(() {
      repository = TodoRepository(networkDelayMs: 50);
      bloc = AsyncTodoBloc(repository: repository);
    });

    tearDown(() async {
      await bloc.close();
    });

    test('initial state is empty data', () {
      expect(bloc.state.hasData, true);
      expect(bloc.state.dataOrNull, isEmpty);
      expect(bloc.state.isLoading, false);
    });

    test('loadAllTodos emits loading then data', () {
      // Expect: initial, loading, data
      expect(
        bloc.stream,
        emitsInOrder([
          predicate<MonoAsyncValue<List<Todo>>>(
            (state) => state.isLoading && state.dataOrNull != null,
          ),
          predicate<MonoAsyncValue<List<Todo>>>(
            (state) =>
                state.hasData && !state.isLoading && state.data.isNotEmpty,
          ),
        ]),
      );

      bloc.loadAllTodos();
    });

    test('addTodo with MonoAsyncEmitter', () async {
      bloc.addTodo('Test Todo', priority: TodoPriority.high);

      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(bloc.state.hasData, true);
      final todos = bloc.state.data;
      // The repository adds the todo, so check if any todos exist
      expect(todos.isNotEmpty, true, reason: 'Expected todos to be added');
    });

    test('filterByPriority returns filtered data synchronously', () {
      bloc.filterByPriority(TodoPriority.high);

      // Should emit immediately (sync)
      expect(bloc.state.hasData, true);
    });

    test('error handling wraps error in state', () async {
      final errorRepo = TodoRepository(
        networkDelayMs: 10,
        shouldThrowError: true,
      );
      final errorBloc = AsyncTodoBloc(repository: errorRepo);

      errorBloc.loadAllTodos();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(errorBloc.state.hasError, true);
      expect(errorBloc.state.error, isNotNull);
      // Error handler should preserve empty list
      expect(errorBloc.state.dataOrNull, isEmpty);

      await errorBloc.close();
    });

    test('Stream event with loading() helper', () {
      expect(
        bloc.stream,
        emitsInOrder([
          predicate<MonoAsyncValue<List<Todo>>>(
            (state) => state.isLoading,
          ), // loading state
          predicate<MonoAsyncValue<List<Todo>>>(
            (state) => state.hasData && !state.isLoading,
          ), // data states
        ]),
      );

      bloc.searchTodos('test');
    });

    test('@onEvent skips events while loading', () async {
      final states = <MonoAsyncValue<List<Todo>>>[];
      final subscription = bloc.stream.listen(states.add);

      // Start a search operation that will emit loading state
      bloc.searchTodos('test');

      // Wait for loading state to be emitted
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Verify we're in loading state
      expect(
        states.isNotEmpty,
        true,
        reason: 'Should have emitted loading state',
      );
      expect(
        states.any((s) => s.isLoading),
        true,
        reason: 'Should be in loading state',
      );

      // Try to add a todo while loading - this should be skipped by onEvent
      final statesBeforeSkip = states.length;
      bloc.addTodo('Should be skipped', priority: TodoPriority.high);

      // Wait a bit to see if the addTodo event gets processed
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // The addTodo event should have been skipped, so we should only have
      // states from the search operation (loading + data updates)
      // If addTodo was processed, we'd see additional loading/data states
      final statesAfterSkip = states.length;

      // We might have gotten some search data updates, but no addTodo states
      // The key is that addTodo shouldn't cause any new loading state
      final loadingStatesAfterSkip = states
          .skip(statesBeforeSkip)
          .where((s) => s.isLoading)
          .length;

      expect(
        loadingStatesAfterSkip,
        equals(0),
        reason: 'addTodo should have been skipped, no new loading states',
      );

      // Wait for search to complete
      await Future<void>.delayed(const Duration(milliseconds: 200));

      // After search completes, try adding again - this should work
      bloc.addTodo('Should work', priority: TodoPriority.high);

      await Future<void>.delayed(const Duration(milliseconds: 100));

      // This time we should see the loading state from addTodo
      final finalStates = states.skip(statesAfterSkip).toList();
      expect(
        finalStates.any((s) => s.isLoading),
        true,
        reason: 'addTodo should work after search completes',
      );

      await subscription.cancel();
    });

    test('@onEvent allows events when not loading', () async {
      final states = <MonoAsyncValue<List<Todo>>>[];
      final subscription = bloc.stream.listen(states.add);

      // Ensure we're not in loading state
      expect(bloc.state.isLoading, false);

      // Add a todo - this should work because we're not loading
      bloc.addTodo('Test Todo');

      await Future<void>.delayed(const Duration(milliseconds: 200));

      // Should have emitted loading and data states
      expect(
        states.any((s) => s.isLoading),
        true,
        reason: 'Should emit loading state',
      );
      expect(
        states.any((s) => s.hasData && !s.isLoading),
        true,
        reason: 'Should emit data state after loading',
      );

      await subscription.cancel();
    });

    test('@onEvent demonstrates race condition prevention', () async {
      final events = <String>[];
      final states = <MonoAsyncValue<List<Todo>>>[];
      final subscription = bloc.stream.listen((state) {
        states.add(state);
        if (state.isLoading) {
          events.add('loading');
        } else if (state.hasData) {
          events.add('data(${state.data.length})');
        }
      });

      // Rapidly fire multiple operations
      bloc.searchTodos('test'); // This will start loading
      events.add('dispatched: search');

      await Future<void>.delayed(const Duration(milliseconds: 5));

      // These should be skipped because search is loading
      bloc.addTodo('Todo 1', priority: TodoPriority.high);
      events.add('dispatched: addTodo1 (should skip)');

      bloc.addTodo('Todo 2', priority: TodoPriority.low);
      events.add('dispatched: addTodo2 (should skip)');

      bloc.refreshTodos();
      events.add('dispatched: refresh (should skip)');

      // Wait for search to complete
      await Future<void>.delayed(const Duration(milliseconds: 300));

      // Now dispatch should work
      bloc.addTodo('Todo 3');
      events.add('dispatched: addTodo3 (should work)');

      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Verify event flow
      expect(events, contains('dispatched: search'));
      expect(events, contains('dispatched: addTodo1 (should skip)'));
      expect(events, contains('dispatched: addTodo2 (should skip)'));
      expect(events, contains('dispatched: refresh (should skip)'));
      expect(events, contains('dispatched: addTodo3 (should work)'));

      // Should only have loading states from search and the final addTodo3
      // The skipped events won't produce loading states
      final loadingCount = states.where((s) => s.isLoading).length;

      // We expect loading from search and from addTodo3 (if it completes in time)
      // The skipped events should NOT produce loading states
      expect(
        loadingCount,
        lessThanOrEqualTo(2),
        reason: 'Should only have loading states from search and addTodo3',
      );

      await subscription.cancel();
    });
  });
}
