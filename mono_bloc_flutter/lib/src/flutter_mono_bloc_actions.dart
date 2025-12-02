import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

/// Base class for action handlers in Flutter projects.
///
/// This class is used by generated code when the source file imports Flutter
/// or mono_bloc_flutter. For pure Dart projects, the generator uses
/// `MonoBlocActions` from the mono_bloc package.
///
/// **Flutter projects** (imports flutter or mono_bloc_flutter):
/// ```dart
/// class _$CartBlocActions extends FlutterMonoBlocActions<_Action> {
///   @override
///   final void Function(BlocBase bloc, BuildContext context, _Action action) actions;
///
///   _$CartBlocActions({required this.actions});
/// }
/// ```
///
/// The action handler receives the bloc, BuildContext and the action object,
/// allowing Flutter-specific operations like navigation and showing dialogs.
/// Errors in action handlers are forwarded to `bloc.onError`.
abstract class FlutterMonoBlocActions {
  /// Action handler function that processes actions with BuildContext.
  ///
  /// In Flutter projects, this handler receives bloc (for error handling),
  /// BuildContext (for UI operations), and the action object.
  void Function(BlocBase<dynamic> bloc, BuildContext context, dynamic action)
  get actions;
}
