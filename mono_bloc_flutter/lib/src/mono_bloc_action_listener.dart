import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mono_bloc/mono_bloc.dart';
import 'package:mono_bloc_flutter/src/flutter_mono_bloc_actions.dart';

/// A Flutter widget that listens to actions from a MonoBloc and executes
/// corresponding handlers with access to BuildContext.
///
/// Actions are side effects that don't modify state, such as navigation,
/// showing dialogs, or displaying snack bars. This widget bridges the gap
/// between the bloc layer and the UI layer.
///
/// Example usage:
/// ```dart
/// MonoBlocActionListener<CartBloc>(
///   actions: CartBlocActions.when(
///     showNotification: (context, message, type) {
///       ScaffoldMessenger.of(context).showSnackBar(
///         SnackBar(content: Text(message)),
///       );
///     },
///     navigateToCheckout: (context) {
///       Navigator.pushNamed(context, '/checkout');
///     },
///   ),
///   child: MyWidget(),
/// )
/// ```
class MonoBlocActionListener<B extends MonoBlocActionMixin<dynamic, dynamic>>
    extends StatefulWidget {
  const MonoBlocActionListener({
    required this.actions,
    required this.child,
    this.bloc,
    super.key,
  });

  /// Optional bloc instance. If null, the widget will look up the bloc
  /// from the widget tree using context.read<B>().
  final B? bloc;

  /// The child widget to display.
  final Widget child;

  /// Action handlers that define what to do when each action is emitted.
  final FlutterMonoBlocActions actions;

  @override
  State<MonoBlocActionListener<B>> createState() =>
      _MonoBlocActionListenerState<B>();
}

class _MonoBlocActionListenerState<
  B extends MonoBlocActionMixin<dynamic, dynamic>
>
    extends State<MonoBlocActionListener<B>> {
  late B _bloc;

  StreamSubscription<dynamic>? _subscription;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? context.read<B>();
    _subscribe();
  }

  @override
  void didUpdateWidget(MonoBlocActionListener<B> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc = oldWidget.bloc ?? _bloc;
    final currentBloc = widget.bloc ?? _bloc;

    if (oldBloc != currentBloc) {
      if (_subscription != null) {
        _unsubscribe();
        _bloc = currentBloc;
      }
      _subscribe();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = widget.bloc ?? context.read<B>();
    if (_bloc != bloc) {
      if (_subscription != null) {
        _unsubscribe();
      }
      _bloc = bloc;
      _subscribe();
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    _subscription = _bloc.actions.listen((action) {
      if (mounted) {
        widget.actions.actions(_bloc, context, action);
      }
    });
  }

  void _unsubscribe() {
    unawaited(_subscription?.cancel());
    _subscription = null;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
