import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mono_bloc_example/event_catch/event_catch_bloc.dart';

void main() {
  group('EventCatchBloc @onEvent Tests', () {
    late EventCatchBloc bloc;

    setUp(() {
      bloc = EventCatchBloc();
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
      blocTest<EventCatchBloc, EventCatchState>(
        'allows updateMessage when NOT loading',
        build: EventCatchBloc.new,
        act: (bloc) => bloc.updateMessage('Test message'),
        expect: () => [
          isA<EventCatchState>()
              .having((s) => s.message, 'message', 'Test message')
              .having((s) => s.isLoading, 'isLoading', false),
        ],
      );

      blocTest<EventCatchBloc, EventCatchState>(
        'blocks updateMessage while loading',
        build: EventCatchBloc.new,
        act: (bloc) async {
          bloc.startLoading();
          await Future<void>.delayed(const Duration(milliseconds: 100));
          // Try to update message while loading - should be blocked
          bloc.updateMessage('This should be blocked');
          await Future<void>.delayed(const Duration(milliseconds: 100));
        },
        expect: () => [
          // First emission: loading starts
          isA<EventCatchState>()
              .having((s) => s.isLoading, 'isLoading', true)
              .having((s) => s.message, 'message', 'Loading...'),
          // No emission from updateMessage because it was blocked
          // Final emission: loading completes
          isA<EventCatchState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.message, 'message', 'Loading completed!'),
        ],
      );

      blocTest<EventCatchBloc, EventCatchState>(
        'allows forceUpdate even while loading',
        build: EventCatchBloc.new,
        act: (bloc) async {
          bloc.startLoading();
          await Future<void>.delayed(const Duration(milliseconds: 100));
          // Force update should work even while loading
          bloc.forceUpdate('Force works!');
          await Future<void>.delayed(const Duration(milliseconds: 100));
        },
        expect: () => [
          // Loading starts
          isA<EventCatchState>()
              .having((s) => s.isLoading, 'isLoading', true)
              .having((s) => s.message, 'message', 'Loading...'),
          // Force update succeeds (not blocked)
          isA<EventCatchState>()
              .having((s) => s.isLoading, 'isLoading', true)
              .having((s) => s.message, 'message', '[FORCED] Force works!'),
          // Loading completes
          isA<EventCatchState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.message, 'message', 'Loading completed!'),
        ],
      );
    });

    group('Event Methods', () {
      test('startLoading changes isLoading to true then false', () async {
        expect(bloc.state.isLoading, false);

        bloc.startLoading();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        expect(bloc.state.isLoading, true);

        await Future<void>.delayed(const Duration(seconds: 3));
        expect(bloc.state.isLoading, false);
        expect(bloc.state.message, 'Loading completed!');
      });

      test('reset returns to initial state', () async {
        bloc.updateMessage('Changed');
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.message, 'Changed');

        bloc.reset();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.message, 'Ready');
        expect(bloc.state.isLoading, false);
      });
    });

    group('@onEvent Demonstration', () {
      test('demonstrates conditional filtering based on state', () async {
        // When not loading, updateMessage works
        bloc.updateMessage('Message 1');
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.message, 'Message 1');

        // Start loading
        bloc.startLoading();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        expect(bloc.state.isLoading, true);

        // Now updateMessage should be blocked
        bloc.updateMessage('This is blocked');
        await Future<void>.delayed(const Duration(milliseconds: 100));
        // Message should NOT change
        expect(bloc.state.message, 'Loading...');

        // But forceUpdate should still work
        bloc.forceUpdate('But this works!');
        await Future<void>.delayed(const Duration(milliseconds: 100));
        expect(bloc.state.message, '[FORCED] But this works!');
      });
    });
  });
}
