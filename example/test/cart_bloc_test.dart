import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mono_bloc_example/actions/cart_bloc.dart';
import 'package:mono_bloc_example/actions/cart_item.dart';

void main() {
  group('CartBloc', () {
    late CartBloc bloc;

    setUp(() {
      bloc = CartBloc();
    });

    tearDown(() async {
      await bloc.close();
    });

    test('initial state is empty cart', () {
      expect(bloc.state.items, isEmpty);
      expect(bloc.state.total, equals(0.0));
    });

    group('Events', () {
      blocTest<CartBloc, CartState>(
        'addItem adds item to cart and updates total',
        build: () => bloc,
        act: (bloc) =>
            bloc.addItem(const CartItem(id: '1', name: 'Product 1', price: 10)),
        expect: () => [
          isA<CartState>()
              .having((s) => s.items.length, 'items length', 1)
              .having((s) => s.total, 'total', 10.0)
              .having((s) => s.items.first.name, 'item name', 'Product 1'),
        ],
      );

      blocTest<CartBloc, CartState>(
        'addItem adds multiple items correctly',
        build: () => bloc,
        act: (bloc) {
          bloc.addItem(const CartItem(id: '1', name: 'Product 1', price: 10));
          bloc.addItem(const CartItem(id: '2', name: 'Product 2', price: 20));
          bloc.addItem(const CartItem(id: '3', name: 'Product 3', price: 15));
        },
        expect: () => [
          isA<CartState>()
              .having((s) => s.items.length, 'items length', 1)
              .having((s) => s.total, 'total', 10.0),
          isA<CartState>()
              .having((s) => s.items.length, 'items length', 2)
              .having((s) => s.total, 'total', 30.0),
          isA<CartState>()
              .having((s) => s.items.length, 'items length', 3)
              .having((s) => s.total, 'total', 45.0),
        ],
      );

      blocTest<CartBloc, CartState>(
        'removeItem removes item from cart and updates total',
        build: () => bloc,
        seed: () => const CartState(
          items: [
            CartItem(id: '1', name: 'Product 1', price: 10),
            CartItem(id: '2', name: 'Product 2', price: 20),
          ],
          total: 30,
        ),
        act: (bloc) => bloc.removeItem('1'),
        expect: () => [
          isA<CartState>()
              .having((s) => s.items.length, 'items length', 1)
              .having((s) => s.total, 'total', 20.0)
              .having((s) => s.items.first.id, 'remaining item id', '2'),
        ],
      );

      blocTest<CartBloc, CartState>(
        'clear empties cart',
        build: () => bloc,
        seed: () => const CartState(
          items: [
            CartItem(id: '1', name: 'Product 1', price: 10),
            CartItem(id: '2', name: 'Product 2', price: 20),
          ],
          total: 30,
        ),
        act: (bloc) => bloc.clear(),
        expect: () => [
          isA<CartState>()
              .having((s) => s.items, 'items', isEmpty)
              .having((s) => s.total, 'total', 0.0),
        ],
      );

      blocTest<CartBloc, CartState>(
        'checkout clears cart when items exist',
        build: () => bloc,
        seed: () => const CartState(
          items: [CartItem(id: '1', name: 'Product 1', price: 10)],
          total: 10,
        ),
        act: (bloc) => bloc.checkout(),
        expect: () => [
          isA<CartState>()
              .having((s) => s.items, 'items', isEmpty)
              .having((s) => s.total, 'total', 0.0),
        ],
      );

      blocTest<CartBloc, CartState>(
        'checkout does not change state when cart is empty',
        build: () => bloc,
        act: (bloc) => bloc.checkout(),
        expect: () => [
          isA<CartState>()
              .having((s) => s.items, 'items', isEmpty)
              .having((s) => s.total, 'total', 0.0),
        ],
      );
    });

    group('Actions', () {
      test('addItem emits action', () async {
        var actionCount = 0;
        final subscription = bloc.actions.listen((_) => actionCount++);

        bloc.addItem(const CartItem(id: '1', name: 'Product 1', price: 10));

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(actionCount, equals(1));

        await subscription.cancel();
      });

      test('removeItem emits action', () async {
        var actionCount = 0;
        final subscription = bloc.actions.listen((_) => actionCount++);

        bloc.addItem(const CartItem(id: '1', name: 'Product 1', price: 10));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        actionCount = 0;

        bloc.removeItem('1');
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(actionCount, equals(1));

        await subscription.cancel();
      });

      test('clear emits action', () async {
        var actionCount = 0;
        final subscription = bloc.actions.listen((_) => actionCount++);

        bloc.clear();

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(actionCount, equals(1));

        await subscription.cancel();
      });

      test('checkout with items emits action', () async {
        var actionCount = 0;
        final subscription = bloc.actions.listen((_) => actionCount++);

        bloc.addItem(const CartItem(id: '1', name: 'Product 1', price: 10));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        actionCount = 0;

        bloc.checkout();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(actionCount, equals(1));

        await subscription.cancel();
      });

      test('checkout with empty cart emits action', () async {
        var actionCount = 0;
        final subscription = bloc.actions.listen((_) => actionCount++);

        bloc.checkout();

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(actionCount, equals(1));

        await subscription.cancel();
      });

      test('multiple events emit multiple actions', () async {
        var actionCount = 0;
        final subscription = bloc.actions.listen((_) => actionCount++);

        bloc.addItem(const CartItem(id: '1', name: 'Product 1', price: 10));
        await Future<void>.delayed(const Duration(milliseconds: 10));

        bloc.removeItem('1');
        await Future<void>.delayed(const Duration(milliseconds: 10));

        bloc.clear();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(actionCount, equals(3));

        await subscription.cancel();
      });
    });

    group('Action Stream Lifecycle', () {
      test('action stream is available before close', () {
        expect(bloc.actions, isNotNull);
      });

      test('action stream closes with bloc', () async {
        await bloc.close();

        expect(bloc.isClosed, true);
      });

      test('can listen to actions multiple times', () async {
        var listener1Count = 0;
        var listener2Count = 0;

        final sub1 = bloc.actions.listen((_) => listener1Count++);
        final sub2 = bloc.actions.listen((_) => listener2Count++);

        bloc.addItem(const CartItem(id: '1', name: 'Product 1', price: 10));

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(listener1Count, equals(1));
        expect(listener2Count, equals(1));

        await sub1.cancel();
        await sub2.cancel();
      });
    });

    group('State Calculations', () {
      blocTest<CartBloc, CartState>(
        'total is calculated correctly with multiple items',
        build: () => bloc,
        act: (bloc) {
          bloc.addItem(
            const CartItem(id: '1', name: 'Product 1', price: 10.99),
          );
          bloc.addItem(
            const CartItem(id: '2', name: 'Product 2', price: 20.50),
          );
          bloc.addItem(const CartItem(id: '3', name: 'Product 3', price: 5.25));
        },
        skip: 2,
        expect: () => [
          isA<CartState>().having(
            (s) => s.total,
            'total',
            closeTo(36.74, 0.01),
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        'total is recalculated after removal',
        build: () => bloc,
        act: (bloc) {
          bloc.addItem(const CartItem(id: '1', name: 'Product 1', price: 10));
          bloc.addItem(const CartItem(id: '2', name: 'Product 2', price: 20));
          bloc.addItem(const CartItem(id: '3', name: 'Product 3', price: 15));
          bloc.removeItem('2');
        },
        skip: 3,
        expect: () => [
          isA<CartState>()
              .having((s) => s.total, 'total', equals(25.0))
              .having((s) => s.items.length, 'items count', 2),
        ],
      );

      blocTest<CartBloc, CartState>(
        'items order is preserved',
        build: () => bloc,
        act: (bloc) {
          bloc.addItem(const CartItem(id: '1', name: 'First', price: 10));
          bloc.addItem(const CartItem(id: '2', name: 'Second', price: 20));
          bloc.addItem(const CartItem(id: '3', name: 'Third', price: 30));
        },
        skip: 2,
        expect: () => [
          isA<CartState>()
              .having((s) => s.items[0].name, 'first item', 'First')
              .having((s) => s.items[1].name, 'second item', 'Second')
              .having((s) => s.items[2].name, 'third item', 'Third'),
        ],
      );
    });
  });
}
