/// Example of using mono_bloc_generator to generate bloc code.
///
/// This file shows the source code patterns that mono_bloc_generator processes.
/// The generator creates `.g.dart` files with event classes, base bloc classes,
/// and action handling code.
///
/// ## Setup
///
/// 1. Add dependencies to `pubspec.yaml`:
/// ```yaml
/// dependencies:
///   bloc: ^9.0.0
///   mono_bloc: ^1.0.0
///
/// dev_dependencies:
///   build_runner: ^2.10.0
///   mono_bloc_generator: ^1.0.0
/// ```
///
/// 2. Add `build.yaml` to your project root:
/// ```yaml
/// targets:
///   $default:
///     builders:
///       mono_bloc_generator:
///         generate_for:
///           - lib/**_bloc.dart
/// ```
///
/// 3. Run the generator:
/// ```bash
/// dart run build_runner build
/// ```
///
/// ## Basic Counter Bloc
///
/// The generator creates:
/// - `_$CounterBloc<S>` base class
/// - `_IncrementEvent`, `_DecrementEvent` event classes
/// - `increment()`, `decrement()` dispatch methods
///
/// ```dart
/// @MonoBloc()
/// class CounterBloc extends _$CounterBloc<int> {
///   CounterBloc() : super(0);
///
///   @event
///   int _onIncrement() => state + 1;
///
///   @event
///   int _onDecrement() => state - 1;
///
///   @event
///   int _onAdd(int value) => state + value;
/// }
/// ```
///
/// ## Async Bloc with Loading States
///
/// The generator wraps state in `MonoAsyncValue<T>` for automatic
/// loading/error handling.
///
/// ```dart
/// @AsyncMonoBloc()
/// class UserBloc extends _$UserBloc<User> {
///   UserBloc(this.repository) : super(const MonoAsyncValue.loading());
///
///   final UserRepository repository;
///
///   @onInit
///   void _onInit() => loadUser();
///
///   @event
///   Future<User> _onLoadUser() async {
///     return await repository.getUser();
///   }
///
///   @restartableEvent
///   Future<User> _onSearch(String query) async {
///     return await repository.search(query);
///   }
/// }
/// ```
///
/// ## Bloc with Actions for Side Effects
///
/// Actions are for navigation, dialogs, and other side effects
/// that don't modify state. Actions must be defined in a private mixin:
///
/// ```dart
/// // Actions mixin - side effects that don't modify state
/// @MonoActions()
/// mixin _AuthBlocActions {
///   void navigateToHome(String userId);
///
///   void showError({required String message});
/// }
///
/// // 2. Bloc class - the generated base class includes the actions mixin
/// @MonoBloc()
/// class AuthBloc extends _$AuthBloc<AuthState> {
///   AuthBloc() : super(const AuthState.initial());
///
///   @event
///   Future<AuthState> _onLogin(String email, String password) async {
///     final user = await authService.login(email, password);
///     navigateToHome(user.id);  // Trigger action
///     return AuthState.authenticated(user);
///   }
/// }
/// ```
///
/// ## Bloc with Event Queues
///
/// Events in different queues can run in parallel.
/// Events in the same queue are processed according to the queue's transformer.
///
/// ```dart
/// const uploadQueue = 'upload';
/// const downloadQueue = 'download';
///
/// @MonoBloc()
/// class FileBloc extends _$FileBloc<FileState> {
///   FileBloc() : super(
///     const FileState(),
///     queues: {
///       uploadQueue: MonoEventTransformer.sequential,
///       downloadQueue: MonoEventTransformer.concurrent,
///     },
///   );
///
///   @MonoEvent.queue(uploadQueue)
///   Future<FileState> _onUpload(File file) async { ... }
///
///   @MonoEvent.queue(downloadQueue)
///   Future<FileState> _onDownload(String url) async { ... }
/// }
/// ```
library;

void main() {
  // This is a documentation-only example.
  // See the doc comments above for usage patterns.
  print('See mono_bloc_generator documentation for usage examples.');
}
