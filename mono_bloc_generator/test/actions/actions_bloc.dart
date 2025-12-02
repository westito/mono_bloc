import 'package:equatable/equatable.dart';
import 'package:mono_bloc/mono_bloc.dart';

part 'actions_bloc.g.dart';

enum Level { level1, level2, level3, level4 }

class ActionsState extends Equatable {
  const ActionsState({this.count = 0, this.lastMessage, this.lastLevel});

  final int count;
  final String? lastMessage;
  final Level? lastLevel;

  ActionsState copyWith({int? count, String? lastMessage, Level? lastLevel}) {
    return ActionsState(
      count: count ?? this.count,
      lastMessage: lastMessage ?? this.lastMessage,
      lastLevel: lastLevel ?? this.lastLevel,
    );
  }

  @override
  List<Object?> get props => [count, lastMessage, lastLevel];
}

@MonoActions()
mixin _ActionsBlocActions {
  void action1(String message, Level level);

  void action2(String param1, String param2, String param3);

  void action3(String param1, String param2);

  void action4({required String url, required Map<String, dynamic> data});
}

@MonoBloc()
class ActionsBloc extends _$ActionsBloc<ActionsState> {
  ActionsBloc() : super(const ActionsState());

  @event
  ActionsState _onEvent1(String message, Level level) {
    return ActionsState(
      count: state.count + 1,
      lastMessage: message,
      lastLevel: level,
    );
  }

  @event
  Future<ActionsState> _onEvent2(List<String> messages, Level level) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    return ActionsState(
      count: state.count + messages.length,
      lastMessage: messages.isNotEmpty ? messages.last : null,
      lastLevel: level,
    );
  }

  @event
  ActionsState _onEvent3() {
    return const ActionsState();
  }
}
