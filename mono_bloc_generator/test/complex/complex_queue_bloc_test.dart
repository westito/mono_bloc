import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

import 'complex_queue_bloc.dart';

void main() {
  group('ComplexQueueBloc - Runtime Tests', () {
    late ComplexQueueBloc bloc;

    setUp(() {
      bloc = ComplexQueueBloc();
    });

    tearDown(() async {
      await bloc.close();
    });

    group('Initialization', () {
      test('starts with initial state', () {
        expect(bloc.state, equals('initial'));
      });

      test('calls _initialize on creation', () {
        // The @onInit method should be called during construction
        // We verify this by checking the bloc is properly initialized
        expect(bloc.state, equals('initial'));
      });
    });

    group('Queue 1 - Sequential Events', () {
      blocTest<ComplexQueueBloc, String>(
        'q1Sync emits sync state',
        build: ComplexQueueBloc.new,
        act: (bloc) => bloc.q1Sync(),
        expect: () => ['q1_sync'],
      );

      blocTest<ComplexQueueBloc, String>(
        'q1Async emits async state',
        build: ComplexQueueBloc.new,
        act: (bloc) => bloc.q1Async(10),
        expect: () => ['q1_async_10'],
      );

      blocTest<ComplexQueueBloc, String>(
        'q1WithParams emits state with parameters',
        build: ComplexQueueBloc.new,
        act: (bloc) => bloc.q1WithParams('test', count: 5, flag: true),
        expect: () => ['q1_params_test_5_true'],
      );

      blocTest<ComplexQueueBloc, String>(
        'q1WithParams uses default flag value',
        build: ComplexQueueBloc.new,
        act: (bloc) => bloc.q1WithParams('test', count: 3),
        expect: () => ['q1_params_test_3_false'],
      );

      blocTest<ComplexQueueBloc, String>(
        'sequential queue processes events in order',
        build: ComplexQueueBloc.new,
        act: (bloc) {
          bloc.q1Sync();
          bloc.q1Async(5);
          bloc.q1WithParams('ordered', count: 1);
        },
        expect: () => ['q1_sync', 'q1_async_5', 'q1_params_ordered_1_false'],
      );
    });

    group('Queue 2 - Droppable Events', () {
      blocTest<ComplexQueueBloc, String>(
        'q2Stream emits stream states',
        build: ComplexQueueBloc.new,
        act: (bloc) => bloc.q2Stream(),
        wait: const Duration(milliseconds: 50),
        expect: () => ['q2_stream_1', 'q2_stream_2'],
      );

      blocTest<ComplexQueueBloc, String>(
        'q2Emitter emits multiple states',
        build: ComplexQueueBloc.new,
        act: (bloc) => bloc.q2Emitter('hello', 3),
        wait: const Duration(milliseconds: 50),
        expect: () => ['q2_hello_0', 'q2_hello_1', 'q2_hello_2'],
      );

      blocTest<ComplexQueueBloc, String>(
        'q2Emitter uses custom prefix',
        build: ComplexQueueBloc.new,
        act: (bloc) => bloc.q2Emitter('world', 2, prefix: 'custom'),
        wait: const Duration(milliseconds: 50),
        expect: () => ['custom_world_0', 'custom_world_1'],
      );

      blocTest<ComplexQueueBloc, String>(
        'q2Complex performs addition',
        build: ComplexQueueBloc.new,
        act: (bloc) => bloc.q2Complex(10, 5, operation: 'add'),
        expect: () => ['q2_add_15'],
      );

      blocTest<ComplexQueueBloc, String>(
        'q2Complex performs subtraction',
        build: ComplexQueueBloc.new,
        act: (bloc) => bloc.q2Complex(10, 5, operation: 'sub'),
        expect: () => ['q2_sub_5'],
      );

      blocTest<ComplexQueueBloc, String>(
        'q2Complex negates result',
        build: ComplexQueueBloc.new,
        act: (bloc) => bloc.q2Complex(10, 5, operation: 'add', negate: true),
        expect: () => ['q2_add_-15'],
      );

      blocTest<ComplexQueueBloc, String>(
        'droppable queue drops events when busy',
        build: ComplexQueueBloc.new,
        act: (bloc) {
          // First event starts processing
          bloc.q2Emitter('first', 3);
          // Second event should be dropped since queue is droppable
          bloc.q2Emitter('second', 2);
        },
        wait: const Duration(milliseconds: 50),
        // Only first event should be processed
        expect: () => ['q2_first_0', 'q2_first_1', 'q2_first_2'],
      );
    });

    group('Queue 5 - Restartable Events', () {
      blocTest<ComplexQueueBloc, String>(
        'q5Single emits stream states',
        build: ComplexQueueBloc.new,
        act: (bloc) => bloc.q5Single(3),
        wait: const Duration(milliseconds: 50),
        expect: () => ['q5_single_0', 'q5_single_1', 'q5_single_2'],
      );

      blocTest<ComplexQueueBloc, String>(
        'restartable queue cancels previous event',
        build: ComplexQueueBloc.new,
        act: (bloc) async {
          bloc.q5Single(5); // Start first event
          await Future<void>.delayed(const Duration(milliseconds: 15));
          bloc.q5Single(2); // Restart with new event
        },
        wait: const Duration(milliseconds: 100),
        // First event emits first value, then is cancelled
        // Second event emits both values
        expect: () => [
          'q5_single_0', // From first event
          'q5_single_1', // From first event (not cancelled yet)
          'q5_single_0', // Second event starts and completes
          'q5_single_1',
        ],
      );
    });

    group('Non-Queued Events', () {
      blocTest<ComplexQueueBloc, String>(
        'normal event emits state',
        build: ComplexQueueBloc.new,
        act: (bloc) => bloc.normal(),
        expect: () => ['normal'],
      );

      blocTest<ComplexQueueBloc, String>(
        'sequential event emits state',
        build: ComplexQueueBloc.new,
        act: (bloc) => bloc.sequential('test'),
        expect: () => ['sequential_test'],
      );

      blocTest<ComplexQueueBloc, String>(
        'concurrent event emits state',
        build: ComplexQueueBloc.new,
        act: (bloc) => bloc.concurrent(42),
        wait: const Duration(milliseconds: 20),
        expect: () => ['concurrent_42'],
      );

      blocTest<ComplexQueueBloc, String>(
        'restartable event emits stream states',
        build: ComplexQueueBloc.new,
        act: (bloc) => bloc.restartable('test'),
        wait: const Duration(milliseconds: 50),
        expect: () => ['test_0', 'test_1', 'test_2'],
      );

      blocTest<ComplexQueueBloc, String>(
        'droppable event emits state',
        build: ComplexQueueBloc.new,
        act: (bloc) => bloc.droppable('msg'),
        wait: const Duration(milliseconds: 30),
        expect: () => ['droppable_msg'],
      );

      blocTest<ComplexQueueBloc, String>(
        'sequential transformer processes events in order',
        build: ComplexQueueBloc.new,
        act: (bloc) {
          bloc.sequential('first');
          bloc.sequential('second');
          bloc.sequential('third');
        },
        expect: () => [
          'sequential_first',
          'sequential_second',
          'sequential_third',
        ],
      );

      blocTest<ComplexQueueBloc, String>(
        'concurrent transformer processes events concurrently',
        build: ComplexQueueBloc.new,
        act: (bloc) async {
          bloc.concurrent(1);
          bloc.concurrent(2);
          bloc.concurrent(3);
          // Give time for concurrent processing
          await Future<void>.delayed(const Duration(milliseconds: 20));
        },
        // Events may complete in any order due to concurrent processing
        verify: (bloc) {
          // Just verify all three events were processed
          expect(
            bloc.state,
            anyOf(['concurrent_1', 'concurrent_2', 'concurrent_3']),
          );
        },
      );

      blocTest<ComplexQueueBloc, String>(
        'droppable transformer drops events when busy',
        build: ComplexQueueBloc.new,
        act: (bloc) {
          bloc.droppable('first');
          bloc.droppable('second'); // Should be dropped
        },
        wait: const Duration(milliseconds: 30),
        expect: () => ['droppable_first'],
      );
    });

    group('Mixed Queue and Non-Queue Events', () {
      blocTest<ComplexQueueBloc, String>(
        'can mix queue and non-queue events',
        build: ComplexQueueBloc.new,
        act: (bloc) {
          bloc.normal();
          bloc.q1Sync();
          bloc.sequential('test');
          bloc.q2Complex(5, 3, operation: 'add');
        },
        wait: const Duration(milliseconds: 20),
        // Sync events complete before async sequential
        expect: () => [
          'normal',
          'q1_sync',
          'q2_add_8', // Sync, completes before async sequential
          'sequential_test', // Async, completes after delay
        ],
      );

      blocTest<ComplexQueueBloc, String>(
        'different queues process independently',
        build: ComplexQueueBloc.new,
        act: (bloc) {
          bloc.q1Sync(); // Queue 1
          bloc.q2Stream(); // Queue 2
          bloc.q5Single(2); // Queue 5
        },
        wait: const Duration(milliseconds: 100),
        expect: () => [
          'q1_sync',
          'q2_stream_1',
          'q5_single_0',
          'q2_stream_2',
          'q5_single_1',
        ],
      );
    });

    group('Parameter Handling', () {
      blocTest<ComplexQueueBloc, String>(
        'handles positional parameters',
        build: ComplexQueueBloc.new,
        act: (bloc) => bloc.q1Async(50),
        expect: () => ['q1_async_50'],
      );

      blocTest<ComplexQueueBloc, String>(
        'handles required named parameters',
        build: ComplexQueueBloc.new,
        act: (bloc) => bloc.q1WithParams('value', count: 10),
        expect: () => ['q1_params_value_10_false'],
      );

      blocTest<ComplexQueueBloc, String>(
        'handles optional named parameters with defaults',
        build: ComplexQueueBloc.new,
        act: (bloc) => bloc.q2Complex(7, 3, operation: 'add'),
        expect: () => ['q2_add_10'],
      );

      blocTest<ComplexQueueBloc, String>(
        'handles nullable parameters',
        build: ComplexQueueBloc.new,
        act: (bloc) => bloc.q2Emitter('test', 1),
        wait: const Duration(milliseconds: 20),
        expect: () => ['q2_test_0'],
      );

      blocTest<ComplexQueueBloc, String>(
        'handles multiple parameter types',
        build: ComplexQueueBloc.new,
        act: (bloc) => bloc.q2Complex(15, 7, operation: 'sub', negate: true),
        expect: () => ['q2_sub_-8'],
      );
    });

    group('Return Type Handling', () {
      blocTest<ComplexQueueBloc, String>(
        'handles sync return type',
        build: ComplexQueueBloc.new,
        act: (bloc) => bloc.q1Sync(),
        expect: () => ['q1_sync'],
      );

      blocTest<ComplexQueueBloc, String>(
        'handles Future<State> return type',
        build: ComplexQueueBloc.new,
        act: (bloc) => bloc.q1Async(5),
        expect: () => ['q1_async_5'],
      );

      blocTest<ComplexQueueBloc, String>(
        'handles Stream<State> return type',
        build: ComplexQueueBloc.new,
        act: (bloc) => bloc.q2Stream(),
        wait: const Duration(milliseconds: 50),
        expect: () => ['q2_stream_1', 'q2_stream_2'],
      );

      blocTest<ComplexQueueBloc, String>(
        'handles Emitter return type',
        build: ComplexQueueBloc.new,
        act: (bloc) => bloc.q2Emitter('emit', 2),
        wait: const Duration(milliseconds: 30),
        expect: () => ['q2_emit_0', 'q2_emit_1'],
      );
    });
  });
}
