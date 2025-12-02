// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// MonoBlocGenerator
// **************************************************************************

// ignore_for_file: unused_element, prefer_foreach, library_private_types_in_public_api, always_put_control_body_on_new_line, invalid_use_of_protected_member, avoid_annotating_with_dynamic, avoid_futureor_void

typedef _Emitter = Emitter<int>;

abstract class _Event {
  _Event() : trace = StackTrace.current;

  final StackTrace trace;
}

class _IncrementEvent extends _Event {
  _IncrementEvent();
}

class _IncrementAsyncEvent extends _Event {
  _IncrementAsyncEvent();
}

class _AddValueEvent extends _Event {
  _AddValueEvent(this.value);

  final int value;
}

class _CountdownEvent extends _Event {
  _CountdownEvent(this.from);

  final int from;
}

abstract class _$CounterBloc<_> extends Bloc<_Event, int>
    with MonoBlocActionMixin<_Action, int>, _CounterBlocActions {
  _$CounterBloc(super.initialState) {
    _$(this)._$init();
  }

  /// [CounterBloc._onIncrement]
  void increment() {
    add(_IncrementEvent());
  }

  /// [CounterBloc._onIncrementAsync]
  void incrementAsync() {
    add(_IncrementAsyncEvent());
  }

  /// [CounterBloc._onAddValue]
  void addValue(int value) {
    add(_AddValueEvent(value));
  }

  /// [CounterBloc._onCountdown]
  void countdown(int from) {
    add(_CountdownEvent(from));
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

  @override
  void showMessage(String text) {
    actionController?.add(_ShowMessageAction(text));
  }
}

final class _ShowMessageAction extends _Action {
  _ShowMessageAction(this.text);

  final String text;
}

abstract interface class CounterBlocActions {
  FutureOr<void> showMessage(BuildContext context, String text);

  static _$CounterBlocActions when({
    FutureOr<void> Function(BuildContext context, String text)? showMessage,
  }) => _$CounterBlocActions(
    actions: (bloc, context, action) {
      switch (action) {
        case _ShowMessageAction(:final text, :final trace):
          if (showMessage != null) {
            unawaited(
              Future.sync(() async {
                try {
                  await showMessage(context, text);
                } catch (e, s) {
                  bloc.onError(e, _$._$stack(trace, s));
                }
              }),
            );
          }
      }
    },
  );

  static _$CounterBlocActions of(CounterBlocActions actions) =>
      when(showMessage: actions.showMessage);
}

class _$CounterBlocActions extends FlutterMonoBlocActions {
  @override
  final void Function(
    BlocBase<dynamic> bloc,
    BuildContext context,
    dynamic action,
  )
  actions;

  _$CounterBlocActions({required this.actions});
}

sealed class _Action {
  _Action() : trace = StackTrace.current;
  final StackTrace trace;
}

extension type _$._(CounterBloc bloc) implements CounterBloc {
  _$(_$CounterBloc<dynamic> base) : bloc = base as CounterBloc;

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
    bloc.on<_IncrementEvent>((event, emit) {
      try {
        emit(_onIncrement());
      } catch (e, s) {
        _$handleError(e, s, event.trace, (stack) {
          emit(_onError(e, stack));
        });
      }
    });
    bloc.on<_IncrementAsyncEvent>((event, emit) async {
      try {
        emit(await _onIncrementAsync());
      } catch (e, s) {
        _$handleError(e, s, event.trace, (stack) {
          emit(_onError(e, stack));
        });
      }
    });
    bloc.on<_AddValueEvent>((event, emit) {
      try {
        emit(_onAddValue(event.value));
      } catch (e, s) {
        _$handleError(e, s, event.trace, (stack) {
          emit(_onError(e, stack));
        });
      }
    });
    bloc.on<_CountdownEvent>((event, emit) async {
      try {
        await emit.forEach<int>(
          _onCountdown(event.from),
          onData: (state) => state,
        );
      } catch (e, s) {
        _$handleError(e, s, event.trace, (stack) {
          emit(_onError(e, stack));
        });
      }
    });
  }

  static StackTrace _$stack(StackTrace origin, StackTrace trace) {
    return MonoStackTrace.filtered(origin, trace, 'main.g.dart');
  }
}
