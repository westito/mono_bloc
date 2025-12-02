// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parallel_init_bloc.dart';

// **************************************************************************
// MonoBlocGenerator
// **************************************************************************

// ignore_for_file: unused_element, prefer_foreach, library_private_types_in_public_api, always_put_control_body_on_new_line, invalid_use_of_protected_member, avoid_annotating_with_dynamic, avoid_futureor_void

typedef _Emitter = Emitter<InitParallelismState>;

abstract class _Event {
  _Event() : trace = StackTrace.current;

  final StackTrace trace;
}

class _ResetEvent extends _Event {
  _ResetEvent();
}

class _InitAEvent extends _Event {
  _InitAEvent();
}

class _InitBEvent extends _Event {
  _InitBEvent();
}

class _InitCEvent extends _Event {
  _InitCEvent();
}

abstract class _$ParallelInitBloc<_>
    extends Bloc<_Event, InitParallelismState> {
  _$ParallelInitBloc(super.initialState) {
    _$(this)._$init();
  }

  /// [ParallelInitBloc._onReset]
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

extension type _$._(ParallelInitBloc bloc) implements ParallelInitBloc {
  _$(_$ParallelInitBloc<dynamic> base) : bloc = base as ParallelInitBloc;

  void _$init() {
    bloc.on<_ResetEvent>((event, emit) {
      try {
        emit(_onReset());
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });
    bloc.on<_InitAEvent>((event, emit) async {
      try {
        emit(await _initA());
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });
    bloc.on<_InitBEvent>((event, emit) async {
      try {
        emit(await _initB());
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });
    bloc.on<_InitCEvent>((event, emit) async {
      try {
        emit(await _initC());
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });

    // Dispatch @onInit events
    bloc.add(_InitAEvent());
    bloc.add(_InitBEvent());
    bloc.add(_InitCEvent());
  }

  static StackTrace _$stack(StackTrace origin, StackTrace trace) {
    return MonoStackTrace.filtered(origin, trace, 'parallel_init_bloc.g.dart');
  }
}
