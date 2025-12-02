import 'package:flutter/material.dart';
import 'package:mono_bloc_example/error_handler/error_handler_bloc.dart';
import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';

class ErrorHandlerPage extends StatelessWidget {
  const ErrorHandlerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ErrorHandlerBloc(),
      child: const _ErrorHandlerView(),
    );
  }
}

class _ErrorHandlerView extends StatelessWidget {
  const _ErrorHandlerView();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ErrorHandlerBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Handler Demo'),
        backgroundColor: Colors.red.shade700,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: BlocBuilder<ErrorHandlerBloc, int>(
                builder: (context, state) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current State: $state',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _stateColor(state),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _stateDescription(state),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Section 1: Parameter Patterns (Void Handlers)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _DemoButton(
                  label: '1. No Parameters',
                  description: 'void _onErrorNoParams()',
                  onPressed: bloc.noParams,
                ),
                _DemoButton(
                  label: '2. Only Error',
                  description: 'void _onErrorErrorParam(Object error)',
                  onPressed: bloc.errorParam,
                ),
                _DemoButton(
                  label: '3. Error & StackTrace',
                  description:
                      'void _onErrorErrorAndStack(Object error, StackTrace stack)',
                  onPressed: bloc.errorAndStack,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Section 2: Return Type Patterns (All use Object error)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _DemoButton(
                  label: '4. Returns Nullable State',
                  description:
                      'int? _onErrorNullableReturn(Object error) => 999 or null',
                  color: Colors.orange,
                  onPressed: bloc.nullableReturn,
                ),
                _DemoButton(
                  label: '5. Returns Non-Null State',
                  description: 'int _onErrorNonNullReturn(Object error) => 777',
                  color: Colors.orange,
                  onPressed: bloc.nonNullReturn,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Success Event (For Comparison)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _DemoButton(
                  label: 'Success (Set to 42)',
                  description: 'No error - sets state to 42',
                  color: Colors.green,
                  onPressed: () => bloc.success(42),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _stateDescription(int state) {
    if (state == 0) {
      return 'Initial state - no events triggered yet';
    } else if (state == 999) {
      return 'Error handled with nullable return - returned 999';
    } else if (state == 777) {
      return 'Error handled with non-null return - returned 777';
    } else if (state == 42) {
      return 'Success event - set to 42';
    }
    return 'State value: $state';
  }

  Color _stateColor(int state) {
    if (state == 0) return Colors.grey;
    if (state == 999 || state == 777) return Colors.orange;
    if (state == 42) return Colors.green;
    return Colors.blue;
  }
}

class _DemoButton extends StatelessWidget {
  const _DemoButton({
    required this.label,
    required this.description,
    required this.onPressed,
    this.color,
  });

  final String label;
  final String description;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.red.shade400,
          padding: const EdgeInsets.all(12),
          alignment: Alignment.centerLeft,
        ),
        onPressed: onPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
