import 'package:flutter/widgets.dart';
import 'package:mono_bloc_example/shared_action/error_handler_actions.dart';
import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';

part 'order_bloc.g.dart';

/// Order-specific actions that extend shared error handling.
///
/// By implementing [ErrorHandlerActions], this mixin inherits all shared
/// error handling actions (showError, showRetryError) in addition to
/// defining order-specific actions.
///
/// The generator collects actions from both this mixin AND the implemented
/// [ErrorHandlerActions] interface.
@MonoActions()
mixin _OrderBlocActions implements ErrorHandlerActions {
  /// Navigate to the order details page.
  void navigateToOrderDetails(String orderId);

  /// Show a confirmation message after placing an order.
  void showOrderConfirmation(String orderId, double total);
}

/// State for the order bloc.
class OrderState {
  const OrderState({this.orders = const [], this.isLoading = false});

  final List<Order> orders;
  final bool isLoading;

  OrderState copyWith({List<Order>? orders, bool? isLoading}) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Order model.
class Order {
  const Order({required this.id, required this.total, required this.status});
  final String id;
  final double total;
  final String status;
}

/// Example bloc demonstrating shared action mixins.
///
/// The generated [_$OrderBloc] includes [_OrderBlocActions] which implements
/// [ErrorHandlerActions], giving it access to both order-specific actions
/// (navigateToOrderDetails, showOrderConfirmation) and shared error handling
/// actions (showError, showRetryError).
@MonoBloc()
class OrderBloc extends _$OrderBloc<OrderState> {
  OrderBloc() : super(const OrderState());

  /// Loads orders from the repository.
  /// Uses inherited [showRetryError] action on failure.
  @event
  Future<OrderState> _onLoadOrders() async {
    try {
      await Future<void>.delayed(const Duration(seconds: 1));
      return state.copyWith(
        isLoading: false,
        orders: const [
          Order(id: '1', total: 99.99, status: 'pending'),
          Order(id: '2', total: 149.99, status: 'shipped'),
        ],
      );
    } catch (e) {
      showRetryError('Failed to load orders', loadOrders);
      return state.copyWith(isLoading: false);
    }
  }

  /// Places a new order.
  /// Uses [showOrderConfirmation] on success and [showError] on failure.
  @event
  Future<OrderState> _onPlaceOrder(double total) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final newOrder = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        total: total,
        status: 'pending',
      );
      showOrderConfirmation(newOrder.id, total);
      return state.copyWith(orders: [...state.orders, newOrder]);
    } catch (e) {
      showError('Failed to place order: $e');
      return state;
    }
  }

  /// Selects an order to view details.
  /// Triggers [navigateToOrderDetails] action.
  @event
  OrderState _onSelectOrder(String orderId) {
    navigateToOrderDetails(orderId);
    return state;
  }
}
