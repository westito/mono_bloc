// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_bloc.dart';

// **************************************************************************
// MonoBlocGenerator
// **************************************************************************

// ignore_for_file: unused_element, prefer_foreach, library_private_types_in_public_api, always_put_control_body_on_new_line, invalid_use_of_protected_member, avoid_annotating_with_dynamic, avoid_futureor_void

typedef _Emitter = Emitter<OrderState>;

abstract class _Event {
  _Event() : trace = StackTrace.current;

  final StackTrace trace;
}

class _LoadOrdersEvent extends _Event {
  _LoadOrdersEvent();
}

class _PlaceOrderEvent extends _Event {
  _PlaceOrderEvent(this.total);

  final double total;
}

class _SelectOrderEvent extends _Event {
  _SelectOrderEvent(this.orderId);

  final String orderId;
}

abstract class _$OrderBloc<_> extends Bloc<_Event, OrderState>
    with MonoBlocActionMixin<_Action, OrderState>, _OrderBlocActions {
  _$OrderBloc(super.initialState) {
    _$(this)._$init();
  }

  /// [OrderBloc._onLoadOrders]
  void loadOrders() {
    add(_LoadOrdersEvent());
  }

  /// [OrderBloc._onPlaceOrder]
  void placeOrder(double total) {
    add(_PlaceOrderEvent(total));
  }

  /// [OrderBloc._onSelectOrder]
  void selectOrder(String orderId) {
    add(_SelectOrderEvent(orderId));
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
    EventHandler<E, OrderState> handler, {
    EventTransformer<E>? transformer,
  }) {
    super.on<E>(handler, transformer: transformer);
  }

  @override
  void navigateToOrderDetails(String orderId) {
    actionController?.add(_NavigateToOrderDetailsAction(orderId));
  }

  @override
  void showOrderConfirmation(String orderId, double total) {
    actionController?.add(_ShowOrderConfirmationAction(orderId, total));
  }

  @override
  void showError(String message) {
    actionController?.add(_ShowErrorAction(message));
  }

  @override
  void showRetryError(String message, VoidCallback onRetry) {
    actionController?.add(_ShowRetryErrorAction(message, onRetry));
  }
}

final class _NavigateToOrderDetailsAction extends _Action {
  _NavigateToOrderDetailsAction(this.orderId);

  final String orderId;
}

final class _ShowOrderConfirmationAction extends _Action {
  _ShowOrderConfirmationAction(this.orderId, this.total);

  final String orderId;

  final double total;
}

final class _ShowErrorAction extends _Action {
  _ShowErrorAction(this.message);

  final String message;
}

final class _ShowRetryErrorAction extends _Action {
  _ShowRetryErrorAction(this.message, this.onRetry);

  final String message;

  final VoidCallback onRetry;
}

abstract interface class OrderBlocActions {
  FutureOr<void> navigateToOrderDetails(BuildContext context, String orderId);
  FutureOr<void> showOrderConfirmation(
    BuildContext context,
    String orderId,
    double total,
  );
  FutureOr<void> showError(BuildContext context, String message);
  FutureOr<void> showRetryError(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  );

  static _$OrderBlocActions when({
    FutureOr<void> Function(BuildContext context, String orderId)?
    navigateToOrderDetails,
    FutureOr<void> Function(BuildContext context, String orderId, double total)?
    showOrderConfirmation,
    FutureOr<void> Function(BuildContext context, String message)? showError,
    FutureOr<void> Function(
      BuildContext context,
      String message,
      VoidCallback onRetry,
    )?
    showRetryError,
  }) => _$OrderBlocActions(
    actions: (bloc, context, action) {
      switch (action) {
        case _NavigateToOrderDetailsAction(:final orderId, :final trace):
          if (navigateToOrderDetails != null) {
            unawaited(
              Future.sync(() async {
                try {
                  await navigateToOrderDetails(context, orderId);
                } catch (e, s) {
                  bloc.onError(e, _$._$stack(trace, s));
                }
              }),
            );
          }
        case _ShowOrderConfirmationAction(
          :final orderId,
          :final total,
          :final trace,
        ):
          if (showOrderConfirmation != null) {
            unawaited(
              Future.sync(() async {
                try {
                  await showOrderConfirmation(context, orderId, total);
                } catch (e, s) {
                  bloc.onError(e, _$._$stack(trace, s));
                }
              }),
            );
          }
        case _ShowErrorAction(:final message, :final trace):
          if (showError != null) {
            unawaited(
              Future.sync(() async {
                try {
                  await showError(context, message);
                } catch (e, s) {
                  bloc.onError(e, _$._$stack(trace, s));
                }
              }),
            );
          }
        case _ShowRetryErrorAction(
          :final message,
          :final onRetry,
          :final trace,
        ):
          if (showRetryError != null) {
            unawaited(
              Future.sync(() async {
                try {
                  await showRetryError(context, message, onRetry);
                } catch (e, s) {
                  bloc.onError(e, _$._$stack(trace, s));
                }
              }),
            );
          }
      }
    },
  );

  static _$OrderBlocActions of(OrderBlocActions actions) => when(
    navigateToOrderDetails: actions.navigateToOrderDetails,
    showOrderConfirmation: actions.showOrderConfirmation,
    showError: actions.showError,
    showRetryError: actions.showRetryError,
  );
}

class _$OrderBlocActions extends FlutterMonoBlocActions {
  @override
  final void Function(
    BlocBase<dynamic> bloc,
    BuildContext context,
    dynamic action,
  )
  actions;

  _$OrderBlocActions({required this.actions});
}

sealed class _Action {
  _Action() : trace = StackTrace.current;
  final StackTrace trace;
}

extension type _$._(OrderBloc bloc) implements OrderBloc {
  _$(_$OrderBloc<dynamic> base) : bloc = base as OrderBloc;

  void _$init() {
    bloc.on<_LoadOrdersEvent>((event, emit) async {
      try {
        emit(await _onLoadOrders());
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });
    bloc.on<_PlaceOrderEvent>((event, emit) async {
      try {
        emit(await _onPlaceOrder(event.total));
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });
    bloc.on<_SelectOrderEvent>((event, emit) {
      try {
        emit(_onSelectOrder(event.orderId));
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });
  }

  static StackTrace _$stack(StackTrace origin, StackTrace trace) {
    return MonoStackTrace.filtered(origin, trace, 'order_bloc.g.dart');
  }
}
