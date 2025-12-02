// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_bloc.dart';

// **************************************************************************
// MonoBlocGenerator
// **************************************************************************

// ignore_for_file: unused_element, prefer_foreach, library_private_types_in_public_api, always_put_control_body_on_new_line, invalid_use_of_protected_member, avoid_annotating_with_dynamic, avoid_futureor_void

typedef _Emitter = Emitter<TodoState>;

abstract class _Event {
  _Event() : trace = StackTrace.current;

  final StackTrace trace;
}

class _LoadAllTodosEvent extends _Event {
  _LoadAllTodosEvent();
}

class _SearchAcrossSourcesEvent extends _Event {
  _SearchAcrossSourcesEvent(this.query);

  final String query;
}

class _AddTodoEvent extends _Event {
  _AddTodoEvent(
    this.sourceName,
    this.title, {
    this.description,
    this.priority = TodoPriority.medium,
    this.tags = const [],
    this.dueDate,
  });

  final String sourceName;

  final String title;

  final String? description;

  final TodoPriority priority;

  final List<String> tags;

  final DateTime? dueDate;
}

class _UpdateTodoEvent extends _Event {
  _UpdateTodoEvent(this.todo);

  final Todo todo;
}

class _DeleteTodoEvent extends _Event {
  _DeleteTodoEvent(this.todo);

  final Todo todo;
}

class _ToggleTodoEvent extends _Event {
  _ToggleTodoEvent(this.todo);

  final Todo todo;
}

class _FilterByPriorityEvent extends _Event {
  _FilterByPriorityEvent(this.priority);

  final TodoPriority priority;
}

class _FilterBySourceEvent extends _Event {
  _FilterBySourceEvent(this.sourceName);

  final String sourceName;
}

class _ClearFiltersEvent extends _Event {
  _ClearFiltersEvent();
}

abstract class _$TodoBloc<_> extends Bloc<_Event, TodoState> {
  _$TodoBloc(super.initialState) {
    _$(this)._$init();
  }

  /// [TodoBloc._onLoadAllTodos]
  void loadAllTodos() {
    add(_LoadAllTodosEvent());
  }

  /// [TodoBloc._onSearchAcrossSources]
  void searchAcrossSources(String query) {
    add(_SearchAcrossSourcesEvent(query));
  }

  /// [TodoBloc.onAddTodo]
  void addTodo(
    String sourceName,
    String title, {
    String? description,
    TodoPriority priority = TodoPriority.medium,
    List<String> tags = const [],
    DateTime? dueDate,
  }) {
    add(
      _AddTodoEvent(
        sourceName,
        title,
        description: description,
        priority: priority,
        tags: tags,
        dueDate: dueDate,
      ),
    );
  }

  /// [TodoBloc._onUpdateTodo]
  void updateTodo(Todo todo) {
    add(_UpdateTodoEvent(todo));
  }

  /// [TodoBloc._onDeleteTodo]
  void deleteTodo(Todo todo) {
    add(_DeleteTodoEvent(todo));
  }

  /// [TodoBloc._onToggleTodo]
  void toggleTodo(Todo todo) {
    add(_ToggleTodoEvent(todo));
  }

  /// [TodoBloc._onFilterByPriority]
  void filterByPriority(TodoPriority priority) {
    add(_FilterByPriorityEvent(priority));
  }

  /// [TodoBloc._onFilterBySource]
  void filterBySource(String sourceName) {
    add(_FilterBySourceEvent(sourceName));
  }

  /// [TodoBloc._onClearFilters]
  void clearFilters() {
    add(_ClearFiltersEvent());
  }

  @override
  @protected
  void add(_Event event) {
    if (isClosed) {
      return;
    }
    super.add(event);
  }

  @override
  @protected
  void on<E extends _Event>(
    EventHandler<E, TodoState> handler, {
    EventTransformer<E>? transformer,
  }) {
    super.on<E>(handler, transformer: transformer);
  }
}

extension type _$._(TodoBloc bloc) implements TodoBloc {
  _$(_$TodoBloc<dynamic> base) : bloc = base as TodoBloc;

  void _$handleError(
    Object e,
    StackTrace s,
    StackTrace eventTrace,
    void Function(StackTrace stack)? errorHandler,
  ) {
    final stack = _$stack(eventTrace, s);
    bloc.onError(e, stack);
    if (errorHandler != null) {
      try {
        errorHandler(stack);
      } catch (e2, s2) {
        bloc.onError(e2, s2);
      }
    }
  }

  EventTransformer<E> _castTransformer<E>(
    EventTransformer<dynamic> transformer,
  ) {
    return (events, mapper) => transformer(
      events.cast<dynamic>(),
      (event) => mapper(event as E).cast<dynamic>(),
    ).cast<E>();
  }

  void _$init() {
    bloc.on<_LoadAllTodosEvent>((event, emit) async {
      try {
        emit(await _onLoadAllTodos());
      } catch (e, s) {
        _$handleError(e, s, event.trace, (stack) {
          emit(_onError(e, stack));
        });
      }
    });
    bloc.on<_SearchAcrossSourcesEvent>(
      (event, emit) async {
        try {
          await emit.forEach<TodoState>(
            _onSearchAcrossSources(event.query),
            onData: (state) => state,
          );
        } catch (e, s) {
          _$handleError(e, s, event.trace, (stack) {
            emit(_onError(e, stack));
          });
        }
      },
      transformer: _castTransformer<_SearchAcrossSourcesEvent>(
        MonoEventTransformer.restartable,
      ),
    );
    bloc.on<_AddTodoEvent>((event, emit) async {
      try {
        await emit.forEach<TodoState>(
          onAddTodo(
            event.sourceName,
            event.title,
            description: event.description,
            priority: event.priority,
            tags: event.tags,
            dueDate: event.dueDate,
          ),
          onData: (state) => state,
        );
      } catch (e, s) {
        _$handleError(e, s, event.trace, (stack) {
          emit(_onErrorAddTodo(e, stack));
        });
      }
    });
    bloc.on<_UpdateTodoEvent>((event, emit) async {
      try {
        await _onUpdateTodo(emit, event.todo);
      } catch (e, s) {
        _$handleError(e, s, event.trace, (stack) {
          emit(_onError(e, stack));
        });
      }
    });
    bloc.on<_DeleteTodoEvent>((event, emit) async {
      try {
        await _onDeleteTodo(emit, event.todo);
      } catch (e, s) {
        _$handleError(e, s, event.trace, (stack) {
          emit(_onError(e, stack));
        });
      }
    });
    bloc.on<_ToggleTodoEvent>((event, emit) async {
      try {
        await _onToggleTodo(emit, event.todo);
      } catch (e, s) {
        _$handleError(e, s, event.trace, (stack) {
          emit(_onError(e, stack));
        });
      }
    });
    bloc.on<_FilterByPriorityEvent>((event, emit) {
      try {
        emit(_onFilterByPriority(event.priority));
      } catch (e, s) {
        _$handleError(e, s, event.trace, (stack) {
          emit(_onError(e, stack));
        });
      }
    });
    bloc.on<_FilterBySourceEvent>((event, emit) {
      try {
        emit(_onFilterBySource(event.sourceName));
      } catch (e, s) {
        _$handleError(e, s, event.trace, (stack) {
          emit(_onError(e, stack));
        });
      }
    });
    bloc.on<_ClearFiltersEvent>((event, emit) async {
      try {
        emit(await _onClearFilters());
      } catch (e, s) {
        _$handleError(e, s, event.trace, (stack) {
          emit(_onError(e, stack));
        });
      }
    });
  }

  static StackTrace _$stack(StackTrace origin, StackTrace trace) {
    return MonoStackTrace.filtered(origin, trace, 'todo_bloc.g.dart');
  }
}
