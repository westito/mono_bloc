import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - Error Handler Generation', () {
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

    test('should generate general error handler', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class MyState {
          const MyState();
        }
        
        @MonoBloc()
        class MyBloc extends _$MyBloc<MyState> {
          MyBloc() : super(const MyState());
          
          @event
          MyState _onIncrement() => const MyState();
          
          @onError
          MyState _onError(Object error, StackTrace stackTrace) {
            return const MyState();
          }
        }
      ''';

      final result = await generateForSource(source);
      expect(result, contains('try {'));
      expect(result, contains('catch (e, s)'));
      expect(result, contains('emit(_onError(e, stack))'));
    });

    test('should generate event-specific error handler', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class MyState {
          const MyState();
        }
        
        @MonoBloc()
        class MyBloc extends _$MyBloc<MyState> {
          MyBloc() : super(const MyState());
          
          @event
          MyState _onLoad() => const MyState();
          
          @onError
          MyState _onErrorLoad(Object error, StackTrace stackTrace) {
            return const MyState();
          }
        }
      ''';

      final result = await generateForSource(source);
      expect(result, contains('emit(_onLoad())'));
      expect(result, contains('emit(_onErrorLoad(e, stack))'));
    });

    test('should throw error when error handler has Future<void> return', () {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class MyState {
          const MyState();
        }
        
        typedef _Emitter = Emitter<MyState>;
        
        @MonoBloc()
        class MyBloc extends _$MyBloc<MyState> {
          MyBloc() : super(const MyState());
          
          @event
          Future<void> _onLoad(_Emitter emit) async {
            emit(const MyState());
          }
          
          @onError
          Future<void> _onError(
            _Emitter emit,
            Object error,
            StackTrace stackTrace,
          ) async {
            emit(const MyState());
          }
        }
      ''';

      expect(
        () => generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains('must return "MyState", "MyState?", or "void"'),
          ),
        ),
      );
    });

    test('should throw error when error handler returns Future<State>', () {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class MyState {
          const MyState();
        }
        
        @MonoBloc()
        class MyBloc extends _$MyBloc<MyState> {
          MyBloc() : super(const MyState());
          
          @event
          Future<MyState> _onLoad() async => const MyState();
          
          @onError
          Future<MyState> _onError(Object error, StackTrace stackTrace) async {
            return const MyState();
          }
        }
      ''';

      expect(
        () => generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains('must return "MyState", "MyState?", or "void"'),
          ),
        ),
      );
    });

    test('should throw error when method has both @event and @onError', () {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class MyState {
          const MyState();
        }
        
        @MonoBloc()
        class MyBloc extends _$MyBloc<MyState> {
          MyBloc() : super(const MyState());
          
          @event
          @onError
          MyState _onLoad() => const MyState();
        }
      ''';

      expect(
        () => generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains('cannot have both @event and @onError'),
          ),
        ),
      );
    });

    test('should throw error when error handler returns Stream', () {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class MyState {
          const MyState();
        }
        
        @MonoBloc()
        class MyBloc extends _$MyBloc<MyState> {
          MyBloc() : super(const MyState());
          
          @event
          MyState _onLoad() => const MyState();
          
          @onError
          Stream<MyState> _onError(Object error, StackTrace stackTrace) async* {
            yield const MyState();
          }
        }
      ''';

      expect(
        () => generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains('must return "MyState", "MyState?", or "void"'),
          ),
        ),
      );
    });

    test(
      'should generate default error handler with stack filtering',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class MyState {
          const MyState();
        }
        
        @MonoBloc()
        class MyBloc extends _$MyBloc<MyState> {
          MyBloc() : super(const MyState());
          
          @event
          MyState _onIncrement() => const MyState();
        }
      ''';

        final result = await generateForSource(source);
        // Always wrap with try-catch for stack trace filtering
        expect(result, contains('try {'));
        expect(result, contains('catch (e, s)'));
        // Uses _$stack to filter the stack trace
        expect(result, contains(r'_$stack(event.trace, s)'));
        // Calls bloc.onError with filtered stack
        expect(result, contains('bloc.onError(e, stack)'));
        // Rethrows the error
        expect(result, contains('rethrow'));
      },
    );

    test(
      'should use event-specific error handler over general handler',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class MyState {
          const MyState(this.message);
          final String message;
        }
        
        @MonoBloc()
        class MyBloc extends _$MyBloc<MyState> {
          MyBloc() : super(const MyState('initial'));
          
          @event
          MyState _onLoad() => const MyState('loaded');
          
          @onError
          MyState _onError(Object error, StackTrace stackTrace) {
            return const MyState('general error');
          }
          
          @onError
          MyState _onErrorLoad(Object error, StackTrace stackTrace) {
            return const MyState('load error');
          }
        }
      ''';

        final result = await generateForSource(source);
        // Event-specific handler should be called for _onLoad
        expect(result, contains('emit(_onErrorLoad(e, stack))'));
      },
    );
  });
}
