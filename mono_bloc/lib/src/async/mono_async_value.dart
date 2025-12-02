import 'package:mono_bloc/mono_bloc.dart';

/// Represents an asynchronous operation state with loading, data, or error.
/// Similar to AsyncSnapshot but with additional error handling utilities.
@immutable
class MonoAsyncValue<T> {
  /// Internal constructor for creating custom async states
  const MonoAsyncValue(
    this._data,
    this.isLoading,
    this._error,
    this.stackTrace,
  );

  /// Creates a loading state without data.
  const MonoAsyncValue.loading() : this(null, true, null, null);

  /// Creates a success state with [data].
  const MonoAsyncValue.withData(T data) : this(data, false, null, null);

  /// Creates an error state with [error] and [stackTrace].
  /// Optionally includes [data] from previous successful state.
  const MonoAsyncValue.withError(Object error, StackTrace stackTrace, [T? data])
    : this(data, false, error, stackTrace);

  /// The data value if available.
  final T? _data;

  /// Returns data if available, otherwise null.
  T? get dataOrNull => _data;

  /// Returns data if available, throws error if present, or throws StateError.
  T get data {
    if (hasData) {
      return _data!;
    }

    if (hasError) {
      Error.throwWithStackTrace(error, stackTrace ?? StackTrace.current);
    }

    if (isLoading) {
      throw StateError('Data is still loading');
    }

    throw StateError('Snapshot has neither data nor error and is not loading');
  }

  /// The error object if an error occurred.
  final Object? _error;

  /// Getter for error to avoid name conflict with data property.
  Object? get errorOrNull => _error;

  /// The stack trace associated with the error.
  final StackTrace? stackTrace;

  /// Returns the error object if present, throws StateError otherwise.
  Object get error {
    if (_error != null) {
      return _error;
    }

    throw StateError('No error present');
  }

  /// True if the async operation is in progress.
  final bool isLoading;

  /// True if data is available.
  bool get hasData => _data != null;

  /// True if an error occurred.
  bool get hasError => _error != null;

  /// Returns formatted error message from Exception or error.toString().
  String get errorMessage {
    if (hasError) {
      return error.toString();
    }
    return '';
  }

  /// Pattern matching for AsyncValue states.
  R when<R>({
    required R Function() loading,
    required R Function(Object error, StackTrace? stackTrace) error,
    required R Function(T data) data,
  }) {
    if (isLoading) {
      return loading();
    }
    if (hasError) {
      return error(this.error, stackTrace);
    }
    if (hasData) {
      return data(_data as T);
    }

    throw StateError('Snapshot has neither data nor error and is not loading');
  }

  /// Creates a new AsyncValue with updated data.
  MonoAsyncValue<R> withData<R>(R data) =>
      MonoAsyncValue(data, isLoading, _error, stackTrace);

  /// Creates a new AsyncValue with updated loading state.
  MonoAsyncValue<R> withLoading<R>({required bool isLoading}) => MonoAsyncValue(
    hasData ? _data as R : null,
    isLoading,
    _error,
    stackTrace,
  );

  /// Creates a new AsyncValue with updated error state.
  MonoAsyncValue<R> withError<R>(Object error, StackTrace stackTrace) =>
      MonoAsyncValue(hasData ? _data as R : null, false, error, stackTrace);

  @override
  String toString() =>
      'MonoAsyncValue<$T>(data: $_data, isLoading: $isLoading, error: $_error)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is MonoAsyncValue<T> &&
        other._data == _data &&
        other.isLoading == isLoading &&
        other._error == _error &&
        other.stackTrace == stackTrace;
  }

  @override
  int get hashCode => Object.hash(_data, isLoading, _error);
}
