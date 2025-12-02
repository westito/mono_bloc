import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mono_bloc_example/actions/cart_bloc.dart';
import 'package:mono_bloc_example/actions/cart_item.dart';
import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';

void main() {
  group('MonoBlocActionListener', () {
    late CartBloc bloc;

    setUp(() {
      bloc = CartBloc();
    });

    tearDown(() async {
      await bloc.close();
    });

    group('Action handling', () {
      testWidgets('receives showNotification action when item is added', (
        tester,
      ) async {
        String? capturedMessage;
        NotificationType? capturedType;

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<CartBloc>.value(
              value: bloc,
              child: MonoBlocActionListener<CartBloc>(
                actions: CartBlocActions.when(
                  showNotification: (context, message, type) {
                    capturedMessage = message;
                    capturedType = type;
                  },
                ),
                child: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () => context.read<CartBloc>().addItem(
                      const CartItem(id: '1', name: 'Test Item', price: 10),
                    ),
                    child: const Text('Add Item'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Add Item'));
        // Use runAsync to allow microtasks to complete
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();

        expect(capturedMessage, contains('Test Item'));
        expect(capturedType, NotificationType.success);
      });

      testWidgets('receives navigateToCheckout action on checkout', (
        tester,
      ) async {
        var navigateCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<CartBloc>.value(
              value: bloc,
              child: MonoBlocActionListener<CartBloc>(
                actions: CartBlocActions.when(
                  navigateToCheckout: (context) {
                    navigateCalled = true;
                  },
                ),
                child: Builder(
                  builder: (context) => Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => context.read<CartBloc>().addItem(
                          const CartItem(
                            id: '1',
                            name: 'Test Item',
                            price: 10,
                          ),
                        ),
                        child: const Text('Add Item'),
                      ),
                      ElevatedButton(
                        onPressed: () => context.read<CartBloc>().checkout(),
                        child: const Text('Checkout'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Add item first so cart is not empty
        await tester.tap(find.text('Add Item'));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();

        // Then checkout
        await tester.tap(find.text('Checkout'));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();

        expect(navigateCalled, isTrue);
      });

      testWidgets(
        'receives showNotification with error type on empty checkout',
        (tester) async {
          String? capturedMessage;
          NotificationType? capturedType;

          await tester.pumpWidget(
            MaterialApp(
              home: BlocProvider<CartBloc>.value(
                value: bloc,
                child: MonoBlocActionListener<CartBloc>(
                  actions: CartBlocActions.when(
                    showNotification: (context, message, type) {
                      capturedMessage = message;
                      capturedType = type;
                    },
                  ),
                  child: Builder(
                    builder: (context) => ElevatedButton(
                      onPressed: () => context.read<CartBloc>().checkout(),
                      child: const Text('Checkout'),
                    ),
                  ),
                ),
              ),
            ),
          );

          await tester.tap(find.text('Checkout'));
          await tester.runAsync(() async {
            await Future<void>.delayed(const Duration(milliseconds: 50));
          });
          await tester.pump();

          expect(capturedMessage, contains('empty'));
          expect(capturedType, NotificationType.error);
        },
      );

      testWidgets('receives navigateToProductDetail action with productId', (
        tester,
      ) async {
        String? capturedProductId;

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<CartBloc>.value(
              value: bloc,
              child: MonoBlocActionListener<CartBloc>(
                actions: CartBlocActions.when(
                  navigateToProductDetail: (context, productId) {
                    capturedProductId = productId;
                  },
                ),
                child: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () =>
                        bloc.navigateToProductDetail('product-123'),
                    child: const Text('View Product'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('View Product'));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();

        expect(capturedProductId, 'product-123');
      });
    });

    group('Multiple actions', () {
      testWidgets('receives multiple actions in sequence', (tester) async {
        final receivedMessages = <String>[];

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<CartBloc>.value(
              value: bloc,
              child: MonoBlocActionListener<CartBloc>(
                actions: CartBlocActions.when(
                  showNotification: (context, message, type) {
                    receivedMessages.add(message);
                  },
                ),
                child: Builder(
                  builder: (context) => Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => context.read<CartBloc>().addItem(
                          const CartItem(
                            id: '1',
                            name: 'Item 1',
                            price: 10,
                          ),
                        ),
                        child: const Text('Add Item 1'),
                      ),
                      ElevatedButton(
                        onPressed: () => context.read<CartBloc>().addItem(
                          const CartItem(
                            id: '2',
                            name: 'Item 2',
                            price: 20,
                          ),
                        ),
                        child: const Text('Add Item 2'),
                      ),
                      ElevatedButton(
                        onPressed: () => context.read<CartBloc>().clear(),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Add Item 1'));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();

        await tester.tap(find.text('Add Item 2'));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();

        await tester.tap(find.text('Clear'));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();

        expect(receivedMessages.length, 3);
        expect(receivedMessages[0], contains('Item 1'));
        expect(receivedMessages[1], contains('Item 2'));
        expect(receivedMessages[2], contains('cleared'));
      });
    });

    group('Bloc instance handling', () {
      testWidgets('works with bloc provided directly', (tester) async {
        String? capturedMessage;

        await tester.pumpWidget(
          MaterialApp(
            home: MonoBlocActionListener<CartBloc>(
              bloc: bloc,
              actions: CartBlocActions.when(
                showNotification: (context, message, type) {
                  capturedMessage = message;
                },
              ),
              child: ElevatedButton(
                onPressed: () => bloc.addItem(
                  const CartItem(
                    id: '1',
                    name: 'Direct Bloc Item',
                    price: 10,
                  ),
                ),
                child: const Text('Add'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Add'));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();

        expect(capturedMessage, contains('Direct Bloc Item'));
      });

      testWidgets('works with bloc from context', (tester) async {
        String? capturedMessage;

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<CartBloc>.value(
              value: bloc,
              child: MonoBlocActionListener<CartBloc>(
                actions: CartBlocActions.when(
                  showNotification: (context, message, type) {
                    capturedMessage = message;
                  },
                ),
                child: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () => context.read<CartBloc>().addItem(
                      const CartItem(
                        id: '1',
                        name: 'Context Bloc Item',
                        price: 10,
                      ),
                    ),
                    child: const Text('Add'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Add'));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();

        expect(capturedMessage, contains('Context Bloc Item'));
      });
    });

    group('Widget lifecycle', () {
      testWidgets('unsubscribes on dispose', (tester) async {
        var actionCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<CartBloc>.value(
              value: bloc,
              child: MonoBlocActionListener<CartBloc>(
                actions: CartBlocActions.when(
                  showNotification: (context, message, type) {
                    actionCount++;
                  },
                ),
                child: const SizedBox(),
              ),
            ),
          ),
        );

        // Trigger an action
        bloc.addItem(const CartItem(id: '1', name: 'Item', price: 10));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();
        expect(actionCount, 1);

        // Replace widget tree to dispose listener
        await tester.pumpWidget(const MaterialApp(home: SizedBox()));
        await tester.pumpAndSettle();

        // Trigger another action - should not be received
        bloc.addItem(const CartItem(id: '2', name: 'Item 2', price: 20));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();

        // Action count should still be 1
        expect(actionCount, 1);
      });

      testWidgets('resubscribes when bloc changes', (tester) async {
        final bloc1 = CartBloc();
        final receivedMessages = <String>[];

        addTearDown(() async {
          await bloc1.close();
        });

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<CartBloc>.value(
              value: bloc1,
              child: MonoBlocActionListener<CartBloc>(
                actions: CartBlocActions.when(
                  showNotification: (context, message, type) {
                    receivedMessages.add(message);
                  },
                ),
                child: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () => context.read<CartBloc>().addItem(
                      const CartItem(
                        id: '1',
                        name: 'Bloc1 Item',
                        price: 10,
                      ),
                    ),
                    child: const Text('Add'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Action from bloc1
        await tester.tap(find.text('Add'));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();

        expect(receivedMessages.length, 1);
        expect(receivedMessages[0], contains('Bloc1 Item'));
      });
    });

    group('BuildContext availability', () {
      testWidgets('provides valid BuildContext to action handlers', (
        tester,
      ) async {
        BuildContext? capturedContext;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<CartBloc>.value(
                value: bloc,
                child: MonoBlocActionListener<CartBloc>(
                  actions: CartBlocActions.when(
                    showNotification: (context, message, type) {
                      capturedContext = context;
                      // Use context to show a snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                    },
                  ),
                  child: Builder(
                    builder: (context) => ElevatedButton(
                      onPressed: () => context.read<CartBloc>().addItem(
                        const CartItem(
                          id: '1',
                          name: 'Test Item',
                          price: 10,
                        ),
                      ),
                      child: const Text('Add'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Add'));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pumpAndSettle();

        expect(capturedContext, isNotNull);
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Added Test Item to cart'), findsOneWidget);
      });

      testWidgets('can perform navigation from action handler', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            routes: {
              '/': (context) => BlocProvider<CartBloc>.value(
                value: bloc,
                child: MonoBlocActionListener<CartBloc>(
                  actions: CartBlocActions.when(
                    navigateToCheckout: (context) async {
                      await Navigator.pushNamed(context, '/checkout');
                    },
                  ),
                  child: Scaffold(
                    body: Builder(
                      builder: (context) => Column(
                        children: [
                          ElevatedButton(
                            onPressed: () => context.read<CartBloc>().addItem(
                              const CartItem(
                                id: '1',
                                name: 'Item',
                                price: 10,
                              ),
                            ),
                            child: const Text('Add'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                context.read<CartBloc>().checkout(),
                            child: const Text('Checkout'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              '/checkout': (context) => const Scaffold(
                body: Center(child: Text('Checkout Page')),
              ),
            },
          ),
        );

        // Add item first
        await tester.tap(find.text('Add'));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();

        // Checkout - should trigger navigation
        await tester.tap(find.text('Checkout'));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pumpAndSettle();

        expect(find.text('Checkout Page'), findsOneWidget);
      });
    });

    group('Interface implementation pattern', () {
      testWidgets('works with CartBlocActions.of() pattern', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<CartBloc>.value(
                value: bloc,
                child: const _TestPageWithInterface(),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Add Item'));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.text('Notification: Added Widget Item to cart'),
          findsOneWidget,
        );
      });
    });

    group('Async action handlers', () {
      testWidgets('handles async action handlers correctly', (tester) async {
        final completer = Completer<void>();
        var handlerCompleted = false;
        var handlerStarted = false;

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<CartBloc>.value(
              value: bloc,
              child: MonoBlocActionListener<CartBloc>(
                actions: CartBlocActions.when(
                  showNotification: (context, message, type) async {
                    handlerStarted = true;
                    await completer.future;
                    handlerCompleted = true;
                  },
                ),
                child: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () => context.read<CartBloc>().addItem(
                      const CartItem(
                        id: '1',
                        name: 'Async Item',
                        price: 10,
                      ),
                    ),
                    child: const Text('Add'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Add'));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();

        // Handler should have started but not completed
        expect(handlerStarted, isTrue);
        expect(handlerCompleted, isFalse);

        // Complete the async operation
        completer.complete();
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();

        // Now handler should be completed
        expect(handlerCompleted, isTrue);
      });
    });

    group('Null action handlers', () {
      testWidgets('ignores actions when handler is null', (tester) async {
        var notificationReceived = false;

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<CartBloc>.value(
              value: bloc,
              child: MonoBlocActionListener<CartBloc>(
                // Only handle navigateToCheckout, ignore others
                actions: CartBlocActions.when(
                  navigateToCheckout: (context) {
                    notificationReceived = true;
                  },
                  // showNotification is null - should be ignored
                ),
                child: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () => context.read<CartBloc>().addItem(
                      const CartItem(id: '1', name: 'Item', price: 10),
                    ),
                    child: const Text('Add'),
                  ),
                ),
              ),
            ),
          ),
        );

        // This should trigger showNotification which is not handled
        await tester.tap(find.text('Add'));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();

        // No error should occur, notificationReceived should still be false
        expect(notificationReceived, isFalse);
      });
    });
  });
}

/// Test widget that implements CartBlocActions interface
class _TestPageWithInterface extends StatelessWidget
    implements CartBlocActions {
  const _TestPageWithInterface();

  @override
  void showNotification(
    BuildContext context,
    String message,
    NotificationType type,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notification: $message')),
    );
  }

  @override
  void navigateToCheckout(BuildContext context) {
    // Not used in this test
  }

  @override
  void navigateToProductDetail(
    BuildContext context,
    String productId,
  ) {
    // Not used in this test
  }

  @override
  Widget build(BuildContext context) {
    return MonoBlocActionListener<CartBloc>(
      actions: CartBlocActions.of(this),
      child: ElevatedButton(
        onPressed: () => context.read<CartBloc>().addItem(
          const CartItem(id: '1', name: 'Widget Item', price: 10),
        ),
        child: const Text('Add Item'),
      ),
    );
  }
}
