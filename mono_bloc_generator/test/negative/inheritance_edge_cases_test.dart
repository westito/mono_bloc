import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - Inheritance Edge Cases', () {
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

    test('should reject class not extending generated base', () async {
      const source = '''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends Bloc<Object, TestState> {
          SimpleBloc() : super(TestState());
          
          @event
          TestState _onEvent() => TestState();
        }
      ''';

      await expectLater(
        generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains(r'must extend _$SimpleBloc'),
          ),
        ),
      );
    });

    test('should reject class extending wrong base class name', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$WrongBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @event
          TestState _onEvent() => TestState();
        }
      ''';

      await expectLater(
        generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains(r'must extend _$SimpleBloc'),
          ),
        ),
      );
    });

    test('should reject bloc without State generic parameter', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc {
          SimpleBloc() : super(TestState());
          
          @event
          TestState _onEvent() => TestState();
        }
      ''';

      await expectLater(
        generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains(r'must extend _$SimpleBloc<State>'),
          ),
        ),
      );
    });

    test('should handle abstract bloc with generic type parameters', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoBloc()
        abstract class BaseBloc<T> extends _$BaseBloc<T> {
          BaseBloc(super.initialState);
          
          @event
          T _onEvent();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, isNotEmpty);
    });

    test('should handle class extending another MonoBloc class', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class BaseBloc extends _$BaseBloc<TestState> {
          BaseBloc() : super(TestState());
          
          @event
          TestState _onEvent() => TestState();
        }
        
        class ChildBloc extends BaseBloc {
          ChildBloc() : super();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, isNotEmpty);
    });

    test('should handle actions from mixin on concrete class', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoActions()
        mixin _TestBlocActions {
          void navigate(String route);
        }
        
        @MonoBloc()
        class TestBloc extends _$TestBloc<int> {
          TestBloc() : super(0);
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('_NavigateAction'));
      expect(generated, contains('void navigate(String route)'));
    });

    test('should handle bloc with implements clause', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        abstract class TestInterface {
          void doSomething();
        }
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> implements TestInterface {
          SimpleBloc() : super(TestState());
          
          @event
          TestState _onEvent() => TestState();
          
          @override
          void doSomething() {}
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, isNotEmpty);
    });

    test('should handle bloc with with clause (mixin)', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        mixin LoggerMixin {
          void log(String message) {}
        }
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> with LoggerMixin {
          SimpleBloc() : super(TestState());
          
          @event
          TestState _onEvent() {
            log('Event triggered');
            return TestState();
          }
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, isNotEmpty);
    });

    test('should handle bloc with both mixin and implements', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        mixin LoggerMixin {
          void log(String message) {}
        }
        
        abstract class TestInterface {
          void doSomething();
        }
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> 
            with LoggerMixin 
            implements TestInterface {
          SimpleBloc() : super(TestState());
          
          @event
          TestState _onEvent() => TestState();
          
          @override
          void doSomething() {}
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, isNotEmpty);
    });

    test('should reject class with wrong base class pattern', () async {
      const source = '''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        abstract class CustomBase<T> extends Bloc<Object, T> {
          CustomBase(super.initialState);
        }
        
        @MonoBloc()
        class SimpleBloc extends CustomBase<TestState> {
          SimpleBloc() : super(TestState());
          
          @event
          TestState _onEvent() => TestState();
        }
      ''';

      await expectLater(
        generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains(r'must extend _$SimpleBloc'),
          ),
        ),
      );
    });
  });
}
