import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

const _mockPackages = {
  'bloc|lib/bloc.dart': '''
    class Emitter<S> {
      void call(S state) {}
    }
    
    abstract class Bloc<E, S> {
      Bloc(S initialState);
      void add(E event) {}
      void emit(S state) {}
      void on<T>(Function handler, {Function? transformer}) {}
    }
  ''',
  'mono_bloc|lib/mono_bloc.dart': '''
    export 'src/annotations/mono_bloc.dart';
    export 'src/annotations/mono_event.dart';
    export 'src/annotations/mono_init.dart';
    export 'src/annotations/error_handler.dart';
    export 'src/annotations/on_event.dart';
    export 'src/annotations/mono_action.dart';
    export 'src/annotations/async_mono_bloc.dart';
    export 'src/annotations/mono_concurrency.dart';
    export 'src/mono_bloc_base.dart';
  ''',
  'mono_bloc|lib/src/mono_bloc_base.dart': '''
    import 'package:bloc/bloc.dart';
    
    typedef EventTransformer<E> = Function();
    
    abstract class MonoBloc<Event, State> extends Bloc<Event, State> {
      final Map<int, EventTransformer<Event>> queues;
      
      MonoBloc(State initialState, {this.queues = const {}}) : super(initialState);
      
      void wrapEventHandler<E extends Event, S extends State>(
        E event,
        Emitter<S> emit,
        void Function() handler,
      ) {
        handler();
      }
    }
  ''',
  'mono_bloc|lib/src/annotations/mono_bloc.dart': '''
    import 'package:meta/meta_meta.dart';
    
    @Target({TargetKind.classType})
    final class MonoBloc {
      const MonoBloc();
    }
  ''',
  'mono_bloc|lib/src/annotations/mono_event.dart': '''
    import 'package:meta/meta_meta.dart';
    import 'package:mono_bloc/src/annotations/mono_concurrency.dart';
    
    @Target({TargetKind.method})
    final class MonoEvent {
      final MonoConcurrency? concurrency;
      final String? queue;
      
      const MonoEvent([this.concurrency]) : queue = null;
      const MonoEvent.queue([this.queue]) : concurrency = null;
    }
    
    const event = MonoEvent();
  ''',
  'mono_bloc|lib/src/annotations/mono_init.dart': '''
    import 'package:meta/meta_meta.dart';
    
    @Target({TargetKind.method})
    final class MonoInit {
      const MonoInit();
    }
    
    const init = MonoInit();
  ''',
  'mono_bloc|lib/src/annotations/mono_concurrency.dart': '''
    enum MonoConcurrency { sequential, concurrent, restartable, droppable }
  ''',
  'mono_bloc|lib/src/annotations/error_handler.dart': '''
    import 'package:meta/meta_meta.dart';
    
    @Target({TargetKind.method})
    final class MonoOnError {
      const MonoOnError();
    }
    
    const onError = MonoOnError();
  ''',
  'mono_bloc|lib/src/annotations/on_event.dart': '''
    import 'package:meta/meta_meta.dart';
    
    @Target({TargetKind.method})
    final class MonoOnEvent {
      const MonoOnEvent();
    }
    
    const onEvent = MonoOnEvent();
  ''',
  'mono_bloc|lib/src/annotations/mono_action.dart': '''
    import 'package:meta/meta_meta.dart';
    
    @Target({TargetKind.method})
    final class MonoAction {
      const MonoAction();
    }
    
    const action = MonoAction();
  ''',
  'mono_bloc|lib/src/annotations/async_mono_bloc.dart': '''
    import 'package:meta/meta_meta.dart';
    
    @Target({TargetKind.classType})
    final class AsyncMonoBloc {
      const AsyncMonoBloc();
    }
  ''',
  'bloc_concurrency|lib/bloc_concurrency.dart': '''
    typedef EventTransformer<T> = Function();
    
    EventTransformer<T> restartable<T>() => () {};
    EventTransformer<T> droppable<T>() => () {};
    EventTransformer<T> sequential<T>() => () {};
    EventTransformer<T> concurrent<T>() => () {};
  ''',
};

void main() {
  group('MonoBlocGenerator', () {
    late MonoBlocGenerator generator;

    setUp(() {
      generator = MonoBlocGenerator();
    });

    Future<String> generateForSource(String source) {
      return resolveSources({..._mockPackages, 'pkg|lib/test.dart': source}, (
        resolver,
      ) async {
        final lib = await resolver.libraryFor(
          AssetId.parse('pkg|lib/test.dart'),
        );
        final generated = await generator.generate(
          LibraryReader(lib),
          _MockBuildStep(),
        );
        return generated;
      });
    }

    test('should generate Event classes for @MonoEvent methods', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent()
          TestState _onIncrement() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('abstract class _Event'));
      expect(generated, contains('class _IncrementEvent extends _Event'));
      expect(generated, contains('extends Bloc<_Event, TestState>'));
      expect(generated, contains(r'void _$init()'));
    });

    test('should register events in init method', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent()
          TestState _onIncrement() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('on<_IncrementEvent>'));
      expect(generated, contains('emit(_onIncrement())'));
    });

    test('should generate public helper methods', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent()
          TestState _onIncrement() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('void increment()'));
      expect(generated, contains('add(_IncrementEvent())'));
    });

    test('should generate public methods with parameters', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestEvent {}
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent()
          TestState _setValue(int value) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('void setValue(int value)'));
      expect(generated, contains('add(_SetValueEvent(value))'));
    });

    test('should handle State return type with simple return', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestEvent {}
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent()
          TestState _increment() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('emit(_increment())'));
    });

    test('should handle State return type - emit wrapper', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestEvent {}
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent()
          TestState _reset() {
            return TestState();
          }
        }
      ''';

      final generated = await generateForSource(source);

      // Check for the key components (ignore whitespace differences)
      expect(generated, contains('emit(_reset())'));
    });

    test('should handle Stream<State> return type - emit.forEach', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestEvent {}
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent()
          Stream<TestState> _loadAsync() async* {
            yield TestState();
          }
        }
      ''';

      final generated = await generateForSource(source);

      expect(
        generated,
        contains(
          'await emit.forEach<TestState>(_loadAsync(), onData: (state) => state)',
        ),
      );
    });

    test('should handle transformers in event registration', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestEvent {}
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent(MonoConcurrency.restartable)
          TestState _restartable() => TestState();
          
          @MonoEvent(MonoConcurrency.droppable)
          TestState _droppable() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('MonoEventTransformer.restartable'));
      expect(generated, contains('MonoEventTransformer.droppable'));
    });

    test('should generate queue base classes', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestEvent {}
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent.queue('queue5')
          TestState _queued(int value) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains(r'class _$Queue5QueueEvent extends _Event'));
      expect(
        generated,
        contains(r'class _QueuedEvent extends _$Queue5QueueEvent'),
      );
    });

    test('should register queue events with transformer', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestEvent {}
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent.queue('queue5')
          TestState _queued(int value) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains(r'on<_$Queue5QueueEvent>'));
      expect(
        generated,
        contains(
          r"transformer: bloc._getTransformer<_$Queue5QueueEvent>('queue5')",
        ),
      );
    });

    test('should handle multiple methods', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestEvent {}
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent()
          TestState _increment() => TestState();
          
          @MonoEvent()
          TestState _decrement() => TestState();
          
          @MonoEvent()
          TestState _reset() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('class _IncrementEvent'));
      expect(generated, contains('class _DecrementEvent'));
      expect(generated, contains('class _ResetEvent'));
      expect(generated, contains('void increment()'));
      expect(generated, contains('void decrement()'));
      expect(generated, contains('void reset()'));
    });

    test(
      'should generate base class even for MonoBloc without @MonoEvent methods',
      () async {
        const source = r'''
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
        // Note: Extension type is only generated when there are events or init methods
        expect(generated, contains(r'abstract class _$SimpleBloc'));
        expect(generated, contains('extends Bloc<_Event, TestState>'));
      },
    );

    test('should map parameters correctly in event registration', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestEvent {}
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent()
          TestState _setValue(int value, String label) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('_setValue(event.value, event.label)'));
    });

    test('should map named parameters correctly', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestEvent {}
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent()
          TestState _setValues(
            int value, {
            required String label,
          }) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(
        generated,
        contains('_setValues(event.value, label: event.label)'),
      );
    });

    test('should handle multiple queues', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestEvent {}
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent.queue('queue5')
          TestState _queue5() => TestState();
          
          @MonoEvent.queue('queue10')
          TestState _queue10() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains(r'class _$Queue5QueueEvent extends _Event'));
      expect(generated, contains(r'class _$Queue10QueueEvent extends _Event'));
      expect(generated, contains(r'on<_$Queue5QueueEvent>'));
      expect(generated, contains(r'on<_$Queue10QueueEvent>'));
    });

    test(
      'should generate public methods without abstract declarations',
      () async {
        const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestEvent {}
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent()
          void _increment(Emitter<TestState> emit) {}
          
          @MonoEvent()
          TestState _reset() {
            return TestState();
          }
          
          @MonoEvent()
          Stream<TestState> _loadAsync() async* {
            yield TestState();
          }
        }
      ''';

        final generated = await generateForSource(source);

        // Should generate public methods
        expect(generated, contains('void increment()'));
        expect(generated, contains('void reset()'));
        expect(generated, contains('void loadAsync()'));
      },
    );
  });
}

// Mock BuildStep for testing
class _MockBuildStep implements BuildStep {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
