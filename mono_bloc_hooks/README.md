# mono_bloc_hooks

[![pub version](https://img.shields.io/pub/v/mono_bloc_hooks?logo=dart)](https://pub.dev/packages/mono_bloc_hooks)
[![Tests](https://github.com/westito/mono_bloc/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/westito/mono_bloc/actions/workflows/tests.yml)

Flutter hooks integration for MonoBloc actions.

## Installation

```yaml
dependencies:
  flutter:
    sdk: flutter
  mono_bloc_flutter: ^1.0.0  # Exports flutter_bloc + mono_bloc
  mono_bloc_hooks: ^1.0.0
  flutter_hooks: ^0.21.0  # Required peer dependency

dev_dependencies:
  mono_bloc_generator: ^1.0.0
  build_runner: ^2.10.0
```

> **Note:** `mono_bloc_flutter` exports `flutter_bloc` and `mono_bloc`, so you don't need to add them separately. However, you do need `flutter_hooks` as a direct dependency.

## Usage

### Define your MonoBloc with actions

Actions are defined in a private mixin annotated with `@MonoActions()`. All abstract `void` methods in the mixin automatically become actions:

```dart
import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';

part 'counter_bloc.g.dart';

// 1. Define actions in a private mixin with @MonoActions()
@MonoActions()
mixin _CounterBlocActions {
  void showMessage(String message);
}

// 2. Bloc class - generated base class includes the actions mixin automatically
@MonoBloc()
class CounterBloc extends _$CounterBloc<int> {
  CounterBloc() : super(0);

  @event
  int _onIncrement() {
    final newValue = state + 1;
    if (newValue >= 10) {
      showMessage('Maximum reached!');
    }
    return newValue;
  }
}
```

### Use in HookWidget

#### Option 1: Using `.when()` for inline actions

```dart
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';
import 'package:mono_bloc_hooks/mono_bloc_hooks.dart';

class CounterPage extends HookWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = useBloc<CounterBloc>();
    
    // Automatically handles subscription lifecycle
    useMonoBlocActionListener(
      bloc,
      CounterBlocActions.when(
        showMessage: (context, message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
      ),
    );

    return BlocBuilder<CounterBloc, int>(
      builder: (context, count) => Text('$count'),
    );
  }
}
```

#### Option 2: Using `.of()` with inline implementation

Useful when you want organized, type-safe action handling:

```dart
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';
import 'package:mono_bloc_hooks/mono_bloc_hooks.dart';

class CounterPage extends HookWidget implements CounterBlocActions {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = useBloc<CounterBloc>();
    
    // Use .of() to pass this widget as action handler
    useMonoBlocActionListener(
      bloc,
      CounterBlocActions.of(this),
    );

    return BlocBuilder<CounterBloc, int>(
      builder: (context, count) => Text('$count'),
    );
  }

  // Implement action handlers
  @override
  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
```

## API Reference

### Hooks

- **`useMonoBlocActionListener(bloc, handler)`** - Listens to bloc actions with automatic subscription cleanup when the widget is disposed.

## Documentation

For complete documentation, examples, and actions guide, see the [MonoBloc package](https://pub.dev/packages/mono_bloc).

## License

MIT License - see the [LICENSE](https://github.com/westito/mono_bloc/blob/main/LICENSE) file for details.
