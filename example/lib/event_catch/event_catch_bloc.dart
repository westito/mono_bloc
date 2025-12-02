import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';

part 'event_catch_bloc.g.dart';

/// State for demonstrating @onEvent filtering
class EventCatchState {
  final bool isLoading;
  final String message;
  final List<String> eventLog;

  const EventCatchState({
    this.isLoading = false,
    this.message = 'Ready',
    this.eventLog = const [],
  });

  EventCatchState copyWith({
    bool? isLoading,
    String? message,
    List<String>? eventLog,
  }) {
    return EventCatchState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      eventLog: eventLog ?? this.eventLog,
    );
  }
}

/// Demonstrates @onEvent for filtering and logging events
/// Blocks UpdateMessage events while loading, allows all others
@MonoBloc()
class EventCatchBloc extends _$EventCatchBloc<EventCatchState> {
  EventCatchBloc() : super(const EventCatchState());

  /// Filter events based on current state
  /// - Blocks UpdateMessage events when isLoading=true
  /// - Logs all events with timestamps for debugging
  /// - Returns false to block event, true to allow
  @onEvent
  bool _filterEvents(_Event event) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final eventName = event.runtimeType.toString();

    // Log all events (in real app, use a logger package)
    print('[$timestamp] Event: $eventName');

    // Block UpdateMessage events while loading
    if (event is _UpdateMessageEvent && state.isLoading) {
      print('  → BLOCKED (currently loading)');
      return false;
    }

    // Allow all other events
    return true;
  }

  @onEvent
  bool _filterAAAEvents(_StartLoadingEvent event) {
    return true;
  }

  /// Simulate a long-running operation (3 seconds)
  /// During this time, UpdateMessage events will be blocked
  @event
  Future<void> _onStartLoading(_Emitter emit) async {
    emit(state.copyWith(isLoading: true, message: 'Loading...'));
    await Future<void>.delayed(const Duration(seconds: 3));
    emit(state.copyWith(isLoading: false, message: 'Loading completed!'));
  }

  /// Update message event - BLOCKED while loading
  /// This demonstrates conditional event filtering
  @event
  EventCatchState _onUpdateMessage(String text) {
    return state.copyWith(message: text);
  }

  /// Force update event - ALWAYS ALLOWED even while loading
  /// Shows that filtering can be selective per event type
  @event
  EventCatchState _onForceUpdate(String text) {
    return state.copyWith(message: '[FORCED] $text');
  }

  /// Reset state to initial values
  @event
  EventCatchState _onReset() {
    return const EventCatchState();
  }
}
