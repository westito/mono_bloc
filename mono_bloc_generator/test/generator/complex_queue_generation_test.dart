import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - Complex Queue Generation', () {
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

    const complexQueueSource = r'''
      import 'package:mono_bloc/mono_bloc.dart';
      import 'package:mono_bloc/src/mono_bloc_annotations.dart';
      import 'package:bloc/bloc.dart';
      
      typedef _Emitter = Emitter<String>;
      
      @MonoBloc()
      class ComplexQueueBloc extends _$ComplexQueueBloc<String> {
        ComplexQueueBloc() : super('initial', queues: const {
          'queue1': null,
          'queue2': null,
          'queue5': null,
        });

        // ========== QUEUE 'queue1': SEQUENTIAL ==========
        @MonoEvent.queue('queue1')
        String _q1Sync() => 'q1_sync';

        @MonoEvent.queue('queue1')
        Future<String> _q1Async(int delay) async {
          return 'q1_async';
        }

        @MonoEvent.queue('queue1')
        String _q1WithParams(String value, {required int count, bool flag = false}) {
          return 'q1_params';
        }

        // ========== QUEUE 'queue2': DROPPABLE ==========
        @MonoEvent.queue('queue2')
        Stream<String> _q2Stream() async* {
          yield 'q2_stream';
        }

        @MonoEvent.queue('queue2')
        Future<void> _q2Emitter(
          _Emitter emit,
          String msg,
          int times, {
          String? prefix,
        }) async {
          emit('q2');
        }

        @MonoEvent.queue('queue2')
        String _q2Complex(
          int a,
          int b, {
          required String operation,
          bool negate = false,
        }) {
          return 'q2_complex';
        }

        // ========== QUEUE 'queue5': RESTARTABLE ==========
        @MonoEvent.queue('queue5')
        Stream<String> _q5Single(int count) async* {
          yield 'q5';
        }

        // ========== NON-QUEUED EVENTS ==========
        @event
        String _onNormal() => 'normal';

        @MonoEvent(MonoConcurrency.sequential)
        Future<String> _onSequential(String value) async {
          return 'sequential';
        }

        @MonoEvent(MonoConcurrency.concurrent)
        Future<String> _onConcurrent(int id) async {
          return 'concurrent';
        }

        @MonoEvent(MonoConcurrency.restartable)
        Stream<String> _onRestartable(String prefix) async* {
          yield 'restartable';
        }

        @MonoEvent(MonoConcurrency.droppable)
        Future<String> _onDroppable(String msg) async {
          return 'droppable';
        }

        @onInit
        void _initialize() {}
      }
    ''';

    test('should generate all queue base classes', () async {
      final generated = await generateForSource(complexQueueSource);

      // Should generate 3 queue base classes
      expect(generated, contains(r'class _$Queue1QueueEvent extends _Event'));
      expect(generated, contains(r'class _$Queue2QueueEvent extends _Event'));
      expect(generated, contains(r'class _$Queue5QueueEvent extends _Event'));
    });

    test('should generate Queue 1 events (3 events)', () async {
      final generated = await generateForSource(complexQueueSource);

      expect(
        generated,
        contains(r'class _Q1SyncEvent extends _$Queue1QueueEvent'),
      );
      expect(
        generated,
        contains(r'class _Q1AsyncEvent extends _$Queue1QueueEvent'),
      );
      expect(
        generated,
        contains(r'class _Q1WithParamsEvent extends _$Queue1QueueEvent'),
      );
    });

    test('should generate Queue 2 events (3 events)', () async {
      final generated = await generateForSource(complexQueueSource);

      expect(
        generated,
        contains(r'class _Q2StreamEvent extends _$Queue2QueueEvent'),
      );
      expect(
        generated,
        contains(r'class _Q2EmitterEvent extends _$Queue2QueueEvent'),
      );
      expect(
        generated,
        contains(r'class _Q2ComplexEvent extends _$Queue2QueueEvent'),
      );
    });

    test('should generate Queue 5 event (single event)', () async {
      final generated = await generateForSource(complexQueueSource);

      expect(
        generated,
        contains(r'class _Q5SingleEvent extends _$Queue5QueueEvent'),
      );
    });

    test('should generate non-queued event classes', () async {
      final generated = await generateForSource(complexQueueSource);

      expect(generated, contains('class _NormalEvent extends _Event'));
      expect(generated, contains('class _SequentialEvent extends _Event'));
      expect(generated, contains('class _ConcurrentEvent extends _Event'));
      expect(generated, contains('class _RestartableEvent extends _Event'));
      expect(generated, contains('class _DroppableEvent extends _Event'));
    });

    test('should generate proper event fields for Queue 1', () async {
      final generated = await generateForSource(complexQueueSource);

      // _q1Async has int delay parameter
      expect(generated, contains('final int delay;'));

      // _q1WithParams has complex parameters
      expect(generated, contains('final String value;'));
      expect(generated, contains('final int count;'));
      expect(generated, contains('final bool flag;'));
    });

    test('should generate proper event fields for Queue 2', () async {
      final generated = await generateForSource(complexQueueSource);

      // _q2Emitter parameters (skip Emitter)
      expect(generated, contains('final String msg;'));
      expect(generated, contains('final int times;'));
      expect(generated, contains('final String? prefix;'));

      // _q2Complex parameters
      expect(generated, contains('final int a;'));
      expect(generated, contains('final int b;'));
      expect(generated, contains('final String operation;'));
      expect(generated, contains('final bool negate;'));
    });

    test('should register queue handlers with proper transformers', () async {
      final generated = await generateForSource(complexQueueSource);

      expect(generated, contains(r'on<_$Queue1QueueEvent>'));
      expect(
        generated,
        contains(
          r"transformer: bloc._getTransformer<_$Queue1QueueEvent>('queue1')",
        ),
      );

      expect(generated, contains(r'on<_$Queue2QueueEvent>'));
      expect(
        generated,
        contains(
          r"transformer: bloc._getTransformer<_$Queue2QueueEvent>('queue2')",
        ),
      );

      expect(generated, contains(r'on<_$Queue5QueueEvent>'));
      expect(
        generated,
        contains(
          r"transformer: bloc._getTransformer<_$Queue5QueueEvent>('queue5')",
        ),
      );
    });

    test('should generate if-else chain for Queue 1 (3 events)', () async {
      final generated = await generateForSource(complexQueueSource);

      expect(generated, contains('if (event is _Q1SyncEvent)'));
      expect(generated, contains('else if (event is _Q1AsyncEvent)'));
      expect(generated, contains('else if (event is _Q1WithParamsEvent)'));
    });

    test('should generate if-else chain for Queue 2 (3 events)', () async {
      final generated = await generateForSource(complexQueueSource);

      expect(generated, contains('if (event is _Q2StreamEvent)'));
      expect(generated, contains('else if (event is _Q2EmitterEvent)'));
      expect(generated, contains('else if (event is _Q2ComplexEvent)'));
    });

    test('should generate single if statement for Queue 5 (1 event)', () async {
      final generated = await generateForSource(complexQueueSource);

      expect(generated, contains('if (event is _Q5SingleEvent)'));
      // Should not have else-if for single event
      final queue5Handler = RegExp(
        r'on<_\$Queue5QueueEvent>.*?\{.*?if \(event is _Q5SingleEvent\).*?\}',
        multiLine: true,
        dotAll: true,
      );
      expect(queue5Handler.hasMatch(generated), isTrue);
    });

    test(
      'should generate proper wrappers for different return types in Queue 1',
      () async {
        final generated = await generateForSource(complexQueueSource);

        // Sync return: emit(_q1Sync())
        expect(generated, contains('emit(_q1Sync())'));

        // Async return: emit(await _q1Async(...))
        expect(generated, contains('emit(await _q1Async(event.delay))'));

        // Sync with params: emit(_q1WithParams(...))
        expect(generated, contains('_q1WithParams'));
        expect(generated, contains('event.value'));
        expect(generated, contains('count: event.count'));
        expect(generated, contains('flag: event.flag'));
      },
    );

    test(
      'should generate proper wrappers for different return types in Queue 2',
      () async {
        final generated = await generateForSource(complexQueueSource);

        // Stream return: await emit.forEach
        expect(generated, contains('await emit.forEach'));

        // Emitter: await _q2Emitter(emit, ...)
        expect(generated, contains('await _q2Emitter'));
        expect(generated, contains('emit'));
        expect(generated, contains('event.msg'));
        expect(generated, contains('event.times'));
        expect(generated, contains('prefix: event.prefix'));

        // Sync with complex params
        expect(generated, contains('_q2Complex'));
        expect(generated, contains('event.a'));
        expect(generated, contains('event.b'));
        expect(generated, contains('operation: event.operation'));
        expect(generated, contains('negate: event.negate'));
      },
    );

    test('should generate proper wrappers for Queue 5 stream', () async {
      final generated = await generateForSource(complexQueueSource);

      expect(generated, contains('await emit.forEach'));
      expect(generated, contains('event.count'));
    });

    test(
      'should register non-queued events with proper transformers',
      () async {
        final generated = await generateForSource(complexQueueSource);

        // Non-transformer event
        expect(generated, contains('on<_NormalEvent>'));

        // With transformers
        expect(generated, contains('on<_SequentialEvent>'));
        expect(generated, contains('MonoEventTransformer.sequential'));

        expect(generated, contains('on<_ConcurrentEvent>'));
        expect(generated, contains('MonoEventTransformer.concurrent'));

        expect(generated, contains('on<_RestartableEvent>'));
        expect(generated, contains('MonoEventTransformer.restartable'));

        expect(generated, contains('on<_DroppableEvent>'));
        expect(generated, contains('MonoEventTransformer.droppable'));
      },
    );

    test('should generate public methods for all events', () async {
      final generated = await generateForSource(complexQueueSource);

      // Queue 1 public methods
      expect(generated, contains('void q1Sync()'));
      expect(generated, contains('void q1Async(int delay)'));
      expect(generated, contains('void q1WithParams'));
      expect(generated, contains('String value'));
      expect(generated, contains('required int count'));
      expect(generated, contains('bool flag = false'));

      // Queue 2 public methods
      expect(generated, contains('void q2Stream()'));
      expect(generated, contains('void q2Emitter'));
      expect(generated, contains('String msg'));
      expect(generated, contains('int times'));
      expect(generated, contains('String? prefix'));
      expect(generated, contains('void q2Complex'));
      expect(generated, contains('int a'));
      expect(generated, contains('int b'));
      expect(generated, contains('required String operation'));
      expect(generated, contains('bool negate = false'));

      // Queue 5 public method
      expect(generated, contains('void q5Single(int count)'));

      // Non-queued public methods
      expect(generated, contains('void normal()'));
      expect(generated, contains('void sequential(String value)'));
      expect(generated, contains('void concurrent(int id)'));
      expect(generated, contains('void restartable(String prefix)'));
      expect(generated, contains('void droppable(String msg)'));
    });

    test('should call init method from _initialize', () async {
      final generated = await generateForSource(complexQueueSource);

      expect(generated, contains('_initialize();'));
    });

    test('should generate base class with correct signature', () async {
      final generated = await generateForSource(complexQueueSource);

      // Base class should use <_> template and actual String state type
      expect(generated, contains(r'abstract class _$ComplexQueueBloc<_>'));
      expect(generated, contains('extends Bloc<_Event, String>'));

      // Constructor should use super.initialState
      expect(generated, contains(r'_$ComplexQueueBloc'));
      expect(generated, contains('super.initialState'));

      // Should have private _queues field
      expect(
        generated,
        contains('final Map<String, EventTransformer<dynamic>> _queues;'),
      );

      // Should have private _$init method
      expect(generated, contains(r'void _$init()'));
    });

    test('should handle all event counts correctly', () async {
      final generated = await generateForSource(complexQueueSource);

      // Count event class declarations using regex
      // Pattern must match _$Queue1Event, _NormalEvent, etc.
      final eventClassPattern = RegExp(r'class _[\w$]+Event extends');
      final eventClassCount = eventClassPattern.allMatches(generated).length;

      // Total: 3 queues + 7 queued + 5 non-queued + 1 @onInit = 16 event classes
      expect(
        eventClassCount,
        equals(16),
      ); // 3 queue base + 7 queued + 5 non-queued + 1 init
    });

    test('should generate proper parameter passing for all events', () async {
      final generated = await generateForSource(complexQueueSource);

      // Check that all add() calls pass parameters correctly
      expect(generated, contains('add'));
      expect(generated, contains('_Q1AsyncEvent(delay)'));

      expect(generated, contains('_Q1WithParamsEvent'));
      expect(generated, contains('value'));
      expect(generated, contains('count: count'));
      expect(generated, contains('flag: flag'));

      expect(generated, contains('_Q2EmitterEvent'));
      expect(generated, contains('msg'));
      expect(generated, contains('times'));
      expect(generated, contains('prefix: prefix'));

      expect(generated, contains('_Q2ComplexEvent'));
      expect(generated, contains('a,'));
      expect(generated, contains('b,'));
      expect(generated, contains('operation: operation'));
      expect(generated, contains('negate: negate'));
    });
  });
}
