import 'package:mono_bloc/mono_bloc.dart';

part 'event_catch_test_bloc.g.dart';

class EventCatchTestState {
  final bool isLoading;
  final String message;
  final List<String> eventLog;

  const EventCatchTestState({
    this.isLoading = false,
    this.message = 'Ready',
    this.eventLog = const [],
  });

  EventCatchTestState copyWith({
    bool? isLoading,
    String? message,
    List<String>? eventLog,
  }) {
    return EventCatchTestState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      eventLog: eventLog ?? this.eventLog,
    );
  }
}

@MonoBloc()
class EventCatchTestBloc extends _$EventCatchTestBloc<EventCatchTestState> {
  EventCatchTestBloc() : super(const EventCatchTestState());

  @onEvent
  bool _filterEvents(_Event event) {
    if (event is _Event2Event && state.isLoading) {
      return false;
    }

    return true;
  }

  @onEvent
  bool _filterAAAEvents(_Event1Event event) {
    return true;
  }

  @event
  Future<void> _onEvent1(_Emitter emit) async {
    emit(state.copyWith(isLoading: true, message: 'Loading...'));
    await Future<void>.delayed(const Duration(seconds: 3));
    emit(state.copyWith(isLoading: false, message: 'Loading completed!'));
  }

  @event
  EventCatchTestState _onEvent2(String text) {
    return state.copyWith(message: text);
  }

  @event
  EventCatchTestState _onEvent3(String text) {
    return state.copyWith(message: '[FORCED] $text');
  }

  @event
  EventCatchTestState _onEvent4() {
    return const EventCatchTestState();
  }
}
