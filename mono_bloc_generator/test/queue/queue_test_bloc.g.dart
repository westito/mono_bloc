// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_test_bloc.dart';

// **************************************************************************
// MonoBlocGenerator
// **************************************************************************

// ignore_for_file: unused_element, prefer_foreach, library_private_types_in_public_api, always_put_control_body_on_new_line, invalid_use_of_protected_member, avoid_annotating_with_dynamic, avoid_futureor_void

typedef _Emitter = Emitter<QueueState>;

abstract class _Event {
  _Event() : trace = StackTrace.current;

  final StackTrace trace;
}

class _$Queue1QueueEvent extends _Event {}

class _$Queue2QueueEvent extends _Event {}

class _$Queue3QueueEvent extends _Event {}

class _$Queue4QueueEvent extends _Event {}

class _Event1Event extends _$Queue1QueueEvent {
  _Event1Event(this.item);

  final String item;
}

class _Event2Event extends _$Queue1QueueEvent {
  _Event2Event(this.item);

  final String item;
}

class _Event3Event extends _$Queue2QueueEvent {
  _Event3Event();
}

class _Event4Event extends _$Queue2QueueEvent {
  _Event4Event();
}

class _Event5Event extends _$Queue3QueueEvent {
  _Event5Event(this.query);

  final String query;
}

class _Event6Event extends _$Queue3QueueEvent {
  _Event6Event();
}

class _Event7Event extends _$Queue4QueueEvent {
  _Event7Event(this.item);

  final String item;
}

class _Event8Event extends _Event {
  _Event8Event();
}

class _Event9Event extends _Event {
  _Event9Event(this.item);

  final String item;
}

class _Event10Event extends _Event {
  _Event10Event();
}

abstract class _$QueueTestBloc<_> extends Bloc<_Event, QueueState> {
  _$QueueTestBloc(
    super.initialState, {
    Map<String, EventTransformer<dynamic>>? queues,
  }) : _queues = queues ?? const {} {
    _$(this)._$init();
  }

  final Map<String, EventTransformer<dynamic>> _queues;

  EventTransformer<E>? _getTransformer<E>(String queueName) {
    final $ = _$(this);
    assert(
      _queues.containsKey(queueName),
      'Queue "$queueName" does not exist. Add it in super constructor queues parameter.',
    );
    final transformer = _queues[queueName];
    if (transformer == null) return null;
    return $._castTransformer<E>(transformer);
  }

  /// [QueueTestBloc._onEvent1]
  void event1(String item) {
    add(_Event1Event(item));
  }

  /// [QueueTestBloc._onEvent2]
  void event2(String item) {
    add(_Event2Event(item));
  }

  /// [QueueTestBloc._onEvent3]
  void event3() {
    add(_Event3Event());
  }

  /// [QueueTestBloc._onEvent4]
  void event4() {
    add(_Event4Event());
  }

  /// [QueueTestBloc._onEvent5]
  void event5(String query) {
    add(_Event5Event(query));
  }

  /// [QueueTestBloc._onEvent6]
  void event6() {
    add(_Event6Event());
  }

  /// [QueueTestBloc._onEvent7]
  void event7(String item) {
    add(_Event7Event(item));
  }

  /// [QueueTestBloc._onEvent8]
  void event8() {
    add(_Event8Event());
  }

  /// [QueueTestBloc._onEvent9]
  void event9(String item) {
    add(_Event9Event(item));
  }

  /// [QueueTestBloc._onEvent10]
  void event10() {
    add(_Event10Event());
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
    EventHandler<E, QueueState> handler, {
    EventTransformer<E>? transformer,
  }) {
    super.on<E>(handler, transformer: transformer);
  }
}

extension type _$._(QueueTestBloc bloc) implements QueueTestBloc {
  _$(_$QueueTestBloc<dynamic> base) : bloc = base as QueueTestBloc;

  EventTransformer<E> _castTransformer<E>(
    EventTransformer<dynamic> transformer,
  ) {
    return (events, mapper) => transformer(
      events.cast<dynamic>(),
      (event) => mapper(event as E).cast<dynamic>(),
    ).cast<E>();
  }

  void _$init() {
    bloc.on<_$Queue1QueueEvent>((event, emit) async {
      if (event is _Event1Event) {
        try {
          emit(await _onEvent1(emit, event.item));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      } else if (event is _Event2Event) {
        try {
          emit(await _onEvent2(emit, event.item));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      }
    }, transformer: bloc._getTransformer<_$Queue1QueueEvent>('queue1'));
    bloc.on<_$Queue2QueueEvent>((event, emit) async {
      if (event is _Event3Event) {
        try {
          emit(await _onEvent3(emit));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      } else if (event is _Event4Event) {
        try {
          emit(await _onEvent4(emit));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      }
    }, transformer: bloc._getTransformer<_$Queue2QueueEvent>('queue2'));
    bloc.on<_$Queue3QueueEvent>((event, emit) async {
      if (event is _Event5Event) {
        try {
          emit(await _onEvent5(event.query));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      } else if (event is _Event6Event) {
        try {
          emit(await _onEvent6());
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      }
    }, transformer: bloc._getTransformer<_$Queue3QueueEvent>('queue3'));
    bloc.on<_$Queue4QueueEvent>((event, emit) async {
      if (event is _Event7Event) {
        try {
          emit(await _onEvent7(emit, event.item));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      }
    }, transformer: bloc._getTransformer<_$Queue4QueueEvent>('queue4'));
    bloc.on<_Event8Event>((event, emit) {
      try {
        emit(_onEvent8());
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });
    bloc.on<_Event9Event>((event, emit) {
      try {
        emit(_onEvent9(event.item));
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });
    bloc.on<_Event10Event>((event, emit) {
      try {
        emit(_onEvent10());
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });
  }

  static StackTrace _$stack(StackTrace origin, StackTrace trace) {
    return MonoStackTrace.filtered(origin, trace, 'queue_test_bloc.g.dart');
  }
}
