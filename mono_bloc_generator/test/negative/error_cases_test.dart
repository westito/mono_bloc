import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - Error Cases', () {
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

    test('should throw error when public method has @MonoEvent annotation', () {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent()
          TestState publicMethod() => TestState();
        }
      ''';

      expect(
        () => generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains('Public @event methods MUST have BOTH'),
          ),
        ),
      );
    });

    test(
      'should throw error when State type is not provided in generic parameter',
      () {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc {
          SimpleBloc() : super(TestState());
          
          @event
          TestState _onIncrement() => TestState();
        }
      ''';

        expect(
          () => generateForSource(source),
          throwsA(
            isA<InvalidGenerationSourceError>().having(
              (e) => e.message,
              'message',
              contains(r'must extend _$SimpleBloc<State>'),
            ),
          ),
        );
      },
    );

    test(
      'should throw error for public method with @MonoEvent in strict mode',
      () {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        abstract class TestEvent {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent()
          TestState setValue(int value) => TestState();
        }
      ''';

        expect(
          () => generateForSource(source),
          throwsA(
            isA<InvalidGenerationSourceError>().having(
              (e) => e.message,
              'message',
              contains('Public @event methods MUST have BOTH'),
            ),
          ),
        );
      },
    );

    test('should throw error when method name contains dollar sign', () {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @event
          TestState _on$Increment() => TestState();
        }
      ''';

      expect(
        () => generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains(r'contains "$" character'),
          ),
        ),
      );
    });

    test(
      'should throw error when _onDeposit and _deposit generate same event name',
      () {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class BankBloc extends _$BankBloc<TestState> {
          BankBloc() : super(TestState());
          
          @event
          TestState _onDeposit(double amount) => TestState();
          
          @event
          TestState _deposit(double amount) => TestState();
        }
      ''';

        expect(
          () => generateForSource(source),
          throwsA(
            isA<InvalidGenerationSourceError>().having(
              (e) => e.message,
              'message',
              contains('Method name conflict detected'),
            ),
          ),
        );
      },
    );

    test(
      'should throw error when OnDeposit and deposit generate same event name',
      () {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class BankBloc extends _$BankBloc<TestState> {
          BankBloc() : super(TestState());
          
          @event
          TestState _OnDeposit(double amount) => TestState();
          
          @event
          TestState _deposit(double amount) => TestState();
        }
      ''';

        expect(
          () => generateForSource(source),
          throwsA(
            isA<InvalidGenerationSourceError>().having(
              (e) => e.message,
              'message',
              contains('Event name conflict'),
            ),
          ),
        );
      },
    );

    test('should throw error when @onEvent parameter is not _Event type', () {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @event
          TestState _onIncrement() => TestState();
          
          @onEvent
          bool _onEvent(Object event) => true;
        }
      ''';

      expect(
        () => generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains('has invalid parameter'),
          ),
        ),
      );
    });

    test('should throw error when @onEvent parameter is dynamic type', () {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @event
          TestState _onIncrement() => TestState();
          
          @onEvent
          bool _onEvent(dynamic event) => true;
        }
      ''';

      expect(
        () => generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains('has invalid parameter'),
          ),
        ),
      );
    });

    test('should throw error when @onEvent does not return bool', () {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @event
          TestState _onIncrement() => TestState();
          
          @onEvent
          void _onEvent(_Event event) {}
        }
      ''';

      expect(
        () => generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains('must return bool'),
          ),
        ),
      );
    });

    test('should throw error when @onEvent is async (Future return type)', () {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @event
          TestState _onIncrement() => TestState();
          
          @onEvent
          Future<bool> _onEvent(_Event event) async => true;
        }
      ''';

      expect(
        () => generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains('must return bool'),
          ),
        ),
      );
    });
  });
}
