import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - Sequential Mode', () {
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

    test('should generate queue 0 for sequential mode', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestState {}
        
        @MonoBloc(sequential: true)
        class SequentialBloc extends _$SequentialBloc<TestState> {
          SequentialBloc() : super(TestState());
          
          @event
          TestState _onFirst() => TestState();
          
          @event
          TestState _onSecond() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      // Should create _\$SequentialEvent base class
      expect(generated, contains(r'class _$SequentialEvent extends _Event'));

      // Both events should extend _\$SequentialEvent
      expect(
        generated,
        contains(r'class _FirstEvent extends _$SequentialEvent'),
      );
      expect(
        generated,
        contains(r'class _SecondEvent extends _$SequentialEvent'),
      );

      // Should register sequential event handler
      expect(generated, contains(r'on<_$SequentialEvent>'));
      expect(generated, contains('MonoEventTransformer.sequential'));
    });

    test('should put simple events in queue 0 with sequential mode', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestState {}
        
        @MonoBloc(sequential: true)
        class SequentialBloc extends _$SequentialBloc<TestState> {
          SequentialBloc() : super(TestState());
          
          @event
          TestState _onAddItem() => TestState();
          
          @event
          TestState _onDelete() => TestState();
          
          @event
          TestState _onUpdate() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      // All events extend _\$SequentialEvent
      expect(
        generated,
        contains(r'class _AddItemEvent extends _$SequentialEvent'),
      );
      expect(
        generated,
        contains(r'class _DeleteEvent extends _$SequentialEvent'),
      );
      expect(
        generated,
        contains(r'class _UpdateEvent extends _$SequentialEvent'),
      );

      // Should have if-else chain in sequential event handler
      expect(generated, contains('if (event is _AddItemEvent)'));
      expect(generated, contains('else if (event is _DeleteEvent)'));
      expect(generated, contains('else if (event is _UpdateEvent)'));
    });

    test(
      'should exclude events with explicit transformers from queue 0',
      () async {
        const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestState {}
        
        @MonoBloc(sequential: true)
        class MixedBloc extends _$MixedBloc<TestState> {
          MixedBloc() : super(TestState());
          
          @event
          TestState _onSequential1() => TestState();
          
          @restartableEvent
          TestState _onRestartable() => TestState();
          
          @event
          TestState _onSequential2() => TestState();
          
          @droppableEvent
          TestState _onDroppable() => TestState();
        }
      ''';

        final generated = await generateForSource(source);

        // Sequential events extend _\$SequentialEvent
        expect(generated, contains(r'class _$SequentialEvent extends _Event'));
        expect(
          generated,
          contains(r'class _Sequential1Event extends _$SequentialEvent'),
        );
        expect(
          generated,
          contains(r'class _Sequential2Event extends _$SequentialEvent'),
        );

        // Events with transformers extend base event
        expect(generated, contains('class _RestartableEvent extends _Event'));
        expect(generated, contains('class _DroppableEvent extends _Event'));

        // Should have separate registrations
        expect(generated, contains(r'on<_$SequentialEvent>'));
        expect(generated, contains('on<_RestartableEvent>'));
        expect(generated, contains('on<_DroppableEvent>'));

        // Transformers should be applied
        expect(generated, contains('MonoEventTransformer.sequential'));
        expect(generated, contains('MonoEventTransformer.restartable'));
        expect(generated, contains('MonoEventTransformer.droppable'));
      },
    );

    test(
      'should exclude events with manual queue assignment from queue 0',
      () async {
        const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestState {}
        
        @MonoBloc(sequential: true)
        class ManualQueueBloc extends _$ManualQueueBloc<TestState> {
          ManualQueueBloc() : super(TestState());
          
          @event
          TestState _onSequential() => TestState();
          
          @MonoEvent.queue('queue5')
          TestState _onManualQueue() => TestState();
        }
      ''';

        final generated = await generateForSource(source);

        // Sequential event extends _\$SequentialEvent
        expect(generated, contains(r'class _$SequentialEvent extends _Event'));
        expect(
          generated,
          contains(r'class _SequentialEvent extends _$SequentialEvent'),
        );

        // Manual queue event in queue 'queue5'
        expect(generated, contains(r'class _$Queue5QueueEvent extends _Event'));
        expect(
          generated,
          contains(r'class _ManualQueueEvent extends _$Queue5QueueEvent'),
        );

        // Two separate handlers: _\$SequentialEvent and queue 'queue5'
        expect(generated, contains(r'on<_$SequentialEvent>'));
        expect(generated, contains(r'on<_$Queue5QueueEvent>'));
      },
    );

    test('should set default queue 0 as sequential in constructor', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestState {}
        
        @MonoBloc(sequential: true)
        class SequentialBloc extends _$SequentialBloc<TestState> {
          SequentialBloc() : super(TestState());
          
          @event
          TestState _onEvent() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      // Sequential-only mode should NOT have queues parameter
      expect(
        generated,
        isNot(contains('Map<String, EventTransformer<dynamic>>? queues')),
      );

      // Should use transformer on _\$SequentialEvent
      expect(generated, contains(r'on<_$SequentialEvent>'));
      expect(generated, contains('MonoEventTransformer.sequential'));
    });

    test('should work with multiple events in sequential mode', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestState {}
        
        @MonoBloc(sequential: true)
        class MultiEventBloc extends _$MultiEventBloc<TestState> {
          MultiEventBloc() : super(TestState());
          
          @event
          TestState _onFirst() => TestState();
          
          @event
          TestState _onSecond() => TestState();
          
          @event
          TestState _onThird() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      // All should extend _\$SequentialEvent
      expect(
        generated,
        contains(r'class _FirstEvent extends _$SequentialEvent'),
      );
      expect(
        generated,
        contains(r'class _SecondEvent extends _$SequentialEvent'),
      );
      expect(
        generated,
        contains(r'class _ThirdEvent extends _$SequentialEvent'),
      );
    });

    test('should handle different return types in sequential mode', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        import 'package:bloc/bloc.dart';
        
        part 'test_bloc.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc(sequential: true)
        class ReturnTypeBloc extends _$ReturnTypeBloc<TestState> {
          ReturnTypeBloc() : super(TestState());
          
          @event
          TestState _onSync() => TestState();
          
          @event
          Future<TestState> _onAsync() async => TestState();
          
          @event
          Stream<TestState> _onStreamData() async* {
            yield TestState();
          }
          
          @event
          Future<void> _onEmitter(_Emitter emit) async {
            emit(TestState());
          }
        }
      ''';

      final generated = await generateForSource(source);

      // All should extend _\$SequentialEvent
      expect(
        generated,
        contains(r'class _SyncEvent extends _$SequentialEvent'),
      );
      expect(
        generated,
        contains(r'class _AsyncEvent extends _$SequentialEvent'),
      );
      expect(
        generated,
        contains(r'class _StreamDataEvent extends _$SequentialEvent'),
      );
      expect(
        generated,
        contains(r'class _EmitterEvent extends _$SequentialEvent'),
      );

      // Check proper handling
      expect(generated, contains('emit(_onSync())'));
      expect(generated, contains('emit(await _onAsync())'));
      expect(generated, contains('await emit.forEach'));
      expect(generated, contains('await _onEmitter(emit)'));
    });

    test('should not create queue 0 when sequential is false', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class NonSequentialBloc extends _$NonSequentialBloc<TestState> {
          NonSequentialBloc() : super(TestState());
          
          @event
          TestState _onEvent() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      // Should not create _\$SequentialEvent
      expect(generated, isNot(contains(r'class _$SequentialEvent')));

      // Event should extend base event
      expect(generated, contains('class _EventEvent extends _Event'));

      // No sequential handler
      expect(generated, isNot(contains(r'on<_$SequentialEvent>')));
    });

    test(
      'should not create queue 0 when sequential is omitted (default false)',
      () async {
        const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class DefaultBloc extends _$DefaultBloc<TestState> {
          DefaultBloc() : super(TestState());
          
          @event
          TestState _onEvent() => TestState();
        }
      ''';

        final generated = await generateForSource(source);

        // Should not create _\$SequentialEvent
        expect(generated, isNot(contains(r'class _$SequentialEvent')));

        // Event should extend base event
        expect(generated, contains('class _EventEvent extends _Event'));
      },
    );

    test('should handle parameters correctly in sequential mode', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestState {}
        
        @MonoBloc(sequential: true)
        class ParamsBloc extends _$ParamsBloc<TestState> {
          ParamsBloc() : super(TestState());
          
          @event
          TestState _onPositional(int x, String y) => TestState();
          
          @event
          TestState _onNamed({required int a, String? b}) => TestState();
          
          @event
          TestState _onMixed(int pos, {required String named}) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      // All extend _\$SequentialEvent
      expect(
        generated,
        contains(r'class _PositionalEvent extends _$SequentialEvent'),
      );
      expect(
        generated,
        contains(r'class _NamedEvent extends _$SequentialEvent'),
      );
      expect(
        generated,
        contains(r'class _MixedEvent extends _$SequentialEvent'),
      );

      // Parameters should be passed correctly
      expect(generated, contains('_onPositional(event.x, event.y)'));
      expect(generated, contains('_onNamed(a: event.a, b: event.b)'));
      expect(generated, contains('_onMixed(event.pos, named: event.named)'));
    });

    test('should allow mixing queue 0 with other queues', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestState {}
        
        @MonoBloc(sequential: true)
        class MultiQueueSeqBloc extends _$MultiQueueSeqBloc<TestState> {
          MultiQueueSeqBloc() : super(TestState());
          
          @event
          TestState _onAutoQueue() => TestState();
          
          @MonoEvent.queue('queue1')
          TestState _onManualQueue1() => TestState();
          
          @MonoEvent.queue('queue2')
          TestState _onManualQueue2() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      // Should have _\$SequentialEvent and manual queue classes
      expect(generated, contains(r'class _$SequentialEvent extends _Event'));
      expect(generated, contains(r'class _$Queue1QueueEvent extends _Event'));
      expect(generated, contains(r'class _$Queue2QueueEvent extends _Event'));

      // Auto queue event extends _\$SequentialEvent, manual queues extend their queue classes
      expect(
        generated,
        contains(r'class _AutoQueueEvent extends _$SequentialEvent'),
      );
      expect(
        generated,
        contains(r'class _ManualQueue1Event extends _$Queue1QueueEvent'),
      );
      expect(
        generated,
        contains(r'class _ManualQueue2Event extends _$Queue2QueueEvent'),
      );

      // Three handlers: _\$SequentialEvent and two manual queues
      expect(generated, contains(r'on<_$SequentialEvent>'));
      expect(generated, contains(r'on<_$Queue1QueueEvent>'));
      expect(generated, contains(r'on<_$Queue2QueueEvent>'));
    });

    test(
      'should generate MonoSeqEmitter for sequential non-async bloc',
      () async {
        const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestState {}
        
        @MonoBloc(sequential: true)
        class SequentialBloc extends _$SequentialBloc<TestState> {
          SequentialBloc() : super(TestState());
          
          @event
          void _onWithEmitter(_Emitter emit) {
            emit(TestState());
          }
        }
      ''';

        final generated = await generateForSource(source);

        // Should generate MonoSeqEmitter typedef (not regular Emitter)
        // MonoSeqEmitter has call() and isDone but NO forEach/onEach
        expect(
          generated,
          contains('typedef _Emitter = MonoSeqEmitter<TestState>'),
          reason: 'Sequential non-async bloc should use MonoSeqEmitter',
        );

        // Should NOT use regular Emitter
        expect(
          generated,
          isNot(contains('typedef _Emitter = Emitter<TestState>')),
          reason: 'Sequential bloc should not use regular Emitter',
        );
      },
    );

    test(
      'should generate regular Emitter for parallel non-async bloc',
      () async {
        const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestState {}
        
        @MonoBloc()  // NOT sequential
        class ParallelBloc extends _$ParallelBloc<TestState> {
          ParallelBloc() : super(TestState());
          
          @event
          void _onWithEmitter(_Emitter emit) {
            emit(TestState());
          }
        }
      ''';

        final generated = await generateForSource(source);

        // Should generate regular Emitter typedef (not MonoSeqEmitter)
        expect(
          generated,
          contains('typedef _Emitter = Emitter<TestState>'),
          reason: 'Parallel non-async bloc should use regular Emitter',
        );

        // Should NOT use MonoSeqEmitter
        expect(
          generated,
          isNot(contains('typedef _Emitter = MonoSeqEmitter<TestState>')),
          reason: 'Parallel bloc should not use MonoSeqEmitter',
        );
      },
    );
  });
}
