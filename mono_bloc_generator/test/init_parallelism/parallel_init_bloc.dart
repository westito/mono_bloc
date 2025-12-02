import 'package:mono_bloc/mono_bloc.dart';

import 'init_parallelism_state.dart';

part 'parallel_init_bloc.g.dart';

/// Parallel bloc - @onInit methods run in parallel
/// Longest delay (initA: 150ms) should complete LAST
@MonoBloc()
class ParallelInitBloc extends _$ParallelInitBloc<InitParallelismState> {
  ParallelInitBloc() : super(const InitParallelismState());

  /// Longest delay - 150ms
  @onInit
  Future<InitParallelismState> _initA() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return state.copyWith(executionOrder: [...state.executionOrder, 'A']);
  }

  /// Medium delay - 100ms
  @onInit
  Future<InitParallelismState> _initB() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return state.copyWith(executionOrder: [...state.executionOrder, 'B']);
  }

  /// Shortest delay - 50ms
  @onInit
  Future<InitParallelismState> _initC() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return state.copyWith(executionOrder: [...state.executionOrder, 'C']);
  }

  @event
  InitParallelismState _onReset() {
    return const InitParallelismState();
  }
}
