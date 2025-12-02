import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

/// Interface for objects that provide an action stream.
///
/// This interface is used by `MonoBlocActionListener` to access the actions
/// stream without requiring knowledge of the state type, avoiding generic
/// type variance issues.
abstract interface class ActionStreamable {
  /// Stream of actions emitted by this bloc.
  ///
  /// Actions are side effects that don't modify bloc state.
  /// Listen to this stream to handle side effects in your application.
  Stream<dynamic> get actions;
}

/// Mixin that adds action stream capability to a Bloc.
///
/// This mixin is automatically added to generated bloc classes that have
/// a `@MonoActions()` annotated mixin. It provides an `actions` stream that emits
/// action objects whenever an action method is called.
///
/// The mixin manages the lifecycle of the action stream controller, ensuring
/// proper cleanup when the bloc is closed.
///
/// Actions are side effects that don't modify state, such as:
/// - Navigation
/// - Showing dialogs or snack bars
/// - Triggering analytics
/// - Logging
/// - API calls that don't affect state
///
/// Example (pure Dart):
/// ```dart
/// bloc.actions.listen((action) {
///   print('Action emitted: $action');
///   // Handle action without UI dependencies
/// });
/// ```
///
/// Example (with Flutter - use mono_bloc_flutter package):
/// ```dart
/// MonoBlocActionListener<MyBloc>(
///   actions: MyBlocActions.when(
///     navigate: (context, route) => Navigator.pushNamed(context, route),
///     showMessage: (context, message) => showSnackBar(message),
///   ),
///   child: MyWidget(),
/// )
/// ```
mixin MonoBlocActionMixin<A, S> on BlocBase<S> implements ActionStreamable {
  @protected
  StreamController<A>? actionController = StreamController<A>.broadcast();

  /// Stream of actions emitted by this bloc.
  ///
  /// Actions are side effects that don't modify bloc state.
  /// Listen to this stream to handle side effects in your application.
  @override
  Stream<A> get actions => actionController?.stream ?? const Stream.empty();

  @override
  Future<void> close() async {
    await super.close();
    await actionController?.close();
    actionController = null;
  }
}
