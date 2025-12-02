import 'package:flutter/widgets.dart';
import 'package:mono_bloc_example/actions/cart_item.dart';
import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';

part 'cart_bloc.g.dart';

@MonoActions()
mixin _CartBlocActions {
  void showNotification(String message, NotificationType type);

  void navigateToCheckout();

  void navigateToProductDetail(String productId);
}

/// Simple shopping cart bloc demonstrating MonoBloc actions for Flutter
/// Actions are used for side effects like showing notifications and navigation.
@MonoBloc()
class CartBloc extends _$CartBloc<CartState> {
  CartBloc() : super(const CartState());

  // Events - modify state
  @event
  CartState _onAddItem(CartItem item) {
    final updatedItems = [...state.items, item];
    final updatedTotal = state.total + item.price;

    // Trigger notification action
    showNotification('Added ${item.name} to cart', NotificationType.success);

    return state.copyWith(items: updatedItems, total: updatedTotal);
  }

  @event
  CartState _onRemoveItem(String itemId) {
    final itemToRemove = state.items.firstWhere((item) => item.id == itemId);
    final updatedItems = state.items
        .where((item) => item.id != itemId)
        .toList();
    final updatedTotal = state.total - itemToRemove.price;

    // Trigger notification action
    showNotification(
      'Removed ${itemToRemove.name} from cart',
      NotificationType.info,
    );

    return state.copyWith(items: updatedItems, total: updatedTotal);
  }

  @event
  CartState _onClear() {
    showNotification('Cart cleared', NotificationType.info);

    return const CartState();
  }

  @event
  CartState _onCheckout() {
    if (state.items.isEmpty) {
      showNotification('Cart is empty', NotificationType.error);
      return state;
    }

    // Navigate to checkout
    navigateToCheckout();

    // Clear cart after successful navigation trigger
    return const CartState();
  }
}
