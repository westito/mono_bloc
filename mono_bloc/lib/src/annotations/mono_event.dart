import 'package:meta/meta_meta.dart';
import 'package:mono_bloc/src/annotations/mono_concurrency.dart';

/// Marks a method as an event handler in MonoBloc.
///
/// Event methods are the core of MonoBloc - they handle business logic and state transitions.
/// For each @event method, MonoBloc generates:
/// - An event class (e.g., `_IncrementEvent`)
/// - A public dispatch method (e.g., `increment()`)
/// - Event handling setup in the base class
///
/// ## Basic Event Handler
///
/// ```dart
/// @MonoBloc()
/// class CounterBloc extends _$CounterBloc<int> {
///   CounterBloc() : super(0);
///
///   @event
///   int _onIncrement() => state + 1;
///   // Generates: bloc.increment()
/// }
/// ```
///
/// ## Method Signatures
///
/// Event methods support multiple signatures:
///
/// ### Return State Directly
/// ```dart
/// @event
/// int _onIncrement() => state + 1;
/// ```
///
/// ### Return `Future<State>`
/// ```dart
/// @event
/// Future<CounterState> _onLoadData() async {
///   final data = await api.fetch();
///   return state.copyWith(data: data);
/// }
/// ```
///
/// ### Return `Stream<State>`
/// ```dart
/// @event
/// Stream<CounterState> _onAutoIncrement() async* {
///   for (int i = 0; i < 10; i++) {
///     await Future.delayed(Duration(seconds: 1));
///     yield state.copyWith(count: state.count + 1);
///   }
/// }
/// ```
///
/// ### Use Emitter for Multiple Updates
/// ```dart
/// @event
/// Future<void> _onLoadData(_Emitter emit) async {
///   emit(state.copyWith(loading: true));
///   final data = await api.fetch();
///   emit(state.copyWith(loading: false, data: data));
/// }
/// ```
///
/// ## Method Parameters
///
/// Event methods can accept parameters that become the public API:
///
/// ```dart
/// @event
/// CounterState _onAdd(int value) {
///   return state.copyWith(count: state.count + value);
/// }
/// // Generates: bloc.add(5)
///
/// @event
/// TodoState _onAddTodo({
///   required String title,
///   String? description,
/// }) {
///   final todo = Todo(title: title, description: description);
///   return state.copyWith(todos: [...state.todos, todo]);
/// }
/// // Generates: bloc.addTodo(title: 'Buy milk', description: 'From store')
/// ```
///
/// ## Concurrency Control
///
/// Control how multiple events are processed using [concurrency]:
///
/// ### Restartable (Cancel Previous)
/// ```dart
/// @event  // Shorthand: @restartableEvent
/// @MonoEvent(MonoConcurrency.restartable)
/// Future<SearchState> _onSearch(String query) async {
///   // If user types again, this cancels and restarts
///   return await searchApi.search(query);
/// }
/// ```
///
/// ### Droppable (Ignore New)
/// ```dart
/// @event  // Shorthand: @droppableEvent
/// @MonoEvent(MonoConcurrency.droppable)
/// Future<FormState> _onSubmit() async {
///   // Ignore additional clicks while submitting
///   await api.submit(state.data);
///   return state.copyWith(submitted: true);
/// }
/// ```
///
/// ### Sequential (Process in Order)
/// ```dart
/// @event  // Shorthand: @sequentialEvent
/// @MonoEvent(MonoConcurrency.sequential)
/// Future<BankState> _onTransfer(double amount) async {
///   // Waits for previous transfers to complete
///   return await processTransfer(amount);
/// }
/// ```
///
/// ### Concurrent (Default)
/// ```dart
/// @event  // Shorthand: @concurrentEvent
/// @MonoEvent(MonoConcurrency.concurrent)
/// Future<DataState> _onLoadUsers() async {
///   // Runs in parallel with other events
///   return await fetchUsers();
/// }
/// ```
///
/// ## Event Queues
///
/// Group related events into custom queues for specialized processing:
///
/// ```dart
/// const uploadQueue = 'upload';
/// const downloadQueue = 'download';
///
/// @MonoBloc()
/// class FileTransferBloc extends _$FileTransferBloc<FileState> {
///   FileTransferBloc() : super(
///     const FileState(),
///     queues: {
///       uploadQueue: MonoEventTransformer.sequential,  // Upload queue
///       downloadQueue: MonoEventTransformer.sequential,  // Download queue
///     },
///   );
///
///   @MonoEvent.queue(uploadQueue)  // Upload queue
///   Future<FileState> _onUpload(File file) async {
///     // Uploads process sequentially in upload queue
///     await uploadApi.upload(file);
///     return state.copyWith(uploaded: [...state.uploaded, file]);
///   }
///
///   @MonoEvent.queue(downloadQueue)  // Download queue
///   Future<FileState> _onDownload(String url) async {
///     // Downloads process sequentially in download queue
///     // But parallel to uploads (different queue)
///     final file = await downloadApi.download(url);
///     return state.copyWith(downloaded: [...state.downloaded, file]);
///   }
///
///   @event  // Not in a queue - processes independently
///   FileState _onCancel(String id) {
///     return state.copyWith(
///       uploaded: state.uploaded.where((f) => f.id != id).toList(),
///     );
///   }
/// }
/// ```
///
/// ## Public Event Methods
///
/// For advanced use cases (base classes), events can be public with `@protected`:
///
/// ```dart
/// abstract class AppBaseBloc<T> extends _$AppBaseBloc<AppState<T>> {
///   AppBaseBloc(AppState<T> initialState) : super(initialState);
///
///   @event
///   @protected  // Must have @protected for public events
///   AppState<T> onMultiply(int factor) {  // Must start with 'on'
///     return state.copyWith(value: state.value * factor);
///   }
/// }
///
/// // Child bloc can use the public event
/// class CounterBloc extends AppBaseBloc<int> {
///   CounterBloc() : super(AppState(value: 1));
///
///   void multiplyByTwo() {
///     onMultiply(2);  // Can call public event method
///   }
/// }
/// ```
///
/// ## Naming Conventions
///
/// ### Private Events (Recommended)
/// - Method name: `_onSomething` or `_something`
/// - Generated public method: `something()`
/// - Generated event class: `_SomethingEvent`
///
/// ```dart
/// @event
/// State _onIncrement() => ...;  // → bloc.increment()
///
/// @event
/// State _onAddItem() => ...;    // → bloc.addItem()
///
/// @event
/// State _deposit() => ...;       // → bloc.deposit()
/// ```
///
/// ### Public Events (Advanced)
/// - Method name: Must start with `on` (e.g., `onMultiply`)
/// - Must have `@protected` annotation
/// - Called directly (no generated dispatch method)
///
/// ## Error Handling
///
/// Errors in event methods are automatically caught and passed to error handlers:
///
/// ```dart
/// @MonoBloc()
/// class MyBloc extends _$MyBloc<MyState> {
///   @event
///   Future<MyState> _onRiskyOperation() async {
///     // If this throws, _onError is called automatically
///     return await riskyApi.call();
///   }
///
///   @onError
///   MyState _onError(Object error, StackTrace stack) {
///     return state.copyWith(error: error.toString());
///   }
/// }
/// ```
///
/// ## Complete Example
///
/// ```dart
/// @MonoBloc(sequential: true)
/// class TodoBloc extends _$TodoBloc<TodoState> {
///   TodoBloc() : super(const TodoState(todos: []));
///
///   @event
///   Future<TodoState> _onLoadTodos() async {
///     final todos = await api.fetchTodos();
///     return state.copyWith(todos: todos);
///   }
///
///   @event
///   TodoState _onAddTodo(String title) {
///     final todo = Todo(id: uuid(), title: title);
///     return state.copyWith(todos: [...state.todos, todo]);
///   }
///
///   @event
///   TodoState _onToggleTodo(String id) {
///     return state.copyWith(
///       todos: state.todos.map((todo) {
///         return todo.id == id ? todo.copyWith(done: !todo.done) : todo;
///       }).toList(),
///     );
///   }
///
///   @restartableEvent  // Override sequential mode
///   Future<TodoState> _onSearch(String query) async {
///     final results = await api.searchTodos(query);
///     return state.copyWith(searchResults: results);
///   }
/// }
/// ```
///
/// ## Shorthand Constants
///
/// MonoBloc provides shorthand constants for common patterns:
///
/// ```dart
/// @event              // Same as @MonoEvent()
/// @restartableEvent   // Same as @MonoEvent(MonoConcurrency.restartable)
/// @sequentialEvent    // Same as @MonoEvent(MonoConcurrency.sequential)
/// @concurrentEvent    // Same as @MonoEvent(MonoConcurrency.concurrent)
/// @droppableEvent     // Same as @MonoEvent(MonoConcurrency.droppable)
/// ```
///
/// See also:
/// - [@MonoBloc] for bloc-level configuration
/// - [MonoConcurrency] for concurrency modes
/// - [@onError] for error handling
/// - [MonoEvent.queue] for custom event queues
@Target({TargetKind.method})
final class MonoEvent {
  /// Concurrency mode for this specific event.
  ///
  /// Overrides the default concurrency set at the bloc level.
  ///
  /// **Example:**
  /// ```dart
  /// @MonoBloc(sequential: true)
  /// class MyBloc extends _$MyBloc<MyState> {
  ///   @event  // Uses sequential (from bloc default)
  ///   Future<MyState> _onSave() async { ... }
  ///
  ///   @MonoEvent(MonoConcurrency.restartable)  // Override: use restartable
  ///   Future<MyState> _onSearch(String q) async { ... }
  /// }
  /// ```
  final MonoConcurrency? concurrency;

  /// Queue name for grouping events.
  ///
  /// Events in the same queue are processed according to the queue's transformer.
  /// Events in different queues can run in parallel.
  ///
  /// Queue names must be valid Dart identifiers (alphanumeric and underscores,
  /// cannot start with a digit).
  ///
  /// **Example:**
  /// ```dart
  /// const uploadQueue = 'upload';
  /// const downloadQueue = 'download';
  ///
  /// @MonoBloc()
  /// class FileBloc extends _$FileBloc<FileState> {
  ///   FileBloc() : super(
  ///     const FileState(),
  ///     queues: {
  ///       uploadQueue: MonoEventTransformer.sequential,  // Upload queue
  ///       downloadQueue: MonoEventTransformer.sequential,  // Download queue
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
  final String? queue;

  /// Creates an event annotation with optional concurrency mode.
  ///
  /// **Examples:**
  /// ```dart
  /// @MonoEvent()  // Use bloc default
  /// @MonoEvent(MonoConcurrency.restartable)  // Specific concurrency
  /// ```
  const MonoEvent([this.concurrency]) : queue = null;

  /// Creates an event annotation with queue assignment.
  ///
  /// The queue name must be a valid Dart identifier.
  ///
  /// **Example:**
  /// ```dart
  /// const uploadQueue = 'upload';
  ///
  /// @MonoEvent.queue(uploadQueue)  // Assign to upload queue
  /// Future<MyState> _onUpload(File file) async { ... }
  /// ```
  const MonoEvent.queue([this.queue]) : concurrency = null;
}
