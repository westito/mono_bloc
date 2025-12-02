// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loading_state_bug_bloc.dart';

// **************************************************************************
// MonoBlocGenerator
// **************************************************************************

// ignore_for_file: unused_element, prefer_foreach, library_private_types_in_public_api, always_put_control_body_on_new_line, invalid_use_of_protected_member, avoid_annotating_with_dynamic, avoid_futureor_void

typedef _State = MonoAsyncValue<LoadingBugState>;

typedef _Emitter = MonoAsyncEmitter<LoadingBugState>;

abstract class _Event {
  _Event() : trace = StackTrace.current;

  final StackTrace trace;
}

class _IncrementThenLoadEvent extends _Event {
  _IncrementThenLoadEvent();
}

abstract class _$LoadingStateBugBloc<_> extends Bloc<_Event, _State> {
  _$LoadingStateBugBloc(super.initialState) {
    _$(this)._$init();
  }

  @protected
  _State loading() =>
      MonoAsyncValue<LoadingBugState>(state.dataOrNull, true, null, null);

  @protected
  _State loadingClearData() => const MonoAsyncValue.loading();

  @protected
  _State withData(LoadingBugState data) => MonoAsyncValue.withData(data);

  @protected
  _State withError(
    Object error,
    StackTrace stackTrace, [
    LoadingBugState? data,
  ]) => MonoAsyncValue.withError(error, stackTrace, data);

  /// [LoadingStateBugBloc._onIncrementThenLoad]
  void incrementThenLoad() {
    add(_IncrementThenLoadEvent());
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
    EventHandler<E, _State> handler, {
    EventTransformer<E>? transformer,
  }) {
    super.on<E>(handler, transformer: transformer);
  }
}

extension type _$._(LoadingStateBugBloc bloc) implements LoadingStateBugBloc {
  _$(_$LoadingStateBugBloc<dynamic> base) : bloc = base as LoadingStateBugBloc;

  MonoAsyncEmitter<LoadingBugState> _$wrapEmit(
    Emitter<_State> emit,
    _State state,
  ) {
    return MonoAsyncEmitter<LoadingBugState>(emit, bloc);
  }

  StackTrace _$onError(StackTrace eventTrace, Object e, StackTrace s) {
    final stack = _$stack(eventTrace, s);
    bloc.onError(e, stack);
    return stack;
  }

  void _$handleError(
    Object e,
    StackTrace s,
    StackTrace eventTrace,
    void Function(StackTrace stack)? errorHandler,
  ) {
    final stack = _$onError(eventTrace, e, s);
    if (errorHandler != null) {
      try {
        errorHandler(stack);
      } catch (e2, s2) {
        bloc.onError(e2, s2);
      }
    }
  }

  void _$init() {
    bloc.on<_IncrementThenLoadEvent>((event, emit) async {
      await _onIncrementThenLoad(_$wrapEmit(emit, bloc.state));
    });
  }

  static StackTrace _$stack(StackTrace origin, StackTrace trace) {
    return MonoStackTrace.filtered(
      origin,
      trace,
      'loading_state_bug_bloc.g.dart',
    );
  }
}
