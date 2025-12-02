enum NotificationType { success, error, info }

class CartItem {
  const CartItem({required this.id, required this.name, required this.price});

  final String id;
  final String name;
  final double price;
}

class CartState {
  const CartState({this.items = const [], this.total = 0.0});

  final List<CartItem> items;
  final double total;

  CartState copyWith({List<CartItem>? items, double? total}) {
    return CartState(items: items ?? this.items, total: total ?? this.total);
  }
}
