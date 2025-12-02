import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - Edge Cases', () {
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
      'should not generate code for class without @MonoBloc annotation',
      () async {
        const source = '''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestEvent {}
        abstract class TestState {}
        
        class SimpleBloc extends Bloc<TestEvent, TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent()
          TestState _increment() => TestState();
        }
      ''';

        final generated = await generateForSource(source);

        expect(generated, isEmpty);
      },
    );

    test(
      'should not generate code for MonoBloc without @MonoEvent methods',
      () async {
        const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestEvent {}
        abstract class TestState {}
        
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          void publicMethod() {}
          void _privateMethod() {}
        }
      ''';

        final generated = await generateForSource(source);

        expect(generated, isNot(contains(r'_$SimpleBloc')));
        expect(generated, isNot(contains('init()')));
      },
    );

    test(
      'should handle Bloc with @MonoBloc but no @MonoEvent methods',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestEvent {}
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          void publicMethod() {}
          void _privateMethod() {}
        }
      ''';

        final generated = await generateForSource(source);

        // Should generate base class even without events
        expect(generated, contains(r'abstract class _$SimpleBloc'));
        expect(generated, contains(r'void _$init()'));
      },
    );

    test('should handle empty file gracefully', () async {
      const source = '''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
      ''';

      final generated = await generateForSource(source);

      expect(generated, isEmpty);
    });

    test('should require correct extends clause for @MonoBloc classes', () {
      const source = '''
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class NotABloc {
          @MonoEvent()
          TestState _increment() => TestState();
        }
      ''';

      // Should throw error because class doesn't extend _$NotABloc<State>
      expect(
        () => generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains(r'must extend _$NotABloc<State>'),
          ),
        ),
      );
    });

    test('should handle Bloc with only @MonoInit methods', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestEvent {}
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoInit()
          void _setupLogger() {}
          
          @MonoInit()
          void _initServices() {}
        }
      ''';

      final generated = await generateForSource(source);

      // Should generate base class
      expect(generated, contains(r'abstract class _$SimpleBloc<_>'));
      expect(generated, contains(r'void _$init() {'));

      // @onInit methods are treated as events - generate event classes
      expect(generated, contains('class _SetupLoggerEvent extends _Event'));
      expect(generated, contains('class _InitServicesEvent extends _Event'));

      // Register handlers for @onInit events
      expect(generated, contains('bloc.on<_SetupLoggerEvent>'));
      expect(generated, contains('bloc.on<_InitServicesEvent>'));

      // Dispatch @onInit events at the end (no public methods generated)
      expect(generated, contains('bloc.add(_SetupLoggerEvent())'));
      expect(generated, contains('bloc.add(_InitServicesEvent())'));
    });

    test('should handle Bloc with very long method names', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent()
          TestState _onThisIsAVeryLongMethodNameThatTestsEdgeCasesForNamingConventions() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(
        generated,
        contains(
          'class _ThisIsAVeryLongMethodNameThatTestsEdgeCasesForNamingConventionsEvent',
        ),
      );
      expect(
        generated,
        contains(
          'void thisIsAVeryLongMethodNameThatTestsEdgeCasesForNamingConventions()',
        ),
      );
    });

    test('should handle Bloc with single character method names', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent()
          TestState _x() => TestState();
          
          @MonoEvent()
          TestState _y() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('class _XEvent'));
      expect(generated, contains('class _YEvent'));
      expect(generated, contains('void x()'));
      expect(generated, contains('void y()'));
    });

    test('should handle Bloc with many parameters', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent()
          TestState _manyParams(
            int a,
            String b,
            double c,
            bool d,
            List<int> e, {
            required Map<String, dynamic> f,
            int? g,
            String h = 'default',
          }) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('final int a;'));
      expect(generated, contains('final String b;'));
      expect(generated, contains('final double c;'));
      expect(generated, contains('final bool d;'));
      expect(generated, contains('final List<int> e;'));
      expect(generated, contains('final Map<String, dynamic> f;'));
      expect(generated, contains('final int? g;'));
      expect(generated, contains('final String h;'));
    });

    test('should reject queue name starting with digit', () {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent.queue('1queue')
          TestState _queued() => TestState();
        }
      ''';

      expect(
        () => generateForSource(source),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Invalid queue name "1queue"'),
          ),
        ),
      );
    });

    test('should reject queue name with spaces', () {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent.queue('my queue')
          TestState _queued() => TestState();
        }
      ''';

      expect(
        () => generateForSource(source),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Invalid queue name "my queue"'),
          ),
        ),
      );
    });

    test('should reject queue name with special characters', () {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent.queue('queue-name')
          TestState _queued() => TestState();
        }
      ''';

      expect(
        () => generateForSource(source),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Invalid queue name "queue-name"'),
          ),
        ),
      );
    });

    test('should reject empty queue name', () {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent.queue('')
          TestState _queued() => TestState();
        }
      ''';

      expect(
        () => generateForSource(source),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Invalid queue name ""'),
          ),
        ),
      );
    });

    test('should accept valid queue name with underscores', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent.queue('my_valid_queue_123')
          TestState _queued() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(
        generated,
        contains(r'class _$MyValidQueue123QueueEvent extends _Event'),
      );
      expect(
        generated,
        contains(r'class _QueuedEvent extends _$MyValidQueue123QueueEvent'),
      );
    });

    test('should accept queue name starting with underscore', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent.queue('_private_queue')
          TestState _queued() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(
        generated,
        contains(r'class _$PrivateQueueQueueEvent extends _Event'),
      );
      expect(
        generated,
        contains(r'class _QueuedEvent extends _$PrivateQueueQueueEvent'),
      );
    });

    test('should handle multiple @MonoInit methods', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoInit()
          void _loadConfig() {}
          
          @MonoInit()
          void _setupLogging() {}
          
          @MonoInit()
          void _initializeCache() {}
          
          @MonoEvent()
          TestState _increment() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      // Should generate event classes for all @onInit methods
      expect(generated, contains('class _LoadConfigEvent extends _Event'));
      expect(generated, contains('class _SetupLoggingEvent extends _Event'));
      expect(generated, contains('class _InitializeCacheEvent extends _Event'));
      expect(generated, contains('class _IncrementEvent extends _Event'));

      // Should register handlers for all @onInit events
      expect(generated, contains('bloc.on<_LoadConfigEvent>'));
      expect(generated, contains('bloc.on<_SetupLoggingEvent>'));
      expect(generated, contains('bloc.on<_InitializeCacheEvent>'));

      // Should dispatch all @onInit events
      expect(generated, contains('bloc.add(_LoadConfigEvent())'));
      expect(generated, contains('bloc.add(_SetupLoggingEvent())'));
      expect(generated, contains('bloc.add(_InitializeCacheEvent())'));

      // Regular event should still have public method
      expect(generated, contains('void increment()'));
    });

    test(
      'should put @onInit events in sequential queue for sequential blocs',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc(sequential: true)
        class SequentialBloc extends _$SequentialBloc<TestState> {
          SequentialBloc() : super(TestState());
          
          @MonoInit()
          void _initialize() {}
          
          @MonoEvent()
          TestState _increment() => TestState();
        }
      ''';

        final generated = await generateForSource(source);

        // @onInit events should extend _$SequentialEvent in sequential mode
        expect(
          generated,
          contains(r'class _InitializeEvent extends _$SequentialEvent'),
        );
        expect(
          generated,
          contains(r'class _IncrementEvent extends _$SequentialEvent'),
        );

        // Should have single _$SequentialEvent handler that includes @onInit event
        expect(generated, contains(r'bloc.on<_$SequentialEvent>'));

        // The sequential handler should contain the @onInit event handling
        expect(generated, contains('if (event is _InitializeEvent)'));

        // Should NOT have a separate on<_InitializeEvent> handler
        // (it's handled by the _$SequentialEvent handler)
        final separateHandlerMatches = RegExp(
          r'bloc\.on<_InitializeEvent>',
        ).allMatches(generated).length;
        expect(
          separateHandlerMatches,
          equals(0),
          reason:
              r'@onInit events should be handled by _$SequentialEvent handler, not separately',
        );

        // Should still dispatch @onInit events
        expect(generated, contains('bloc.add(_InitializeEvent())'));
      },
    );

    test('should handle @onInit with parameters in sequential mode', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc(sequential: true)
        class SequentialBloc extends _$SequentialBloc<TestState> {
          SequentialBloc() : super(TestState());
          
          @MonoInit()
          void _setupWithConfig(String configPath) {}
          
          @MonoEvent()
          TestState _increment() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      // @onInit event with parameters should extend _$SequentialEvent
      expect(
        generated,
        contains(r'class _SetupWithConfigEvent extends _$SequentialEvent'),
      );

      // Should have the configPath field
      expect(generated, contains('final String configPath;'));

      // Should handle in sequential handler
      expect(generated, contains('if (event is _SetupWithConfigEvent)'));

      // Should dispatch with parameters
      expect(generated, contains('bloc.add(_SetupWithConfigEvent('));
    });
  });
}
