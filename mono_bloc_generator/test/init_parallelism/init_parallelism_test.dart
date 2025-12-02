import 'package:test/test.dart';

import 'parallel_init_bloc.dart';
import 'sequential_init_bloc.dart';

void main() {
  group('Init Parallelism - Order Tests', () {
    test(
      'parallel @onInit: order is by delay (shortest completes first)',
      () async {
        final bloc = ParallelInitBloc();

        // Wait for all 3 emissions
        await bloc.stream.take(3).toList();

        // Parallel: C (50ms) finishes first, B (100ms) second, A (150ms) last
        expect(
          bloc.state.executionOrder,
          equals(['C', 'B', 'A']),
          reason: 'Parallel: shortest delay should complete first',
        );

        await bloc.close();
      },
    );

    test(
      'sequential @onInit: order is by declaration (A first, then B, then C)',
      () async {
        final bloc = SequentialInitBloc();

        // Wait for all 3 emissions
        await bloc.stream.take(3).toList();

        // Sequential: A runs first (declared first), then B, then C
        expect(
          bloc.state.executionOrder,
          equals(['A', 'B', 'C']),
          reason: 'Sequential: declaration order should be preserved',
        );

        await bloc.close();
      },
    );

    test(
      'parallel vs sequential: different order proves different execution mode',
      () async {
        final parallelBloc = ParallelInitBloc();
        final sequentialBloc = SequentialInitBloc();

        // Wait for both to complete
        await Future.wait([
          parallelBloc.stream.take(3).toList(),
          sequentialBloc.stream.take(3).toList(),
        ]);

        // Key assertion: orders are different!
        // Parallel: [C, B, A] (by delay)
        // Sequential: [A, B, C] (by declaration)
        expect(parallelBloc.state.executionOrder, equals(['C', 'B', 'A']));
        expect(sequentialBloc.state.executionOrder, equals(['A', 'B', 'C']));

        // They should NOT be equal
        expect(
          parallelBloc.state.executionOrder,
          isNot(equals(sequentialBloc.state.executionOrder)),
          reason:
              'Parallel and sequential should have different execution order',
        );

        await parallelBloc.close();
        await sequentialBloc.close();
      },
    );
  });
}
