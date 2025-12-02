import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

import 'queue_state.dart';
import 'queue_test_bloc.dart';

void main() {
  group('QueueTestBloc', () {
    late QueueTestBloc bloc;

    setUp(() {
      bloc = QueueTestBloc();
    });

    tearDown(() async {
      await bloc.close();
    });

    test('initial state is idle with empty items', () {
      expect(bloc.state, isA<IdleState>());
      final state = bloc.state as IdleState;
      expect(state.items, isEmpty);
    });

    group('Sequential Queue', () {
      blocTest<QueueTestBloc, QueueState>(
        'event1 processes one item at a time',
        build: () => bloc,
        act: (bloc) => bloc.event1('item1'),
        expect: () => [
          isA<ProcessingState>(),
          isA<ProcessingState>(),
          isA<ProcessingState>(),
          isA<ProcessingState>(),
          isA<ProcessingState>(),
          isA<ProcessingState>(),
          isA<ProcessingState>(),
          isA<ProcessingState>(),
          isA<ProcessingState>(),
          isA<ProcessingState>(),
          isA<ProcessingState>(),
          isA<ProcessingState>(),
          isA<IdleState>(),
        ],
        wait: const Duration(seconds: 2),
        verify: (bloc) {
          final state = bloc.state as IdleState;
          expect(state.items.length, equals(1));
          expect(state.items.first, equals('item1'));
        },
      );

      blocTest<QueueTestBloc, QueueState>(
        'multiple events process sequentially',
        build: () => bloc,
        act: (bloc) {
          bloc.event2('item1');
          bloc.event2('item2');
        },
        skip: 1,
        expect: () => [
          isA<IdleState>(),
          isA<ProcessingState>(),
          isA<IdleState>(),
        ],
        wait: const Duration(seconds: 2),
        verify: (bloc) {
          final state = bloc.state as IdleState;
          expect(state.items.length, equals(2));
          expect(state.items[0], equals('item1'));
          expect(state.items[1], equals('item2'));
        },
      );
    });

    group('Droppable Queue', () {
      blocTest<QueueTestBloc, QueueState>(
        'event3 completes and ignores subsequent calls',
        build: () => bloc,
        act: (bloc) {
          bloc.event3();
          bloc.event3();
          bloc.event3();
        },
        wait: const Duration(milliseconds: 2500),
        verify: (bloc) {
          expect(bloc.state, isA<IdleState>());
        },
      );
    });

    group('Restartable Queue', () {
      blocTest<QueueTestBloc, QueueState>(
        'event5 restarts on new query',
        build: () => bloc,
        seed: () => const IdleState(items: ['apple', 'banana', 'apricot']),
        act: (bloc) {
          bloc.event5('ban');
          bloc.event5('ap');
        },
        wait: const Duration(milliseconds: 800),
        verify: (bloc) {
          expect(bloc.state, isA<SearchingState>());
          final state = bloc.state as SearchingState;
          expect(state.query, equals('ap'));
          expect(state.results.length, equals(2));
        },
      );

      blocTest<QueueTestBloc, QueueState>(
        'event6 sorts items',
        build: () => bloc,
        seed: () => const IdleState(items: ['zebra', 'apple', 'mango']),
        act: (bloc) => bloc.event6(),
        wait: const Duration(milliseconds: 300),
        verify: (bloc) {
          final state = bloc.state as IdleState;
          expect(state.items, equals(['apple', 'mango', 'zebra']));
        },
      );
    });

    group('Concurrent Queue', () {
      blocTest<QueueTestBloc, QueueState>(
        'event7 allows concurrent execution',
        build: () => bloc,
        act: (bloc) {
          bloc.event7('concurrent1');
          bloc.event7('concurrent2');
        },
        skip: 2,
        expect: () => [isA<IdleState>(), isA<IdleState>()],
        wait: const Duration(milliseconds: 800),
        verify: (bloc) {
          expect(bloc.state, isA<IdleState>());
        },
      );
    });

    group('Utility Events', () {
      test('event8 clears search', () async {
        bloc.event5('test');
        await Future<void>.delayed(const Duration(milliseconds: 400));

        bloc.event8();
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(bloc.state, isA<IdleState>());
      });

      test('event9 adds item', () async {
        bloc.event9('new_item');
        await Future<void>.delayed(const Duration(milliseconds: 100));

        final state = bloc.state as IdleState;
        expect(state.items, contains('new_item'));
      });

      test('event10 clears all items', () async {
        bloc.event9('item1');
        await Future<void>.delayed(const Duration(milliseconds: 50));

        bloc.event10();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final state = bloc.state as IdleState;
        expect(state.items, isEmpty);
      });
    });
  });
}
