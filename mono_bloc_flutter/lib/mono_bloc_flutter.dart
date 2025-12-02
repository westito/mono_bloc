/// Flutter widgets and utilities for MonoBloc.
///
/// This package provides Flutter-specific widgets for handling MonoBloc actions,
/// which are side effects like navigation, dialogs, and snackbars.
///
/// ## Usage with `when()`
///
/// Use inline callbacks for simple action handling:
///
/// ```dart
/// import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';
///
/// // In your widget tree:
/// MonoBlocActionListener<CartBloc>(
///   actions: CartBlocActions.when(
///     showNotification: (context, message, type) {
///       ScaffoldMessenger.of(context).showSnackBar(
///         SnackBar(content: Text(message)),
///       );
///     },
///     navigateToCheckout: (context) {
///       Navigator.pushNamed(context, '/checkout');
///     },
///   ),
///   child: CartPage(),
/// )
/// ```
///
/// ## Usage with `of()`
///
/// For cleaner code, implement the generated actions interface:
///
/// ```dart
/// class CartPage extends StatelessWidget implements CartBlocActions {
///   const CartPage({super.key});
///
///   @override
///   void showNotification(BuildContext context, String message, NotificationType type) {
///     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
///   }
///
///   @override
///   void navigateToCheckout(BuildContext context) {
///     Navigator.pushNamed(context, '/checkout');
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return MonoBlocActionListener<CartBloc>(
///       actions: CartBlocActions.of(this),  // Wire this instance as handler
///       child: CartContent(),
///     );
///   }
/// }
/// ```
///
/// **When to use which pattern:**
/// - **`when()`** - Inline callbacks, good for simple pages with few actions
/// - **`of()`** - Interface implementation, better for complex pages or reusable handlers
library;

export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:mono_bloc/mono_bloc.dart';

export 'src/flutter_mono_bloc_actions.dart';
export 'src/mono_bloc_action_listener.dart';
