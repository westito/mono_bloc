// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_catch_test_bloc.dart';

// **************************************************************************
// MonoBlocGenerator
// **************************************************************************

// ignore_for_file: unused_element, prefer_foreach, library_private_types_in_public_api, always_put_control_body_on_new_line, invalid_use_of_protected_member, avoid_annotating_with_dynamic, avoid_futureor_void

typedef _Emitter = Emitter<EventCatchTestState>;

abstract class _Event {
  _Event() : trace = StackTrace.current;

  final StackTrace trace;
}

class _Event1Event extends _Event {
  _Event1Event();
}

class _Event2Event extends _Event {
  _Event2Event(this.text);

  final String text;
}

class _Event3Event extends _Event {
  _Event3Event(this.text);

  final String text;
}

class _Event4Event extends _Event {
  _Event4Event();
}

abstract class _$EventCatchTestBloc<_>
    extends Bloc<_Event, EventCatchTestState> {
  _$EventCatchTestBloc(super.initialState) {
    _$(this)._$init();
  }

  /// [EventCatchTestBloc._onEvent1]
  void event1() {
    add(_Event1Event());
  }

  /// [EventCatchTestBloc._onEvent2]
  void event2(String text) {
    add(_Event2Event(text));
  }

  /// [EventCatchTestBloc._onEvent3]
  void event3(String text) {
    add(_Event3Event(text));
  }

  /// [EventCatchTestBloc._onEvent4]
  void event4() {
    add(_Event4Event());
  }

  @override
  @protected
  void add(_Event event) {
    if (isClosed) {
      return;
    }
    super.add(event);
  }

  @override
  @protected
  void on<E extends _Event>(
    EventHandler<E, EventCatchTestState> handler, {
    EventTransformer<E>? transformer,
  }) {
    super.on<E>(handler, transformer: transformer);
  }
}

extension type _$._(EventCatchTestBloc bloc) implements EventCatchTestBloc {
  _$(_$EventCatchTestBloc<dynamic> base) : bloc = base as EventCatchTestBloc;

  EventTransformer<E> _castTransformer<E>(
    EventTransformer<dynamic> transformer,
  ) {
    return (events, mapper) => transformer(
      events.cast<dynamic>(),
      (event) => mapper(event as E).cast<dynamic>(),
    ).cast<E>();
  }

  // ignore: avoid_annotating_with_dynamic
  bool _filterEvent(dynamic event) {
    final $ = bloc;
    // Check specific event type first
    if (event is _Event1Event) return $._filterAAAEvents(event);
    // Fallback to all events handler
    return $._filterEvents(event as _Event);
  }

  EventTransformer<E> _wrapWithOnEvent<E>(EventTransformer<E> transformer) {
    return (events, mapper) {
      // ignore: unnecessary_lambdas
      final filteredEvents = events.where((event) => _filterEvent(event));
      return transformer(filteredEvents, mapper);
    };
  }

  void _$init() {
    bloc.on<_Event1Event>(
      (event, emit) async {
        try {
          await _onEvent1(emit);
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      },
      transformer: _wrapWithOnEvent<_Event1Event>(
        (events, mapper) => events.asyncExpand(mapper),
      ),
    );
    bloc.on<_Event2Event>(
      (event, emit) {
        try {
          emit(_onEvent2(event.text));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      },
      transformer: _wrapWithOnEvent<_Event2Event>(
        (events, mapper) => events.asyncExpand(mapper),
      ),
    );
    bloc.on<_Event3Event>(
      (event, emit) {
        try {
          emit(_onEvent3(event.text));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      },
      transformer: _wrapWithOnEvent<_Event3Event>(
        (events, mapper) => events.asyncExpand(mapper),
      ),
    );
    bloc.on<_Event4Event>(
      (event, emit) {
        try {
          emit(_onEvent4());
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      },
      transformer: _wrapWithOnEvent<_Event4Event>(
        (events, mapper) => events.asyncExpand(mapper),
      ),
    );
  }

  static StackTrace _$stack(StackTrace origin, StackTrace trace) {
    return MonoStackTrace.filtered(
      origin,
      trace,
      'event_catch_test_bloc.g.dart',
    );
  }
}
