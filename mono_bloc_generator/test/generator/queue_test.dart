import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - Queues', () {
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

    test('should generate queue base classes', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestEvent {}
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent.queue('myQueue')
          TestState _queued(int value) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains(r'class _$MyQueueQueueEvent extends _Event'));
      expect(
        generated,
        contains(r'class _QueuedEvent extends _$MyQueueQueueEvent'),
      );
    });

    test('should register queue events with transformer', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent.queue('myQueue')
          TestState _queued(int value) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains(r'on<_$MyQueueQueueEvent>'));
      expect(
        generated,
        contains(
          r"transformer: bloc._getTransformer<_$MyQueueQueueEvent>('myQueue')",
        ),
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
          
          @MonoEvent.queue('queue_a')
          TestState _queue5() => TestState();
          
          @MonoEvent.queue('queue_b')
          TestState _queue10() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains(r'class _$QueueAQueueEvent extends _Event'));
      expect(generated, contains(r'class _$QueueBQueueEvent extends _Event'));
      expect(generated, contains(r'on<_$QueueAQueueEvent>'));
      expect(generated, contains(r'on<_$QueueBQueueEvent>'));
    });

    test('should group multiple events in same queue', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class GroupedBloc extends _$GroupedBloc<TestState> {
          GroupedBloc() : super(TestState());
          
          @MonoEvent.queue('upload')
          TestState _onFirst() => TestState();
          
          @MonoEvent.queue('upload')
          TestState _onSecond(int value) => TestState();
          
          @MonoEvent.queue('upload')
          TestState _onThird(String name, {bool flag = false}) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      // Should create only one queue base class for upload queue
      expect(generated, contains(r'class _$UploadQueueEvent extends _Event'));

      // All three events should extend _\$UploadQueueEvent (method _onFirst -> OnFirst -> _FirstEvent)
      expect(
        generated,
        contains(r'class _FirstEvent extends _$UploadQueueEvent'),
      );
      expect(
        generated,
        contains(r'class _SecondEvent extends _$UploadQueueEvent'),
      );
      expect(
        generated,
        contains(r'class _ThirdEvent extends _$UploadQueueEvent'),
      );

      // Should have only one on<_\$UploadQueueEvent> handler
      expect(generated, contains(r'on<_$UploadQueueEvent>'));

      // Should have if-else chain for all three events
      expect(generated, contains('if (event is _FirstEvent)'));
      expect(generated, contains('else if (event is _SecondEvent)'));
      expect(generated, contains('else if (event is _ThirdEvent)'));

      // Should use queue transformer
      expect(
        generated,
        contains(
          r"transformer: bloc._getTransformer<_$UploadQueueEvent>('upload')",
        ),
      );
    });

    test('should handle non-sequential queue numbers', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class NonSeqBloc extends _$NonSeqBloc<TestState> {
          NonSeqBloc() : super(TestState());
          
          @MonoEvent.queue('highPriority')
          TestState _queue100() => TestState();
          
          @MonoEvent.queue('lowPriority')
          TestState _queue5() => TestState();
          
          @MonoEvent.queue('mediumPriority')
          TestState _queue42() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(
        generated,
        contains(r'class _$HighPriorityQueueEvent extends _Event'),
      );
      expect(
        generated,
        contains(r'class _$LowPriorityQueueEvent extends _Event'),
      );
      expect(
        generated,
        contains(r'class _$MediumPriorityQueueEvent extends _Event'),
      );

      expect(generated, contains(r'_getTransformer<_$HighPriorityQueueEvent>'));
      expect(generated, contains("'highPriority'"));
      expect(generated, contains(r'_getTransformer<_$LowPriorityQueueEvent>'));
      expect(generated, contains("'lowPriority'"));
      expect(
        generated,
        contains(r'_getTransformer<_$MediumPriorityQueueEvent>'),
      );
      expect(generated, contains("'mediumPriority'"));
    });

    test('should mix queued and non-queued events', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class MixedBloc extends _$MixedBloc<TestState> {
          MixedBloc() : super(TestState());
          
          @event
          TestState _onNormal1() => TestState();
          
          @MonoEvent.queue('download')
          TestState _onQueued1() => TestState();
          
          @event
          TestState _onNormal2() => TestState();
          
          @MonoEvent.queue('download')
          TestState _onQueued2() => TestState();
          
          @MonoEvent(MonoConcurrency.sequential)
          TestState _onSequential() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      // Queue base class should exist
      expect(generated, contains(r'class _$DownloadQueueEvent extends _Event'));

      // Queued events extend queue base (_onQueued1 -> OnQueued1 -> _Queued1Event)
      expect(
        generated,
        contains(r'class _Queued1Event extends _$DownloadQueueEvent'),
      );
      expect(
        generated,
        contains(r'class _Queued2Event extends _$DownloadQueueEvent'),
      );

      // Non-queued events extend main event base
      expect(generated, contains('class _Normal1Event extends _Event'));
      expect(generated, contains('class _Normal2Event extends _Event'));
      expect(generated, contains('class _SequentialEvent extends _Event'));

      // Separate registrations for queued vs non-queued
      expect(generated, contains(r'on<_$DownloadQueueEvent>'));
      expect(generated, contains('on<_Normal1Event>'));
      expect(generated, contains('on<_Normal2Event>'));
      expect(generated, contains('on<_SequentialEvent>'));

      // Sequential should have transformer
      expect(generated, contains('MonoEventTransformer.sequential'));
    });

    test('should handle queue with different return types', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        import 'package:bloc/bloc.dart';
        
        part 'test_bloc.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class ReturnTypeBloc extends _$ReturnTypeBloc<TestState> {
          ReturnTypeBloc() : super(TestState());
          
          @MonoEvent.queue('process')
          TestState _sync() => TestState();
          
          @MonoEvent.queue('process')
          Future<TestState> _async() async => TestState();
          
          @MonoEvent.queue('process')
          Stream<TestState> _streamData() async* {
            yield TestState();
          }
          
          @MonoEvent.queue('process')
          Future<void> _emitter(_Emitter emit) async {
            emit(TestState());
          }
        }
      ''';

      final generated = await generateForSource(source);

      // All should be in same queue
      expect(
        generated,
        contains(r'class _SyncEvent extends _$ProcessQueueEvent'),
      );
      expect(
        generated,
        contains(r'class _AsyncEvent extends _$ProcessQueueEvent'),
      );
      expect(
        generated,
        contains(r'class _StreamDataEvent extends _$ProcessQueueEvent'),
      );
      expect(
        generated,
        contains(r'class _EmitterEvent extends _$ProcessQueueEvent'),
      );

      // Check proper wrapper generation for each type
      expect(generated, contains('if (event is _SyncEvent)'));
      expect(generated, contains('emit(_sync())'));

      expect(generated, contains('if (event is _AsyncEvent)'));
      expect(generated, contains('emit(await _async())'));

      expect(generated, contains('if (event is _StreamDataEvent)'));
      expect(
        generated,
        contains('await emit.forEach<TestState>('),
      );
      expect(generated, contains('_streamData()'));
      expect(generated, contains('onData: (state) => state'));

      expect(generated, contains('if (event is _EmitterEvent)'));
      expect(generated, contains('await _emitter(emit)'));
    });

    test('should handle queue with complex parameters', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class ParamBloc extends _$ParamBloc<TestState> {
          ParamBloc() : super(TestState());
          
          @MonoEvent.queue('sync')
          TestState _onPositional(int a, String b) => TestState();
          
          @MonoEvent.queue('sync')
          TestState _onNamed({required int x, String? y}) => TestState();
          
          @MonoEvent.queue('sync')
          TestState _onMixed(int pos, {required String named, bool opt = false}) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      // Event classes should have proper fields
      expect(generated, contains('final int a;'));
      expect(generated, contains('final String b;'));
      expect(generated, contains('final int x;'));
      expect(generated, contains('final String? y;'));
      expect(generated, contains('final int pos;'));
      expect(generated, contains('final String named;'));
      expect(generated, contains('final bool opt;'));

      // Should pass parameters correctly to handlers
      expect(generated, contains('_onPositional(event.a, event.b)'));
      expect(generated, contains('_onNamed(x: event.x, y: event.y)'));
      expect(generated, contains('_onMixed'));
      expect(generated, contains('event.pos'));
      expect(generated, contains('named: event.named'));
      expect(generated, contains('opt: event.opt'));
    });

    test('should handle single event in queue (edge case)', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SingleQueueBloc extends _$SingleQueueBloc<TestState> {
          SingleQueueBloc() : super(TestState());
          
          @MonoEvent.queue('critical')
          TestState _onlySingle() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains(r'class _$CriticalQueueEvent extends _Event'));
      expect(
        generated,
        contains(r'class _OnlySingleEvent extends _$CriticalQueueEvent'),
      );
      expect(generated, contains(r'on<_$CriticalQueueEvent>'));

      // Should still use if (not else-if) for single event
      expect(generated, contains('if (event is _OnlySingleEvent)'));
      expect(
        generated,
        contains(
          r"transformer: bloc._getTransformer<_$CriticalQueueEvent>('critical')",
        ),
      );
    });

    test('should handle multiple queues with multiple events each', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class MultiQueueBloc extends _$MultiQueueBloc<TestState> {
          MultiQueueBloc() : super(TestState());
          
          @MonoEvent.queue('fileUpload')
          TestState _q1First() => TestState();
          
          @MonoEvent.queue('fileUpload')
          TestState _q1Second() => TestState();
          
          @MonoEvent.queue('fileDownload')
          TestState _q2First() => TestState();
          
          @MonoEvent.queue('fileDownload')
          TestState _q2Second() => TestState();
          
          @MonoEvent.queue('fileDownload')
          TestState _q2Third() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      // Two queue base classes
      expect(
        generated,
        contains(r'class _$FileUploadQueueEvent extends _Event'),
      );
      expect(
        generated,
        contains(r'class _$FileDownloadQueueEvent extends _Event'),
      );

      // Queue 1 events
      expect(
        generated,
        contains(r'class _Q1FirstEvent extends _$FileUploadQueueEvent'),
      );
      expect(
        generated,
        contains(r'class _Q1SecondEvent extends _$FileUploadQueueEvent'),
      );

      // Queue 2 events
      expect(
        generated,
        contains(r'class _Q2FirstEvent extends _$FileDownloadQueueEvent'),
      );
      expect(
        generated,
        contains(r'class _Q2SecondEvent extends _$FileDownloadQueueEvent'),
      );
      expect(
        generated,
        contains(r'class _Q2ThirdEvent extends _$FileDownloadQueueEvent'),
      );

      // Two separate handlers
      expect(generated, contains(r'on<_$FileUploadQueueEvent>'));
      expect(generated, contains(r'on<_$FileDownloadQueueEvent>'));

      // Queue 1 should have both events checked
      expect(generated, contains('if (event is _Q1FirstEvent)'));
      expect(generated, contains('else if (event is _Q1SecondEvent)'));

      // Queue 2 should have all three events checked
      expect(generated, contains('if (event is _Q2FirstEvent)'));
      expect(generated, contains('else if (event is _Q2SecondEvent)'));
      expect(generated, contains('else if (event is _Q2ThirdEvent)'));

      // Should use queue transformers
      expect(generated, contains(r'_getTransformer<_$FileUploadQueueEvent>'));
      expect(generated, contains("'fileUpload'"));
      expect(generated, contains(r'_getTransformer<_$FileDownloadQueueEvent>'));
      expect(generated, contains("'fileDownload'"));
    });

    test(
      'should not use queues field reference in _init for non-queued events',
      () async {
        const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class NoQueueBloc extends _$NoQueueBloc<TestState> {
          NoQueueBloc() : super(TestState());
          
          @event
          TestState _onNormal() => TestState();
          
          @MonoEvent(MonoConcurrency.sequential)
          TestState _onSequential() => TestState();
        }
      ''';

        final generated = await generateForSource(source);

        // Should not contain _getTransformer reference for non-queued events
        expect(generated, isNot(contains('_getTransformer')));

        // Should NOT have _queues field when there are no queued events
        expect(generated, isNot(contains('_queues')));

        // Should have transformers for decorated events
        expect(generated, contains('MonoEventTransformer.sequential'));
      },
    );
  });
}
