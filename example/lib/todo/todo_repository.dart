import 'dart:async';

import 'package:mono_bloc_example/todo/todo_data.dart';
import 'package:mono_bloc_example/todo/todo_model.dart';

/// Represents different todo sources that can be aggregated
/// Simulates multiple todo apps/services being combined
enum TodoSource { myTodo, doItNow, taskMaster, quickTask }

/// Extension to get display names for todo sources
extension TodoSourceExtension on TodoSource {
  String get displayName {
    switch (this) {
      case TodoSource.myTodo:
        return 'MyTodo';
      case TodoSource.doItNow:
        return 'DoItNow';
      case TodoSource.taskMaster:
        return 'TaskMaster';
      case TodoSource.quickTask:
        return 'QuickTask';
    }
  }
}

/// Response containing all todos from all sources with counts
class AllTodosResponse {
  const AllTodosResponse({required this.todos, required this.sourceCount});

  /// All todos from all sources
  final List<Todo> todos;

  /// Count of todos per source
  final Map<String, int> sourceCount;
}

/// Result from fetching todos from a specific source
class TodoSourceResult {
  const TodoSourceResult({
    required this.source,
    required this.todos,
    this.error,
  });

  /// The source that was queried
  final TodoSource source;

  /// Todos returned from the source
  final List<Todo> todos;

  /// Error message if the fetch failed
  final String? error;

  /// Whether this result contains an error
  bool get hasError => error != null;

  /// Whether this result has no todos and no error
  bool get isEmpty => todos.isEmpty && !hasError;
}

/// Repository for managing todos from multiple sources
/// Simulates network delays and error conditions for realistic testing
class TodoRepository {
  TodoRepository({this.networkDelayMs = 800, this.shouldThrowError = false})
    : _dataStore = TodoDataStore();

  /// Simulated network delay in milliseconds
  final int networkDelayMs;

  /// Whether to throw errors for testing error handling
  final bool shouldThrowError;

  final TodoDataStore _dataStore;

  /// Build response with todos and counts from all sources
  AllTodosResponse _buildAllTodosResponse() {
    final allTodos = _dataStore.getAllTodos();
    final counts = _dataStore.getTodoCountsBySource();
    final sourceCount = counts.map(
      (key, value) => MapEntry(key.displayName, value),
    );

    return AllTodosResponse(todos: allTodos, sourceCount: sourceCount);
  }

  /// Fetch all todos from all sources
  /// Simulates network delay and possible errors
  Future<AllTodosResponse> fetchAllTodos() async {
    await Future<void>.delayed(Duration(milliseconds: networkDelayMs));

    if (shouldThrowError) {
      throw Exception('Network error fetching todos');
    }

    return _buildAllTodosResponse();
  }

  /// Add new todo to specified source
  Future<void> addTodo(TodoSource source, Todo todo) async {
    await Future<void>.delayed(Duration(milliseconds: networkDelayMs));

    if (shouldThrowError) {
      throw Exception('Network error adding todo');
    }

    _dataStore.addTodo(source, todo);
  }

  /// Update existing todo in specified source
  Future<void> updateTodo(TodoSource source, Todo todo) async {
    await Future<void>.delayed(Duration(milliseconds: networkDelayMs));

    if (shouldThrowError) {
      throw Exception('Network error updating todo');
    }

    _dataStore.updateTodo(source, todo);
  }

  /// Delete todo from specified source
  Future<void> deleteTodo(TodoSource source, String todoId) async {
    await Future<void>.delayed(Duration(milliseconds: networkDelayMs));

    if (shouldThrowError) {
      throw Exception('Network error deleting todo');
    }

    _dataStore.deleteTodo(source, todoId);
  }

  /// Search for todos in specific source by query
  /// Returns todos with source label attached
  Future<List<Todo>> searchInSource(TodoSource source, String query) async {
    await Future<void>.delayed(Duration(milliseconds: networkDelayMs));

    if (shouldThrowError) {
      throw Exception('Network error searching in ${source.displayName}');
    }

    final results = _dataStore.searchInSource(source, query);
    return results.map((todo) {
      return todo.copyWith(source: source.displayName);
    }).toList();
  }

  /// Get count of todos per source
  Map<TodoSource, int> getTodoCountsBySource() {
    return _dataStore.getTodoCountsBySource();
  }
}
