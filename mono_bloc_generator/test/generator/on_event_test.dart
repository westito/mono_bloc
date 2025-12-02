import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - @onEvent Generation', () {
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
      'should generate _filterEvent for all events handler (_Event)',
      () async {
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
          
          @event
          TestState _onDecrement() => TestState();
          
          @onEvent
          bool _filterAll(_Event event) {
            // Allow all events
            return true;
          }
        }
      ''';

        final output = await generateForSource(source);

        // Should generate _filterEvent method
        expect(output, contains('bool _filterEvent(dynamic event)'));

        // Should have fallback to all events handler
        expect(output, contains('// Fallback to all events handler'));
        expect(output, contains(r'return $._filterAll(event as _Event)'));

        // Should generate _wrapWithOnEvent wrapper
        expect(output, contains('EventTransformer<E> _wrapWithOnEvent<E>('));
        expect(output, contains('(event) => _filterEvent(event)'));

        // Should wrap event registrations
        expect(output, contains('_wrapWithOnEvent'));
      },
    );

    test('should generate _filterEvent for specific event handler', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class CounterBloc extends _$CounterBloc<TestState> {
          CounterBloc() : super(TestState());
          
          @event
          TestState _onIncrement() => TestState();
          
          @event
          TestState _onDecrement() => TestState();
          
          @onEvent
          bool _filterIncrement(_IncrementEvent event) {
            // Only filter increment events
            return false; // Block increment
          }
        }
      ''';

      final output = await generateForSource(source);

      // Should generate _filterEvent with specific event check
      expect(output, contains('bool _filterEvent(dynamic event)'));
      expect(output, contains('// Check specific event type first'));
      expect(output, contains('if (event is _IncrementEvent)'));
      expect(output, contains(r'return $._filterIncrement(event)'));

      // Should have fallback for non-matching events
      expect(output, contains('// No matching handler, allow event'));
      expect(output, contains('return true;'));
    });

    test(
      r'should generate _filterEvent for event group (_$SequentialEvent)',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class TaskBloc extends _$TaskBloc<TestState> {
          TaskBloc() : super(TestState());
          
          @sequentialEvent
          TestState _onProcess() => TestState();
          
          @sequentialEvent
          TestState _onExecute() => TestState();
          
          @event
          TestState _onStatus() => TestState();
          
          @onEvent
          bool _filterSequential(_$SequentialEvent event) {
            // Filter all sequential events
            return false; // Block sequential events
          }
        }
      ''';

        final output = await generateForSource(source);

        // Should generate _filterEvent with group check
        expect(output, contains('bool _filterEvent(dynamic event)'));
        expect(output, contains(r'if (event is _$SequentialEvent)'));
        expect(output, contains(r'return $._filterSequential(event)'));

        // Non-sequential events should pass through
        expect(output, contains('return true;'));
      },
    );

    test('should handle multiple onEvent handlers with hierarchy', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class ComplexBloc extends _$ComplexBloc<TestState> {
          ComplexBloc() : super(TestState());
          
          @sequentialEvent
          TestState _onSave() => TestState();
          
          @event
          TestState _onLoad() => TestState();
          
          @event
          TestState _onRefresh() => TestState();
          
          // Specific event filter - highest priority
          @onEvent
          bool _filterLoad(_LoadEvent event) {
            return false; // Block load
          }
          
          // Event group filter - medium priority
          @onEvent
          bool _filterSequentialGroup(_$SequentialEvent event) {
            return false; // Block all sequential
          }
          
          // All events filter - lowest priority (fallback)
          @onEvent
          bool _filterAllEvents(_Event event) {
            return true; // Allow all others
          }
        }
      ''';

      final output = await generateForSource(source);

      // Should generate hierarchical checks
      expect(output, contains('bool _filterEvent(dynamic event)'));

      // Specific event check first
      expect(output, contains('if (event is _LoadEvent)'));
      expect(output, contains(r'return $._filterLoad(event)'));

      // Group event check second
      expect(output, contains(r'if (event is _$SequentialEvent)'));
      expect(output, contains(r'return $._filterSequentialGroup(event)'));

      // All events fallback last
      expect(output, contains('// Fallback to all events handler'));
      expect(output, contains(r'return $._filterAllEvents(event as _Event)'));
    });

    test('should handle queue event group filtering', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class QueueBloc extends _$QueueBloc<TestState> {
          QueueBloc() : super(TestState(), queues: {'queue1': null});
          
          @MonoEvent.queue('queue1')
          TestState _onUpload() => TestState();
          
          @MonoEvent.queue('queue1')
          TestState _onDownload() => TestState();
          
          @event
          TestState _onStatus() => TestState();
          
          @onEvent
          bool _filterQueue1(_$Queue1QueueEvent event) {
            // Filter queue 'queue1' events
            return true; // Allow queue 'queue1'
          }
        }
      ''';

      final output = await generateForSource(source);

      // Should generate _filterEvent with queue group check
      expect(output, contains('bool _filterEvent(dynamic event)'));
      expect(output, contains(r'if (event is _$Queue1QueueEvent)'));
      expect(output, contains(r'return $._filterQueue1(event)'));
    });

    test('should wrap all event registrations with onEvent filter', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class WrapperBloc extends _$WrapperBloc<TestState> {
          WrapperBloc() : super(TestState());
          
          @event
          TestState _onAction1() => TestState();
          
          @restartableEvent
          TestState _onAction2() => TestState();
          
          @sequentialEvent
          TestState _onAction3() => TestState();
          
          @onEvent
          bool _filterAll(_Event event) => true;
        }
      ''';

      final output = await generateForSource(source);

      // All registrations should be wrapped
      expect(output, contains('on<_Action1Event>('));
      expect(output, contains('_wrapWithOnEvent'));

      // Restartable event should be wrapped
      expect(output, contains('on<_Action2Event>('));

      // Sequential event should be wrapped (individual registration, not grouped)
      expect(output, contains('on<_Action3Event>('));
    });

    test('should not generate onEvent helpers without @onEvent', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class NoFilterBloc extends _$NoFilterBloc<TestState> {
          NoFilterBloc() : super(TestState());
          
          @event
          TestState _onAction() => TestState();
        }
      ''';

      final output = await generateForSource(source);

      // Should NOT generate filter methods
      expect(output, isNot(contains('_filterEvent')));
      expect(output, isNot(contains('_wrapWithOnEvent')));
    });

    test('should handle conditional logic in specific event handler', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        class TestState {
          final bool isLoading;
          TestState(this.isLoading);
        }
        
        @MonoBloc()
        class ConditionalBloc extends _$ConditionalBloc<TestState> {
          ConditionalBloc() : super(TestState(false));
          
          @event
          TestState _onLoadData() => TestState(true);
          
          @event
          TestState _onSaveData() => TestState(false);
          
          @onEvent
          bool _filterLoadWhenBusy(_LoadDataEvent event) {
            // Skip load if already loading
            return !state.isLoading;
          }
        }
      ''';

      final output = await generateForSource(source);

      // Should generate specific event filter
      expect(output, contains('if (event is _LoadDataEvent)'));
      expect(output, contains(r'return $._filterLoadWhenBusy(event)'));
    });

    test('should allow multiple specific event handlers', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class MultiFilterBloc extends _$MultiFilterBloc<TestState> {
          MultiFilterBloc() : super(TestState());
          
          @event
          TestState _onAction1() => TestState();
          
          @event
          TestState _onAction2() => TestState();
          
          @event
          TestState _onAction3() => TestState();
          
          @onEvent
          bool _filterAction1(_Action1Event event) => false;
          
          @onEvent
          bool _filterAction2(_Action2Event event) => false;
          
          @onEvent
          bool _filterAction3(_Action3Event event) => true;
        }
      ''';

      final output = await generateForSource(source);

      // Should generate checks for all specific events
      expect(output, contains('if (event is _Action1Event)'));
      expect(output, contains(r'return $._filterAction1(event)'));

      expect(output, contains('if (event is _Action2Event)'));
      expect(output, contains(r'return $._filterAction2(event)'));

      expect(output, contains('if (event is _Action3Event)'));
      expect(output, contains(r'return $._filterAction3(event)'));
    });

    test('should maintain order: specific > group > all', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class OrderBloc extends _$OrderBloc<TestState> {
          OrderBloc() : super(TestState());
          
          @sequentialEvent
          TestState _onSeq1() => TestState();
          
          @sequentialEvent  
          TestState _onSeq2() => TestState();
          
          @event
          TestState _onOther() => TestState();
          
          @onEvent
          bool _all(_Event event) => true;
          
          @onEvent
          bool _group(_$SequentialEvent event) => false;
          
          @onEvent
          bool _specific(_Seq1Event event) => true;
        }
      ''';

      final output = await generateForSource(source);

      // Find positions of each check
      final specificPos = output.indexOf('if (event is _Seq1Event)');
      final groupPos = output.indexOf(r'if (event is _$SequentialEvent)');
      final allPos = output.indexOf('// Fallback to all events handler');

      // Verify order
      expect(
        specificPos,
        lessThan(groupPos),
        reason: 'Specific event check should come before group',
      );
      expect(
        groupPos,
        lessThan(allPos),
        reason: 'Group event check should come before all events fallback',
      );
    });
  });
}
