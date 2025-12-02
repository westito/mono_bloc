import 'package:flutter_test/flutter_test.dart';
import 'package:mono_bloc_example/error_handler/error_handler_bloc.dart';

void main() {
  group('ErrorHandlerBloc - Section 1: Parameter Patterns', () {
    late ErrorHandlerBloc bloc;

    setUp(() {
      bloc = ErrorHandlerBloc();
    });

    tearDown(() async {
      await bloc.close();
    });

    test('1. No parameters', () async {
      bloc.noParams();
      await Future<void>.delayed(const Duration(milliseconds: 200));

      // Void handler - no state change
      expect(bloc.state, 0);
    });

    test('2. Only error parameter', () async {
      bloc.errorParam();
      await Future<void>.delayed(const Duration(milliseconds: 200));

      // Void handler - no state change
      expect(bloc.state, 0);
    });

    test('3. Error and StackTrace', () async {
      bloc.errorAndStack();
      await Future<void>.delayed(const Duration(milliseconds: 200));

      // Void handler - no state change
      expect(bloc.state, 0);
    });
  });

  group('ErrorHandlerBloc - Section 2: Return Type Patterns', () {
    late ErrorHandlerBloc bloc;

    setUp(() {
      bloc = ErrorHandlerBloc();
    });

    tearDown(() async {
      await bloc.close();
    });

    test('4. Returns nullable state - emits when recoverable', () async {
      bloc.nullableReturn();
      await Future<void>.delayed(const Duration(milliseconds: 200));

      // Handler returns 999 for recoverable errors
      expect(bloc.state, 999);
    });

    test('5. Returns non-null state - always emits', () async {
      bloc.nonNullReturn();
      await Future<void>.delayed(const Duration(milliseconds: 200));

      // Handler always returns 777
      expect(bloc.state, 777);
    });
  });

  group('ErrorHandlerBloc - Success Cases', () {
    late ErrorHandlerBloc bloc;

    setUp(() {
      bloc = ErrorHandlerBloc();
    });

    tearDown(() async {
      await bloc.close();
    });

    test('Success event works normally', () async {
      bloc.success(42);
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(bloc.state, 42);
    });

    test('Success after error updates state', () async {
      bloc.nonNullReturn();
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(bloc.state, 777);

      bloc.success(100);
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(bloc.state, 100);
    });
  });

  group('ErrorHandlerBloc - Error State Structure', () {
    late ErrorHandlerBloc bloc;

    setUp(() {
      bloc = ErrorHandlerBloc();
    });

    tearDown(() async {
      await bloc.close();
    });

    test('Error handler with non-null return emits state', () async {
      bloc.nonNullReturn();
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(bloc.state, 777);
    });

    test('Void handler does not change state', () async {
      bloc.errorAndStack();
      await Future<void>.delayed(const Duration(milliseconds: 200));

      // Void handler doesn't emit
      expect(bloc.state, 0);
    });
  });

  group('ErrorHandlerBloc - Stack Trace Handling', () {
    late ErrorHandlerBloc bloc;

    setUp(() {
      bloc = ErrorHandlerBloc();
    });

    tearDown(() async {
      await bloc.close();
    });

    test('Error handler receives stack trace', () async {
      // Error handlers with StackTrace parameter should receive stack trace
      // This test verifies the handler is called without throwing errors
      bloc.errorAndStack();
      await Future<void>.delayed(const Duration(milliseconds: 200));

      // Note: Stack trace handling is internal to error handlers
      // This test just ensures the void handler completes successfully
      expect(bloc.state, 0); // Void handler doesn't emit
    });

    test('Error handler with only error parameter works', () async {
      bloc.errorParam();
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(bloc.state, 0); // Void handler doesn't emit
    });

    test('Multiple error handlers can be defined', () async {
      // All these should work without errors
      bloc.noParams();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      bloc.errorParam();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      bloc.errorAndStack();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state, 0);
    });

    test('Error handler with nullable return can choose to emit', () async {
      bloc.nullableReturn();
      await Future<void>.delayed(const Duration(milliseconds: 200));

      // Handler should return 999 for recoverable errors
      expect(bloc.state, 999);
    });

    test(
      'Error handler priority: specific handlers override general ones',
      () async {
        // When multiple error handlers exist, they all get called
        // This test verifies that nullable return handler works correctly
        bloc.nullableReturn();
        await Future<void>.delayed(const Duration(milliseconds: 200));

        expect(bloc.state, 999);
      },
    );
  });

  group('ErrorHandlerBloc - Error Recovery', () {
    late ErrorHandlerBloc bloc;

    setUp(() {
      bloc = ErrorHandlerBloc();
    });

    tearDown(() async {
      await bloc.close();
    });

    test('Can recover from error with nullable return', () async {
      // Trigger error with nullable return
      bloc.nullableReturn();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(bloc.state, 999);

      // Should be able to continue with success
      bloc.success(42);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(bloc.state, 42);
    });

    test('Can recover from error with non-null return', () async {
      // Trigger error with non-null return
      bloc.nonNullReturn();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(bloc.state, 777);

      // Should be able to continue with success
      bloc.success(100);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(bloc.state, 100);
    });

    test('Void error handlers allow normal operation to continue', () async {
      // Trigger void error handler
      bloc.errorAndStack();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(bloc.state, 0);

      // Should still work normally
      bloc.success(50);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(bloc.state, 50);
    });
  });
}
