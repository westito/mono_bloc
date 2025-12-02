import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mono_bloc_example/todo/todo_bloc.dart';
import 'package:mono_bloc_example/todo/todo_model.dart';
import 'package:mono_bloc_example/todo/todo_repository.dart';

void main() {
  group('TodoBloc', () {
    late TodoBloc bloc;
    late TodoRepository repository;

    setUp(() {
      repository = TodoRepository(networkDelayMs: 100);
      bloc = TodoBloc(repository: repository);
    });

    tearDown(() async {
      await bloc.close();
    });

    test('initial state is empty', () {
      expect(bloc.state.todos, isEmpty);
      expect(bloc.state.isLoading, isFalse);
    });

    group('Load', () {
      blocTest<TodoBloc, TodoState>(
        'loadAllTodos fetches all todos',
        build: () => bloc,
        act: (bloc) => bloc.loadAllTodos(),
        wait: const Duration(milliseconds: 200),
        verify: (bloc) {
          expect(bloc.state.todos.length, equals(15));
          expect(bloc.state.sourceCount.keys.length, equals(4));
          expect(bloc.state.isLoading, isFalse);
        },
      );

      blocTest<TodoBloc, TodoState>(
        'loadAllTodos handles error',
        build: () => TodoBloc(
          repository: TodoRepository(
            networkDelayMs: 100,
            shouldThrowError: true,
          ),
        ),
        act: (bloc) => bloc.loadAllTodos(),
        wait: const Duration(milliseconds: 200),
        verify: (bloc) {
          expect(bloc.state.errorMessage, isNotNull);
          expect(bloc.state.errorMessage, contains('Network error'));
        },
      );
    });

    group('Search', () {
      blocTest<TodoBloc, TodoState>(
        'searchAcrossSources finds todos progressively',
        build: () => bloc,
        act: (bloc) => bloc.searchAcrossSources('presentation'),
        wait: const Duration(milliseconds: 500),
        verify: (bloc) {
          expect(bloc.state.searchQuery, equals('presentation'));
          expect(
            bloc.state.todos.any((t) => t.title.contains('presentation')),
            isTrue,
          );
          expect(bloc.state.isLoading, isFalse);
        },
      );

      blocTest<TodoBloc, TodoState>(
        'searchAcrossSources with empty query loads all',
        build: () => bloc,
        act: (bloc) => bloc.searchAcrossSources(''),
        wait: const Duration(milliseconds: 200),
        verify: (bloc) {
          expect(bloc.state.todos.length, equals(15));
        },
      );

      blocTest<TodoBloc, TodoState>(
        'searchAcrossSources shows partial results while loading',
        build: () => bloc,
        act: (bloc) => bloc.searchAcrossSources('work'),
        expect: () => [
          // Initial loading - no results yet
          predicate<TodoState>(
            (s) =>
                s.isLoading &&
                s.todos.isEmpty &&
                s.searchQuery == 'work' &&
                s.pendingSources.length == 4,
          ),
          // First source loaded - may or may not have results, still loading
          predicate<TodoState>(
            (s) =>
                s.isLoading &&
                s.loadedSources.length == 1 &&
                s.pendingSources.length == 3,
          ),
          // Second source loaded - partial results + still loading
          predicate<TodoState>(
            (s) =>
                s.isLoading &&
                s.loadedSources.length == 2 &&
                s.pendingSources.length == 2 &&
                s.todos.isNotEmpty,
          ),
          // Third source loaded - more partial results + still loading
          predicate<TodoState>(
            (s) =>
                s.isLoading &&
                s.loadedSources.length == 3 &&
                s.pendingSources.length == 1 &&
                s.todos.isNotEmpty,
          ),
          // All sources loaded - final results + not loading
          predicate<TodoState>(
            (s) =>
                !s.isLoading &&
                s.loadedSources.length == 4 &&
                s.pendingSources.isEmpty &&
                s.todos.isNotEmpty,
          ),
        ],
        wait: const Duration(milliseconds: 500),
      );

      blocTest<TodoBloc, TodoState>(
        'items added during search appear in results',
        build: () => bloc,
        act: (bloc) async {
          bloc.searchAcrossSources('presentation');
          await Future<void>.delayed(const Duration(milliseconds: 150));
          bloc.addTodo(
            'MyTodo',
            'New presentation task',
            priority: TodoPriority.high,
          );
        },
        wait: const Duration(milliseconds: 600),
        verify: (bloc) {
          expect(
            bloc.state.todos.any((t) => t.title == 'New presentation task'),
            isTrue,
          );
          expect(
            bloc.state.todos.any((t) => t.title.contains('presentation')),
            isTrue,
          );
        },
      );
    });

    group('Add Todo', () {
      blocTest<TodoBloc, TodoState>(
        'addTodo adds new todo with stream',
        build: () => bloc,
        act: (bloc) =>
            bloc.addTodo('MyTodo', 'New task', priority: TodoPriority.high),
        wait: const Duration(milliseconds: 300),
        verify: (bloc) {
          expect(bloc.state.isLoading, isFalse);
          expect(bloc.state.todos.any((t) => t.title == 'New task'), isTrue);
        },
      );
    });

    group('Update/Delete/Toggle with Emitter', () {
      blocTest<TodoBloc, TodoState>(
        'updateTodo updates existing todo',
        build: () => bloc,
        act: (bloc) async {
          bloc.loadAllTodos();
          await Future<void>.delayed(const Duration(milliseconds: 200));
          final todo = bloc.state.todos.first.copyWith(
            title: 'Updated title',
            priority: TodoPriority.urgent,
          );
          bloc.updateTodo(todo);
        },
        wait: const Duration(milliseconds: 400),
        verify: (bloc) {
          expect(
            bloc.state.todos.any((t) => t.title == 'Updated title'),
            isTrue,
          );
        },
      );

      blocTest<TodoBloc, TodoState>(
        'deleteTodo removes todo',
        build: () => bloc,
        act: (bloc) async {
          bloc.loadAllTodos();
          await Future<void>.delayed(const Duration(milliseconds: 200));
          final todoToDelete = bloc.state.todos.first;
          bloc.deleteTodo(todoToDelete);
        },
        wait: const Duration(milliseconds: 400),
        verify: (bloc) {
          expect(bloc.state.todos.length, equals(14));
        },
      );

      blocTest<TodoBloc, TodoState>(
        'toggleTodo toggles completion',
        build: () => bloc,
        act: (bloc) async {
          bloc.loadAllTodos();
          await Future<void>.delayed(const Duration(milliseconds: 200));
          final todoToToggle = bloc.state.todos.firstWhere((t) => !t.completed);
          final originalCompleted = todoToToggle.completed;
          bloc.toggleTodo(todoToToggle);
          await Future<void>.delayed(const Duration(milliseconds: 300));
          final updated = bloc.state.todos.firstWhere(
            (t) => t.id == todoToToggle.id,
          );
          expect(updated.completed, equals(!originalCompleted));
        },
        wait: const Duration(milliseconds: 600),
      );

      blocTest<TodoBloc, TodoState>(
        'updateTodo requires source',
        build: () => bloc,
        act: (bloc) {
          const todo = Todo(id: 'test', title: 'No source');
          bloc.updateTodo(todo);
        },
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          expect(bloc.state.errorMessage, contains('source information'));
        },
      );

      blocTest<TodoBloc, TodoState>(
        'deleteTodo requires source',
        build: () => bloc,
        act: (bloc) {
          const todo = Todo(id: 'test', title: 'No source');
          bloc.deleteTodo(todo);
        },
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          expect(bloc.state.errorMessage, contains('source information'));
        },
      );
    });

    group('Filtering with Future return', () {
      blocTest<TodoBloc, TodoState>(
        'filterByPriority filters todos',
        build: () => bloc,
        act: (bloc) async {
          bloc.loadAllTodos();
          await Future<void>.delayed(const Duration(milliseconds: 200));
          bloc.filterByPriority(TodoPriority.urgent);
        },
        wait: const Duration(milliseconds: 300),
        verify: (bloc) {
          expect(bloc.state.activeFilter, equals(TodoFilter.byPriority));
          expect(
            bloc.state.todos.every((t) => t.priority == TodoPriority.urgent),
            isTrue,
          );
        },
      );

      blocTest<TodoBloc, TodoState>(
        'filterBySource filters by source',
        build: () => bloc,
        act: (bloc) async {
          bloc.loadAllTodos();
          await Future<void>.delayed(const Duration(milliseconds: 200));
          bloc.filterBySource('MyTodo');
        },
        wait: const Duration(milliseconds: 300),
        verify: (bloc) {
          expect(bloc.state.todos.every((t) => t.source == 'MyTodo'), isTrue);
        },
      );

      blocTest<TodoBloc, TodoState>(
        'clearFilters reloads all todos',
        build: () => bloc,
        act: (bloc) async {
          bloc.loadAllTodos();
          await Future<void>.delayed(const Duration(milliseconds: 200));
          bloc.clearFilters();
        },
        wait: const Duration(milliseconds: 500),
        verify: (bloc) {
          expect(bloc.state.todos.length, equals(15));
        },
      );
    });

    group('Error Handlers', () {
      blocTest<TodoBloc, TodoState>(
        'general error handler catches loadAllTodos error',
        build: () => TodoBloc(
          repository: TodoRepository(
            networkDelayMs: 50,
            shouldThrowError: true,
          ),
        ),
        act: (bloc) => bloc.loadAllTodos(),
        wait: const Duration(milliseconds: 150),
        verify: (bloc) {
          expect(bloc.state.errorMessage, isNotNull);
          expect(bloc.state.errorMessage, contains('Error:'));
          expect(bloc.state.errorMessage, contains('Network error'));
          expect(bloc.state.isLoading, isFalse);
        },
      );

      blocTest<TodoBloc, TodoState>(
        'event-specific error handler catches addTodo error',
        build: () => TodoBloc(
          repository: TodoRepository(
            networkDelayMs: 50,
            shouldThrowError: true,
          ),
        ),
        act: (bloc) => bloc.addTodo(
          'MyTodo',
          'This will fail',
          priority: TodoPriority.high,
        ),
        wait: const Duration(milliseconds: 150),
        verify: (bloc) {
          expect(bloc.state.errorMessage, isNotNull);
          expect(bloc.state.errorMessage, contains('Failed to add todo:'));
          expect(bloc.state.errorMessage, contains('Network error'));
          expect(bloc.state.isLoading, isFalse);
        },
      );

      blocTest<TodoBloc, TodoState>(
        'general error handler catches updateTodo error',
        build: () => TodoBloc(
          repository: TodoRepository(
            networkDelayMs: 50,
            shouldThrowError: true,
          ),
        ),
        act: (bloc) async {
          bloc.loadAllTodos();
          await Future<void>.delayed(const Duration(milliseconds: 100));
          const todo = Todo(id: 'test', title: 'Test', source: 'MyTodo');
          bloc.updateTodo(todo);
        },
        wait: const Duration(milliseconds: 250),
        verify: (bloc) {
          expect(bloc.state.errorMessage, isNotNull);
          expect(bloc.state.errorMessage, contains('Error:'));
          expect(bloc.state.isLoading, isFalse);
        },
      );

      blocTest<TodoBloc, TodoState>(
        'general error handler catches deleteTodo error',
        build: () => TodoBloc(
          repository: TodoRepository(
            networkDelayMs: 50,
            shouldThrowError: true,
          ),
        ),
        act: (bloc) {
          const todo = Todo(id: 'test', title: 'Test', source: 'MyTodo');
          bloc.deleteTodo(todo);
        },
        wait: const Duration(milliseconds: 150),
        verify: (bloc) {
          expect(bloc.state.errorMessage, isNotNull);
          expect(bloc.state.errorMessage, contains('Error:'));
          expect(bloc.state.isLoading, isFalse);
        },
      );
    });
  });
}
