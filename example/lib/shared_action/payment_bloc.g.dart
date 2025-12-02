// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_bloc.dart';

// **************************************************************************
// MonoBlocGenerator
// **************************************************************************

// ignore_for_file: unused_element, prefer_foreach, library_private_types_in_public_api, always_put_control_body_on_new_line, invalid_use_of_protected_member, avoid_annotating_with_dynamic, avoid_futureor_void

typedef _Emitter = Emitter<PaymentState>;

abstract class _Event {
  _Event() : trace = StackTrace.current;

  final StackTrace trace;
}

class _SelectPaymentMethodEvent extends _Event {
  _SelectPaymentMethodEvent(this.method);

  final String method;
}

class _ShowPaymentMethodsEvent extends _Event {
  _ShowPaymentMethodsEvent();
}

class _ProcessPaymentEvent extends _Event {
  _ProcessPaymentEvent(this.amount);

  final double amount;
}

abstract class _$PaymentBloc<_> extends Bloc<_Event, PaymentState>
    with MonoBlocActionMixin<_Action, PaymentState>, _PaymentBlocActions {
  _$PaymentBloc(super.initialState) {
    _$(this)._$init();
  }

  /// [PaymentBloc._onSelectPaymentMethod]
  void selectPaymentMethod(String method) {
    add(_SelectPaymentMethodEvent(method));
  }

  /// [PaymentBloc._onShowPaymentMethods]
  void showPaymentMethods() {
    add(_ShowPaymentMethodsEvent());
  }

  /// [PaymentBloc._onProcessPayment]
  void processPayment(double amount) {
    add(_ProcessPaymentEvent(amount));
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
    EventHandler<E, PaymentState> handler, {
    EventTransformer<E>? transformer,
  }) {
    super.on<E>(handler, transformer: transformer);
  }

  @override
  void navigateToPaymentSuccess(String transactionId) {
    actionController?.add(_NavigateToPaymentSuccessAction(transactionId));
  }

  @override
  void showPaymentMethodSelector() {
    actionController?.add(_ShowPaymentMethodSelectorAction());
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

final class _NavigateToPaymentSuccessAction extends _Action {
  _NavigateToPaymentSuccessAction(this.transactionId);

  final String transactionId;
}

final class _ShowPaymentMethodSelectorAction extends _Action {
  _ShowPaymentMethodSelectorAction();
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

abstract interface class PaymentBlocActions {
  FutureOr<void> navigateToPaymentSuccess(
    BuildContext context,
    String transactionId,
  );
  FutureOr<void> showPaymentMethodSelector(BuildContext context);
  FutureOr<void> showError(BuildContext context, String message);
  FutureOr<void> showRetryError(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  );

  static _$PaymentBlocActions when({
    FutureOr<void> Function(BuildContext context, String transactionId)?
    navigateToPaymentSuccess,
    FutureOr<void> Function(BuildContext context)? showPaymentMethodSelector,
    FutureOr<void> Function(BuildContext context, String message)? showError,
    FutureOr<void> Function(
      BuildContext context,
      String message,
      VoidCallback onRetry,
    )?
    showRetryError,
  }) => _$PaymentBlocActions(
    actions: (bloc, context, action) {
      switch (action) {
        case _NavigateToPaymentSuccessAction(
          :final transactionId,
          :final trace,
        ):
          if (navigateToPaymentSuccess != null) {
            unawaited(
              Future.sync(() async {
                try {
                  await navigateToPaymentSuccess(context, transactionId);
                } catch (e, s) {
                  bloc.onError(e, _$._$stack(trace, s));
                }
              }),
            );
          }
        case _ShowPaymentMethodSelectorAction(:final trace):
          if (showPaymentMethodSelector != null) {
            unawaited(
              Future.sync(() async {
                try {
                  await showPaymentMethodSelector(context);
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

  static _$PaymentBlocActions of(PaymentBlocActions actions) => when(
    navigateToPaymentSuccess: actions.navigateToPaymentSuccess,
    showPaymentMethodSelector: actions.showPaymentMethodSelector,
    showError: actions.showError,
    showRetryError: actions.showRetryError,
  );
}

class _$PaymentBlocActions extends FlutterMonoBlocActions {
  @override
  final void Function(
    BlocBase<dynamic> bloc,
    BuildContext context,
    dynamic action,
  )
  actions;

  _$PaymentBlocActions({required this.actions});
}

sealed class _Action {
  _Action() : trace = StackTrace.current;
  final StackTrace trace;
}

extension type _$._(PaymentBloc bloc) implements PaymentBloc {
  _$(_$PaymentBloc<dynamic> base) : bloc = base as PaymentBloc;

  void _$init() {
    bloc.on<_SelectPaymentMethodEvent>((event, emit) {
      try {
        emit(_onSelectPaymentMethod(event.method));
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });
    bloc.on<_ShowPaymentMethodsEvent>((event, emit) {
      try {
        emit(_onShowPaymentMethods());
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });
    bloc.on<_ProcessPaymentEvent>((event, emit) async {
      try {
        emit(await _onProcessPayment(event.amount));
      } catch (e, s) {
        final stack = _$stack(event.trace, s);
        bloc.onError(e, stack);
        rethrow;
      }
    });
  }

  static StackTrace _$stack(StackTrace origin, StackTrace trace) {
    return MonoStackTrace.filtered(origin, trace, 'payment_bloc.g.dart');
  }
}
