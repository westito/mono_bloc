// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_bloc.dart';

// **************************************************************************
// MonoBlocGenerator
// **************************************************************************

// ignore_for_file: unused_element, prefer_foreach, library_private_types_in_public_api, always_put_control_body_on_new_line, invalid_use_of_protected_member, avoid_annotating_with_dynamic, avoid_futureor_void

typedef _Emitter = Emitter<CartState>;

abstract class _Event {
  _Event() : trace = StackTrace.current;

  final StackTrace trace;
}

class _AddItemEvent extends _Event {
  _AddItemEvent(this.item);

  final CartItem item;
}

class _RemoveItemEvent extends _Event {
  _RemoveItemEvent(this.itemId);

  final String itemId;
}

class _ClearEvent extends _Event {
  _ClearEvent();
}

class _CheckoutEvent extends _Event {
  _CheckoutEvent();
}

abstract class _$CartBloc<_> extends Bloc<_Event, CartState>
    with MonoBlocActionMixin<_Action, CartState>, _CartBlocActions {
  _$CartBloc(super.initialState) {
    _$(this)._$init();
  }

  /// [CartBloc._onAddItem]
  void addItem(CartItem item) {
    add(_AddItemEvent(item));
  }

  /// [CartBloc._onRemoveItem]
  void removeItem(String itemId) {
    add(_RemoveItemEvent(itemId));
  }

  /// [CartBloc._onClear]
  void clear() {
    add(_ClearEvent());
  }

  /// [CartBloc._onCheckout]
  void checkout() {
    add(_CheckoutEvent());
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
    EventHandler<E, CartState> handler, {
    EventTransformer<E>? transformer,
  }) {
    super.on<E>(handler, transformer: transformer);
  }

  @override
  void showNotification(String message, NotificationType type) {
    actionController?.add(_ShowNotificationAction(message, type));
  }

  @override
  void navigateToCheckout() {
    actionController?.add(_NavigateToCheckoutAction());
  }

  @override
  void navigateToProductDetail(String productId) {
    actionController?.add(_NavigateToProductDetailAction(productId));
  }
}

final class _ShowNotificationAction extends _Action {
  _ShowNotificationAction(this.message, this.type);

  final String message;

  final NotificationType type;
}

final class _NavigateToCheckoutAction extends _Action {
  _NavigateToCheckoutAction();
}

final class _NavigateToProductDetailAction extends _Action {
  _NavigateToProductDetailAction(this.productId);

  final String productId;
}

abstract interface class CartBlocActions {
  FutureOr<void> showNotification(
    BuildContext context,
    String message,
    NotificationType type,
  );
  FutureOr<void> navigateToCheckout(BuildContext context);
  FutureOr<void> navigateToProductDetail(
    BuildContext context,
    String productId,
  );

  static _$CartBlocActions when({
    FutureOr<void> Function(
      BuildContext context,
      String message,
      NotificationType type,
    )?
    showNotification,
    FutureOr<void> Function(BuildContext context)? navigateToCheckout,
    FutureOr<void> Function(BuildContext context, String productId)?
    navigateToProductDetail,
  }) => _$CartBlocActions(
    actions: (bloc, context, action) {
      switch (action) {
        case _ShowNotificationAction(:final message, :final type, :final trace):
          if (showNotification != null) {
            unawaited(
              Future.sync(() async {
                try {
                  await showNotification(context, message, type);
                } catch (e, s) {
                  bloc.onError(e, _$._$stack(trace, s));
                }
              }),
            );
          }
        case _NavigateToCheckoutAction(:final trace):
          if (navigateToCheckout != null) {
            unawaited(
              Future.sync(() async {
                try {
                  await navigateToCheckout(context);
                } catch (e, s) {
                  bloc.onError(e, _$._$stack(trace, s));
                }
              }),
            );
          }
        case _NavigateToProductDetailAction(:final productId, :final trace):
          if (navigateToProductDetail != null) {
            unawaited(
              Future.sync(() async {
                try {
                  await navigateToProductDetail(context, productId);
                } catch (e, s) {
                  bloc.onError(e, _$._$stack(trace, s));
                }
              }),
            );
          }
      }
    },
  );

  static _$CartBlocActions of(CartBlocActions actions) => when(
    showNotification: actions.showNotification,
    navigateToCheckout: actions.navigateToCheckout,
    navigateToProductDetail: actions.navigateToProductDetail,
  );
}

class _$CartBlocActions extends FlutterMonoBlocActions {
  @override
  final void Function(
    BlocBase<dynamic> bloc,
    BuildContext context,
    dynamic action,
  )
  actions;

  _$CartBlocActions({required this.actions});
}

sealed class _Action {
  _Action() : trace = StackTrace.current;
  final StackTrace trace;
}

extension type _$._(CartBloc bloc) implements CartBloc {
  _$(_$CartBloc<dynamic> base) : bloc = base as CartBloc;

  void _$init() {
    bloc.on<_AddItemEvent>((event, emit) {
      try {
        emit(_onAddItem(event.item));
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });
    bloc.on<_RemoveItemEvent>((event, emit) {
      try {
        emit(_onRemoveItem(event.itemId));
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });
    bloc.on<_ClearEvent>((event, emit) {
      try {
        emit(_onClear());
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });
    bloc.on<_CheckoutEvent>((event, emit) {
      try {
        emit(_onCheckout());
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });
  }

  static StackTrace _$stack(StackTrace origin, StackTrace trace) {
    return MonoStackTrace.filtered(origin, trace, 'cart_bloc.g.dart');
  }
}
