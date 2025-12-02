import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';

part 'error_handler_bloc.g.dart';

/// Demonstrates error handler patterns
@MonoBloc()
class ErrorHandlerBloc extends _$ErrorHandlerBloc<int> {
  ErrorHandlerBloc() : super(0);

  // ============================================================================
  // SECTION 1: PARAMETER PATTERNS (Void handlers - side effects only)
  // ============================================================================

  /// No parameters - just for side effects
  @onError
  void _onErrorNoParams() {
    print('Error handler with no params');
  }

  /// Only Object error parameter
  @onError
  void _onErrorErrorParam(Object error) {
    print('Error: $error');
  }

  /// Error and StackTrace (most common pattern)
  @onError
  void _onErrorErrorAndStack(Object error, StackTrace stack) {
    print('Error: $error, Stack: $stack');
  }

  // ============================================================================
  // SECTION 2: RETURN TYPE PATTERNS (All use Object error parameter)
  // ============================================================================

  /// Returns nullable state - can choose to emit or not
  @onError
  int? _onErrorNullableReturn(Object error) {
    print('Nullable return: $error');
    if (error.toString().contains('recoverable')) {
      return 999; // Emit error state with data
    }
    return null; // Don't emit
  }

  /// Returns non-null state - always emits error state
  @onError
  int _onErrorNonNullReturn(Object error) {
    print('Non-null return: $error');
    return 777; // Always emit error state with this data
  }

  // ============================================================================
  // EVENTS
  // ============================================================================

  @event
  Future<int> _onNoParams() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    throw Exception('Error for no params handler');
  }

  @event
  Future<int> _onErrorParam() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    throw Exception('Error for error param handler');
  }

  @event
  Future<int> _onErrorAndStack() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    throw Exception('Error for error+stack handler');
  }

  @event
  Future<int> _onNullableReturn() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    throw Exception('recoverable error');
  }

  @event
  Future<int> _onNonNullReturn() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    throw Exception('Error for non-null return');
  }

  @event
  Future<int> _onSuccess(int value) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return value;
  }
}
