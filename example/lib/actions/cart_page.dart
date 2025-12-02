import 'package:flutter/material.dart' hide Action;
import 'package:mono_bloc_example/actions/cart_bloc.dart';
import 'package:mono_bloc_example/actions/cart_item.dart';
import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';

/// Example page demonstrating MonoBlocActionListener with interface pattern
/// Implements CartBlocActions to handle all cart actions in one place
class CartPage extends StatelessWidget implements CartBlocActions {
  const CartPage({super.key});

  /// Navigate to checkout screen
  @override
  void navigateToCheckout(BuildContext context) {
    // Replace with actual navigation logic
  }

  /// Navigate to product detail screen
  @override
  void navigateToProductDetail(BuildContext context, String productId) {
    // Replace with actual navigation logic
  }

  /// Show notification to user
  @override
  void showNotification(
    BuildContext context,
    String message,
    NotificationType type,
  ) {
    // Replace with actual notification logic
  }

  @override
  Widget build(BuildContext context) {
    return MonoBlocActionListener<CartBloc>(
      // Using CartBlocActions.of() to wire this instance as action handler
      actions: CartBlocActions.of(this),
      child: _CartView(),
    );
  }
}

/// Alternative example using inline action handlers with .when() constructor
/// Useful for simple pages where actions don't need to be reused
class CartPageInline extends StatelessWidget {
  const CartPageInline({super.key});

  @override
  Widget build(BuildContext context) {
    return MonoBlocActionListener<CartBloc>(
      // Using CartBlocActions.when() to define actions inline without interface
      actions: CartBlocActions.when(
        showNotification: (context, message, type) {
          // Show SnackBar notification based on type
        },
        navigateToCheckout: (context) {
          // Navigate to checkout screen
        },
        navigateToProductDetail: (context, productId) {
          // Navigate to product detail with productId
        },
      ),
      child: _CartView(),
    );
  }
}

/// Shared cart view widget
class _CartView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Actions Demo'), elevation: 2),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          // Replace with actual cart UI showing items, total, etc.
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
