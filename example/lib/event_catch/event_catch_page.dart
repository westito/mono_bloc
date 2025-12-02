import 'package:flutter/material.dart';
import 'package:mono_bloc_example/event_catch/event_catch_bloc.dart';
import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';

class EventCatchPage extends StatelessWidget {
  const EventCatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EventCatchBloc(),
      child: const _EventCatchView(),
    );
  }
}

class _EventCatchView extends StatelessWidget {
  const _EventCatchView();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<EventCatchBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text('Event Filtering Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Card(
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@onEvent Demo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. "Update Message" is blocked while loading\n'
                      '2. "Force Update" works even during loading\n'
                      '3. All events are logged to console',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // State Display
            BlocBuilder<EventCatchBloc, EventCatchState>(
              builder: (context, state) {
                return Column(
                  children: [
                    // Loading Indicator
                    if (state.isLoading)
                      const Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Loading... (try clicking "Update Message")',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),

                    // Message Display
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Current Message:',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Controls
            ElevatedButton.icon(
              onPressed: bloc.startLoading,
              icon: const Icon(Icons.hourglass_empty),
              label: const Text('Start Loading (3s)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () {
                bloc.updateMessage(
                  'Message updated at ${DateTime.now().second}s',
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Update Message (blocked while loading)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () {
                bloc.forceUpdate('Force updated at ${DateTime.now().second}s');
              },
              icon: const Icon(Icons.flash_on),
              label: const Text('Force Update (always works)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: bloc.reset,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            const Spacer(),

            // Footer
            const Card(
              color: Colors.grey,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check your console/logs',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'All events are logged with timestamps',
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
