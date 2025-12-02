/// Example of using mono_bloc_flutter widgets.
///
/// This package provides Flutter widgets for handling MonoBloc actions,
/// which are side effects like navigation, dialogs, and snackbars.
///
/// ## Setup
///
/// Add dependencies to `pubspec.yaml`:
/// ```yaml
/// dependencies:
///   mono_bloc_flutter: ^1.0.0  # Exports flutter_bloc + mono_bloc
///
/// dev_dependencies:
///   build_runner: ^2.10.0
///   mono_bloc_generator: ^1.0.0
/// ```
///
/// ## Defining a Bloc with Actions
///
/// Actions must be defined in a private mixin that the bloc mixes in:
///
/// ```dart
/// import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';
///
/// part 'cart_bloc.g.dart';
///
/// // Actions mixin - side effects that don't modify state
/// @MonoActions()
/// mixin _CartBlocActions {
///   void showNotification({required String message});
///
///   void navigateToConfirmation();
/// }
///
/// // The generated base class includes _CartBlocActions automatically
/// @MonoBloc()
/// class CartBloc extends _$CartBloc<CartState> {
///   CartBloc() : super(const CartState());
///
///   @event
///   CartState _onAddItem(Product product) {
///     showNotification(message: 'Added ${product.name}');
///     return state.copyWith(items: [...state.items, product]);
///   }
///
///   @event
///   Future<CartState> _onCheckout() async {
///     await processPayment();
///     navigateToConfirmation();
///     return state.copyWith(items: []);
///   }
/// }
/// ```
///
/// ## Using MonoBlocActionListener
///
/// Use `MonoBlocActionListener<CartBloc>` widget with the generated
/// `CartBlocActions` helper class:
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:flutter_bloc/flutter_bloc.dart';
/// import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';
///
/// class CartPage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return BlocProvider(
///       create: (_) => CartBloc(),
///       child: MonoBlocActionListener<CartBloc>(
///         actions: CartBlocActions.when(
///           showNotification: (context, {required message}) {
///             ScaffoldMessenger.of(context).showSnackBar(
///               SnackBar(content: Text(message)),
///             );
///           },
///           navigateToConfirmation: (context) {
///             Navigator.pushNamed(context, '/confirmation');
///           },
///         ),
///         child: CartView(),
///       ),
///     );
///   }
/// }
/// ```
///
/// ## Key Features
///
/// - **Context-aware actions**: All action handlers receive `BuildContext`
/// - **Type-safe**: Generated code ensures all actions are handled
/// - **Automatic subscription**: Widget manages action stream lifecycle
/// - **Bloc lookup**: Automatically finds bloc from widget tree if not provided
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
          child: Text('See documentation for mono_bloc_flutter usage'),
        ),
      ),
    );
  }
}
