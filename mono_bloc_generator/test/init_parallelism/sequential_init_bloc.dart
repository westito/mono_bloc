import 'package:mono_bloc/mono_bloc.dart';

import 'init_parallelism_state.dart';

part 'sequential_init_bloc.g.dart';

/// Sequential bloc - @onInit methods run sequentially
/// First declared (initA) should complete FIRST, regardless of delay
@MonoBloc(sequential: true)
class SequentialInitBloc extends _$SequentialInitBloc<InitParallelismState> {
  SequentialInitBloc() : super(const InitParallelismState());

  /// Longest delay - 150ms, but runs first
  @onInit
  Future<InitParallelismState> _initA() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return state.copyWith(executionOrder: [...state.executionOrder, 'A']);
  }

  /// Medium delay - 100ms, runs second
  @onInit
  Future<InitParallelismState> _initB() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return state.copyWith(executionOrder: [...state.executionOrder, 'B']);
  }

  /// Shortest delay - 50ms, runs last
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
