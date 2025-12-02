import 'package:flutter/material.dart';
import 'package:mono_bloc_example/shared_action/error_handler_impl.dart';
import 'package:mono_bloc_example/shared_action/payment_bloc.dart';
import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';

/// Payment page demonstrating shared action mixins pattern.
///
/// This page:
/// 1. Mixes in [ErrorHandlerImpl] to get shared error handling UI
/// 2. Implements [PaymentBlocActions] to handle all actions from PaymentBloc
///
/// The [ErrorHandlerImpl] mixin provides implementations for [showError]
/// and [showRetryError], so only payment-specific actions need to be
/// implemented here.
class PaymentPage extends StatelessWidget
    with ErrorHandlerImpl
    implements PaymentBlocActions {
  const PaymentPage({super.key});

  /// Handles navigation to payment success screen.
  @override
  void navigateToPaymentSuccess(BuildContext context, String transactionId) {
    unawaited(
      Navigator.of(context).pushNamed('/payment/success/$transactionId'),
    );
  }

  /// Shows the payment method selection bottom sheet.
  @override
  void showPaymentMethodSelector(BuildContext context) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (context) => const _PaymentMethodSheet(),
      ),
    );
  }

  // showError and showRetryError implementations come from ErrorHandlerImpl

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PaymentBloc(),
      child: MonoBlocActionListener<PaymentBloc>(
        actions: PaymentBlocActions.of(this),
        child: const _PaymentView(),
      ),
    );
  }
}

class _PaymentView extends StatelessWidget {
  const _PaymentView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: BlocBuilder<PaymentBloc, PaymentState>(
        builder: (context, state) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Selected: ${state.selectedMethod ?? 'None'}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<PaymentBloc>().showPaymentMethods(),
                  child: const Text('Select Payment Method'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: state.selectedMethod != null
                      ? () => context.read<PaymentBloc>().processPayment(99.99)
                      : null,
                  child: const Text(r'Pay $99.99'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PaymentMethodSheet extends StatelessWidget {
  const _PaymentMethodSheet();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.credit_card),
          title: const Text('Credit Card'),
          onTap: () {
            context.read<PaymentBloc>().selectPaymentMethod('credit_card');
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.account_balance),
          title: const Text('Bank Transfer'),
          onTap: () {
            context.read<PaymentBloc>().selectPaymentMethod('bank');
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
