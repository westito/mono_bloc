import 'package:mono_bloc/mono_bloc.dart';
import 'package:test/test.dart';

import 'async_test_bloc.dart';
import 'item_model.dart';
import 'item_repository.dart';

void main() {
  group('AsyncTestBloc', () {
    late AsyncTestBloc bloc;
    late ItemRepository repository;

    setUp(() {
      repository = ItemRepository(networkDelayMs: 50);
      bloc = AsyncTestBloc(repository: repository);
    });

    tearDown(() async {
      await bloc.close();
    });

    test('initial state is empty data', () {
      expect(bloc.state.hasData, true);
      expect(bloc.state.dataOrNull, isEmpty);
      expect(bloc.state.isLoading, false);
    });

    test('event1 emits loading then data', () {
      expect(
        bloc.stream,
        emitsInOrder([
          predicate<MonoAsyncValue<List<Item>>>(
            (state) => state.isLoading && state.dataOrNull != null,
          ),
          predicate<MonoAsyncValue<List<Item>>>(
            (state) =>
                state.hasData && !state.isLoading && state.data.isNotEmpty,
          ),
        ]),
      );

      bloc.event1();
    });

    test('event3 with MonoAsyncEmitter', () async {
      bloc.event3('Test Item', priority: ItemPriority.high);

      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(bloc.state.hasData, true);
      final items = bloc.state.data;
      expect(items.isNotEmpty, true);
    });

    test('event5 returns filtered data synchronously', () {
      bloc.event5(ItemPriority.high);

      expect(bloc.state.hasData, true);
    });

    test('error handling wraps error in state', () async {
      final errorRepo = ItemRepository(
        networkDelayMs: 10,
        shouldThrowError: true,
      );
      final errorBloc = AsyncTestBloc(repository: errorRepo);

      errorBloc.event1();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(errorBloc.state.hasError, true);
      expect(errorBloc.state.error, isNotNull);
      expect(errorBloc.state.dataOrNull, isEmpty);

      await errorBloc.close();
    });

    test('Stream event with loading() helper', () {
      expect(
        bloc.stream,
        emitsInOrder([
          predicate<MonoAsyncValue<List<Item>>>((state) => state.isLoading),
          predicate<MonoAsyncValue<List<Item>>>(
            (state) => state.hasData && !state.isLoading,
          ),
        ]),
      );

      bloc.event2('test');
    });

    test('@onEvent skips events while loading', () async {
      final states = <MonoAsyncValue<List<Item>>>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.event2('test');

      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(states.isNotEmpty, true);
      expect(states.any((s) => s.isLoading), true);

      final statesBeforeSkip = states.length;
      bloc.event3('Should be skipped', priority: ItemPriority.high);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      final statesAfterSkip = states.length;

      final loadingStatesAfterSkip = states
          .skip(statesBeforeSkip)
          .where((s) => s.isLoading)
          .length;

      expect(loadingStatesAfterSkip, equals(0));

      await Future<void>.delayed(const Duration(milliseconds: 200));

      bloc.event3('Should work', priority: ItemPriority.high);

      await Future<void>.delayed(const Duration(milliseconds: 100));

      final finalStates = states.skip(statesAfterSkip).toList();
      expect(finalStates.any((s) => s.isLoading), true);

      await subscription.cancel();
    });

    test('@onEvent allows events when not loading', () async {
      final states = <MonoAsyncValue<List<Item>>>[];
      final subscription = bloc.stream.listen(states.add);

      expect(bloc.state.isLoading, false);

      bloc.event3('Test Item');

      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(states.any((s) => s.isLoading), true);
      expect(states.any((s) => s.hasData && !s.isLoading), true);

      await subscription.cancel();
    });

    test('@onEvent demonstrates race condition prevention', () async {
      final events = <String>[];
      final states = <MonoAsyncValue<List<Item>>>[];
      final subscription = bloc.stream.listen((state) {
        states.add(state);
        if (state.isLoading) {
          events.add('loading');
        } else if (state.hasData) {
          events.add('data(${state.data.length})');
        }
      });

      bloc.event2('test');
      events.add('dispatched: event2');

      await Future<void>.delayed(const Duration(milliseconds: 5));

      bloc.event3('Item 1', priority: ItemPriority.high);
      events.add('dispatched: event3-1 (should skip)');

      bloc.event3('Item 2', priority: ItemPriority.low);
      events.add('dispatched: event3-2 (should skip)');

      bloc.event4();
      events.add('dispatched: event4 (should skip)');

      await Future<void>.delayed(const Duration(milliseconds: 300));

      bloc.event3('Item 3');
      events.add('dispatched: event3-3 (should work)');

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(events, contains('dispatched: event2'));
      expect(events, contains('dispatched: event3-1 (should skip)'));
      expect(events, contains('dispatched: event3-2 (should skip)'));
      expect(events, contains('dispatched: event4 (should skip)'));
      expect(events, contains('dispatched: event3-3 (should work)'));

      final loadingCount = states.where((s) => s.isLoading).length;

      expect(loadingCount, lessThanOrEqualTo(2));

      await subscription.cancel();
    });
  });
}
