// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'async_test_bloc.dart';

// **************************************************************************
// MonoBlocGenerator
// **************************************************************************

// ignore_for_file: unused_element, prefer_foreach, library_private_types_in_public_api, always_put_control_body_on_new_line, invalid_use_of_protected_member, avoid_annotating_with_dynamic, avoid_futureor_void

typedef _State = MonoAsyncValue<List<Item>>;

typedef _Emitter = MonoAsyncEmitter<List<Item>>;

abstract class _Event {
  _Event() : trace = StackTrace.current;

  final StackTrace trace;
}

class _Event1Event extends _Event {
  _Event1Event();
}

class _Event2Event extends _Event {
  _Event2Event(this.query);

  final String query;
}

class _Event3Event extends _Event {
  _Event3Event(
    this.title, {
    this.description,
    this.priority = ItemPriority.medium,
  });

  final String title;

  final String? description;

  final ItemPriority priority;
}

class _Event4Event extends _Event {
  _Event4Event();
}

class _Event5Event extends _Event {
  _Event5Event(this.priority);

  final ItemPriority priority;
}

class _Event6Event extends _Event {
  _Event6Event();
}

abstract class _$AsyncTestBloc<_> extends Bloc<_Event, _State> {
  _$AsyncTestBloc(super.initialState) {
    _$(this)._$init();
  }

  @protected
  _State loading() =>
      MonoAsyncValue<List<Item>>(state.dataOrNull, true, null, null);

  @protected
  _State loadingClearData() => const MonoAsyncValue.loading();

  @protected
  _State withData(List<Item> data) => MonoAsyncValue.withData(data);

  @protected
  _State withError(Object error, StackTrace stackTrace, [List<Item>? data]) =>
      MonoAsyncValue.withError(error, stackTrace, data);

  /// [AsyncTestBloc._onEvent1]
  void event1() {
    add(_Event1Event());
  }

  /// [AsyncTestBloc._onEvent2]
  void event2(String query) {
    add(_Event2Event(query));
  }

  /// [AsyncTestBloc._onEvent3]
  void event3(
    String title, {
    String? description,
    ItemPriority priority = ItemPriority.medium,
  }) {
    add(_Event3Event(title, description: description, priority: priority));
  }

  /// [AsyncTestBloc._onEvent4]
  void event4() {
    add(_Event4Event());
  }

  /// [AsyncTestBloc._onEvent5]
  void event5(ItemPriority priority) {
    add(_Event5Event(priority));
  }

  /// [AsyncTestBloc._onEvent6]
  void event6() {
    add(_Event6Event());
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

extension type _$._(AsyncTestBloc bloc) implements AsyncTestBloc {
  _$(_$AsyncTestBloc<dynamic> base) : bloc = base as AsyncTestBloc;

  MonoAsyncEmitter<List<Item>> _$wrapEmit(Emitter<_State> emit, _State state) {
    return MonoAsyncEmitter<List<Item>>(emit, bloc);
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
    bloc.on<_Event1Event>(
      (event, emit) async {
        emit(loading());
        try {
          emit(withData(await _onEvent1()));
        } catch (error, stackTrace) {
          final stack = _$stack(event.trace, stackTrace);
          bloc.onError(error, stack);
          emit(withError(error, stack, bloc.state.dataOrNull));
        }
      },
      transformer: _wrapWithOnEvent<_Event1Event>(
        (events, mapper) => events.asyncExpand(mapper),
      ),
    );
    bloc.on<_Event2Event>(
      (event, emit) async {
        await emit.forEach<MonoAsyncValue<List<Item>>>(
          _onEvent2(event.query),
          onData: (state) => state,
        );
      },
      transformer: _wrapWithOnEvent(
        _castTransformer<_Event2Event>(MonoEventTransformer.restartable),
      ),
    );
    bloc.on<_Event3Event>(
      (event, emit) async {
        await _onEvent3(
          _$wrapEmit(emit, bloc.state),
          event.title,
          description: event.description,
          priority: event.priority,
        );
      },
      transformer: _wrapWithOnEvent<_Event3Event>(
        (events, mapper) => events.asyncExpand(mapper),
      ),
    );
    bloc.on<_Event4Event>(
      (event, emit) async {
        await _onEvent4(_$wrapEmit(emit, bloc.state));
      },
      transformer: _wrapWithOnEvent<_Event4Event>(
        (events, mapper) => events.asyncExpand(mapper),
      ),
    );
    bloc.on<_Event5Event>(
      (event, emit) {
        emit(withData(_onEvent5(event.priority)));
      },
      transformer: _wrapWithOnEvent<_Event5Event>(
        (events, mapper) => events.asyncExpand(mapper),
      ),
    );
    bloc.on<_Event6Event>(
      (event, emit) {
        _onEvent6(_$wrapEmit(emit, bloc.state));
      },
      transformer: _wrapWithOnEvent<_Event6Event>(
        (events, mapper) => events.asyncExpand(mapper),
      ),
    );
  }

  static StackTrace _$stack(StackTrace origin, StackTrace trace) {
    return MonoStackTrace.filtered(origin, trace, 'async_test_bloc.g.dart');
  }
}
