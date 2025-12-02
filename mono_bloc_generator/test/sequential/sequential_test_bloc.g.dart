// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sequential_test_bloc.dart';

// **************************************************************************
// MonoBlocGenerator
// **************************************************************************

// ignore_for_file: unused_element, prefer_foreach, library_private_types_in_public_api, always_put_control_body_on_new_line, invalid_use_of_protected_member, avoid_annotating_with_dynamic, avoid_futureor_void

typedef _Emitter = MonoSeqEmitter<SequentialState>;

abstract class _Event {
  _Event() : trace = StackTrace.current;

  final StackTrace trace;
}

class _$SequentialEvent extends _Event {}

class _Event1Event extends _$SequentialEvent {
  _Event1Event(this.amount);

  final double amount;
}

class _Event2Event extends _$SequentialEvent {
  _Event2Event(this.amount);

  final double amount;
}

class _Event3Event extends _$SequentialEvent {
  _Event3Event(this.amount, this.recipient);

  final double amount;

  final String recipient;
}

class _Event4Event extends _$SequentialEvent {
  _Event4Event();
}

class _Event5Event extends _Event {
  _Event5Event();
}

abstract class _$SequentialTestBloc<_> extends Bloc<_Event, SequentialState> {
  _$SequentialTestBloc(super.initialState) {
    _$(this)._$init();
  }

  /// [SequentialTestBloc._onEvent1]
  void event1(double amount) {
    add(_Event1Event(amount));
  }

  /// [SequentialTestBloc._onEvent2]
  void event2(double amount) {
    add(_Event2Event(amount));
  }

  /// [SequentialTestBloc._onEvent3]
  void event3(double amount, String recipient) {
    add(_Event3Event(amount, recipient));
  }

  /// [SequentialTestBloc._onEvent4]
  void event4() {
    add(_Event4Event());
  }

  /// [SequentialTestBloc._onEvent5]
  void event5() {
    add(_Event5Event());
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
    EventHandler<E, SequentialState> handler, {
    EventTransformer<E>? transformer,
  }) {
    super.on<E>(handler, transformer: transformer);
  }
}

extension type _$._(SequentialTestBloc bloc) implements SequentialTestBloc {
  _$(_$SequentialTestBloc<dynamic> base) : bloc = base as SequentialTestBloc;

  EventTransformer<E> _castTransformer<E>(
    EventTransformer<dynamic> transformer,
  ) {
    return (events, mapper) => transformer(
      events.cast<dynamic>(),
      (event) => mapper(event as E).cast<dynamic>(),
    ).cast<E>();
  }

  void _$init() {
    bloc.on<_$SequentialEvent>(
      (event, emit) async {
        if (event is _Event1Event) {
          try {
            emit(await _onEvent1(event.amount));
          } catch (e, s) {
            final stack = _$stack(event.trace, s);
            bloc.onError(e, stack);
            rethrow;
          }
        } else if (event is _Event2Event) {
          try {
            emit(await _onEvent2(event.amount));
          } catch (e, s) {
            final stack = _$stack(event.trace, s);
            bloc.onError(e, stack);
            rethrow;
          }
        } else if (event is _Event3Event) {
          try {
            emit(await _onEvent3(event.amount, event.recipient));
          } catch (e, s) {
            final stack = _$stack(event.trace, s);
            bloc.onError(e, stack);
            rethrow;
          }
        } else if (event is _Event4Event) {
          try {
            emit(_onEvent4());
          } catch (e, s) {
            final stack = _$stack(event.trace, s);
            bloc.onError(e, stack);
            rethrow;
          }
        }
      },
      transformer: _castTransformer<_$SequentialEvent>(
        MonoEventTransformer.sequential,
      ),
    );
    bloc.on<_Event5Event>(
      (event, emit) async {
        try {
          await emit.forEach<SequentialState>(
            _onEvent5(),
            onData: (state) => state,
          );
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      },
      transformer: _castTransformer<_Event5Event>(
        MonoEventTransformer.restartable,
      ),
    );
  }

  static StackTrace _$stack(StackTrace origin, StackTrace trace) {
    return MonoStackTrace.filtered(
      origin,
      trace,
      'sequential_test_bloc.g.dart',
    );
  }
}
