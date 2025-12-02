import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_model.freezed.dart';

/// Priority levels for todo items
enum TodoPriority { low, medium, high, urgent }

/// Available filter types for todo lists
enum TodoFilter { all, active, completed, byPriority, byTag }

/// Task item model using Freezed for immutability and copying
@freezed
sealed class Todo with _$Todo {
  const factory Todo({
    /// Unique identifier for the todo
    required String id,

    /// Title or main description
    required String title,

    /// Whether the todo has been completed
    @Default(false) bool completed,

    /// Priority level for sorting and filtering
    @Default(TodoPriority.medium) TodoPriority priority,

    /// Tags for categorization and search
    @Default([]) List<String> tags,

    /// Optional detailed description
    String? description,

    /// Source system this todo came from (MyTodo, DoItNow, etc.)
    String? source,

    /// Optional due date for deadline tracking
    DateTime? dueDate,

    /// When the todo was created
    DateTime? createdAt,

    /// When the todo was marked complete
    DateTime? completedAt,
  }) = _Todo;
}

/// State for TodoBloc managing todos from multiple sources
@freezed
sealed class TodoState with _$TodoState {
  const factory TodoState({
    /// All todos from all sources
    @Default([]) List<Todo> todos,

    /// Count of todos per source for display
    @Default({}) Map<String, int> sourceCount,

    /// Loading state for async operations
    @Default(false) bool isLoading,

    /// Sources that have completed loading
    @Default([]) List<String> loadedSources,

    /// Sources still being fetched
    @Default([]) List<String> pendingSources,

    /// Current active filter
    @Default(TodoFilter.all) TodoFilter activeFilter,

    /// Current search query if searching
    String? searchQuery,

    /// Error message from failed operations
    String? errorMessage,
  }) = _TodoState;
}
