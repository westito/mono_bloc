/// Example of using mono_bloc_hooks for Flutter hooks integration.
///
/// This package provides hooks for working with MonoBloc in Flutter applications
/// using the flutter_hooks package.
///
/// ## Setup
///
/// Add dependencies to `pubspec.yaml`:
/// ```yaml
/// dependencies:
///   flutter_hooks: ^0.21.0
///   mono_bloc_flutter: ^1.0.0  # Exports flutter_bloc + mono_bloc
///   mono_bloc_hooks: ^1.0.0
///
/// dev_dependencies:
///   build_runner: ^2.10.0
///   mono_bloc_generator: ^1.0.0
/// ```
///
/// ## Defining a Bloc with Actions
///
/// Actions must be defined in a private mixin:
///
/// ```dart
/// import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';
///
/// part 'counter_bloc.g.dart';
///
/// // Actions mixin
/// @MonoActions()
/// mixin _CounterBlocActions {
///   void showMessage(String message);
/// }
///
/// // The generated base class includes _CounterBlocActions automatically
/// @MonoBloc()
/// class CounterBloc extends _$CounterBloc<int> {
///   CounterBloc() : super(0);
///
///   @event
///   int _onIncrement() {
///     final newValue = state + 1;
///     if (newValue >= 10) {
///       showMessage('Maximum reached!');
///     }
///     return newValue;
///   }
/// }
/// ```
///
/// ## Using useMonoBlocActionListener Hook
///
/// The `useMonoBlocActionListener` hook allows you to listen to bloc actions
/// in a HookWidget with automatic subscription lifecycle management.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:flutter_hooks/flutter_hooks.dart';
/// import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';
/// import 'package:mono_bloc_hooks/mono_bloc_hooks.dart';
///
/// class CounterPage extends HookWidget {
///   const CounterPage({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     final bloc = context.read<CounterBloc>();
///
///     // Listen to actions from the bloc
///     // Automatically handles subscription lifecycle
///     useMonoBlocActionListener(
///       bloc,
///       CounterBlocActions.when(
///         showMessage: (context, message) {
///           ScaffoldMessenger.of(context).showSnackBar(
///             SnackBar(content: Text(message)),
///           );
///         },
///       ),
///     );
///
///     // Memoized callbacks
///     final increment = useCallback(bloc.increment, [bloc]);
///     final decrement = useCallback(bloc.decrement, [bloc]);
///
///     return Scaffold(
///       body: Center(
///         child: Column(
///           mainAxisAlignment: MainAxisAlignment.center,
///           children: [
///             BlocBuilder<CounterBloc, int>(
///               builder: (context, count) => Text('$count'),
///             ),
///             ElevatedButton(
///               onPressed: increment,
///               child: const Text('Increment'),
///             ),
///           ],
///         ),
///       ),
///     );
///   }
/// }
/// ```
///
/// ## Key Features
///
/// - **Automatic cleanup**: Subscriptions are automatically cancelled when
///   the widget is disposed
/// - **Dependency tracking**: Re-subscribes when bloc instance changes
/// - **Context-aware**: Action handlers receive BuildContext for UI operations
library;

import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('See documentation for mono_bloc_hooks usage'),
        ),
      ),
    );
  }
}
