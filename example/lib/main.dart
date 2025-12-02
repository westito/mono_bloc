import 'package:flutter/material.dart';
import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';

part 'main.g.dart';

void main() => runApp(const MyApp());

// Actions must be in a private mixin with @MonoActions() annotation
@MonoActions()
mixin _CounterBlocActions {
  // Action - side effects without state change (navigation, dialogs, etc.)
  void showMessage(String text);
}

@MonoBloc()
// @AsyncMonoBloc() for async loading/error states
// @MonoBloc(sequential: true) for preventing race conditions
class CounterBloc extends _$CounterBloc<int> {
  CounterBloc() : super(0);

  // Basic sync event - returns new state
  @event
  // @restartableEvent - cancels previous, starts new (perfect for search)
  // @droppableEvent - ignores new while processing (perfect for submit buttons)
  // @sequentialEvent - processes one at a time in order
  // @concurrentEvent - processes all simultaneously
  int _onIncrement() => state + 1;

  // Async event - returns Future
  @event
  Future<int> _onIncrementAsync() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return state + 1;
  }

  // Event with parameter
  @event
  int _onAddValue(int value) => state + value;

  // Stream event - emits multiple states
  @event
  Stream<int> _onCountdown(int from) async* {
    for (var i = from; i >= 0; i--) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      yield i;
    }
  }

  // Global error handler - catches all unhandled errors
  @onError
  int _onError(Object error, StackTrace stackTrace) => -1;

  // Event filter - intercept/log/block events before processing
  // @onEvent
  // bool _filterEvent(_Event event) {
  //   print('Event: $event');
  //   return true; // return false to block event
  // }
}

// ============================================================================
// UI - Simple Demo
// ============================================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MonoBloc Demo',
      home: BlocProvider(
        create: (_) => CounterBloc(),
        child: const CounterPage(),
      ),
    );
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CounterBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text('MonoBloc Demo')),
      body: MonoBlocActionListener<CounterBloc>(
        actions: CounterBlocActions.when(
          showMessage: (context, text) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(text)));
          },
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlocBuilder<CounterBloc, int>(
                builder: (context, count) =>
                    Text('$count', style: const TextStyle(fontSize: 48)),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: bloc.increment,
                child: const Text('Increment'),
              ),
              ElevatedButton(
                onPressed: bloc.incrementAsync,
                child: const Text('Increment Async (1s)'),
              ),
              ElevatedButton(
                onPressed: () => bloc.addValue(5),
                child: const Text('Add 5'),
              ),
              ElevatedButton(
                onPressed: () => bloc.countdown(5),
                child: const Text('Countdown from 5'),
              ),
              ElevatedButton(
                onPressed: () => bloc.showMessage('Hello from action!'),
                child: const Text('Show Message'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
