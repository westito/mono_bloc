import 'package:flutter/material.dart';

/// Shared UI implementation for error handling actions.
///
/// This mixin provides consistent error display behavior via snackbars.
/// Pages can mix this in to automatically get implementations for
/// `ErrorHandlerActions` methods (showError and showRetryError).
///
/// Usage:
/// ```dart
/// class OrderPage extends StatelessWidget
///     with ErrorHandlerImpl  // Provides showError, showRetryError
///     implements OrderBlocActions {
///
///   // Only need to implement order-specific actions
///   @override
///   void navigateToOrderDetails(BuildContext context, String orderId) {
///     Navigator.pushNamed(context, '/order/$orderId');
///   }
///
///   // showError and showRetryError come from ErrorHandlerImpl
///
///   @override
///   Widget build(BuildContext context) {
///     return MonoBlocActionListener<OrderBloc>(
///       actions: OrderBlocActions.of(this),
///       child: const OrderView(),
///     );
///   }
/// }
/// ```
mixin ErrorHandlerImpl {
  /// Shows an error message in a red snackbar.
  void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// Shows an error message in an orange snackbar with a retry button.
  void showRetryError(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        action: SnackBarAction(label: 'Retry', onPressed: onRetry),
      ),
    );
  }
}
