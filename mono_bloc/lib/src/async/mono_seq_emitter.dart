import 'package:bloc/bloc.dart';

/// Extension type that wraps Emitter for sequential blocs.
///
/// This type explicitly EXCLUDES `forEach` and `onEach` methods to prevent
/// deadlock in sequential blocs. In sequential mode, only one event can
/// process at a time. Using forEach/onEach would block the sequential queue
/// waiting for a stream that may never complete.
///
/// For non-sequential blocs, use the standard [Emitter] directly.
extension type MonoSeqEmitter<State>(Emitter<State> _emitter) {
  /// Emit a new state.
  void call(State state) => _emitter(state);

  /// Whether the emitter is done (canceled or completed).
  bool get isDone => _emitter.isDone;
}
