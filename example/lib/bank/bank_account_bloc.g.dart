// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_account_bloc.dart';

// **************************************************************************
// MonoBlocGenerator
// **************************************************************************

// ignore_for_file: unused_element, prefer_foreach, library_private_types_in_public_api, always_put_control_body_on_new_line, invalid_use_of_protected_member, avoid_annotating_with_dynamic, avoid_futureor_void

typedef _Emitter = MonoSeqEmitter<BankAccountState>;

abstract class _Event {
  _Event() : trace = StackTrace.current;

  final StackTrace trace;
}

class _$SequentialEvent extends _Event {}

class _DepositEvent extends _$SequentialEvent {
  _DepositEvent(this.amount);

  final double amount;
}

class _WithdrawEvent extends _$SequentialEvent {
  _WithdrawEvent(this.amount);

  final double amount;
}

class _TransferEvent extends _$SequentialEvent {
  _TransferEvent(this.amount, this.recipient);

  final double amount;

  final String recipient;
}

class _ResetEvent extends _$SequentialEvent {
  _ResetEvent();
}

class _CheckBalanceEvent extends _Event {
  _CheckBalanceEvent();
}

abstract class _$BankAccountBloc<_> extends Bloc<_Event, BankAccountState> {
  _$BankAccountBloc(super.initialState) {
    _$(this)._$init();
  }

  /// [BankAccountBloc._deposit]
  void deposit(double amount) {
    add(_DepositEvent(amount));
  }

  /// [BankAccountBloc._onWithdraw]
  void withdraw(double amount) {
    add(_WithdrawEvent(amount));
  }

  /// [BankAccountBloc._onTransfer]
  void transfer(double amount, String recipient) {
    add(_TransferEvent(amount, recipient));
  }

  /// [BankAccountBloc._onReset]
  void reset() {
    add(_ResetEvent());
  }

  /// [BankAccountBloc._onCheckBalance]
  void checkBalance() {
    add(_CheckBalanceEvent());
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
    EventHandler<E, BankAccountState> handler, {
    EventTransformer<E>? transformer,
  }) {
    super.on<E>(handler, transformer: transformer);
  }
}

extension type _$._(BankAccountBloc bloc) implements BankAccountBloc {
  _$(_$BankAccountBloc<dynamic> base) : bloc = base as BankAccountBloc;

  EventTransformer<E> _castTransformer<E>(
    EventTransformer<dynamic> transformer,
  ) {
    return (events, mapper) => transformer(
      events.cast<dynamic>(),
      (event) => mapper(event as E).cast<dynamic>(),
    ).cast<E>();
  }

  void _$init() {
    bloc.on<_$SequentialEvent>(
      (event, emit) async {
        if (event is _DepositEvent) {
          try {
            emit(await _deposit(event.amount));
          } catch (e, s) {
            final stack = _$stack(event.trace, s);
            bloc.onError(e, stack);
            rethrow;
          }
        } else if (event is _WithdrawEvent) {
          try {
            emit(await _onWithdraw(event.amount));
          } catch (e, s) {
            final stack = _$stack(event.trace, s);
            bloc.onError(e, stack);
            rethrow;
          }
        } else if (event is _TransferEvent) {
          try {
            emit(await _onTransfer(event.amount, event.recipient));
          } catch (e, s) {
            final stack = _$stack(event.trace, s);
            bloc.onError(e, stack);
            rethrow;
          }
        } else if (event is _ResetEvent) {
          try {
            emit(_onReset());
          } catch (e, s) {
            final stack = _$stack(event.trace, s);
            bloc.onError(e, stack);
            rethrow;
          }
        }
      },
      transformer: _castTransformer<_$SequentialEvent>(
        MonoEventTransformer.sequential,
      ),
    );
    bloc.on<_CheckBalanceEvent>(
      (event, emit) async {
        try {
          await emit.forEach<BankAccountState>(
            _onCheckBalance(),
            onData: (state) => state,
          );
        } catch (e, s) {
          final stack = _$stack(event.trace, s);
          bloc.onError(e, stack);
          rethrow;
        }
      },
      transformer: _castTransformer<_CheckBalanceEvent>(
        MonoEventTransformer.restartable,
      ),
    );
  }

  static StackTrace _$stack(StackTrace origin, StackTrace trace) {
    return MonoStackTrace.filtered(origin, trace, 'bank_account_bloc.g.dart');
  }
}
