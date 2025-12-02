import 'package:mono_bloc_example/todo/todo_model.dart';
import 'package:mono_bloc_example/todo/todo_repository.dart';

/// In-memory data store for todos from multiple sources
/// Simulates multiple todo apps/services that can be aggregated
class TodoDataStore {
  TodoDataStore() {
    _initializeSampleData();
  }

  /// Storage organized by source (simulating different todo apps)
  final Map<TodoSource, List<Todo>> _storage = {
    TodoSource.myTodo: [],
    TodoSource.doItNow: [],
    TodoSource.taskMaster: [],
    TodoSource.quickTask: [],
  };

  /// Auto-incrementing ID for new todos
  var _nextId = 100;

  /// Get todos from a specific source
  List<Todo> getTodos(TodoSource source) {
    return List.unmodifiable(_storage[source] ?? []);
  }

  /// Get all todos from all sources with source labels
  List<Todo> getAllTodos() {
    final allTodos = <Todo>[];
    for (final source in TodoSource.values) {
      final todos = _storage[source]!.map((todo) {
        return todo.copyWith(source: source.displayName);
      }).toList();
      allTodos.addAll(todos);
    }
    return allTodos;
  }

  /// Add new todo to specific source
  /// Generates ID if not provided
  Todo addTodo(TodoSource source, Todo todo) {
    final newTodo = todo.copyWith(
      id: todo.id.isEmpty ? 'todo_${source.name}_${_nextId++}' : todo.id,
      createdAt: DateTime.now(),
      source: source.displayName,
    );

    _storage[source] = [..._storage[source]!, newTodo];
    return newTodo;
  }

  /// Update existing todo in its source
  Todo updateTodo(TodoSource source, Todo todo) {
    final todos = _storage[source]!;
    final index = todos.indexWhere((t) => t.id == todo.id);

    if (index == -1) {
      throw Exception('Todo not found in ${source.displayName}');
    }

    final updated = List<Todo>.from(todos);
    updated[index] = todo;
    _storage[source] = updated;

    return todo;
  }

  /// Delete todo from specific source
  void deleteTodo(TodoSource source, String todoId) {
    _storage[source] = _storage[source]!.where((t) => t.id != todoId).toList();
  }

  /// Search todos in specific source by query
  /// Searches in title, description, and tags
  List<Todo> searchInSource(TodoSource source, String query) {
    final todos = _storage[source] ?? [];
    return todos.where((todo) {
      final titleMatch = todo.title.toLowerCase().contains(query.toLowerCase());
      final descMatch =
          todo.description?.toLowerCase().contains(query.toLowerCase()) ??
          false;
      final tagMatch = todo.tags.any(
        (tag) => tag.toLowerCase().contains(query.toLowerCase()),
      );
      return titleMatch || descMatch || tagMatch;
    }).toList();
  }

  /// Get count of todos per source
  Map<TodoSource, int> getTodoCountsBySource() {
    return _storage.map((key, value) => MapEntry(key, value.length));
  }

  /// Clear all todos from all sources
  void clearAll() {
    for (final source in TodoSource.values) {
      _storage[source] = [];
    }
  }

  /// Initialize sample data for demo purposes
  /// Creates realistic todos across different sources with various states
  void _initializeSampleData() {
    _storage[TodoSource.myTodo] = [
      Todo(
        id: 'mytodo_1',
        title: 'Buy groceries',
        description: 'Milk, eggs, bread',
        tags: ['shopping', 'personal'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Todo(
        id: 'mytodo_2',
        title: 'Call dentist',
        priority: TodoPriority.high,
        tags: ['health', 'personal'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Todo(
        id: 'mytodo_3',
        title: 'Pay electricity bill',
        description: 'Due by end of month',
        tags: ['bills', 'personal'],
        dueDate: DateTime.now().add(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      ),
    ];

    _storage[TodoSource.doItNow] = [
      Todo(
        id: 'doitnow_1',
        title: 'Prepare presentation',
        description: 'Q4 review slides',
        priority: TodoPriority.urgent,
        tags: ['work', 'presentation'],
        dueDate: DateTime.now().add(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      Todo(
        id: 'doitnow_2',
        title: 'Review pull requests',
        priority: TodoPriority.high,
        tags: ['work', 'code-review'],
        completed: true,
        completedAt: DateTime.now().subtract(const Duration(hours: 2)),
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      Todo(
        id: 'doitnow_3',
        title: 'Team standup meeting',
        description: 'Daily sync at 10 AM',
        priority: TodoPriority.high,
        tags: ['work', 'meeting'],
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      Todo(
        id: 'doitnow_4',
        title: 'Update project documentation',
        priority: TodoPriority.low,
        tags: ['work', 'documentation'],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    _storage[TodoSource.taskMaster] = [
      Todo(
        id: 'taskmaster_1',
        title: 'Update dependencies',
        description: 'Upgrade to latest Flutter version',
        priority: TodoPriority.low,
        tags: ['project', 'maintenance'],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Todo(
        id: 'taskmaster_2',
        title: 'Write unit tests',
        description: 'Cover new repository layer',
        tags: ['project', 'testing'],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Todo(
        id: 'taskmaster_3',
        title: 'Deploy to production',
        priority: TodoPriority.urgent,
        tags: ['project', 'deployment'],
        dueDate: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      Todo(
        id: 'taskmaster_4',
        title: 'Code review automation',
        description: 'Set up GitHub Actions',
        tags: ['project', 'automation'],
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      Todo(
        id: 'taskmaster_5',
        title: 'Performance optimization',
        priority: TodoPriority.low,
        tags: ['project', 'performance'],
        completed: true,
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
    ];

    _storage[TodoSource.quickTask] = [
      Todo(
        id: 'quicktask_1',
        title: 'Water plants',
        priority: TodoPriority.low,
        tags: ['home', 'quick'],
        completed: true,
        completedAt: DateTime.now().subtract(const Duration(hours: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Todo(
        id: 'quicktask_2',
        title: 'Reply to emails',
        tags: ['communication', 'quick'],
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      Todo(
        id: 'quicktask_3',
        title: 'Order coffee beans',
        description: 'Running low on coffee',
        tags: ['shopping', 'quick'],
        createdAt: DateTime.now().subtract(const Duration(hours: 10)),
      ),
    ];
  }
}
