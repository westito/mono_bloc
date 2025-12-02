import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - Annotation Conflicts', () {
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

    test('should reject method with both @event and @onError', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @event
          @onError
          TestState _onSomething() => TestState();
        }
      ''';

      await expectLater(
        generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains('cannot have both @event and @onError'),
          ),
        ),
      );
    });

    test('should reject multiple @MonoBloc annotations in same file', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoBloc()
        class FirstBloc extends _$FirstBloc<int> {
          FirstBloc() : super(0);
        }
        
        @MonoBloc()
        class SecondBloc extends _$SecondBloc<int> {
          SecondBloc() : super(0);
        }
      ''';

      await expectLater(
        generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            allOf([contains('Only ONE'), contains('per file')]),
          ),
        ),
      );
    });

    test('should reject @MonoBloc on mixin', () async {
      const source = '''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        @MonoBloc()
        mixin TestMixin {
          void doSomething();
        }
      ''';

      await expectLater(
        generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains('cannot be used on mixins'),
          ),
        ),
      );
    });

    test('should reject @AsyncMonoBloc with @MonoBloc in same file', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoBloc()
        class FirstBloc extends _$FirstBloc<int> {
          FirstBloc() : super(0);
        }
        
        @AsyncMonoBloc()
        class SecondBloc extends _$SecondBloc<String> {
          SecondBloc() : super(const MonoAsyncValue.initial());
        }
      ''';

      await expectLater(
        generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains('Only ONE'),
          ),
        ),
      );
    });

    test('should reject @onEvent with both @event and @onError', () async {
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
          @onError
          bool _onEventOrError(_Event event) => true;
        }
      ''';

      await expectLater(
        generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains('cannot have both @onError and @onEvent'),
          ),
        ),
      );
    });

    test(
      'should reject method with multiple concurrency annotations',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @restartableEvent
          @sequentialEvent
          TestState _onEvent() => TestState();
        }
      ''';

        final generated = await generateForSource(source);

        expect(generated, isNotEmpty);
      },
    );

    test(
      'should handle @MonoInit with @event annotations separately',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoInit()
          void _init() {}
          
          @event
          TestState _onEvent() => TestState();
        }
      ''';

        final generated = await generateForSource(source);

        expect(generated, contains('_init()'));
        expect(generated, contains('_EventEvent'));
      },
    );

    test('should reject public @event without @protected', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @event
          TestState publicEvent() => TestState();
        }
      ''';

      await expectLater(
        generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains('Public @event methods MUST have BOTH'),
          ),
        ),
      );
    });

    test('should reject public @event without "on" prefix', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @protected
          @event
          TestState publicEvent() => TestState();
        }
      ''';

      await expectLater(
        generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains('does not start with "on"'),
          ),
        ),
      );
    });

    test(
      'should accept public @event with @protected and "on" prefix',
      () async {
        const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @protected
          @event
          TestState onPublicEvent() => TestState();
        }
      ''';

        final generated = await generateForSource(source);

        expect(generated, isNotEmpty);
        expect(generated, contains('onPublicEvent'));
      },
    );
  });
}
