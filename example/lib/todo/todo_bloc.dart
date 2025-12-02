import 'package:mono_bloc_example/todo/todo_model.dart';
import 'package:mono_bloc_example/todo/todo_repository.dart';
import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';

part 'todo_bloc.g.dart';

/// TodoBloc demonstrates aggregating todos from multiple sources
/// Shows real-world patterns like search, filtering, and CRUD operations
@MonoBloc()
class TodoBloc extends _$TodoBloc<TodoState> {
  TodoBloc({TodoRepository? repository})
    : _repository = repository ?? TodoRepository(),
      super(const TodoState());

  final TodoRepository _repository;

  /// Load all todos from all sources
  @event
  Future<TodoState> _onLoadAllTodos() async {
    final response = await _repository.fetchAllTodos();
    return TodoState(todos: response.todos, sourceCount: response.sourceCount);
  }

  /// Search across all todo sources with progressive results
  /// Restartable: Cancels previous search if user types again
  /// Yields intermediate states as each source completes
  @restartableEvent
  Stream<TodoState> _onSearchAcrossSources(String query) async* {
    if (query.isEmpty) {
      final response = await _repository.fetchAllTodos();
      yield TodoState(todos: response.todos, sourceCount: response.sourceCount);
      return;
    }

    // Start fresh search - clear previous results
    yield state.copyWith(
      isLoading: true,
      todos: [],
      loadedSources: [],
      sourceCount: {},
      pendingSources: TodoSource.values.map((s) => s.displayName).toList(),
      searchQuery: query,
    );

    // Search each source sequentially, yielding progressive results
    for (final source in TodoSource.values) {
      try {
        final todos = await _repository.searchInSource(source, query);

        final updatedSourceCount = Map<String, int>.from(state.sourceCount);
        updatedSourceCount[source.displayName] = todos.length;

        final updatedLoadedSources = [
          ...state.loadedSources,
          source.displayName,
        ];

        final pendingSources = TodoSource.values
            .map((s) => s.displayName)
            .where((s) => !updatedLoadedSources.contains(s))
            .toList();

        // Yield accumulated results from all sources loaded so far
        yield state.copyWith(
          todos: [...state.todos, ...todos],
          sourceCount: updatedSourceCount,
          loadedSources: updatedLoadedSources,
          isLoading: pendingSources.isNotEmpty,
          pendingSources: pendingSources,
          searchQuery: query,
        );
      } catch (e) {
        yield state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to search ${source.displayName}: $e',
        );
        return;
      }
    }
  }

  /// Add new todo to specified source
  /// Protected methods can be used as event handlers
  /// Demonstrates public event handler with @protected annotation
  @event
  @protected
  Stream<TodoState> onAddTodo(
    String sourceName,
    String title, {
    String? description,
    TodoPriority priority = TodoPriority.medium,
    List<String> tags = const [],
    DateTime? dueDate,
  }) async* {
    final source = TodoSource.values.firstWhere(
      (s) => s.displayName == sourceName,
      orElse: () => TodoSource.myTodo,
    );

    yield state.copyWith(isLoading: true);

    final todo = Todo(
      id: '',
      title: title,
      description: description,
      priority: priority,
      tags: tags,
      dueDate: dueDate,
    );

    await _repository.addTodo(source, todo);

    final response = await _repository.fetchAllTodos();
    yield state.copyWith(
      todos: response.todos,
      sourceCount: response.sourceCount,
      isLoading: false,
    );
  }

  /// Update existing todo in its source
  /// Uses _Emitter for granular loading state control
  @event
  Future<void> _onUpdateTodo(_Emitter emit, Todo todo) async {
    if (todo.source == null) {
      emit(state.copyWith(errorMessage: 'Todo has no source information'));
      return;
    }

    final source = TodoSource.values.firstWhere(
      (s) => s.displayName == todo.source,
      orElse: () => TodoSource.myTodo,
    );

    emit(state.copyWith(isLoading: true));

    await _repository.updateTodo(source, todo);

    final response = await _repository.fetchAllTodos();
    emit(
      state.copyWith(
        todos: response.todos,
        sourceCount: response.sourceCount,
        isLoading: false,
      ),
    );
  }

  /// Delete todo from its source
  @event
  Future<void> _onDeleteTodo(_Emitter emit, Todo todo) async {
    if (todo.source == null) {
      emit(state.copyWith(errorMessage: 'Todo has no source information'));
      return;
    }

    final source = TodoSource.values.firstWhere(
      (s) => s.displayName == todo.source,
      orElse: () => TodoSource.myTodo,
    );

    emit(state.copyWith(isLoading: true));

    await _repository.deleteTodo(source, todo.id);

    final response = await _repository.fetchAllTodos();
    emit(
      state.copyWith(
        todos: response.todos,
        sourceCount: response.sourceCount,
        isLoading: false,
      ),
    );
  }

  /// Toggle todo completion status
  /// Delegates to update event after modifying completion fields
  @event
  Future<void> _onToggleTodo(_Emitter emit, Todo todo) async {
    final updated = todo.copyWith(
      completed: !todo.completed,
      completedAt: !todo.completed ? DateTime.now() : null,
    );
    await _onUpdateTodo(emit, updated);
  }

  /// Filter todos by priority level
  @event
  TodoState _onFilterByPriority(TodoPriority priority) {
    final filtered = state.todos.where((t) => t.priority == priority).toList();
    return state.copyWith(todos: filtered, activeFilter: TodoFilter.byPriority);
  }

  /// Filter todos by source name
  @event
  TodoState _onFilterBySource(String sourceName) {
    final filtered = state.todos.where((t) => t.source == sourceName).toList();
    return state.copyWith(
      todos: filtered,
      sourceCount: {sourceName: filtered.length},
    );
  }

  /// Clear all active filters and reload all todos
  @event
  Future<TodoState> _onClearFilters() {
    return _onLoadAllTodos();
  }

  /// Global error handler for all unhandled errors
  @onError
  TodoState _onError(Object error, StackTrace stackTrace) {
    return state.copyWith(isLoading: false, errorMessage: 'Error: $error');
  }

  /// Specific error handler for add todo failures
  @onError
  TodoState _onErrorAddTodo(Object error, StackTrace stackTrace) {
    return state.copyWith(
      isLoading: false,
      errorMessage: 'Failed to add todo: $error',
    );
  }
}
