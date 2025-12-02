import 'package:flutter/material.dart';
import 'package:mono_bloc_example/shared_action/error_handler_impl.dart';
import 'package:mono_bloc_example/shared_action/order_bloc.dart';
import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';

/// Order page demonstrating shared action mixins pattern.
///
/// This page:
/// 1. Mixes in [ErrorHandlerImpl] to get shared error handling UI
/// 2. Implements [OrderBlocActions] to handle all actions from OrderBloc
///
/// The [ErrorHandlerImpl] mixin provides implementations for [showError]
/// and [showRetryError], so only order-specific actions need to be
/// implemented here.
class OrderPage extends StatelessWidget
    with ErrorHandlerImpl
    implements OrderBlocActions {
  const OrderPage({super.key});

  /// Handles navigation to order details.
  @override
  void navigateToOrderDetails(BuildContext context, String orderId) {
    unawaited(Navigator.of(context).pushNamed('/order/$orderId'));
  }

  /// Shows order confirmation in a green snackbar.
  @override
  void showOrderConfirmation(
    BuildContext context,
    String orderId,
    double total,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Order $orderId confirmed! Total: \$${total.toStringAsFixed(2)}',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  // showError and showRetryError implementations come from ErrorHandlerImpl

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderBloc()..loadOrders(),
      child: MonoBlocActionListener<OrderBloc>(
        actions: OrderBlocActions.of(this),
        child: const _OrderView(),
      ),
    );
  }
}

class _OrderView extends StatelessWidget {
  const _OrderView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: state.orders.length,
            itemBuilder: (context, index) {
              final order = state.orders[index];
              return ListTile(
                title: Text('Order ${order.id}'),
                subtitle: Text('\$${order.total.toStringAsFixed(2)}'),
                trailing: Text(order.status),
                onTap: () => context.read<OrderBloc>().selectOrder(order.id),
              );
            },
          );
        },
      ),
    );
  }
}
