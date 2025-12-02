// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actions_bloc.dart';

// **************************************************************************
// MonoBlocGenerator
// **************************************************************************

// ignore_for_file: unused_element, prefer_foreach, library_private_types_in_public_api, always_put_control_body_on_new_line, invalid_use_of_protected_member, avoid_annotating_with_dynamic, avoid_futureor_void

typedef _Emitter = Emitter<ActionsState>;

abstract class _Event {
  _Event() : trace = StackTrace.current;

  final StackTrace trace;
}

class _Event1Event extends _Event {
  _Event1Event(this.message, this.level);

  final String message;

  final Level level;
}

class _Event2Event extends _Event {
  _Event2Event(this.messages, this.level);

  final List<String> messages;

  final Level level;
}

class _Event3Event extends _Event {
  _Event3Event();
}

abstract class _$ActionsBloc<_> extends Bloc<_Event, ActionsState>
    with MonoBlocActionMixin<_Action, ActionsState>, _ActionsBlocActions {
  _$ActionsBloc(super.initialState) {
    _$(this)._$init();
  }

  /// [ActionsBloc._onEvent1]
  void event1(String message, Level level) {
    add(_Event1Event(message, level));
  }

  /// [ActionsBloc._onEvent2]
  void event2(List<String> messages, Level level) {
    add(_Event2Event(messages, level));
  }

  /// [ActionsBloc._onEvent3]
  void event3() {
    add(_Event3Event());
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
    EventHandler<E, ActionsState> handler, {
    EventTransformer<E>? transformer,
  }) {
    super.on<E>(handler, transformer: transformer);
  }

  @override
  void action1(String message, Level level) {
    actionController?.add(_Action1Action(message, level));
  }

  @override
  void action2(String param1, String param2, String param3) {
    actionController?.add(_Action2Action(param1, param2, param3));
  }

  @override
  void action3(String param1, String param2) {
    actionController?.add(_Action3Action(param1, param2));
  }

  @override
  void action4({required String url, required Map<String, dynamic> data}) {
    actionController?.add(_Action4Action(url: url, data: data));
  }
}

final class _Action1Action extends _Action {
  _Action1Action(this.message, this.level);

  final String message;

  final Level level;
}

final class _Action2Action extends _Action {
  _Action2Action(this.param1, this.param2, this.param3);

  final String param1;

  final String param2;

  final String param3;
}

final class _Action3Action extends _Action {
  _Action3Action(this.param1, this.param2);

  final String param1;

  final String param2;
}

final class _Action4Action extends _Action {
  _Action4Action({required this.url, required this.data});

  final String url;

  final Map<String, dynamic> data;
}

abstract interface class ActionsBlocActions {
  FutureOr<void> action1(String message, Level level);
  FutureOr<void> action2(String param1, String param2, String param3);
  FutureOr<void> action3(String param1, String param2);
  FutureOr<void> action4({
    required String url,
    required Map<String, dynamic> data,
  });

  static _$ActionsBlocActions when({
    FutureOr<void> Function(String message, Level level)? action1,
    FutureOr<void> Function(String param1, String param2, String param3)?
    action2,
    FutureOr<void> Function(String param1, String param2)? action3,
    FutureOr<void> Function({
      required String url,
      required Map<String, dynamic> data,
    })?
    action4,
  }) => _$ActionsBlocActions(
    actions: (bloc, action) {
      switch (action) {
        case _Action1Action(:final message, :final level, :final trace):
          if (action1 != null) {
            unawaited(
              Future.sync(() async {
                try {
                  await action1(message, level);
                } catch (e, s) {
                  bloc.onError(e, _$._$stack(trace, s));
                }
              }),
            );
          }
        case _Action2Action(
          :final param1,
          :final param2,
          :final param3,
          :final trace,
        ):
          if (action2 != null) {
            unawaited(
              Future.sync(() async {
                try {
                  await action2(param1, param2, param3);
                } catch (e, s) {
                  bloc.onError(e, _$._$stack(trace, s));
                }
              }),
            );
          }
        case _Action3Action(:final param1, :final param2, :final trace):
          if (action3 != null) {
            unawaited(
              Future.sync(() async {
                try {
                  await action3(param1, param2);
                } catch (e, s) {
                  bloc.onError(e, _$._$stack(trace, s));
                }
              }),
            );
          }
        case _Action4Action(:final url, :final data, :final trace):
          if (action4 != null) {
            unawaited(
              Future.sync(() async {
                try {
                  await action4(url: url, data: data);
                } catch (e, s) {
                  bloc.onError(e, _$._$stack(trace, s));
                }
              }),
            );
          }
      }
    },
  );

  static _$ActionsBlocActions of(ActionsBlocActions actions) => when(
    action1: actions.action1,
    action2: actions.action2,
    action3: actions.action3,
    action4: actions.action4,
  );
}

class _$ActionsBlocActions extends MonoBlocActions {
  @override
  final void Function(BlocBase<dynamic> bloc, dynamic action) actions;

  _$ActionsBlocActions({required this.actions});
}

sealed class _Action {
  _Action() : trace = StackTrace.current;
  final StackTrace trace;
}

extension type _$._(ActionsBloc bloc) implements ActionsBloc {
  _$(_$ActionsBloc<dynamic> base) : bloc = base as ActionsBloc;

  void _$init() {
    bloc.on<_Event1Event>((event, emit) {
      try {
        emit(_onEvent1(event.message, event.level));
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });
    bloc.on<_Event2Event>((event, emit) async {
      try {
        emit(await _onEvent2(event.messages, event.level));
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });
    bloc.on<_Event3Event>((event, emit) {
      try {
        emit(_onEvent3());
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });
  }

  static StackTrace _$stack(StackTrace origin, StackTrace trace) {
    return MonoStackTrace.filtered(origin, trace, 'actions_bloc.g.dart');
  }
}
