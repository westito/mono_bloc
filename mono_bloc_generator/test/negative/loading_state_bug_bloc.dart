import 'package:mono_bloc/mono_bloc.dart';

part 'loading_state_bug_bloc.g.dart';

/// State for testing loading() bug
@immutable
class LoadingBugState {
  const LoadingBugState({required this.counter});

  final int counter;

  LoadingBugState copyWith({int? counter}) {
    return LoadingBugState(counter: counter ?? this.counter);
  }

  @override
  String toString() => 'LoadingBugState(counter: $counter)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadingBugState &&
          runtimeType == other.runtimeType &&
          counter == other.counter;

  @override
  int get hashCode => counter.hashCode;
}

/// This bloc demonstrates the bug where loading() restores old state
///
/// SCENARIO:
/// 1. Bloc starts with state counter=0
/// 2. Event handler starts, wrapEmit captures state(counter=0) in _currentState
/// 3. Event handler calls emit(counter=1) - updates bloc state to counter=1
/// 4. Event handler calls loading() - BUG! Uses _currentState (counter=0), not current state (counter=1)
/// 5. Result: counter reverts from 1 back to 0!
@AsyncMonoBloc()
class LoadingStateBugBloc extends _$LoadingStateBugBloc<LoadingBugState> {
  LoadingStateBugBloc()
    : super(const MonoAsyncValue.withData(LoadingBugState(counter: 0)));

  @event
  Future<void> _onIncrementThenLoad(_Emitter emit) async {
    // Step 1: Increment counter
    emit(state.dataOrNull!.copyWith(counter: state.dataOrNull!.counter + 1));

    // Step 2: Call loading() - BUG: This should preserve counter=1, but restores counter=0!
    emit.loading();

    await Future<void>.delayed(const Duration(milliseconds: 100));

    // Step 3: Complete with final value
    emit(state.dataOrNull!.copyWith(counter: state.dataOrNull!.counter + 1));
  }
}
