<p align="center">
  <img src="https://raw.githubusercontent.com/westito/mono_bloc/main/assets/mono_bloc.png" alt="MonoBloc" />
</p>

# MonoBloc

[![pub version](https://img.shields.io/pub/v/mono_bloc?logo=dart)](https://pub.dev/packages/mono_bloc)
[![pub version](https://img.shields.io/pub/v/mono_bloc_generator?logo=dart&label=mono_bloc_generator)](https://pub.dev/packages/mono_bloc_generator)
[![pub version](https://img.shields.io/pub/v/mono_bloc_flutter?logo=dart&label=mono_bloc_flutter)](https://pub.dev/packages/mono_bloc_flutter)
[![pub version](https://img.shields.io/pub/v/mono_bloc_hooks?logo=dart&label=mono_bloc_hooks)](https://pub.dev/packages/mono_bloc_hooks)
[![Tests](https://github.com/westito/mono_bloc/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/westito/mono_bloc/actions/workflows/tests.yml)

**Simplify your Flutter Bloc code with annotations and automatic code generation**

Write cleaner, more maintainable Bloc classes by defining events as simple methods. MonoBloc eliminates boilerplate event and state classes, reduces naming conflicts, and provides built-in concurrency control with action side-effects.

## Features

- ✨ **Less Boilerplate** - Define events as methods instead of separate classes
- 🎛️ **Built-in Concurrency** - Use transformers with simple annotations
- 🎯 **Action Side-Effects** - Handle navigation, dialogs, and snackbars with @MonoActions() mixin
- ♻️ **Automatic Async State** - @AsyncMonoBloc handles loading/error states automatically
- ↩️ **Flexible Returns** - Support for State, Future<State>, Stream<State>, or void with Emitter
- 🚨 **Error Handling** - Centralized error handling with @onError
- 📊️ **Event Queues** - Sequential processing for related operations
- 🪝 **Flutter Hooks Support** - mono_bloc_hooks package for cleaner action handling in HookWidget

## Why MonoBloc?

Traditional Bloc architecture requires separate event classes, leading to verbose code and boilerplate. MonoBloc simplifies this by letting you define events as simple methods, automatically generating all the boilerplate while providing powerful features like built-in concurrency control, action side-effects, and automatic async state management.

## Table of Contents

- [Quick Start](#quick-start)
- [Feature Example](#feature-example)
- [Event Patterns](#event-patterns)
- [Actions - Side Effects Pattern](#actions---side-effects-pattern)
- [Concurrency Transformers](#concurrency-transformers)
- [Event Queues](#event-queues)
- [Event Filtering with @onEvent](#event-filtering-with-onevent)
- [Error Handling](#error-handling)
- [Troubleshooting](#troubleshooting)
- [Coding Agents Instructions](#coding-agents-instructions)
- [Contributing](#contributing)

## Quick Start

### 1. Install

**For pure Dart projects:**

```yaml
dependencies:
  mono_bloc: ^1.0.0

dev_dependencies:
  mono_bloc_generator: ^1.0.0
  build_runner: ^2.10.0
```

**For Flutter projects:**

```yaml
dependencies:
  flutter:
    sdk: flutter
  mono_bloc_flutter: ^1.0.0  # Exports flutter_bloc + mono_bloc

dev_dependencies:
  mono_bloc_generator: ^1.0.0
  build_runner: ^2.10.0
```

**For Flutter + Hooks projects:**

```yaml
dependencies:
  flutter:
    sdk: flutter
  mono_bloc_flutter: ^1.0.0  # Exports flutter_bloc + mono_bloc
  mono_bloc_hooks: ^1.0.0
  flutter_hooks: ^0.21.0

dev_dependencies:
  mono_bloc_generator: ^1.0.0
  build_runner: ^2.10.0
```

### 2. Create your bloc

```dart
import 'package:mono_bloc/mono_bloc.dart';

part 'counter_bloc.g.dart';

@MonoBloc()
class CounterBloc extends _$CounterBloc<int> {
  CounterBloc() : super(0);

  @event
  int _onIncrement() => state + 1;

  @event
  int _onDecrement() => state - 1;

  @event
  int _onReset() => 0;
}
```

### 3. Generate

Run the code generator:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Use

```dart
void main() {
  final bloc = CounterBloc();
  
  // Generated methods - clean and type-safe
  bloc.increment();
  bloc.decrement();
  bloc.reset();
  
  print(bloc.state); // 0
}
```

## Feature Example

Here's a comprehensive example showcasing all MonoBloc features:

```dart
import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';

part 'todo_bloc.g.dart';

// 1. Define actions in a private mixin with @MonoActions()
@MonoActions()
mixin _TodoBlocActions {
  void showSuccess(String message);
  
  void navigateToDetail(String todoId);
}

// 2. Sequential mode - all events processed in order, waiting for each to finish
@MonoBloc(sequential: true)
class TodoBloc extends _$TodoBloc<TodoState> {
  TodoBloc() : super(TodoState());
  
  // 3. Events with different return types
  @event
  Future<TodoState> _onLoadTodos() async {
    final todos = await repository.fetchTodos();
    return state.copyWith(todos: todos);
  }
  
  @restartableEvent  // 4. Concurrency control - cancels previous search
  Stream<TodoState> _onSearch(String query) async* {
    yield state.copyWith(isSearching: true);
    final results = await repository.search(query);
    yield state.copyWith(isSearching: false, todos: results);
  }
  
  @event  // 5. Stream with loading/data yields for progressive updates
  Stream<TodoState> _onLoadFromMultipleSources() async* {
    yield state.copyWith(isLoading: true);
    final allTodos = <Todo>[];
    for (final source in TodoSource.values) {
      final todos = await repository.fetchFrom(source);
      allTodos.addAll(todos);
      yield state.copyWith(isLoading: false, todos: allTodos);
    }
  }
  
  @droppableEvent  // 6. Prevents duplicate submissions
  Future<TodoState> _onAddTodo(String title) async {
    final todo = await repository.add(title);
    showSuccess('Todo added!');  // Trigger action
    return state.copyWith(todos: [...state.todos, todo]);
  }
  
  @event
  Future<TodoState> _onToggleTodo(String id) async {
    final todos = state.todos.map((t) => t.id == id ? t.copyWith(completed: !t.completed) : t).toList();
    return state.copyWith(todos: todos);
  }
  
  @event
  Future<TodoState> _onDeleteTodo(String id) async {
    await repository.delete(id);
    navigateToDetail('list');  // Trigger navigation action
    return state.copyWith(todos: state.todos.where((t) => t.id != id).toList());
  }
  
  // 7. Error handling - centralized for all events
  @onError
  TodoState _onError(Object error, StackTrace stackTrace) {
    return state.copyWith(error: error.toString());
  }
  
  // 8. Initialization - runs automatically on creation
  @onInit
  void _onInit() {
    loadTodos();  // Dispatch event to load initial data
  }
}

// 9. Flutter integration - handle actions with MonoBlocActionListener
class TodoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MonoBlocActionListener<TodoBloc>(
      actions: TodoBlocActions.when(
        showSuccess: (context, message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
        navigateToDetail: (context, todoId) {
          Navigator.pushNamed(context, '/detail', arguments: todoId);
        },
      ),
      child: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          // Build UI based on state
        },
      ),
    );
  }
}

// 10. Flutter Hooks support - cleaner action handling
class TodoPageWithHooks extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = useBloc<TodoBloc>();
    
    useMonoBlocActionListener(
      bloc,
      TodoBlocActions.when(
        showSuccess: (context, message) { /* Show snackbar */ },
        navigateToDetail: (context, todoId) { /* Navigate */ },
      ),
    );
    
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, state) {
        // Build UI
      },
    );
  }
}
```

For more complete examples, see the [example](https://github.com/westito/mono_bloc/tree/main/example) directory.

## Event Patterns

MonoBloc supports multiple return patterns for maximum flexibility:

### Direct state return

The simplest pattern - just return the new state:

```dart
@event
int _onIncrement() => state + 1;

@event
CounterState _onSetValue(int value) => CounterValue(value);
```

### Async state return

For asynchronous operations:

```dart
@event
Future<TodoState> _onLoadTodos() async {
  final todos = await repository.fetchTodos();
  return TodoState(todos: todos);
}
```

### Stream state return

For progressive updates:

```dart
@event
Stream<CounterState> _onLoadAsync() async* {
  yield CounterLoading();
  await Future.delayed(Duration(seconds: 2));
  yield CounterValue(42);
}
```

**Important:** When using stream-returning events with transformers like `@restartableEvent`, dispatching a new event will **cancel the previous stream**. This means any ongoing async operations (like repository fetches or network calls) within the stream will be interrupted. This is useful for scenarios like search-as-you-type, where you want to cancel the previous search when the user types a new query.

### Emitter pattern

For multiple emissions with full control, use the generated `_Emitter` typedef:

```dart
@event
Future<void> _onComplexOperation(_Emitter emit) async {
  emit(LoadingState());
  try {
    final result = await doWork();
    emit(SuccessState(result));
  } catch (e) {
    emit(ErrorState(e));
  }
}
```

## Actions - Side Effects Pattern

Actions provide a clean pattern for handling side effects that don't modify bloc state, such as navigation, showing dialogs, triggering analytics, or displaying notifications. Actions are emitted to a separate stream and can be handled in the UI layer without affecting your state management.

> **📱 Flutter Project Detection**: In Flutter projects (with `flutter` SDK in `pubspec.yaml`), all action handlers automatically receive `BuildContext` as the first parameter. In pure Dart projects, actions don't include `BuildContext`. This is determined by project type, not by file imports.

### Why actions?

- **Separation of Concerns**: Keep side effects separate from state
- **Type Safety**: Full type checking for all action parameters
- **Pattern Matching**: Use `when()` or `of()` for exhaustive action handling
- **No State Pollution**: Navigation/dialogs don't belong in state
- **Clean UI Code**: Handle actions with simple stream listeners

### Basic usage

Define actions in a **private mixin** annotated with `@MonoActions()`. All abstract `void` methods in the mixin automatically become actions:

```dart
import 'package:mono_bloc/mono_bloc.dart';

part 'checkout_bloc.g.dart';

enum NotificationType { success, error, warning }

// 1. Define actions in a private mixin with @MonoActions()
@MonoActions()
mixin _CheckoutBlocActions {
  void navigateToConfirmation(String orderId);
  
  void showNotification({
    required String message,
    required NotificationType type,
  });
  
  void trackAnalyticsEvent(String eventName, Map<String, dynamic> properties);
}

// 2. Bloc class - the generated base class includes the actions mixin
@MonoBloc()
class CheckoutBloc extends _$CheckoutBloc<CheckoutState> {
  CheckoutBloc() : super(CheckoutState());
  
  // Events - modify state as usual
  @event
  Future<CheckoutState> _onSubmitOrder(Order order) async {
    try {
      final orderId = await repository.submitOrder(order);
      
      // Trigger actions during event processing
      trackAnalyticsEvent('order_submitted', {'orderId': orderId});
      navigateToConfirmation(orderId);
      showNotification(
        message: 'Order submitted successfully!',
        type: NotificationType.success,
      );
      
      return state.copyWith(isProcessing: false);
    } catch (e) {
      showNotification(
        message: 'Failed to submit order',
        type: NotificationType.error,
      );
      rethrow;
    }
  }
}
```

### Handling actions in UI - MonoBlocActionListener

Use `MonoBlocActionListener<YourBloc>` widget to handle actions declaratively (recommended):

```dart
import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MonoBlocActionListener<CheckoutBloc>(
      // Generated CheckoutBlocActions with named callbacks
      actions: CheckoutBlocActions.when(
        navigateToConfirmation: (context, orderId) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ConfirmationPage(orderId: orderId),
            ),
          );
        },
        showNotification: (context, message, type) {
          Color color;
          switch (type) {
            case NotificationType.success:
              color = Colors.green;
            case NotificationType.error:
              color = Colors.red;
            case NotificationType.warning:
              color = Colors.orange;
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: color,
            ),
          );
        },
        trackAnalyticsEvent: (context, eventName, properties) {
          analytics.track(eventName, properties);
        },
      ),
      child: BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, state) {
          return CheckoutForm(
            isProcessing: state.isProcessing,
            onSubmit: (order) {
              context.read<CheckoutBloc>().submitOrder(order);
            },
          );
        },
      ),
    );
  }
}
```

### Using `of()` with interface implementation

For cleaner action handling, implement the generated actions interface and use `of()`:

```dart
import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';

/// Implements CheckoutBlocActions interface - all action methods in one place
class CheckoutPage extends StatelessWidget implements CheckoutBlocActions {
  const CheckoutPage({super.key});

  @override
  void navigateToConfirmation(BuildContext context, String orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ConfirmationPage(orderId: orderId)),
    );
  }

  @override
  void showNotification(BuildContext context, String message, NotificationType type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void trackAnalyticsEvent(BuildContext context, String eventName, Map<String, dynamic> properties) {
    analytics.track(eventName, properties);
  }

  @override
  Widget build(BuildContext context) {
    return MonoBlocActionListener<CheckoutBloc>(
      // Use of() to wire this instance as the action handler
      actions: CheckoutBlocActions.of(this),
      child: BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, state) {
          return CheckoutForm(onSubmit: context.read<CheckoutBloc>().submitOrder);
        },
      ),
    );
  }
}
```

**When to use which pattern:**
- **`when()`** - Inline callbacks, good for simple pages with few actions
- **`of()`** - Interface implementation, better for complex pages or reusable action handlers

### Manual subscription (alternative)

You can also manually subscribe to the actions stream using `didChangeDependencies`:

```dart
class CheckoutPage extends StatefulWidget {
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  StreamSubscription? _actionsSubscription;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initSubscription();
  }
  
  void _initSubscription() {
    if (_actionsSubscription != null) return;  // Already initialized
    
    final bloc = context.read<CheckoutBloc>();
    
    // Create actions handler
    final actionHandler = CheckoutBlocActions.when(
      navigateToConfirmation: (context, orderId) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConfirmationPage(orderId: orderId),
          ),
        );
      },
      showNotification: (context, message, type) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
      trackAnalyticsEvent: (context, eventName, properties) {
        analytics.track(eventName, properties);
      },
    );
    
    // Subscribe to actions stream
    _actionsSubscription = bloc.actions.listen(
      (action) => actionHandler.actions(context, action),
    );
  }
  
  @override
  void dispose() {
    _actionsSubscription?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        return CheckoutForm(
          isProcessing: state.isProcessing,
          onSubmit: (order) {
            context.read<CheckoutBloc>().submitOrder(order);
          },
        );
      },
    );
  }
}
```

### With Flutter hooks

Use the `mono_bloc_hooks` package for a cleaner approach with `HookWidget`:

```dart
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mono_bloc_hooks/mono_bloc_hooks.dart';

class CheckoutPage extends HookWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = useBloc<CheckoutBloc>();

    // Hook automatically manages subscription
    useMonoBlocActionListener(
      bloc,
      CheckoutBlocActions.when(
        navigateToConfirmation: (context, orderId) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ConfirmationPage(orderId: orderId),
            ),
          );
        },
        showNotification: (context, message, type) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
      ),
    );

    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        return CheckoutForm(onSubmit: bloc.submitOrder);
      },
    );
  }
}
```

### Mixin requirements

When using actions, follow these rules:

1. **@MonoActions() mixin**: Actions must be defined in a mixin annotated with `@MonoActions()` starting with `_` (e.g., `_CheckoutBlocActions`)
2. **Abstract methods only**: Action methods must be abstract (no body)
3. **Return void**: All action methods must return `void`
4. **Automatic mixin**: The generated `_$Bloc` base class automatically includes the actions mixin - you don't need to add `with _BlocActions`

```dart
// Correct: Actions in a private mixin with @MonoActions()
@MonoActions()
mixin _MyBlocActions {
  void myAction();
}

// The generated _$MyBloc already includes 'with _MyBlocActions'
@MonoBloc()
class MyBloc extends _$MyBloc<MyState> {
  MyBloc() : super(initialState);
}
```

### Inheritance

Share common actions across multiple blocs by having private action mixins implement a public base mixin. This allows you to define reusable action interfaces that can be shared across your application, enabling consistent error handling, navigation patterns, and other cross-cutting concerns. The generated `_$Bloc` base class automatically includes the actions mixin.

## Concurrency Transformers

Control how concurrent events are handled with built-in transformers.

### Important: Bloc-Level vs Event-Level Sequential Mode

**`@MonoBloc(sequential: true)` ≠ `@sequentialEvent`**

These are different concurrency controls:

1. **`@MonoBloc(sequential: true)`** - Global bloc-level mode
   - ALL events in the entire bloc wait for each other
   - Button clicks, API calls, user input - everything queued sequentially
   - Simplest option to prevent any race conditions

2. **`@sequentialEvent`** - Per-event annotation
   - Only that specific event type waits for previous instances of itself
   - Other event types can run in parallel
   - Fine-grained control per event

**Example showing the difference:**

```dart
// Bloc-level sequential: ALL events wait for each other
@MonoBloc(sequential: true)
class BlocLevelSequential extends _$BlocLevelSequential<State> {
  @event
  Future<State> _onSearch(String query) async { /* ... */ }  // Waits for loadData
  
  @event
  Future<State> _onLoadData() async { /* ... */ }  // Waits for search
  
  // If loadData is running, search must wait (and vice versa)
}

// Event-level sequential: Only same event types wait for each other
@MonoBloc()
class EventLevelSequential extends _$EventLevelSequential<State> {
  @sequentialEvent
  Future<State> _onSearch(String query) async { /* ... */ }  // Only waits for previous search
  
  @event
  Future<State> _onLoadData() async { /* ... */ }  // Runs independently
  
  // If loadData is running, search can still execute (they're different events)
}
```

### Default Concurrency Mode

Set a default concurrency mode for all events using `@MonoBloc(concurrency:)`:

```dart
@MonoBloc(concurrency: MonoConcurrency.restartable)
class SearchBloc extends _$SearchBloc<SearchState> {
  SearchBloc() : super(const SearchState());

  @event  // Uses restartable (from bloc default)
  Future<SearchState> _onSearch(String query) async {
    final results = await api.search(query);
    return state.copyWith(results: results);
  }

  @event  // Uses restartable (from bloc default)
  Future<SearchState> _onFilter(String filter) async {
    final results = await api.filter(filter);
    return state.copyWith(results: results);
  }

  @droppableEvent  // Explicit override: uses droppable instead
  Future<SearchState> _onLoadMore() async {
    final more = await api.loadMore(state.page + 1);
    return state.copyWith(results: [...state.results, ...more]);
  }
}
```

**Available concurrency modes:**
- `MonoConcurrency.concurrent` - Process all events simultaneously (default)
- `MonoConcurrency.sequential` - Process events one at a time
- `MonoConcurrency.restartable` - Cancel ongoing event when new one arrives
- `MonoConcurrency.droppable` - Ignore new events while one is processing

## Event Queues

For advanced use cases, group specific events into named queues with custom transformers:

```dart
@MonoBloc()
class TodoBloc extends _$TodoBloc<TodoState> {
  static const modifyQueue = 'modify';
  static const syncQueue = 'sync';

  TodoBloc() : super(
    TodoState(),
    queues: {
      modifyQueue: MonoEventTransformer.sequential,  // Modify queue: sequential
      syncQueue: MonoEventTransformer.droppable,     // Sync queue: droppable
    },
  );

  // Modify operations in 'modify' queue (sequential)
  @MonoEvent.queue(modifyQueue)
  Future<TodoState> _onAddTodo(String title) async {
    await repository.add(title);
    return await _loadTodos();
  }

  @MonoEvent.queue(modifyQueue)
  Future<TodoState> _onDeleteTodo(String id) async {
    await repository.delete(id);
    return await _loadTodos();
  }

  // Sync operations in 'sync' queue (droppable)
  @MonoEvent.queue(syncQueue)
  Future<TodoState> _onSync() async {
    await api.sync();
    return await _loadTodos();
  }

  // Read operations run independently
  @restartableEvent
  Stream<TodoState> _onSearch(String query) async* {
    yield await _performSearch(query);
  }
}
```

**When to use what:**
- **`@MonoBloc(sequential: true)`** - Simplest option. ALL events in the entire bloc wait for each other (global sequential mode).
- **Individual transformers** - Per-event control. Only same event types affect each other (`@sequentialEvent` for one event, `@restartableEvent` for another).
- **Event Queues** - Advanced control. Group specific events with custom transformers.

## Event Filtering with @onEvent

Control which events are processed using `@onEvent` handlers. This is perfect for preventing race conditions, implementing loading state guards, or conditional event processing.

### Basic usage - all events

Filter all events with a single handler:

```dart
@MonoBloc()
class TodoBloc extends _$TodoBloc<TodoState> {
  TodoBloc() : super(TodoState());

  @event
  Future<TodoState> _onLoadTodos() async {
    final todos = await repository.fetchTodos();
    return TodoState(todos: todos);
  }

  @event
  Future<TodoState> _onSaveTodo(Todo todo) async {
    await repository.save(todo);
    return await _loadCurrentState();
  }

  /// Prevent any events while loading
  @onEvent
  bool _onEvents(_Event event) {
    // Skip all events if currently loading
    if (state.isLoading) {
      return false; // Event will be dropped
    }
    return true; // Event will be processed
  }
}
```

### Specific event filtering

Filter individual event types:

```dart
@AsyncMonoBloc()
class DataBloc extends _$DataBloc<Data> {
  DataBloc() : super(const MonoAsyncValue.withData(initialData));

  @event
  Future<Data> _onLoadData() async {
    return await repository.loadData();
  }

  @event
  Future<Data> _onRefreshData() async {
    return await repository.refreshData();
  }

  /// Only filter the loadData event
  @onEvent
  bool _onLoadDataFilter(_LoadDataEvent event) {
    // Skip loadData if already loading
    if (state.isLoading) {
      print('Skipping loadData - already loading');
      return false;
    }
    return true;
  }

  // refreshData is not filtered, can run anytime
}
```

### Event group filtering

Filter groups of events like sequential events or queue events:

```dart
@MonoBloc()
class TaskBloc extends _$TaskBloc<TaskState> {
  TaskBloc() : super(TaskState());

  @sequentialEvent
  Future<TaskState> _onProcessTask(Task task) async {
    await processor.process(task);
    return state.addCompleted(task);
  }

  @sequentialEvent
  Future<TaskState> _onExecuteTask(Task task) async {
    await executor.execute(task);
    return state.addExecuted(task);
  }

  @event
  TaskState _onGetStatus() => state;

  /// Filter all sequential events as a group
  @onEvent
  bool _onSequential(_$SequentialEvent event) {
    // Block sequential events if queue is full
    if (state.queueSize >= maxQueueSize) {
      print('Queue full, dropping sequential event');
      return false;
    }
    return true;
  }

  // getStatus() is not affected by the filter
}
```

### Queue event filtering

Filter events in specific queues:

```dart
@MonoBloc()
class UploadBloc extends _$UploadBloc<UploadState> {
  static const uploadQueue = 'upload';
  static const syncQueue = 'sync';

  UploadBloc() : super(
    UploadState(),
    queues: {
      uploadQueue: MonoEventTransformer.sequential, // Upload queue
      syncQueue: MonoEventTransformer.droppable,    // Sync queue
    },
  );

  @MonoEvent.queue(uploadQueue)
  Future<UploadState> _onUploadFile(File file) async {
    await api.upload(file);
    return state.addUploaded(file);
  }

  @MonoEvent.queue(syncQueue)
  Future<UploadState> _onSync() async {
    await api.sync();
    return await _getCurrentState();
  }

  /// Filter only upload queue events
  @onEvent
  bool _onUploadQueue(_$UploadQueueEvent event) {
    // Limit concurrent uploads
    if (state.activeUploads >= 3) {
      return false;
    }
    return true;
  }

  // Sync events (sync queue) are not affected
}
```

## Error Handling

Centralized error handling for your bloc using `@onError`:

```dart
@MonoBloc()
class TodoBloc extends _$TodoBloc<TodoState> {
  TodoBloc() : super(TodoState());

  @event
  Future<TodoState> _onLoadTodos() async {
    // Any error is caught and passed to error handler
    final todos = await repository.fetchTodos();
    return TodoState(todos: todos);
  }

  @onError
  TodoState _onError(Object error, StackTrace stackTrace) {
    return state.copyWith(
      errorMessage: 'Failed to load: ${error.toString()}',
    );
  }
}
```

MonoBloc automatically provides enhanced stack traces for debugging async errors. Every event captures its dispatch location, and when errors occur, you get a combined stack trace showing both where the event was dispatched and where the error occurred, with framework noise automatically filtered out.

### Specific error handlers

Handle errors for specific events:

```dart
@MonoBloc()
class MyBloc extends _$MyBloc<MyState> {
  @event
  Future<MyState> _onAddItem(String item) async {
    await repository.add(item);
    return SuccessState();
  }

  // Specific handler for addItem errors
  @onError
  MyState _onErrorAddItem(Object error, StackTrace stackTrace) {
    return ErrorState('Failed to add item: $error');
  }

  // General error handler for other events
  @onError
  MyState _onError(Object error, StackTrace stackTrace) {
    return ErrorState('An error occurred: $error');
  }
}
```

## Troubleshooting

### Required imports

Every MonoBloc file needs just **one import** and a `part` directive:

**Pure Dart:**
```dart
import 'package:mono_bloc/mono_bloc.dart';

part 'my_bloc.g.dart';

@MonoBloc()
class MyBloc extends _$MyBloc<MyState> {
  MyBloc() : super(initialState);
  
  @event
  MyState _onEvent() => newState;
}
```

**Flutter (with actions):**
```dart
import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';

part 'my_bloc.g.dart';

@MonoActions()
mixin _MyBlocActions {
  void showMessage(String message);
}

// No need to add 'with _MyBlocActions' - it's included in _$MyBloc
@MonoBloc()
class MyBloc extends _$MyBloc<MyState> {
  MyBloc() : super(initialState);
  
  @event
  MyState _onEvent() => newState;
}
```

**What's exported:**
- `mono_bloc` exports: `package:bloc/bloc.dart` + `@protected`/`@immutable` from `meta`
- `mono_bloc_flutter` exports: `package:flutter_bloc/flutter_bloc.dart` + all of `mono_bloc`
- `mono_bloc_hooks` exports: `useMonoBlocActionListener` (uses `hooked_bloc` internally for `useBloc<T>()`)

**Common Errors:**
- Missing the MonoBloc import - Required for annotations like `@MonoBloc()` and `@event`
- Missing `part` directive - Required to include the generated code
- Importing `bloc` or `flutter_bloc` directly - Not needed, already exported

### Build errors

If you see errors about missing generated files:

1. Ensure you have the `part` directive: `part 'my_bloc.g.dart';`
2. Check that all required imports are present (see above)
3. Run the generator: `dart run build_runner build -d`
4. Check that method names are valid and don't conflict

## Coding agents instructions

Use this guide when working with MonoBloc code generation. Add this to your AI coding agent instructions or context files:

````
# MonoBloc State Management

## Core Annotations

- @MonoBloc() - Marks a class for code generation. Creates base class _$YourBloc with event handlers
- @onInit - Marks a private method to run automatically when bloc is created (e.g., `void _onInit()`)
- @event - Marks a private method as an event handler. Generates public method without underscore/prefix
- @MonoActions() - Marks a mixin containing action side-effect methods (navigation, dialogs)
- @onError - Global error handler for all events. Specific handlers: _onError{EventName}(error, stackTrace)

## Event Return Types

Methods annotated with @event can return:
- State - Direct synchronous state update
- Future<State> - Async operation returning new state
- Stream<State> - Multiple state emissions over time (use async*)
- void with _Emitter emit - Manual control with emit(state) calls
- Future<void> with _Emitter emit - Async manual control

Example:

```dart
class MyBloc extends _$MyBloc<int> {
  @event
  int _onIncrement() => state + 1;
  
  @event
  Future<TodoState> _onLoadTodos() async {
    final todos = await repository.fetchTodos();
    return TodoState(todos: todos);
  }
  
  @event
  Stream<SearchState> _onSearch(String query) async* {
    yield state.copyWith(isSearching: true);
    final results = await repository.search(query);
    yield state.copyWith(isSearching: false, results: results);
  }
  
  // Stream with progressive loading from multiple sources
  @event
  Stream<DataState> _onLoadFromSources() async* {
    yield state.copyWith(isLoading: true);
    final allItems = <Item>[];
    for (final source in sources) {
      final items = await source.fetch();
      allItems.addAll(items);
      yield state.copyWith(isLoading: false, items: allItems);
    }
  }
}
```

Calling events (generated methods remove underscore and prefix):

```dart
void main() {
  final bloc = CounterBloc();
  bloc.increment();  // Calls _onIncrement
  bloc.loadTodos();  // Calls _onLoadTodos
}
```

## Actions Pattern

For side effects (navigation, dialogs, notifications), define actions in a private mixin with @MonoActions():

```dart
// 1. Define actions in a private mixin with @MonoActions()
@MonoActions()
mixin _MyBlocActions {
  void navigateToCheckout();
  
  void showNotification(String message);
}

// 2. Bloc extends generated base class (actions mixin included automatically)
@MonoBloc()
class MyBloc extends _$MyBloc<MyState> {
  MyBloc() : super(MyState());
  
  @event
  Future<MyState> _onSubmit() async {
    // Call actions during event processing
    navigateToCheckout();
    showNotification('Success!');
    return state.copyWith(submitted: true);
  }
}

// In Flutter widget - use MonoBlocActionListener<YourBloc>
void build(BuildContext context) {
  return MonoBlocActionListener<MyBloc>(
    actions: MyBlocActions.when(
      navigateToCheckout: (context) => Navigator.pushNamed(context, '/checkout'),
      showNotification: (context, msg) => ScaffoldMessenger.of(context).showSnackBar(...),
    ),
    child: Widget(),
  )
}
```

## Shared Action Mixins

Share common actions across multiple blocs by having private action mixins `implement` a public base mixin (e.g., `mixin _OrderBlocActions implements ErrorHandlerActions`). The generated base class automatically includes the actions mixin.

## Async State Management

Use @AsyncMonoBloc() for automatic loading/error states:

```dart
@AsyncMonoBloc()
class MyBloc extends _$MyBloc<List<Item>> {
  MyBloc() : super(const MonoAsyncValue.withData([]));
  
  // Future<T> - Automatically emits loading, then data or error
  @event
  Future<List<Item>> _onLoad() async {
    return await repository.fetchItems();
  }
  
  // Stream<_State> - Full control with loading/data/error yields
  @restartableEvent
  Stream<_State> _onSearch(String query) async* {
    yield loading();  // Keeps current data, sets isLoading=true
    try {
      final items = await repository.search(query);
      yield withData(items);
    } catch (e, stack) {
      yield withError(e, stack, state.dataOrNull);
    }
  }
  
  // _Emitter pattern - Fine-grained control
  @event
  Future<void> _onRefresh(_Emitter emit) async {
    emit.loadingClearData();  // Clears data, shows spinner
    try {
      final items = await repository.fetchItems();
      emit(items);
    } catch (e, stack) {
      emit.error(e, stack);
    }
  }
}
```

// Helpers: loading(), loadingClearData(), withData(T), withError(e, stack, [data])
// State accessors: state.isLoading, state.hasError, state.dataOrNull, state.data

## @onInit - Initialization

Run code automatically when bloc is created. Init methods should return `void` and dispatch events:

```dart
@MonoBloc()
class MyBloc extends _$MyBloc<MyState> {
  MyBloc() : super(MyState.initial());

  @onInit
  void _onInit() {
    loadItems();  // Dispatch event to load data
  }

  @event
  Future<MyState> _onLoadItems() async {
    final items = await repository.fetchAll();
    return MyState(items: items);
  }
}
```

## Flutter Hooks

Use the `mono_bloc_hooks` package for cleaner action handling in `HookWidget`:

```dart
import 'package:mono_bloc_hooks/mono_bloc_hooks.dart';

Widget build(BuildContext context) {
  final bloc = useBloc<MyBloc>();

  useMonoBlocActionListener(
    bloc,
    MyBlocActions.when(
      myAction: (context, param) { /* Handle action */ },
    ),
  );
  
  return BlocBuilder<MyBloc, MyState>(...);
}
``` 
````

## Contributing

Contributions are welcome! Here's how you can help:

- **Report bugs**: Open an issue with reproduction steps
- **Request features**: Describe your use case and proposed solution
- **Submit PRs**: Add features, fix bugs, or improve documentation
- **Write tests**: Add test scenarios in the `mono_bloc_generator/test/` directory

Before contributing, please:
1. Check existing issues and PRs
2. Follow the existing code style
3. Add tests for new features
4. Update documentation as needed

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

MonoBloc is built on top of the excellent [bloc](https://pub.dev/packages/bloc) library by [Felix Angelov](https://github.com/felangel). We extend its functionality with code generation to reduce boilerplate while keeping the powerful state management patterns that made bloc great.

## Resources

- [Bloc Documentation](https://bloclibrary.dev/)
- [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- [flutter_hooks](https://pub.dev/packages/flutter_hooks)
- [build_runner](https://pub.dev/packages/build_runner)
- [source_gen](https://pub.dev/packages/source_gen)
