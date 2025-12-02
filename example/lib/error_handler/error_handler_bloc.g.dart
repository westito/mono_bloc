// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_handler_bloc.dart';

// **************************************************************************
// MonoBlocGenerator
// **************************************************************************

// ignore_for_file: unused_element, prefer_foreach, library_private_types_in_public_api, always_put_control_body_on_new_line, invalid_use_of_protected_member, avoid_annotating_with_dynamic, avoid_futureor_void

typedef _Emitter = Emitter<int>;

abstract class _Event {
  _Event() : trace = StackTrace.current;

  final StackTrace trace;
}

class _NoParamsEvent extends _Event {
  _NoParamsEvent();
}

class _ErrorParamEvent extends _Event {
  _ErrorParamEvent();
}

class _ErrorAndStackEvent extends _Event {
  _ErrorAndStackEvent();
}

class _NullableReturnEvent extends _Event {
  _NullableReturnEvent();
}

class _NonNullReturnEvent extends _Event {
  _NonNullReturnEvent();
}

class _SuccessEvent extends _Event {
  _SuccessEvent(this.value);

  final int value;
}

abstract class _$ErrorHandlerBloc<_> extends Bloc<_Event, int> {
  _$ErrorHandlerBloc(super.initialState) {
    _$(this)._$init();
  }

  /// [ErrorHandlerBloc._onNoParams]
  void noParams() {
    add(_NoParamsEvent());
  }

  /// [ErrorHandlerBloc._onErrorParam]
  void errorParam() {
    add(_ErrorParamEvent());
  }

  /// [ErrorHandlerBloc._onErrorAndStack]
  void errorAndStack() {
    add(_ErrorAndStackEvent());
  }

  /// [ErrorHandlerBloc._onNullableReturn]
  void nullableReturn() {
    add(_NullableReturnEvent());
  }

  /// [ErrorHandlerBloc._onNonNullReturn]
  void nonNullReturn() {
    add(_NonNullReturnEvent());
  }

  /// [ErrorHandlerBloc._onSuccess]
  void success(int value) {
    add(_SuccessEvent(value));
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
    EventHandler<E, int> handler, {
    EventTransformer<E>? transformer,
  }) {
    super.on<E>(handler, transformer: transformer);
  }
}

extension type _$._(ErrorHandlerBloc bloc) implements ErrorHandlerBloc {
  _$(_$ErrorHandlerBloc<dynamic> base) : bloc = base as ErrorHandlerBloc;

  void _$handleError(
    Object e,
    StackTrace s,
    StackTrace eventTrace,
    void Function(StackTrace stack)? errorHandler,
  ) {
    final stack = _$stack(eventTrace, s);
    bloc.onError(e, stack);
    if (errorHandler != null) {
      try {
        errorHandler(stack);
      } catch (e2, s2) {
        bloc.onError(e2, s2);
      }
    }
  }

  void _$init() {
    bloc.on<_NoParamsEvent>((event, emit) async {
      try {
        emit(await _onNoParams());
      } catch (e, s) {
        _$handleError(e, s, event.trace, (stack) {
          _onErrorNoParams();
        });
      }
    });
    bloc.on<_ErrorParamEvent>((event, emit) async {
      try {
        emit(await _onErrorParam());
      } catch (e, s) {
        _$handleError(e, s, event.trace, (stack) {
          _onErrorErrorParam(e);
        });
      }
    });
    bloc.on<_ErrorAndStackEvent>((event, emit) async {
      try {
        emit(await _onErrorAndStack());
      } catch (e, s) {
        _$handleError(e, s, event.trace, (stack) {
          _onErrorErrorAndStack(e, stack);
        });
      }
    });
    bloc.on<_NullableReturnEvent>((event, emit) async {
      try {
        emit(await _onNullableReturn());
      } catch (e, s) {
        _$handleError(e, s, event.trace, (stack) {
          final result = _onErrorNullableReturn(e);
          if (result != null) emit(result);
        });
      }
    });
    bloc.on<_NonNullReturnEvent>((event, emit) async {
      try {
        emit(await _onNonNullReturn());
      } catch (e, s) {
        _$handleError(e, s, event.trace, (stack) {
          emit(_onErrorNonNullReturn(e));
        });
      }
    });
    bloc.on<_SuccessEvent>((event, emit) async {
      try {
        emit(await _onSuccess(event.value));
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });
  }

  static StackTrace _$stack(StackTrace origin, StackTrace trace) {
    return MonoStackTrace.filtered(origin, trace, 'error_handler_bloc.g.dart');
  }
}
