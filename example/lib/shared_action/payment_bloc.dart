import 'package:flutter/widgets.dart';
import 'package:mono_bloc_example/shared_action/error_handler_actions.dart';
import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';

part 'payment_bloc.g.dart';

/// Payment-specific actions that extend shared error handling.
///
/// By implementing [ErrorHandlerActions], this mixin inherits all shared
/// error handling actions (showError, showRetryError) in addition to
/// defining payment-specific actions.
@MonoActions()
mixin _PaymentBlocActions implements ErrorHandlerActions {
  /// Navigate to the payment success screen.
  void navigateToPaymentSuccess(String transactionId);

  /// Show the payment method selection UI.
  void showPaymentMethodSelector();
}

/// State for the payment bloc.
class PaymentState {
  const PaymentState({
    this.selectedMethod,
    this.isProcessing = false,
    this.lastTransactionId,
  });

  final String? selectedMethod;
  final bool isProcessing;
  final String? lastTransactionId;

  PaymentState copyWith({
    String? selectedMethod,
    bool? isProcessing,
    String? lastTransactionId,
  }) {
    return PaymentState(
      selectedMethod: selectedMethod ?? this.selectedMethod,
      isProcessing: isProcessing ?? this.isProcessing,
      lastTransactionId: lastTransactionId ?? this.lastTransactionId,
    );
  }
}

/// Example bloc demonstrating shared action mixins for payment processing.
///
/// The generated [_$PaymentBloc] includes [_PaymentBlocActions] which implements
/// [ErrorHandlerActions], giving it access to both payment-specific actions and
/// shared error handling.
@MonoBloc()
class PaymentBloc extends _$PaymentBloc<PaymentState> {
  PaymentBloc() : super(const PaymentState());

  /// Selects a payment method.
  @event
  PaymentState _onSelectPaymentMethod(String method) {
    return state.copyWith(selectedMethod: method);
  }

  /// Shows the payment method selection UI.
  @event
  PaymentState _onShowPaymentMethods() {
    showPaymentMethodSelector();
    return state;
  }

  /// Processes a payment.
  /// Uses inherited [showError] and [showRetryError] actions on failure.
  @event
  Future<PaymentState> _onProcessPayment(double amount) async {
    if (state.selectedMethod == null) {
      showError('Please select a payment method');
      return state;
    }

    try {
      await Future<void>.delayed(const Duration(seconds: 2));
      if (amount > 1000) {
        throw Exception('Amount exceeds limit');
      }
      final transactionId = 'TXN_${DateTime.now().millisecondsSinceEpoch}';
      navigateToPaymentSuccess(transactionId);
      return state.copyWith(
        isProcessing: false,
        lastTransactionId: transactionId,
      );
    } catch (e) {
      showRetryError('Payment failed: $e', () => processPayment(amount));
      return state.copyWith(isProcessing: false);
    }
  }
}
