import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

import 'actions_bloc.dart';

void main() {
  group('ActionsBloc', () {
    late ActionsBloc bloc;

    setUp(() {
      bloc = ActionsBloc();
    });

    tearDown(() async {
      await bloc.close();
    });

    test('initial state has zero count', () {
      expect(bloc.state.count, 0);
      expect(bloc.state.lastMessage, isNull);
      expect(bloc.state.lastLevel, isNull);
    });

    blocTest<ActionsBloc, ActionsState>(
      'event1 increments count',
      build: ActionsBloc.new,
      act: (bloc) => bloc.event1('Test message', Level.level1),
      expect: () => [
        const ActionsState(
          count: 1,
          lastMessage: 'Test message',
          lastLevel: Level.level1,
        ),
      ],
    );

    blocTest<ActionsBloc, ActionsState>(
      'event2 increments by batch size',
      build: ActionsBloc.new,
      act: (bloc) =>
          bloc.event2(['Message 1', 'Message 2', 'Message 3'], Level.level2),
      wait: const Duration(milliseconds: 150),
      expect: () => [
        const ActionsState(
          count: 3,
          lastMessage: 'Message 3',
          lastLevel: Level.level2,
        ),
      ],
    );

    blocTest<ActionsBloc, ActionsState>(
      'event3 resets state',
      build: ActionsBloc.new,
      seed: () => const ActionsState(
        count: 5,
        lastMessage: 'Previous message',
        lastLevel: Level.level3,
      ),
      act: (bloc) => bloc.event3(),
      expect: () => [const ActionsState()],
    );

    group('Actions', () {
      test('action1 emits to action stream', () async {
        final actions = <dynamic>[];

        bloc.actions.listen(actions.add);

        bloc.action1('Debug message', Level.level1);

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(actions.length, 1);
        expect(actions.first.runtimeType.toString(), '_Action1Action');
      });

      test('action2 emits with correct parameters', () async {
        final actions = <dynamic>[];

        bloc.actions.listen(actions.add);

        bloc.action2('param1', 'param2', 'param3');

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(actions.length, 1);
        final action = actions.first;
        expect(action.runtimeType.toString(), '_Action2Action');
      });

      test('action3 emits with parameters', () async {
        final actions = <dynamic>[];

        bloc.actions.listen(actions.add);

        bloc.action3('param1', 'param2');

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(actions.length, 1);
        expect(actions.first.runtimeType.toString(), '_Action3Action');
      });

      test('action4 emits with url and data', () async {
        final actions = <dynamic>[];

        bloc.actions.listen(actions.add);

        bloc.action4(
          url: 'https://example.com/webhook',
          data: {'key': 'value'},
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(actions.length, 1);
        expect(actions.first.runtimeType.toString(), '_Action4Action');
      });

      test('actions can be handled using when() pattern', () async {
        final handledActions = <String>[];

        final actionHandlers = ActionsBlocActions.when(
          action1: (message, level) {
            handledActions.add('Action1: $message [$level]');
          },
          action2: (param1, param2, param3) {
            handledActions.add('Action2: $param1');
          },
          action3: (param1, param2) {
            handledActions.add('Action3: $param1');
          },
          action4: ({required url, required data}) {
            handledActions.add('Action4: $url');
          },
        );

        bloc.actions.listen((action) => actionHandlers.actions(bloc, action));

        bloc.action1('Test log', Level.level1);
        bloc.action2('val1', 'val2', 'val3');
        bloc.action3('val1', 'val2');
        bloc.action4(url: 'https://example.com', data: {});

        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(handledActions.length, 4);
        expect(handledActions[0], 'Action1: Test log [Level.level1]');
        expect(handledActions[1], 'Action2: val1');
        expect(handledActions[2], 'Action3: val1');
        expect(handledActions[3], 'Action4: https://example.com');
      });

      test('multiple actions can be emitted in sequence', () async {
        final actionLog = <String>[];

        bloc.actions.listen((action) {
          actionLog.add(action.runtimeType.toString());
        });

        bloc.action1('Log 1', Level.level1);
        bloc.action2('val1', 'val2', 'val3');
        bloc.action1('Log 2', Level.level2);
        bloc.action3('val1', 'val2');

        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(actionLog, [
          '_Action1Action',
          '_Action2Action',
          '_Action1Action',
          '_Action3Action',
        ]);
      });
    });
  });
}
