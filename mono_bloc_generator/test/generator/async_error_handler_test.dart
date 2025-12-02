import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - Async Error Handler Generation', () {
    late MonoBlocGenerator generator;

    setUp(() {
      generator = MonoBlocGenerator();
    });

    Future<String> generateForSource(String source) {
      return resolveSources({...mockPackages, 'pkg|lib/test.dart': source}, (
        resolver,
      ) async {
        final lib = await resolver.libraryFor(
          AssetId.parse('pkg|lib/test.dart'),
        );
        final generated = await generator.generate(
          LibraryReader(lib),
          MockBuildStep(),
        );
        return generated;
      });
    }

    test(
      'should generate error handler with null when no error handler defined',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @AsyncMonoBloc()
        class TestBloc extends _$TestBloc<String> {
          TestBloc() : super(const MonoAsyncValue.withData(''));
          
          @event
          Future<String> _onLoad() async => 'data';
        }
      ''';

        final result = await generateForSource(source);

        // Should emit error with preserved data when no error handler is defined
        expect(
          result,
          contains('emit(withError(error, stack, bloc.state.dataOrNull));'),
        );
        expect(result, isNot(contains('_onError')));
      },
    );

    test('should use global error handler when defined', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @AsyncMonoBloc()
        class TestBloc extends _$TestBloc<String> {
          TestBloc() : super(const MonoAsyncValue.withData(''));
          
          @event
          Future<String> _onLoad() async => 'data';
          
          @onError
          String _onError(Object error, StackTrace stackTrace) => 'fallback';
        }
      ''';

      final result = await generateForSource(source);

      // Should use global error handler
      expect(result, contains('final data = _onError(error, stack);'));
      expect(result, contains('emit(withError(error, stack, data));'));
      expect(
        result,
        isNot(
          contains('emit(withError(error, stack, bloc.state.dataOrNull));'),
        ),
      );
    });

    test('should use event-specific error handler when defined', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @AsyncMonoBloc()
        class TestBloc extends _$TestBloc<String> {
          TestBloc() : super(const MonoAsyncValue.withData(''));
          
          @event
          Future<String> _onLoad() async => 'data';
          
          @onError
          String _onErrorLoad(Object error, StackTrace stackTrace) => 'specific';
          
          @onError
          String _onError(Object error, StackTrace stackTrace) => 'general';
        }
      ''';

      final result = await generateForSource(source);

      // Should use event-specific error handler for Load event
      expect(result, contains('final data = _onErrorLoad(error, stack);'));
      expect(result, contains('emit(withError(error, stack, data));'));
    });

    test(
      'should generate nullable return for event-specific error handler',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @AsyncMonoBloc()
        class TestBloc extends _$TestBloc<String> {
          TestBloc() : super(const MonoAsyncValue.withData(''));
          
          @event
          Future<String> _onLoad() async => 'data';
          
          @event
          Future<String> _onSave() async => 'saved';
          
          @onError
          String? _onErrorLoad(Object error, StackTrace stackTrace) => null;
          
          @onError
          String _onError(Object error, StackTrace stackTrace) => 'fallback';
        }
      ''';

        final result = await generateForSource(source);

        // Load event should use specific handler that returns nullable
        expect(result, contains('_LoadEvent'));
        expect(result, contains('final data = _onErrorLoad(error, stack);'));

        // Save event should use general handler
        expect(result, contains('_SaveEvent'));
        expect(result, contains('final data = _onError(error, stack);'));
      },
    );

    test(
      'should handle multiple events with different error handlers',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @AsyncMonoBloc()
        class TestBloc extends _$TestBloc<int> {
          TestBloc() : super(const MonoAsyncValue.withData(0));
          
          @event
          Future<int> _onLoad() async => 1;
          
          @event
          Future<int> _onSave() async => 2;
          
          @event
          Future<int> _onDelete() async => 3;
          
          @onError
          int? _onErrorLoad(Object error, StackTrace stackTrace) => null;
          
          @onError
          int _onErrorSave(Object error, StackTrace stackTrace) => 0;
          
          @onError
          int _onError(Object error, StackTrace stackTrace) => -1;
        }
      ''';

        final result = await generateForSource(source);

        // Each event should use its specific error handler if available
        expect(result, contains('_LoadEvent'));
        expect(result, contains('_onErrorLoad(error, stack)'));

        expect(result, contains('_SaveEvent'));
        expect(result, contains('_onErrorSave(error, stack)'));

        // Delete should use general error handler
        expect(result, contains('_DeleteEvent'));
        expect(result, contains('_onError(error, stack)'));
      },
    );

    test(
      'should generate error handler for sync methods in async mode',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @AsyncMonoBloc()
        class TestBloc extends _$TestBloc<int> {
          TestBloc() : super(const MonoAsyncValue.withData(0));
          
          @event
          int _onIncrement() => 1;
          
          @onError
          int _onError(Object error, StackTrace stackTrace) => 0;
        }
      ''';

        final result = await generateForSource(source);

        // Sync method should also have error handling
        expect(result, contains('_IncrementEvent'));
        expect(result, contains('try {'));
        expect(result, contains('_onIncrement()'));
        expect(result, contains('catch (error, stackTrace)'));
        expect(result, contains('final data = _onError(error, stack);'));
      },
    );

    test(
      'should generate error handler for Stream methods in async mode',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @AsyncMonoBloc()
        class TestBloc extends _$TestBloc<int> {
          TestBloc() : super(const MonoAsyncValue.withData(0));
          
          @event
          Stream<MonoAsyncValue<int>> _onCount() async* {
            yield const MonoAsyncValue.withData(1);
          }
        }
      ''';

        final result = await generateForSource(source);

        // Stream method should use emit.forEach for proper handling
        expect(result, contains('_CountEvent'));
        expect(result, contains('emit.forEach<MonoAsyncValue<int>>'));
        expect(result, contains('_onCount()'));
      },
    );

    test(
      'should generate error handler for void emitter methods in async mode',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @AsyncMonoBloc()
        class TestBloc extends _$TestBloc<int> {
          TestBloc() : super(const MonoAsyncValue.withData(0));
          
          @event
          Future<void> _onUpdate(MonoAsyncEmitter<int> emit) async {
            emit(42);
          }
          
          @onError
          int _onError(Object error, StackTrace stackTrace) => -1;
        }
      ''';

        final result = await generateForSource(source);

        // Void emitter method should have error handling
        expect(result, contains('_UpdateEvent'));
        expect(result, contains(r'_$wrapEmit(emit, bloc.state)'));
        expect(result, contains('await _onUpdate('));
        expect(result, contains('catch (error, stackTrace)'));
        expect(result, contains('final data = _onError(error, stack);'));
      },
    );

    test('should handle error handler with nullable return type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @AsyncMonoBloc()
        class TestBloc extends _$TestBloc<String> {
          TestBloc() : super(const MonoAsyncValue.withData(''));
          
          @event
          Future<String> _onLoad() async => 'data';
          
          @onError
          String? _onError(Object error, StackTrace stackTrace) => null;
        }
      ''';

      final result = await generateForSource(source);

      // Should call error handler even if it returns nullable
      expect(result, contains('final data = _onError(error, stack);'));
      expect(result, contains('emit(withError(error, stack, data));'));
    });
  });
}
