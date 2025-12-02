import 'package:mono_bloc_example/todo/todo_model.dart';
import 'package:mono_bloc_example/todo/todo_repository.dart';
import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';

part 'async_todo_bloc.g.dart';

/// Example of @AsyncMonoBloc that automatically wraps state in MonoAsyncValue
///
/// Key Features:
/// - State is automatically wrapped in MonoAsyncValue<>
/// - Future events automatically emit loading state before execution
/// - Errors are automatically caught and emitted as error states
/// - Use MonoAsyncEmitter for manual control of loading/error states
///
/// Generated Typedefs (available from .g.dart):
/// - typedef _State = `MonoAsyncValue<List<Todo>>`
/// - typedef _Emitter = `MonoAsyncEmitter<List<Todo>>`
///
/// Usage: Use _State and _Emitter in your method signatures!
@AsyncMonoBloc()
class AsyncTodoBloc extends _$AsyncTodoBloc<List<Todo>> {
  AsyncTodoBloc({TodoRepository? repository})
    : _repository = repository ?? TodoRepository(),
      super(const MonoAsyncValue.withData([]));

  final TodoRepository _repository;

  /// `Future<T>` return type: Automatically emits loading state before execution,
  /// then emits data on success or error on failure.
  @event
  Future<List<Todo>> _onLoadAllTodos() async {
    final response = await _repository.fetchAllTodos();
    return response.todos;
  }

  /// `Stream<_State>` return type: User has full control over loading/data/error states
  /// Use protected helpers: [loading()], [loadingClearData()], [withData()], [withError()]
  ///
  /// Note: When @restartableEvent is dispatched again, the previous stream is canceled.
  /// This means any ongoing repository operations (like searchInSource) will be interrupted.
  @restartableEvent
  Stream<_State> _onSearchTodos(String query) async* {
    if (query.isEmpty) {
      final response = await _repository.fetchAllTodos();
      yield withData(response.todos);
      return;
    }

    // Emit loading state before starting search
    // loading() returns _State with current data and isLoading=true
    yield loading();

    final allTodos = <Todo>[];
    for (final source in TodoSource.values) {
      final todos = await _repository.searchInSource(source, query);
      allTodos.addAll(todos);

      // Each yield updates the data using helper
      yield withData(allTodos);
    }
  }

  /// Using _Emitter (MonoAsyncEmitter) for fine-grained control
  /// emit.loading() - emit loading state with current data
  /// emit.loadingClearData() - emit loading state without data
  /// emit(data) - emit success state
  @event
  Future<void> _onAddTodo(
    _Emitter emit,
    String title, {
    String? description,
    TodoPriority priority = TodoPriority.medium,
  }) async {
    // Emit loading state with current data
    emit.loading();

    final todo = Todo(
      id: '',
      title: title,
      description: description,
      priority: priority,
    );

    await _repository.addTodo(TodoSource.myTodo, todo);

    final response = await _repository.fetchAllTodos();
    emit(response.todos);
  }

  /// Using _Emitter with loadingClearData()
  @event
  Future<void> _onRefreshTodos(_Emitter emit) async {
    // Emit loading state WITHOUT current data (shows spinner only)
    emit.loadingClearData();

    await Future<void>.delayed(const Duration(seconds: 1));

    final response = await _repository.fetchAllTodos();
    emit(response.todos);
  }

  /// Synchronous events return data directly (no loading state)
  @event
  List<Todo> _onFilterByPriority(TodoPriority priority) {
    final currentData = state.dataOrNull ?? [];
    return currentData.where((t) => t.priority == priority).toList();
  }

  /// Synchronous events with emitter
  @event
  void _onClearFilter(_Emitter emit) {
    final currentData = state.dataOrNull ?? [];
    emit(currentData);
  }

  /// Prevent events from being processed while already loading
  @onEvent
  bool _onEvents(_Event event) {
    if (state.isLoading) {
      return false;
    }
    return true;
  }
}
