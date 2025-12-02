// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'async_todo_bloc.dart';

// **************************************************************************
// MonoBlocGenerator
// **************************************************************************

// ignore_for_file: unused_element, prefer_foreach, library_private_types_in_public_api, always_put_control_body_on_new_line, invalid_use_of_protected_member, avoid_annotating_with_dynamic, avoid_futureor_void

typedef _State = MonoAsyncValue<List<Todo>>;

typedef _Emitter = MonoAsyncEmitter<List<Todo>>;

abstract class _Event {
  _Event() : trace = StackTrace.current;

  final StackTrace trace;
}

class _LoadAllTodosEvent extends _Event {
  _LoadAllTodosEvent();
}

class _SearchTodosEvent extends _Event {
  _SearchTodosEvent(this.query);

  final String query;
}

class _AddTodoEvent extends _Event {
  _AddTodoEvent(
    this.title, {
    this.description,
    this.priority = TodoPriority.medium,
  });

  final String title;

  final String? description;

  final TodoPriority priority;
}

class _RefreshTodosEvent extends _Event {
  _RefreshTodosEvent();
}

class _FilterByPriorityEvent extends _Event {
  _FilterByPriorityEvent(this.priority);

  final TodoPriority priority;
}

class _ClearFilterEvent extends _Event {
  _ClearFilterEvent();
}

abstract class _$AsyncTodoBloc<_> extends Bloc<_Event, _State> {
  _$AsyncTodoBloc(super.initialState) {
    _$(this)._$init();
  }

  @protected
  _State loading() =>
      MonoAsyncValue<List<Todo>>(state.dataOrNull, true, null, null);

  @protected
  _State loadingClearData() => const MonoAsyncValue.loading();

  @protected
  _State withData(List<Todo> data) => MonoAsyncValue.withData(data);

  @protected
  _State withError(Object error, StackTrace stackTrace, [List<Todo>? data]) =>
      MonoAsyncValue.withError(error, stackTrace, data);

  /// [AsyncTodoBloc._onLoadAllTodos]
  void loadAllTodos() {
    add(_LoadAllTodosEvent());
  }

  /// [AsyncTodoBloc._onSearchTodos]
  void searchTodos(String query) {
    add(_SearchTodosEvent(query));
  }

  /// [AsyncTodoBloc._onAddTodo]
  void addTodo(
    String title, {
    String? description,
    TodoPriority priority = TodoPriority.medium,
  }) {
    add(_AddTodoEvent(title, description: description, priority: priority));
  }

  /// [AsyncTodoBloc._onRefreshTodos]
  void refreshTodos() {
    add(_RefreshTodosEvent());
  }

  /// [AsyncTodoBloc._onFilterByPriority]
  void filterByPriority(TodoPriority priority) {
    add(_FilterByPriorityEvent(priority));
  }

  /// [AsyncTodoBloc._onClearFilter]
  void clearFilter() {
    add(_ClearFilterEvent());
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
    EventHandler<E, _State> handler, {
    EventTransformer<E>? transformer,
  }) {
    super.on<E>(handler, transformer: transformer);
  }
}

extension type _$._(AsyncTodoBloc bloc) implements AsyncTodoBloc {
  _$(_$AsyncTodoBloc<dynamic> base) : bloc = base as AsyncTodoBloc;

  MonoAsyncEmitter<List<Todo>> _$wrapEmit(Emitter<_State> emit, _State state) {
    return MonoAsyncEmitter<List<Todo>>(emit, bloc);
  }

  StackTrace _$onError(StackTrace eventTrace, Object e, StackTrace s) {
    final stack = _$stack(eventTrace, s);
    bloc.onError(e, stack);
    return stack;
  }

  void _$handleError(
    Object e,
    StackTrace s,
    StackTrace eventTrace,
    void Function(StackTrace stack)? errorHandler,
  ) {
    final stack = _$onError(eventTrace, e, s);
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

  // ignore: avoid_annotating_with_dynamic
  bool _filterEvent(dynamic event) {
    final $ = bloc;
    // Fallback to all events handler
    return $._onEvents(event as _Event);
  }

  EventTransformer<E> _wrapWithOnEvent<E>(EventTransformer<E> transformer) {
    return (events, mapper) {
      // ignore: unnecessary_lambdas
      final filteredEvents = events.where((event) => _filterEvent(event));
      return transformer(filteredEvents, mapper);
    };
  }

  void _$init() {
    bloc.on<_LoadAllTodosEvent>(
      (event, emit) async {
        emit(loading());
        try {
          emit(withData(await _onLoadAllTodos()));
        } catch (error, stackTrace) {
          final stack = _$stack(event.trace, stackTrace);
          bloc.onError(error, stack);
          emit(withError(error, stack, bloc.state.dataOrNull));
        }
      },
      transformer: _wrapWithOnEvent<_LoadAllTodosEvent>(
        (events, mapper) => events.asyncExpand(mapper),
      ),
    );
    bloc.on<_SearchTodosEvent>(
      (event, emit) async {
        await emit.forEach<MonoAsyncValue<List<Todo>>>(
          _onSearchTodos(event.query),
          onData: (state) => state,
        );
      },
      transformer: _wrapWithOnEvent(
        _castTransformer<_SearchTodosEvent>(MonoEventTransformer.restartable),
      ),
    );
    bloc.on<_AddTodoEvent>(
      (event, emit) async {
        await _onAddTodo(
          _$wrapEmit(emit, bloc.state),
          event.title,
          description: event.description,
          priority: event.priority,
        );
      },
      transformer: _wrapWithOnEvent<_AddTodoEvent>(
        (events, mapper) => events.asyncExpand(mapper),
      ),
    );
    bloc.on<_RefreshTodosEvent>(
      (event, emit) async {
        await _onRefreshTodos(_$wrapEmit(emit, bloc.state));
      },
      transformer: _wrapWithOnEvent<_RefreshTodosEvent>(
        (events, mapper) => events.asyncExpand(mapper),
      ),
    );
    bloc.on<_FilterByPriorityEvent>(
      (event, emit) {
        emit(withData(_onFilterByPriority(event.priority)));
      },
      transformer: _wrapWithOnEvent<_FilterByPriorityEvent>(
        (events, mapper) => events.asyncExpand(mapper),
      ),
    );
    bloc.on<_ClearFilterEvent>(
      (event, emit) {
        _onClearFilter(_$wrapEmit(emit, bloc.state));
      },
      transformer: _wrapWithOnEvent<_ClearFilterEvent>(
        (events, mapper) => events.asyncExpand(mapper),
      ),
    );
  }

  static StackTrace _$stack(StackTrace origin, StackTrace trace) {
    return MonoStackTrace.filtered(origin, trace, 'async_todo_bloc.g.dart');
  }
}
