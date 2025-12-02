// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complex_queue_bloc.dart';

// **************************************************************************
// MonoBlocGenerator
// **************************************************************************

// ignore_for_file: unused_element, prefer_foreach, library_private_types_in_public_api, always_put_control_body_on_new_line, invalid_use_of_protected_member, avoid_annotating_with_dynamic, avoid_futureor_void

typedef _Emitter = Emitter<String>;

abstract class _Event {
  _Event() : trace = StackTrace.current;

  final StackTrace trace;
}

class _$Queue1QueueEvent extends _Event {}

class _$Queue2QueueEvent extends _Event {}

class _$Queue5QueueEvent extends _Event {}

class _Q1SyncEvent extends _$Queue1QueueEvent {
  _Q1SyncEvent();
}

class _Q1AsyncEvent extends _$Queue1QueueEvent {
  _Q1AsyncEvent(this.delay);

  final int delay;
}

class _Q1WithParamsEvent extends _$Queue1QueueEvent {
  _Q1WithParamsEvent(this.value, {required this.count, this.flag = false});

  final String value;

  final int count;

  final bool flag;
}

class _Q2StreamEvent extends _$Queue2QueueEvent {
  _Q2StreamEvent();
}

class _Q2EmitterEvent extends _$Queue2QueueEvent {
  _Q2EmitterEvent(this.msg, this.times, {this.prefix});

  final String msg;

  final int times;

  final String? prefix;
}

class _Q2ComplexEvent extends _$Queue2QueueEvent {
  _Q2ComplexEvent(
    this.a,
    this.b, {
    required this.operation,
    this.negate = false,
  });

  final int a;

  final int b;

  final String operation;

  final bool negate;
}

class _Q5SingleEvent extends _$Queue5QueueEvent {
  _Q5SingleEvent(this.count);

  final int count;
}

class _NormalEvent extends _Event {
  _NormalEvent();
}

class _SequentialEvent extends _Event {
  _SequentialEvent(this.value);

  final String value;
}

class _ConcurrentEvent extends _Event {
  _ConcurrentEvent(this.id);

  final int id;
}

class _RestartableEvent extends _Event {
  _RestartableEvent(this.prefix);

  final String prefix;
}

class _DroppableEvent extends _Event {
  _DroppableEvent(this.msg);

  final String msg;
}

class _InitializeEvent extends _Event {
  _InitializeEvent();
}

abstract class _$ComplexQueueBloc<_> extends Bloc<_Event, String> {
  _$ComplexQueueBloc(
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

  /// [ComplexQueueBloc._q1Sync]
  void q1Sync() {
    add(_Q1SyncEvent());
  }

  /// [ComplexQueueBloc._q1Async]
  void q1Async(int delay) {
    add(_Q1AsyncEvent(delay));
  }

  /// [ComplexQueueBloc._q1WithParams]
  void q1WithParams(String value, {required int count, bool flag = false}) {
    add(_Q1WithParamsEvent(value, count: count, flag: flag));
  }

  /// [ComplexQueueBloc._q2Stream]
  void q2Stream() {
    add(_Q2StreamEvent());
  }

  /// [ComplexQueueBloc._q2Emitter]
  void q2Emitter(String msg, int times, {String? prefix}) {
    add(_Q2EmitterEvent(msg, times, prefix: prefix));
  }

  /// [ComplexQueueBloc._q2Complex]
  void q2Complex(
    int a,
    int b, {
    required String operation,
    bool negate = false,
  }) {
    add(_Q2ComplexEvent(a, b, operation: operation, negate: negate));
  }

  /// [ComplexQueueBloc._q5Single]
  void q5Single(int count) {
    add(_Q5SingleEvent(count));
  }

  /// [ComplexQueueBloc._onNormal]
  void normal() {
    add(_NormalEvent());
  }

  /// [ComplexQueueBloc._onSequential]
  void sequential(String value) {
    add(_SequentialEvent(value));
  }

  /// [ComplexQueueBloc._onConcurrent]
  void concurrent(int id) {
    add(_ConcurrentEvent(id));
  }

  /// [ComplexQueueBloc._onRestartable]
  void restartable(String prefix) {
    add(_RestartableEvent(prefix));
  }

  /// [ComplexQueueBloc._onDroppable]
  void droppable(String msg) {
    add(_DroppableEvent(msg));
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
    EventHandler<E, String> handler, {
    EventTransformer<E>? transformer,
  }) {
    super.on<E>(handler, transformer: transformer);
  }
}

extension type _$._(ComplexQueueBloc bloc) implements ComplexQueueBloc {
  _$(_$ComplexQueueBloc<dynamic> base) : bloc = base as ComplexQueueBloc;

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
      if (event is _Q1SyncEvent) {
        try {
          emit(_q1Sync());
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      } else if (event is _Q1AsyncEvent) {
        try {
          emit(await _q1Async(event.delay));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      } else if (event is _Q1WithParamsEvent) {
        try {
          emit(
            _q1WithParams(event.value, count: event.count, flag: event.flag),
          );
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      }
    }, transformer: bloc._getTransformer<_$Queue1QueueEvent>('queue1'));
    bloc.on<_$Queue2QueueEvent>((event, emit) async {
      if (event is _Q2StreamEvent) {
        try {
          await emit.forEach<String>(_q2Stream(), onData: (state) => state);
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      } else if (event is _Q2EmitterEvent) {
        try {
          await _q2Emitter(emit, event.msg, event.times, prefix: event.prefix);
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      } else if (event is _Q2ComplexEvent) {
        try {
          emit(
            _q2Complex(
              event.a,
              event.b,
              operation: event.operation,
              negate: event.negate,
            ),
          );
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      }
    }, transformer: bloc._getTransformer<_$Queue2QueueEvent>('queue2'));
    bloc.on<_$Queue5QueueEvent>((event, emit) async {
      if (event is _Q5SingleEvent) {
        try {
          await emit.forEach<String>(
            _q5Single(event.count),
            onData: (state) => state,
          );
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      }
    }, transformer: bloc._getTransformer<_$Queue5QueueEvent>('queue5'));
    bloc.on<_NormalEvent>((event, emit) {
      try {
        emit(_onNormal());
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });
    bloc.on<_SequentialEvent>(
      (event, emit) async {
        try {
          emit(await _onSequential(event.value));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      },
      transformer: _castTransformer<_SequentialEvent>(
        MonoEventTransformer.sequential,
      ),
    );
    bloc.on<_ConcurrentEvent>(
      (event, emit) async {
        try {
          emit(await _onConcurrent(event.id));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      },
      transformer: _castTransformer<_ConcurrentEvent>(
        MonoEventTransformer.concurrent,
      ),
    );
    bloc.on<_RestartableEvent>(
      (event, emit) async {
        try {
          await emit.forEach<String>(
            _onRestartable(event.prefix),
            onData: (state) => state,
          );
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      },
      transformer: _castTransformer<_RestartableEvent>(
        MonoEventTransformer.restartable,
      ),
    );
    bloc.on<_DroppableEvent>(
      (event, emit) async {
        try {
          emit(await _onDroppable(event.msg));
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      },
      transformer: _castTransformer<_DroppableEvent>(
        MonoEventTransformer.droppable,
      ),
    );
    bloc.on<_InitializeEvent>((event, emit) {
      try {
        _initialize();
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });

    // Dispatch @onInit events
    bloc.add(_InitializeEvent());
  }

  static StackTrace _$stack(StackTrace origin, StackTrace trace) {
    return MonoStackTrace.filtered(origin, trace, 'complex_queue_bloc.g.dart');
  }
}
