import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - Concurrent/Queue Edge Cases', () {
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

    test('should handle queue with name "zero"', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent.queue('zero')
          TestState _onEvent1() => TestState();
          
          @MonoEvent.queue('zero')
          TestState _onEvent2() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, isNotEmpty);
    });

    test('should handle queues with long names', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent.queue('very_long_queue_name_one')
          TestState _onEvent1() => TestState();
          
          @MonoEvent.queue('very_long_queue_name_two')
          TestState _onEvent2() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, isNotEmpty);
    });

    test('should handle mix of queued and non-queued events', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @event
          TestState _onEvent1() => TestState();
          
          @MonoEvent.queue('queue1')
          TestState _onEvent2() => TestState();
          
          @event
          TestState _onEvent3() => TestState();
          
          @MonoEvent.queue('queue1')
          TestState _onEvent4() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, isNotEmpty);
    });

    test('should handle sequential mode with queue names', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc(sequential: true)
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent.queue('queue1')
          TestState _onEvent1() => TestState();
          
          @MonoEvent.queue('queue2')
          TestState _onEvent2() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, isNotEmpty);
    });

    test('should handle all concurrency types', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @restartableEvent
          TestState _onRestartable() => TestState();
          
          @concurrentEvent
          TestState _onConcurrent() => TestState();
          
          @droppableEvent
          TestState _onDroppable() => TestState();
          
          @sequentialEvent
          TestState _onSequential() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('restartable'));
      expect(generated, contains('concurrent'));
      expect(generated, contains('droppable'));
      expect(generated, contains('sequential'));
    });

    test(
      'should handle default concurrency with per-event overrides',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc(concurrency: MonoConcurrency.sequential)
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @event
          TestState _onDefaultMode() => TestState();
          
          @restartableEvent
          TestState _onRestartable() => TestState();
          
          @concurrentEvent
          TestState _onConcurrent() => TestState();
        }
      ''';

        final generated = await generateForSource(source);

        expect(generated, isNotEmpty);
      },
    );

    test('should handle multiple different queue names', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent.queue('upload')
          TestState _onEvent1() => TestState();
          
          @MonoEvent.queue('download')
          TestState _onEvent2() => TestState();
          
          @MonoEvent.queue('sync')
          TestState _onEvent3() => TestState();
          
          @MonoEvent.queue('delete')
          TestState _onEvent4() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, isNotEmpty);
    });

    test('should handle many events in same queue', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent.queue('shared')
          TestState _onEvent1() => TestState();
          
          @MonoEvent.queue('shared')
          TestState _onEvent2() => TestState();
          
          @MonoEvent.queue('shared')
          TestState _onEvent3() => TestState();
          
          @MonoEvent.queue('shared')
          TestState _onEvent4() => TestState();
          
          @MonoEvent.queue('shared')
          TestState _onEvent5() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, isNotEmpty);
    });

    test('should handle queues with different concurrency modes', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent.queue('restartQueue')
          @restartableEvent
          TestState _onRestartable() => TestState();
          
          @MonoEvent.queue('dropQueue')
          @droppableEvent
          TestState _onDroppable() => TestState();
          
          @MonoEvent.queue('concurrentQueue')
          @concurrentEvent
          TestState _onConcurrent() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, isNotEmpty);
    });

    test('should handle sequential mode with mixed event types', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc(sequential: true)
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @event
          TestState _onSync() => TestState();
          
          @event
          Future<TestState> _onAsync() async => TestState();
          
          @event
          Stream<TestState> _onStreamData() async* {
            yield TestState();
          }
          
          @event
          void _onEmitter(_Emitter emit) {
            emit(TestState());
          }
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, isNotEmpty);
    });

    test(
      'should handle event with both concurrency and queue specified',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent.queue('myQueue')
          @restartableEvent
          TestState _onEvent() => TestState();
        }
      ''';

        final generated = await generateForSource(source);

        expect(generated, isNotEmpty);
      },
    );

    test(
      'should handle bloc with only sequential annotation (no events)',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc(sequential: true)
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
        }
      ''';

        final generated = await generateForSource(source);

        expect(generated, isNotEmpty);
      },
    );

    test('should handle concurrent event returning Stream', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @concurrentEvent
          Stream<TestState> _onStreamData() async* {
            yield TestState();
          }
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('concurrent'));
    });

    test('should handle restartable event with Emitter', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @restartableEvent
          void _onEvent(_Emitter emit) {
            emit(TestState());
          }
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('restartable'));
    });
  });
}
