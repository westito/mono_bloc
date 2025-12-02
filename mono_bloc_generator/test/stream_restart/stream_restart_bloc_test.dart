import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

import 'stream_repository.dart';
import 'stream_restart_bloc.dart';
import 'stream_restart_state.dart';

void main() {
  group('StreamRestartBloc', () {
    late StreamRestartBloc bloc;
    late StreamRepository repository;

    setUp(() {
      repository = StreamRepository();
      bloc = StreamRestartBloc(repository);
    });

    tearDown(() async {
      await bloc.close();
    });

    test('initial state has empty items list', () {
      expect(bloc.state.items, isEmpty);
    });

    blocTest<StreamRestartBloc, StreamRestartState>(
      'restartable event restarts stream when new event is dispatched',
      build: () => bloc,
      act: (bloc) async {
        bloc.fetchItems('first');
        await Future<void>.delayed(const Duration(milliseconds: 2500));
        bloc.fetchItems('second');
      },
      expect: () => [
        isA<StreamRestartState>().having((s) => s.items, 'items', ['first-0']),
        isA<StreamRestartState>().having((s) => s.items, 'items', [
          'first-0',
          'first-1',
        ]),
        isA<StreamRestartState>().having((s) => s.items, 'items', [
          'first-0',
          'first-1',
          'second-0',
        ]),
        isA<StreamRestartState>().having((s) => s.items, 'items', [
          'first-0',
          'first-1',
          'second-0',
          'second-1',
        ]),
        isA<StreamRestartState>().having(
          (s) => s.items.length,
          'items length',
          greaterThanOrEqualTo(5),
        ),
        isA<StreamRestartState>().having(
          (s) => s.items.length,
          'items length',
          greaterThanOrEqualTo(5),
        ),
      ],
      wait: const Duration(seconds: 5),
      verify: (bloc) {
        expect(bloc.state.items.length, greaterThanOrEqualTo(4));
        expect(
          bloc.state.items.where((item) => item.startsWith('first-')).length,
          equals(2),
        );
        expect(
          bloc.state.items
              .where((item) => item.startsWith('second-'))
              .isNotEmpty,
          isTrue,
        );
        final firstItems = bloc.state.items.take(2).toList();
        expect(firstItems, ['first-0', 'first-1']);
        final hasSecondItems = bloc.state.items.any(
          (item) => item.startsWith('second-'),
        );
        expect(hasSecondItems, isTrue);
      },
    );

    blocTest<StreamRestartBloc, StreamRestartState>(
      'stream emits items continuously',
      build: () => bloc,
      act: (bloc) => bloc.fetchItems('test'),
      expect: () => [
        isA<StreamRestartState>().having((s) => s.items, 'items', ['test-0']),
        isA<StreamRestartState>().having((s) => s.items, 'items', [
          'test-0',
          'test-1',
        ]),
        isA<StreamRestartState>().having((s) => s.items, 'items', [
          'test-0',
          'test-1',
          'test-2',
        ]),
      ],
      wait: const Duration(milliseconds: 3500),
      verify: (bloc) {
        expect(bloc.state.items.length, greaterThanOrEqualTo(3));
        expect(
          bloc.state.items.every((item) => item.startsWith('test-')),
          isTrue,
        );
      },
    );

    blocTest<StreamRestartBloc, StreamRestartState>(
      'multiple rapid restarts only process the last one',
      build: () => bloc,
      act: (bloc) async {
        bloc.fetchItems('first');
        await Future<void>.delayed(const Duration(milliseconds: 500));
        bloc.fetchItems('second');
        await Future<void>.delayed(const Duration(milliseconds: 100));
        bloc.fetchItems('third');
      },
      wait: const Duration(milliseconds: 3500),
      verify: (bloc) {
        expect(
          bloc.state.items
              .where((item) => item.startsWith('third-'))
              .isNotEmpty,
          isTrue,
        );
        final thirdItems = bloc.state.items
            .where((item) => item.startsWith('third-'))
            .length;
        expect(thirdItems, greaterThanOrEqualTo(2));
      },
    );
  });
}
