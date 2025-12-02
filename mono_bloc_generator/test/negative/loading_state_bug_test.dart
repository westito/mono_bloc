import 'package:test/test.dart';

import 'loading_state_bug_bloc.dart';

void main() {
  group('MonoAsyncEmitter loading() Bug', () {
    test(
      'loading() should preserve current state, not restore old state',
      () async {
        final bloc = LoadingStateBugBloc();
        final emissions = <LoadingBugState?>[];

        // Collect emissions
        bloc.stream.listen((state) {
          emissions.add(state.dataOrNull);
        });

        // Trigger the event
        bloc.incrementThenLoad();

        // Wait for all emissions
        await Future<void>.delayed(const Duration(milliseconds: 200));

        await bloc.close();

        // Expected emissions:
        // 1. counter=1 (after emit with counter+1)
        // 2. counter=1, isLoading=true (after loading() - should preserve counter=1)
        // 3. counter=2 (after final emit)

        // BUG: Actual emissions are:
        // 1. counter=1 (correct)
        // 2. counter=0, isLoading=true (BUG! loading() restored old state!)
        // 3. counter=1 (uses wrong base)

        expect(emissions.length, greaterThanOrEqualTo(3));

        // First emission: counter should be 1
        expect(
          emissions[0]?.counter,
          equals(1),
          reason: 'First emission should have counter=1',
        );

        // Second emission: loading() should PRESERVE counter=1, not revert to 0
        // THIS IS THE BUG!
        expect(
          emissions[1]?.counter,
          equals(1),
          reason:
              'loading() should preserve current counter=1, not restore old counter=0',
        );

        // Final emission: should be counter=2
        expect(
          emissions[2]?.counter,
          equals(2),
          reason: 'Final emission should have counter=2',
        );
      },
    );

    test(
      'confirms fix: loading() now reads current bloc state, not stale captured state',
      () async {
        final bloc = LoadingStateBugBloc();
        final states = <String>[];

        bloc.stream.listen((state) {
          final data = state.dataOrNull;
          final loading = state.isLoading;
          states.add('counter=${data?.counter}, loading=$loading');
        });

        bloc.incrementThenLoad();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await bloc.close();

        // The fix is confirmed: loading() reads current bloc.state, not stale _currentState
        expect(
          states,
          containsAllInOrder([
            'counter=1, loading=false', // After first emit
            'counter=1, loading=true', // FIXED: loading() preserves current state!
            'counter=2, loading=false', // Final emit (correct base)
          ]),
          reason: 'This proves loading() now reads current bloc.state',
        );
      },
    );
  });
}
