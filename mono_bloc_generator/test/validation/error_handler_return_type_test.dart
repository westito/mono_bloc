import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - Error Handler Return Type Validation', () {
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

    test('should reject error handler with Future<void> return type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class TestState {
          const TestState(this.value);
          final int value;
        }
        
        typedef _Emitter = Emitter<TestState>;
        
        @MonoBloc()
        class CounterBloc extends _$CounterBloc<TestState> {
          CounterBloc() : super(const TestState(0));
          
          @event
          TestState _onIncrement() => TestState(0);
          
          @onError
          Future<void> _onError(Object error, StackTrace stack) async {
            // Invalid: Future<void> not allowed
          }
        }
      ''';

      await expectLater(
        generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            allOf([
              contains('must return'),
              contains('TestState'),
              contains('void'),
            ]),
          ),
        ),
      );
    });

    test('should reject error handler with Stream return type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class TestState {
          const TestState(this.value);
          final int value;
        }
        
        typedef _Emitter = Emitter<TestState>;
        
        @MonoBloc()
        class CounterBloc extends _$CounterBloc<TestState> {
          CounterBloc() : super(const TestState(0));
          
          @event
          TestState _onIncrement() => TestState(0);
          
          @onError
          Stream<TestState> _onError(Object error, StackTrace stack) async* {
            // Invalid: Stream not allowed
            yield TestState(0);
          }
        }
      ''';

      await expectLater(
        generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            allOf([contains('must return'), contains('TestState')]),
          ),
        ),
      );
    });

    test('should accept error handler with void return type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class TestState {
          const TestState(this.value);
          final int value;
        }
        
        typedef _Emitter = Emitter<TestState>;
        
        @MonoBloc()
        class CounterBloc extends _$CounterBloc<TestState> {
          CounterBloc() : super(const TestState(0));
          
          @event
          TestState _onIncrement() => TestState(0);
          
          @onError
          void _onError(Object error, StackTrace stack) {
            // Valid: void is allowed
          }
        }
      ''';

      final result = await generateForSource(source);
      expect(result, isNotEmpty);
    });

    test('should accept error handler with State return type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class TestState {
          const TestState(this.value);
          final int value;
        }
        
        typedef _Emitter = Emitter<TestState>;
        
        @MonoBloc()
        class CounterBloc extends _$CounterBloc<TestState> {
          CounterBloc() : super(const TestState(0));
          
          @event
          TestState _onIncrement() => TestState(0);
          
          @onError
          TestState _onError(Object error, StackTrace stack) {
            // Valid: State is allowed
            return const TestState(-1);
          }
        }
      ''';

      final result = await generateForSource(source);
      expect(result, isNotEmpty);
    });

    test('should accept error handler with State? return type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class TestState {
          const TestState(this.value);
          final int value;
        }
        
        typedef _Emitter = Emitter<TestState>;
        
        @MonoBloc()
        class CounterBloc extends _$CounterBloc<TestState> {
          CounterBloc() : super(const TestState(0));
          
          @event
          TestState _onIncrement() => TestState(0);
          
          @onError
          TestState? _onError(Object error, StackTrace stack) {
            // Valid: State? is allowed
            return null;
          }
        }
      ''';

      final result = await generateForSource(source);
      expect(result, isNotEmpty);
    });

    test(
      'should reject error handler with Future<State> return type',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class TestState {
          const TestState(this.value);
          final int value;
        }
        
        typedef _Emitter = Emitter<TestState>;
        
        @MonoBloc()
        class CounterBloc extends _$CounterBloc<TestState> {
          CounterBloc() : super(const TestState(0));
          
          @event
          TestState _onIncrement() => TestState(0);
          
          @onError
          Future<TestState> _onError(Object error, StackTrace stack) async {
            // Invalid: Future<State> not allowed - error handlers must be synchronous
            return const TestState(-1);
          }
        }
      ''';

        await expectLater(
          generateForSource(source),
          throwsA(
            isA<InvalidGenerationSourceError>().having(
              (e) => e.message,
              'message',
              allOf([contains('must return'), contains('TestState')]),
            ),
          ),
        );
      },
    );

    test(
      'should reject error handler with Future<State?> return type',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class TestState {
          const TestState(this.value);
          final int value;
        }
        
        typedef _Emitter = Emitter<TestState>;
        
        @MonoBloc()
        class CounterBloc extends _$CounterBloc<TestState> {
          CounterBloc() : super(const TestState(0));
          
          @event
          TestState _onIncrement() => TestState(0);
          
          @onError
          Future<TestState?> _onError(Object error, StackTrace stack) async {
            // Invalid: Future<State?> not allowed - error handlers must be synchronous
            return null;
          }
        }
      ''';

        await expectLater(
          generateForSource(source),
          throwsA(
            isA<InvalidGenerationSourceError>().having(
              (e) => e.message,
              'message',
              allOf([contains('must return'), contains('TestState')]),
            ),
          ),
        );
      },
    );

    test('should reject error handler with int return type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class TestState {
          const TestState(this.value);
          final int value;
        }
        
        typedef _Emitter = Emitter<TestState>;
        
        @MonoBloc()
        class CounterBloc extends _$CounterBloc<TestState> {
          CounterBloc() : super(const TestState(0));
          
          @event
          TestState _onIncrement() => TestState(0);
          
          @onError
          int _onError(Object error, StackTrace stack) {
            // Invalid: int is not allowed
            return 0;
          }
        }
      ''';

      await expectLater(
        generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            allOf([contains('must return'), contains('TestState')]),
          ),
        ),
      );
    });

    test('should reject error handler with Future<int> return type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class TestState {
          const TestState(this.value);
          final int value;
        }
        
        typedef _Emitter = Emitter<TestState>;
        
        @MonoBloc()
        class CounterBloc extends _$CounterBloc<TestState> {
          CounterBloc() : super(const TestState(0));
          
          @event
          TestState _onIncrement() => TestState(0);
          
          @onError
          Future<int> _onError(Object error, StackTrace stack) async {
            // Invalid: Future<int> is not allowed
            return 0;
          }
        }
      ''';

      await expectLater(
        generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            allOf([contains('must return'), contains('TestState')]),
          ),
        ),
      );
    });

    test(
      'should accept event-specific error handler with valid return type',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class TestState {
          const TestState(this.value);
          final int value;
        }
        
        typedef _Emitter = Emitter<TestState>;
        
        @MonoBloc()
        class CounterBloc extends _$CounterBloc<TestState> {
          CounterBloc() : super(const TestState(0));
          
          @event
          TestState _onIncrement() => TestState(0);
          
          @onError
          TestState? _onErrorIncrement(Object error, StackTrace stack) {
            // Valid: event-specific error handler with State?
            return null;
          }
        }
      ''';

        final result = await generateForSource(source);
        expect(result, isNotEmpty);
      },
    );

    test(
      'should reject event-specific error handler with Future<void>',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class TestState {
          const TestState(this.value);
          final int value;
        }
        
        typedef _Emitter = Emitter<TestState>;
        
        @MonoBloc()
        class CounterBloc extends _$CounterBloc<TestState> {
          CounterBloc() : super(const TestState(0));
          
          @event
          TestState _onIncrement() => TestState(0);
          
          @onError
          Future<void> _onErrorIncrement(Object error, StackTrace stack) async {
            // Invalid: Future<void> not allowed for event-specific handlers
          }
        }
      ''';

        await expectLater(
          generateForSource(source),
          throwsA(
            isA<InvalidGenerationSourceError>().having(
              (e) => e.message,
              'message',
              allOf([contains('must return'), contains('TestState')]),
            ),
          ),
        );
      },
    );
  });
}
