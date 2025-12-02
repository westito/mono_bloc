import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

import 'event_catch_test_bloc.dart';

void main() {
  group('EventCatchTestBloc @onEvent Tests', () {
    late EventCatchTestBloc bloc;

    setUp(() {
      bloc = EventCatchTestBloc();
    });

    tearDown(() async {
      await bloc.close();
    });

    test('initial state is correct', () {
      expect(bloc.state.isLoading, false);
      expect(bloc.state.message, 'Ready');
      expect(bloc.state.eventLog, isEmpty);
    });

    group('@onEvent - Event Filtering', () {
      blocTest<EventCatchTestBloc, EventCatchTestState>(
        'allows event2 when NOT loading',
        build: EventCatchTestBloc.new,
        act: (bloc) => bloc.event2('Test message'),
        expect: () => [
          isA<EventCatchTestState>()
              .having((s) => s.message, 'message', 'Test message')
              .having((s) => s.isLoading, 'isLoading', false),
        ],
      );

      blocTest<EventCatchTestBloc, EventCatchTestState>(
        'blocks event2 while loading',
        build: EventCatchTestBloc.new,
        act: (bloc) async {
          bloc.event1();
          await Future<void>.delayed(const Duration(milliseconds: 100));
          bloc.event2('This should be blocked');
          await Future<void>.delayed(const Duration(milliseconds: 100));
        },
        expect: () => [
          isA<EventCatchTestState>()
              .having((s) => s.isLoading, 'isLoading', true)
              .having((s) => s.message, 'message', 'Loading...'),
          isA<EventCatchTestState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.message, 'message', 'Loading completed!'),
        ],
      );

      blocTest<EventCatchTestBloc, EventCatchTestState>(
        'allows event3 even while loading',
        build: EventCatchTestBloc.new,
        act: (bloc) async {
          bloc.event1();
          await Future<void>.delayed(const Duration(milliseconds: 100));
          bloc.event3('Force works!');
          await Future<void>.delayed(const Duration(milliseconds: 100));
        },
        expect: () => [
          isA<EventCatchTestState>()
              .having((s) => s.isLoading, 'isLoading', true)
              .having((s) => s.message, 'message', 'Loading...'),
          isA<EventCatchTestState>()
              .having((s) => s.isLoading, 'isLoading', true)
              .having((s) => s.message, 'message', '[FORCED] Force works!'),
          isA<EventCatchTestState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.message, 'message', 'Loading completed!'),
        ],
      );
    });

    group('Event Methods', () {
      test('event1 changes isLoading to true then false', () async {
        expect(bloc.state.isLoading, false);

        bloc.event1();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        expect(bloc.state.isLoading, true);

        await Future<void>.delayed(const Duration(seconds: 3));
        expect(bloc.state.isLoading, false);
        expect(bloc.state.message, 'Loading completed!');
      });

      test('event4 returns to initial state', () async {
        bloc.event2('Changed');
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.message, 'Changed');

        bloc.event4();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.message, 'Ready');
        expect(bloc.state.isLoading, false);
      });
    });

    group('@onEvent Demonstration', () {
      test('demonstrates conditional filtering based on state', () async {
        bloc.event2('Message 1');
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.message, 'Message 1');

        bloc.event1();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        expect(bloc.state.isLoading, true);

        bloc.event2('This is blocked');
        await Future<void>.delayed(const Duration(milliseconds: 100));
        expect(bloc.state.message, 'Loading...');

        bloc.event3('But this works!');
        await Future<void>.delayed(const Duration(milliseconds: 100));
        expect(bloc.state.message, '[FORCED] But this works!');
      });
    });
  });
}
