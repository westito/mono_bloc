import 'package:flutter/widgets.dart';

/// Shared error handling actions that can be reused across multiple blocs.
///
/// This public mixin defines common error handling patterns that any bloc
/// can inherit by having its private action mixin implement this interface.
///
/// Example usage:
/// ```dart
/// // Private action mixin implements shared actions
/// @MonoActions()
/// mixin _OrderBlocActions implements ErrorHandlerActions {
///   void navigateToDetails(String id);
///   // showError and showRetryError are inherited
/// }
///
/// // Generated _$OrderBloc includes _OrderBlocActions automatically
/// @MonoBloc()
/// class OrderBloc extends _$OrderBloc<OrderState> {
///   @event
///   Future<OrderState> _onLoad() async {
///     try {
///       return state.copyWith(data: await repository.load());
///     } catch (e) {
///       showRetryError('Failed to load', () => load());  // Use inherited action
///       return state;
///     }
///   }
/// }
/// ```
mixin ErrorHandlerActions {
  /// Shows an error message to the user.
  void showError(String message);

  /// Shows an error message with a retry button.
  void showRetryError(String message, VoidCallback onRetry);
}
