import 'package:bloc/bloc.dart';
import 'package:mono_bloc/src/async/mono_async_value.dart';

/// Wrapper around Emitter that provides convenient methods for async operations.
class MonoAsyncSeqEmitter<S> {
  /// Creates a MonoAsyncEmitter wrapping the given emitter and bloc.
  ///
  /// The bloc reference is used to always read the current state,
  /// not a stale captured state from when the handler started.
  MonoAsyncSeqEmitter(this._emitter, this._bloc);

  /// The underlying emitter to emit states.
  final Emitter<MonoAsyncValue<S>> _emitter;

  /// The bloc reference to read the current state.
  final Bloc<dynamic, MonoAsyncValue<S>> _bloc;

  /// Emit a loading state while preserving CURRENT data.
  ///
  /// This reads the current bloc state, not a state captured
  /// at handler start, avoiding the "restore old state" bug.
  void loading() {
    final data = _bloc.state.dataOrNull;
    _emitter(MonoAsyncValue<S>(data, true, null, null));
  }

  /// Emit a loading state with cleared data
  void loadingClearData() {
    _emitter(const MonoAsyncValue.loading());
  }

  /// Emit a data state (success)
  void call(S data) {
    _emitter(MonoAsyncValue.withData(data));
  }

  /// Emit an error state while preserving CURRENT data.
  ///
  /// This reads the current bloc state, not a state captured
  /// at handler start, avoiding the "restore old state" bug.
  void error(Object error, StackTrace stackTrace) {
    final data = _bloc.state.dataOrNull;
    _emitter(MonoAsyncValue.withError(error, stackTrace, data));
  }

  /// Whether the emitter is done (canceled or completed)
  bool get isDone => _emitter.isDone;
}

class MonoAsyncEmitter<S> extends MonoAsyncSeqEmitter<S> {
  /// Creates a MonoAsyncEmitter wrapping the given emitter and bloc.
  ///
  /// The bloc reference is used to always read the current state,
  /// not a stale captured state from when the handler started.
  MonoAsyncEmitter(super._emitter, super._bloc);

  /// Emit an error state with cleared data
  Future<void> forEach<T>(
    Stream<T> stream, {
    required MonoAsyncValue<S> Function(T data) onData,
    MonoAsyncValue<S> Function(Object error, StackTrace stackTrace)? onError,
  }) {
    return _emitter.forEach<T>(stream, onData: onData, onError: onError);
  }

  /// Listen to a stream and handle data and errors.
  Future<void> onEach<T>(
    Stream<T> stream, {
    required void Function(T data) onData,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    return _emitter.onEach<T>(stream, onData: onData, onError: onError);
  }
}
