# mono_bloc_flutter

[![pub version](https://img.shields.io/pub/v/mono_bloc_flutter?logo=dart)](https://pub.dev/packages/mono_bloc_flutter)
[![Tests](https://github.com/westito/mono_bloc/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/westito/mono_bloc/actions/workflows/tests.yml)

Flutter widgets and utilities for MonoBloc. Provides `MonoBlocActionListener` for handling side effects in Flutter apps.

## Installation

```yaml
dependencies:
  flutter:
    sdk: flutter
  mono_bloc_flutter: ^1.0.0  # No need to add flutter_bloc or mono_bloc

dev_dependencies:
  mono_bloc_generator: ^1.0.0
  build_runner: ^2.10.0
```

## What's Included

This package exports everything you need for using MonoBloc in Flutter:

- **`MonoBlocActionListener`** - Widget for listening to bloc actions
- **All of `flutter_bloc`** - BlocProvider, BlocBuilder, BlocListener, etc.
- **All of `mono_bloc`** - Annotations, base classes, and core functionality

**Important**: You don't need to add `flutter_bloc` or `mono_bloc` to your dependencies - they're already exported by this package.

## Import

You only need one import:

```dart
import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';
```

## Usage

### Define your bloc with actions

Actions are defined in a private mixin annotated with `@MonoActions()`. All abstract `void` methods in the mixin automatically become actions:

```dart
part 'cart_bloc.g.dart';

// 1. Define actions in a private mixin with @MonoActions()
@MonoActions()
mixin _CartBlocActions {
  void navigateToCheckout();
  
  void showNotification(String message);
}

// 2. Bloc class - generated base class includes the actions mixin automatically
@MonoBloc()
class CartBloc extends _$CartBloc<CartState> {
  CartBloc() : super(const CartState());

  @event
  CartState _onCheckout() {
    if (state.items.isNotEmpty) {
      navigateToCheckout();
    }
    return state.copyWith(items: []);
  }
  
  @event
  CartState _onAddItem(Item item) {
    showNotification('Added ${item.name} to cart');
    return state.copyWith(items: [...state.items, item]);
  }
}
```

### Listen to actions in your widget

#### Option 1: Implement the actions interface

```dart
class CartPage extends StatelessWidget implements CartBlocActions {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MonoBlocActionListener<CartBloc>(
      actions: CartBlocActions.of(this),
      child: CartView(),
    );
  }

  @override
  void navigateToCheckout(BuildContext context) {
    Navigator.pushNamed(context, '/checkout');
  }
  
  @override
  void showNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
```

#### Option 2: Use inline actions with `.when()`

```dart
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MonoBlocActionListener<CartBloc>(
      actions: CartBlocActions.when(
        navigateToCheckout: (context) {
          Navigator.pushNamed(context, '/checkout');
        },
        showNotification: (context, message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
      ),
      child: CartView(),
    );
  }
}
```

## Features

### MonoBlocActionListener

A Flutter widget that listens to actions from a MonoBloc and automatically provides `BuildContext` to action handlers.

**Key benefits:**
- ✅ Automatic subscription management (subscribe/unsubscribe)
- ✅ BuildContext automatically provided to all action handlers
- ✅ Type-safe action handling with generated interfaces
- ✅ Two usage patterns: interface implementation or inline callbacks
- ✅ Integrates seamlessly with BlocProvider

### FlutterMonoBlocActions

Base class for generated action handlers in Flutter. Automatically included in generated code when using `@MonoActions()` annotation on action mixins.

## Documentation

For complete documentation, examples, and guides:

- [MonoBloc package](https://pub.dev/packages/mono_bloc) - Core functionality and annotations
- [MonoBloc hooks](https://pub.dev/packages/mono_bloc_hooks) - Flutter Hooks integration

## License

MIT License - see the [LICENSE](https://github.com/westito/mono_bloc/blob/main/LICENSE) file for details.
