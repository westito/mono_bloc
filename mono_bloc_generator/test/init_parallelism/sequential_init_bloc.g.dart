// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sequential_init_bloc.dart';

// **************************************************************************
// MonoBlocGenerator
// **************************************************************************

// ignore_for_file: unused_element, prefer_foreach, library_private_types_in_public_api, always_put_control_body_on_new_line, invalid_use_of_protected_member, avoid_annotating_with_dynamic, avoid_futureor_void

typedef _Emitter = MonoSeqEmitter<InitParallelismState>;

abstract class _Event {
  _Event() : trace = StackTrace.current;

  final StackTrace trace;
}

class _$SequentialEvent extends _Event {}

class _ResetEvent extends _$SequentialEvent {
  _ResetEvent();
}

class _InitAEvent extends _$SequentialEvent {
  _InitAEvent();
}

class _InitBEvent extends _$SequentialEvent {
  _InitBEvent();
}

class _InitCEvent extends _$SequentialEvent {
  _InitCEvent();
}

abstract class _$SequentialInitBloc<_>
    extends Bloc<_Event, InitParallelismState> {
  _$SequentialInitBloc(super.initialState) {
    _$(this)._$init();
  }

  /// [SequentialInitBloc._onReset]
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
    EventHandler<E, InitParallelismState> handler, {
    EventTransformer<E>? transformer,
  }) {
    super.on<E>(handler, transformer: transformer);
  }
}

extension type _$._(SequentialInitBloc bloc) implements SequentialInitBloc {
  _$(_$SequentialInitBloc<dynamic> base) : bloc = base as SequentialInitBloc;

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
        if (event is _ResetEvent) {
          try {
            emit(_onReset());
          } catch (e, s) {
            final stack = _$stack(event.trace, s);
            bloc.onError(e, stack);
            rethrow;
          }
        } else if (event is _InitAEvent) {
          try {
            emit(await _initA());
          } catch (e, s) {
            final stack = _$stack(event.trace, s);
            bloc.onError(e, stack);
            rethrow;
          }
        } else if (event is _InitBEvent) {
          try {
            emit(await _initB());
          } catch (e, s) {
            final stack = _$stack(event.trace, s);
            bloc.onError(e, stack);
            rethrow;
          }
        } else if (event is _InitCEvent) {
          try {
            emit(await _initC());
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

    // Dispatch @onInit events
    bloc.add(_InitAEvent());
    bloc.add(_InitBEvent());
    bloc.add(_InitCEvent());
  }

  static StackTrace _$stack(StackTrace origin, StackTrace trace) {
    return MonoStackTrace.filtered(
      origin,
      trace,
      'sequential_init_bloc.g.dart',
    );
  }
}
