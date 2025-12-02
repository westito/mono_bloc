// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_catch_bloc.dart';

// **************************************************************************
// MonoBlocGenerator
// **************************************************************************

// ignore_for_file: unused_element, prefer_foreach, library_private_types_in_public_api, always_put_control_body_on_new_line, invalid_use_of_protected_member, avoid_annotating_with_dynamic, avoid_futureor_void

typedef _Emitter = Emitter<EventCatchState>;

abstract class _Event {
  _Event() : trace = StackTrace.current;

  final StackTrace trace;
}

class _StartLoadingEvent extends _Event {
  _StartLoadingEvent();
}

class _UpdateMessageEvent extends _Event {
  _UpdateMessageEvent(this.text);

  final String text;
}

class _ForceUpdateEvent extends _Event {
  _ForceUpdateEvent(this.text);

  final String text;
}

class _ResetEvent extends _Event {
  _ResetEvent();
}

abstract class _$EventCatchBloc<_> extends Bloc<_Event, EventCatchState> {
  _$EventCatchBloc(super.initialState) {
    _$(this)._$init();
  }

  /// [EventCatchBloc._onStartLoading]
  void startLoading() {
    add(_StartLoadingEvent());
  }

  /// [EventCatchBloc._onUpdateMessage]
  void updateMessage(String text) {
    add(_UpdateMessageEvent(text));
  }

  /// [EventCatchBloc._onForceUpdate]
  void forceUpdate(String text) {
    add(_ForceUpdateEvent(text));
  }

  /// [EventCatchBloc._onReset]
  void reset() {
    add(_ResetEvent());
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
    EventHandler<E, EventCatchState> handler, {
    EventTransformer<E>? transformer,
  }) {
    super.on<E>(handler, transformer: transformer);
  }
}

extension type _$._(EventCatchBloc bloc) implements EventCatchBloc {
  _$(_$EventCatchBloc<dynamic> base) : bloc = base as EventCatchBloc;

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
    if (event is _StartLoadingEvent) return $._filterAAAEvents(event);
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
    bloc.on<_StartLoadingEvent>(
      (event, emit) async {
        try {
          await _onStartLoading(emit);
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      },
      transformer: _wrapWithOnEvent<_StartLoadingEvent>(
        (events, mapper) => events.asyncExpand(mapper),
      ),
    );
    bloc.on<_UpdateMessageEvent>(
      (event, emit) {
        try {
          emit(_onUpdateMessage(event.text));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      },
      transformer: _wrapWithOnEvent<_UpdateMessageEvent>(
        (events, mapper) => events.asyncExpand(mapper),
      ),
    );
    bloc.on<_ForceUpdateEvent>(
      (event, emit) {
        try {
          emit(_onForceUpdate(event.text));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      },
      transformer: _wrapWithOnEvent<_ForceUpdateEvent>(
        (events, mapper) => events.asyncExpand(mapper),
      ),
    );
    bloc.on<_ResetEvent>(
      (event, emit) {
        try {
          emit(_onReset());
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      },
      transformer: _wrapWithOnEvent<_ResetEvent>(
        (events, mapper) => events.asyncExpand(mapper),
      ),
    );
  }

  static StackTrace _$stack(StackTrace origin, StackTrace trace) {
    return MonoStackTrace.filtered(origin, trace, 'event_catch_bloc.g.dart');
  }
}
