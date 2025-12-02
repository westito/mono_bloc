/// Example of using mono_bloc annotations and utilities.
///
/// MonoBloc is a code generation library that simplifies the Bloc pattern
/// by generating event classes, base bloc classes, and action handlers
/// from annotated methods.
///
/// ## Setup
///
/// Add dependencies to `pubspec.yaml`:
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
/// ## Basic Counter Bloc
///
/// ```dart
/// import 'package:bloc/bloc.dart';
/// import 'package:mono_bloc/mono_bloc.dart';
///
/// part 'counter_bloc.g.dart';
///
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
/// Generated methods:
/// - `bloc.increment()` - dispatches increment event
/// - `bloc.decrement()` - dispatches decrement event
/// - `bloc.add(5)` - dispatches add event with value
///
/// ## Async Events
///
/// ```dart
/// @MonoBloc()
/// class UserBloc extends _$UserBloc<UserState> {
///   UserBloc(this.repository) : super(const UserState());
///
///   final UserRepository repository;
///
///   @event
///   Future<UserState> _onLoadUser(String id) async {
///     final user = await repository.getUser(id);
///     return state.copyWith(user: user);
///   }
///
///   @restartableEvent  // Cancels previous request if new one comes in
///   Future<UserState> _onSearch(String query) async {
///     final results = await repository.search(query);
///     return state.copyWith(searchResults: results);
///   }
/// }
/// ```
///
/// ## Event Concurrency
///
/// Control how concurrent events are handled:
///
/// - `@event` - Default concurrent processing
/// - `@restartableEvent` - Cancel previous, start new (search)
/// - `@droppableEvent` - Ignore new while processing (submit buttons)
/// - `@sequentialEvent` - Process one at a time in order
/// - `@concurrentEvent` - Process all simultaneously
///
/// ## Async Bloc with Loading States
///
/// ```dart
/// @AsyncMonoBloc()
/// class TodoBloc extends _$TodoBloc<List<Todo>> {
///   TodoBloc(this.repository) : super(const MonoAsyncValue.loading());
///
///   final TodoRepository repository;
///
///   @onInit
///   void _onInit() => loadTodos();
///
///   @event
///   Future<List<Todo>> _onLoadTodos() async {
///     // Automatically shows loading, then data or error
///     return await repository.getTodos();
///   }
/// }
/// ```
///
/// ## Actions (Side Effects)
///
/// Actions are for navigation, dialogs, and other side effects
/// that don't modify state. Define actions in a private mixin:
///
/// ```dart
/// // Define actions in a private mixin
/// @MonoActions()
/// mixin _AuthBlocActions {
///   void navigateToHome();
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
///     navigateToHome();  // Trigger action
///     return AuthState.authenticated(user);
///   }
/// }
/// ```
///
/// ## Event Queues
///
/// Group events into queues with different processing strategies:
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
  // Run: dart run build_runner build
  print('See mono_bloc documentation for usage examples.');
}
