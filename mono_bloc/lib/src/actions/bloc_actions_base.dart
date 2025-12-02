import 'package:bloc/bloc.dart';

/// Base class for action handlers in pure Dart projects.
///
/// This class is used by generated code when the source file does not import
/// Flutter. For Flutter projects, use `FlutterMonoBlocActions` from the
/// mono_bloc_flutter package.
///
/// **Pure Dart projects** (imports only mono_bloc):
/// ```dart
/// class _$BankBlocActions extends MonoBlocActions<_Action> {
///   @override
///   final void Function(BlocBase bloc, _Action action) actions;
///
///   _$BankBlocActions({required this.actions});
/// }
/// ```
///
/// The action handler receives the bloc (for error handling) and the action object.
/// Errors in action handlers are forwarded to `bloc.onError`.
abstract class MonoBlocActions {
  /// Action handler function that processes actions.
  ///
  /// In pure Dart projects, this handler receives the bloc (for error handling)
  /// and the action object. For Flutter projects with BuildContext support,
  /// use FlutterMonoBlocActions.
  void Function(BlocBase<dynamic> bloc, dynamic action) get actions;
}
