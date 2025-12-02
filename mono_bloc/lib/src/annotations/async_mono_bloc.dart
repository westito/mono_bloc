import 'package:meta/meta_meta.dart';
import 'package:mono_bloc/mono_bloc.dart' show MonoAsyncValue;
import 'package:mono_bloc/src/annotations/mono_concurrency.dart';
import 'package:mono_bloc/src/async/mono_async_value.dart' show MonoAsyncValue;

/// Marks a class for MonoBloc code generation with async state management.
///
/// AsyncMonoBloc automatically wraps your state in `MonoAsyncValue<T>`, which provides
/// built-in loading, error, and data states. This eliminates boilerplate for handling
/// async operations and provides a consistent pattern for UI state management.
///
/// ## Basic Usage
///
/// ```dart
/// import 'package:bloc/bloc.dart';
/// import 'package:mono_bloc/mono_bloc.dart';
///
/// part 'user_bloc.g.dart';
///
/// @AsyncMonoBloc()
/// class UserBloc extends _$UserBloc<User> {
///   UserBloc() : super(const MonoAsyncValue.loading());
///
///   @event
///   Future<User> _onLoadUser(String id) async {
///     // Just return the data - wrapping is automatic!
///     return await api.fetchUser(id);
///   }
/// }
/// ```
///
/// ## MonoAsyncValue States
///
/// Your state is automatically wrapped in `MonoAsyncValue<T>`, which has three states:
///
/// - **Loading**: Operation in progress
/// - **Data**: Successful result
/// - **Error**: Operation failed
///
/// ### UI Usage
/// ```dart
/// BlocBuilder<UserBloc, MonoAsyncValue<User>>(
///   builder: (context, state) {
///     return state.when(
///       loading: () => CircularProgressIndicator(),
///       data: (user) => UserProfile(user: user),
///       error: (error, stack) => ErrorWidget(error: error),
///     );
///   },
/// )
/// ```
///
/// ## Helper Methods
///
/// AsyncMonoBloc provides helper methods in your event handlers:
///
/// ### loading()
/// Emit a loading state while preserving current data:
/// ```dart
/// @event
/// Future<void> _onRefresh(_Emitter emit) async {
///   emit(loading());  // Shows loading with current data preserved
///   final user = await api.fetchUser();
///   emit(withData(user));
/// }
/// ```
///
/// ### loadingClearData()
/// Emit a loading state without data:
/// ```dart
/// @event
/// Future<void> _onReset(_Emitter emit) async {
///   emit(loadingClearData());  // Shows loading, clears data
///   final newUser = await api.createUser();
///   emit(withData(newUser));
/// }
/// ```
///
/// ### withData(T data)
/// Wrap data in success state:
/// ```dart
/// @event
/// User _onUpdateName(String name) {
///   // Automatically wrapped
///   return state.dataOrNull!.copyWith(name: name);
/// }
///
/// // Or explicitly
/// @event
/// Future<void> _onLoadUser(_Emitter emit) async {
///   final user = await api.fetchUser();
///   emit(withData(user));  // Explicit wrapping
/// }
/// ```
///
/// ### withError(Object error, StackTrace stack, [T? data])
/// Wrap error in error state:
/// ```dart
/// @event
/// Future<void> _onLoadUser(_Emitter emit) async {
///   try {
///     final user = await api.fetchUser();
///     emit(withData(user));
///   } catch (e, stack) {
///     emit(withError(e, stack, state.dataOrNull));  // Keep current data
///   }
/// }
/// ```
///
/// ## Return Types
///
/// Event methods in AsyncMonoBloc can return:
///
/// ### Return T Directly (Automatic Wrapping)
/// ```dart
/// @event
/// Future<User> _onLoadUser(String id) async {
///   return await api.fetchUser(id);
///   // Automatically wrapped in MonoAsyncValue.data()
/// }
/// ```
///
/// ### Return `MonoAsyncValue<T>` (Manual Control)
/// ```dart
/// @event
/// Future<MonoAsyncValue<User>> _onLoadUser(String id) async {
///   return MonoAsyncValue.data(await api.fetchUser(id));
/// }
/// ```
///
/// ### Use Emitter (Multiple States)
/// ```dart
/// @event
/// Future<void> _onLoadUser(String id, _Emitter emit) async {
///   emit(loading());
///   try {
///     final user = await api.fetchUser(id);
///     emit(withData(user));
///   } catch (e, stack) {
///     emit(withError(e, stack));
///   }
/// }
/// ```
///
/// ### Return `Stream<T>` (Streaming Data)
/// ```dart
/// @event
/// Stream<User> _onWatchUser(String id) {
///   return api.watchUser(id);
///   // Each item automatically wrapped in MonoAsyncValue.data()
/// }
/// ```
///
/// ## Error Handling
///
/// Errors are automatically caught and wrapped in error state:
///
/// ```dart
/// @AsyncMonoBloc()
/// class UserBloc extends _$UserBloc<User> {
///   @event
///   Future<User> _onLoadUser(String id) async {
///     // If this throws, automatically wrapped in MonoAsyncValue.error()
///     return await api.fetchUser(id);
///   }
///
///   // Custom error handler
///   @onError
///   MonoAsyncValue<User> _onError(Object error, StackTrace stack) {
///     return withError(error, stack, state.dataOrNull);
///   }
/// }
/// ```
///
/// ## Concurrency Control
///
/// Control how concurrent async operations are handled:
///
/// ```dart
/// @AsyncMonoBloc(MonoConcurrency.restartable)  // Default for all events
/// class SearchBloc extends _$SearchBloc<List<SearchResult>> {
///   SearchBloc() : super(const MonoAsyncValue.data([]));
///
///   @event  // Uses restartable (from default)
///   Future<List<SearchResult>> _onSearch(String query) async {
///     // Previous searches are cancelled when user types again
///     return await api.search(query);
///   }
///
///   @droppableEvent  // Override: ignore rapid clicks
///   Future<List<SearchResult>> _onLoadMore() async {
///     final more = await api.loadMore();
///     return [...state.data, ...more];
///   }
/// }
/// ```
///
/// ## Accessing Current Data
///
/// MonoAsyncValue provides several ways to access the current data:
///
/// ```dart
/// state.dataOrNull  // T? - null if loading/error
/// state.data        // T - throws if no data available
/// state.hasData     // bool - true if data available
/// state.isLoading   // bool - true if loading
/// state.hasError    // bool - true if error
/// state.errorOrNull // Object? - null if no error
/// state.error       // Object - throws if no error
/// ```
///
/// ## Complete Example
///
/// ```dart
/// @AsyncMonoBloc(MonoConcurrency.restartable)
/// class TodoBloc extends _$TodoBloc<List<Todo>> {
///   TodoBloc(this.repository) : super(const MonoAsyncValue.loading()) {
///     loadTodos();  // Auto-load on creation
///   }
///
///   final TodoRepository repository;
///
///   @event
///   Future<List<Todo>> _onLoadTodos() async {
///     return await repository.fetchTodos();
///   }
///
///   @event
///   Future<List<Todo>> _onAddTodo(String title) async {
///     final newTodo = await repository.createTodo(title);
///     return [...state.data, newTodo];
///   }
///
///   @event
///   Future<List<Todo>> _onToggleTodo(String id) async {
///     final updated = await repository.toggleTodo(id);
///     return state.data.map((todo) {
///       return todo.id == id ? updated : todo;
///     }).toList();
///   }
///
///   @event
///   Future<void> _onRefresh(_Emitter emit) async {
///     emit(loading());  // Show loading with current data
///     final todos = await repository.fetchTodos();
///     emit(withData(todos));
///   }
///
///   @onError
///   MonoAsyncValue<List<Todo>> _onError(Object error, StackTrace stack) {
///     // Keep current data when errors occur
///     return withError(error, stack, state.dataOrNull);
///   }
/// }
/// ```
///
/// See also:
/// - [@MonoBloc] for synchronous state management
/// - [MonoAsyncValue] for the state wrapper
/// - [MonoConcurrency] for concurrency modes
@Target({TargetKind.classType})
final class AsyncMonoBloc {
  /// Default concurrency mode for all simple events (without explicit queue or concurrency transformer).
  ///
  /// **Default:** [MonoConcurrency.concurrent] - events will be processed concurrently.
  ///
  /// **Options:**
  /// - `MonoConcurrency.concurrent`: Process events in parallel (default)
  /// - `MonoConcurrency.sequential`: Process events one at a time in order
  /// - `MonoConcurrency.restartable`: Cancel previous event when new one arrives
  /// - `MonoConcurrency.droppable`: Ignore new events while processing
  ///
  /// **Example:**
  /// ```dart
  /// @AsyncMonoBloc(MonoConcurrency.sequential)
  /// class MyBloc extends _$MyBloc<MyData> {
  ///   // All events processed sequentially unless explicitly overridden
  /// }
  /// ```
  final MonoConcurrency concurrency;

  /// Creates an AsyncMonoBloc annotation with optional concurrency mode.
  ///
  /// If not specified, defaults to [MonoConcurrency.concurrent].
  const AsyncMonoBloc([this.concurrency = MonoConcurrency.concurrent]);
}
