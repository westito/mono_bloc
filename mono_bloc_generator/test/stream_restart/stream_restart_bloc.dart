import 'package:mono_bloc/mono_bloc.dart';

import 'stream_repository.dart';
import 'stream_restart_state.dart';

part 'stream_restart_bloc.g.dart';

@MonoBloc()
class StreamRestartBloc extends _$StreamRestartBloc<StreamRestartState> {
  StreamRestartBloc(this._repository)
    : super(const StreamRestartState(items: []));

  final StreamRepository _repository;

  @restartableEvent
  Stream<StreamRestartState> _onFetchItems(String prefix) {
    return _repository.fetchItems(prefix).map((item) {
      final updatedItems = [...state.items, item];
      return state.copyWith(items: updatedItems);
    });
  }
}
