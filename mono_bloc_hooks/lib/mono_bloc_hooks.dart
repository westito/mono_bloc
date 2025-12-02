/// Flutter hooks for MonoBloc - easily handle actions and state in HookWidget components.
///
/// This library provides hooks for working with MonoBloc in Flutter applications
/// using the flutter_hooks package.
///
/// ## Usage with `when()`
///
/// Use inline callbacks for simple action handling:
///
/// ```dart
/// import 'package:flutter_hooks/flutter_hooks.dart';
/// import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';
/// import 'package:mono_bloc_hooks/mono_bloc_hooks.dart';
///
/// class CounterPage extends HookWidget {
///   const CounterPage({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     final bloc = useBloc<CounterBloc>();
///
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
///     return BlocBuilder<CounterBloc, int>(
///       builder: (context, count) => Text('$count'),
///     );
///   }
/// }
/// ```
///
/// ## Usage with `of()`
///
/// For cleaner code, implement the generated actions interface:
///
/// ```dart
/// class CounterPage extends HookWidget implements CounterBlocActions {
///   const CounterPage({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     final bloc = useBloc<CounterBloc>();
///
///     useMonoBlocActionListener(
///       bloc,
///       CounterBlocActions.of(this),
///     );
///
///     return BlocBuilder<CounterBloc, int>(
///       builder: (context, count) => Text('$count'),
///     );
///   }
///
///   @override
///   void showMessage(BuildContext context, String message) {
///     ScaffoldMessenger.of(context).showSnackBar(
///       SnackBar(content: Text(message)),
///     );
///   }
/// }
/// ```
///
/// **When to use which pattern:**
/// - **`when()`** - Inline callbacks, good for simple pages with few actions
/// - **`of()`** - Interface implementation, better for complex pages or reusable handlers
///
/// ## Hooks
///
/// - `useMonoBlocActionListener` - Listen to bloc actions with automatic cleanup
library;

export 'src/use_mono_action.dart';
