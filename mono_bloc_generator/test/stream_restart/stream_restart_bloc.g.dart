// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream_restart_bloc.dart';

// **************************************************************************
// MonoBlocGenerator
// **************************************************************************

// ignore_for_file: unused_element, prefer_foreach, library_private_types_in_public_api, always_put_control_body_on_new_line, invalid_use_of_protected_member, avoid_annotating_with_dynamic, avoid_futureor_void

typedef _Emitter = Emitter<StreamRestartState>;

abstract class _Event {
  _Event() : trace = StackTrace.current;

  final StackTrace trace;
}

class _FetchItemsEvent extends _Event {
  _FetchItemsEvent(this.prefix);

  final String prefix;
}

abstract class _$StreamRestartBloc<_> extends Bloc<_Event, StreamRestartState> {
  _$StreamRestartBloc(super.initialState) {
    _$(this)._$init();
  }

  /// [StreamRestartBloc._onFetchItems]
  void fetchItems(String prefix) {
    add(_FetchItemsEvent(prefix));
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
    EventHandler<E, StreamRestartState> handler, {
    EventTransformer<E>? transformer,
  }) {
    super.on<E>(handler, transformer: transformer);
  }
}

extension type _$._(StreamRestartBloc bloc) implements StreamRestartBloc {
  _$(_$StreamRestartBloc<dynamic> base) : bloc = base as StreamRestartBloc;

  EventTransformer<E> _castTransformer<E>(
    EventTransformer<dynamic> transformer,
  ) {
    return (events, mapper) => transformer(
      events.cast<dynamic>(),
      (event) => mapper(event as E).cast<dynamic>(),
    ).cast<E>();
  }

  void _$init() {
    bloc.on<_FetchItemsEvent>(
      (event, emit) async {
        try {
          await emit.forEach<StreamRestartState>(
            _onFetchItems(event.prefix),
            onData: (state) => state,
          );
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      },
      transformer: _castTransformer<_FetchItemsEvent>(
        MonoEventTransformer.restartable,
      ),
    );
  }

  static StackTrace _$stack(StackTrace origin, StackTrace trace) {
    return MonoStackTrace.filtered(origin, trace, 'stream_restart_bloc.g.dart');
  }
}
