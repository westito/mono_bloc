/// Code generation library for simplified BLoC pattern with event methods,
/// automatic error handling, concurrency control, and side-effect management.
///
/// ## Basic Usage
///
/// ```dart
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
///
/// // Usage
/// final bloc = CounterBloc();
/// bloc.increment();
/// bloc.decrement();
/// bloc.add(5);
/// ```
///
/// ## Event Methods (@event)
///
/// Event methods handle business logic and state transitions. MonoBloc generates
/// event classes and public dispatch methods automatically.
///
/// ### Return Types
///
/// **1. Synchronous State Return**
/// ```dart
/// @event
/// int _onIncrement() => state + 1;
///
/// @event
/// TodoState _onAddTodo(String title) {
///   return state.copyWith(todos: [...state.todos, Todo(title: title)]);
/// }
/// ```
///
/// **2. Asynchronous State Return**
/// ```dart
/// @event
/// Future<TodoState> _onLoadTodos() async {
///   final todos = await repository.fetchTodos();
///   return state.copyWith(todos: todos);
/// }
/// ```
///
/// **3. Stream State Return**
/// ```dart
/// @event
/// Stream<SearchState> _onSearch(String query) async* {
///   yield state.copyWith(loading: true);
///   final results = await api.search(query);
///   yield state.copyWith(loading: false, results: results);
/// }
/// ```
///
/// **4. Void with Emitter (Multiple Emissions)**
/// ```dart
/// @event
/// void _onLoadData(_Emitter emit) {
///   emit(state.copyWith(loading: true));
///   emit(state.copyWith(loading: false));
/// }
/// ```
///
/// **5. `Future<void>` with Emitter (Async Multiple Emissions)**
/// ```dart
/// @event
/// Future<void> _onLoadData(_Emitter emit) async {
///   emit(state.copyWith(loading: true));
///   final data = await api.fetch();
///   emit(state.copyWith(loading: false, data: data));
/// }
/// ```
///
/// ### Method Parameters
///
/// **Positional Parameters:**
/// ```dart
/// @event
/// State _onAdd(int value) => state.copyWith(count: state.count + value);
/// // Generated: bloc.add(5)
/// ```
///
/// **Named Parameters:**
/// ```dart
/// @event
/// State _onUpdate({required String name, int? age}) {
///   return state.copyWith(name: name, age: age);
/// }
/// // Generated: bloc.update(name: 'John', age: 30)
/// ```
///
/// **Mixed Parameters:**
/// ```dart
/// @event
/// State _onAddTodo(
///   String title,
///   String description, {
///   required TodoPriority priority,
///   List<String> tags = const [],
///   DateTime? dueDate,
/// }) {
///   return state.copyWith(
///     todos: [...state.todos, Todo(
///       title: title,
///       description: description,
///       priority: priority,
///       tags: tags,
///       dueDate: dueDate,
///     )],
///   );
/// }
/// // Generated: bloc.addTodo('Title', 'Desc', priority: TodoPriority.high)
/// ```
///
/// **Complex Types (Preserved):**
/// ```dart
/// // Typedefs preserved
/// typedef Callback = void Function(String result);
///
/// @event
/// State _onProcess(Callback onComplete) { ... }
///
/// // Records preserved
/// @event
/// State _onUpdateCoords((double lat, double lng) location) { ... }
///
/// // Generics preserved
/// @event
/// Future<Map<String, List<Todo>>> _onGroupByTag() async { ... }
/// ```
///
/// ### Event Naming
///
/// **Private Events (Recommended):**
/// ```dart
/// @event
/// State _onIncrement() => ...;     // → bloc.increment()
/// @event
/// State _onAddItem() => ...;       // → bloc.addItem()
/// @event
/// State _loadData() => ...;        // → bloc.loadData()
/// ```
///
/// **Public Events (Base Classes):**
/// ```dart
/// @event
/// @protected
/// State onReset() => ...;          // → Must start with 'on' and be @protected
/// ```
///
/// ## Concurrency Control
///
/// Control how multiple events are processed using four concurrency modes.
///
/// ### Sequential Mode (Bloc-Level)
///
/// All events without explicit concurrency are queued and processed one at a time:
///
/// ```dart
/// @MonoBloc(sequential: true)
/// class BankBloc extends _$BankBloc<BankState> {
///   BankBloc() : super(const BankState(balance: 0));
///
///   @event
///   Future<BankState> _onDeposit(double amount) async {
///     // Queued sequentially
///     return state.copyWith(balance: state.balance + amount);
///   }
///
///   @event
///   Future<BankState> _onWithdraw(double amount) async {
///     // Queued sequentially after deposit completes
///     return state.copyWith(balance: state.balance - amount);
///   }
///
///   @restartableEvent  // Bypasses sequential queue
///   Future<BankState> _onRefresh() async {
///     // Runs independently with restartable behavior
///     final balance = await api.fetchBalance();
///     return state.copyWith(balance: balance);
///   }
/// }
/// ```
///
/// ### Default Concurrency (Bloc-Level)
///
/// Set a default concurrency mode for all events:
///
/// ```dart
/// @MonoBloc(concurrency: MonoConcurrency.restartable)
/// class SearchBloc extends _$SearchBloc<SearchState> {
///   @event
///   Future<SearchState> _onSearch(String query) async {
///     // Uses restartable (from bloc default)
///     return await api.search(query);
///   }
///
///   @droppableEvent  // Override: uses droppable
///   Future<SearchState> _onLoadMore() async {
///     return await api.loadMore();
///   }
/// }
/// ```
///
/// ### Event-Level Concurrency
///
/// **1. Sequential - Queue and Process in Order**
/// ```dart
/// @sequentialEvent  // or @MonoEvent(MonoConcurrency.sequential)
/// Future<State> _onProcess() async {
///   // Events queued, processed one at a time
///   return await processData();
/// }
/// ```
///
/// **2. Concurrent - Process in Parallel (Default)**
/// ```dart
/// @concurrentEvent  // or @event
/// Future<State> _onLoadUsers() async {
///   // Multiple events run in parallel
///   return await api.fetchUsers();
/// }
/// ```
///
/// **3. Restartable - Cancel Previous, Start New**
/// ```dart
/// @restartableEvent  // or @MonoEvent(MonoConcurrency.restartable)
/// Future<SearchState> _onSearch(String query) async {
///   // Previous search cancelled when user types again
///   final results = await api.search(query);
///   return state.copyWith(results: results);
/// }
/// ```
///
/// **4. Droppable - Ignore New While Processing**
/// ```dart
/// @droppableEvent  // or @MonoEvent(MonoConcurrency.droppable)
/// Future<FormState> _onSubmit() async {
///   // Additional clicks ignored until this completes
///   await api.submit(state.data);
///   return state.copyWith(submitted: true);
/// }
/// ```
///
/// ### Comparison
///
/// | Mode | New Event While Processing | Use Case |
/// |------|---------------------------|----------|
/// | Sequential | Queued | Database transactions, state machines |
/// | Concurrent | Runs in parallel | Independent operations |
/// | Restartable | Cancels current, starts new | Search, filters |
/// | Droppable | Ignored | Rate limiting, prevent double-submit |
///
/// ## Async State Management (@AsyncMonoBloc)
///
/// Wraps state in `MonoAsyncValue<T>` for automatic loading/error/data handling.
///
/// ### Basic Usage
///
/// ```dart
/// @AsyncMonoBloc()
/// class UserBloc extends _$UserBloc<User> {
///   UserBloc() : super(const MonoAsyncValue.loading());
///
///   @event
///   Future<User> _onLoadUser(String id) async {
///     return await api.fetchUser(id);  // Auto-wrapped
///   }
/// }
/// ```
///
/// ### Return Types
///
/// **1. Return T Directly (Automatic Wrapping)**
/// ```dart
/// @event
/// Future<User> _onLoadUser() async {
///   return await api.fetchUser();
///   // Wrapped in MonoAsyncValue.withData(user)
/// }
///
/// @event
/// List<Todo> _onFilterCompleted() {
///   return state.dataOrNull?.where((t) => t.completed).toList() ?? [];
///   // Wrapped immediately
/// }
/// ```
///
/// **2. Return `MonoAsyncValue<T>` (Manual Control)**
/// ```dart
/// @event
/// Future<MonoAsyncValue<User>> _onLoadUser() async {
///   return MonoAsyncValue.withData(await api.fetchUser());
/// }
/// ```
///
/// **3. Return `Stream<T>` (Streaming Data)**
/// ```dart
/// @event
/// Stream<List<Todo>> _onWatchTodos() {
///   return repository.watchTodos();
///   // Each item wrapped in MonoAsyncValue.withData()
/// }
/// ```
///
/// **4. Return `Stream<MonoAsyncValue<T>>` (Full Control)**
/// ```dart
/// @event
/// Stream<MonoAsyncValue<List<Todo>>> _onSearchProgressive(String query) async* {
///   yield loading();
///   for (final source in sources) {
///     final results = await source.search(query);
///     yield withData(results);
///   }
/// }
/// ```
///
/// **5. Use Emitter (Multiple States)**
/// ```dart
/// @event
/// Future<void> _onLoadUser(_Emitter emit) async {
///   emit(loading());  // MonoAsyncValue.loading()
///   try {
///     final user = await api.fetchUser();
///     emit(withData(user));  // MonoAsyncValue.withData(user)
///   } catch (e, stack) {
///     emit(withError(e, stack));
///   }
/// }
/// ```
///
/// ### Helper Methods (Available in Event Handlers)
///
/// **loading()** - Loading state with current data preserved:
/// ```dart
/// emit(loading());  // MonoAsyncValue(data: currentData, isLoading: true)
/// ```
///
/// **loadingClearData()** - Loading state without data:
/// ```dart
/// emit(loadingClearData());  // MonoAsyncValue(data: null, isLoading: true)
/// ```
///
/// **withData(T)** - Success state:
/// ```dart
/// emit(withData(user));  // MonoAsyncValue.withData(user)
/// ```
///
/// `withError(error, stack, [data])` - Error state:
/// ```dart
/// emit(withError(error, stack, state.dataOrNull));
/// ```
///
/// ### Accessing Current Data
///
/// ```dart
/// state.dataOrNull    // T? - null if loading/error
/// state.data          // T - throws if not data state
/// state.hasData       // bool - true if data available
/// state.isLoading     // bool - true if loading
/// state.hasError      // bool - true if error
/// state.error         // Object - error if available
/// state.errorOrNull   // Object? - null if no error
/// ```
///
/// ### UI Pattern Matching
///
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
/// ### With Concurrency
///
/// ```dart
/// @AsyncMonoBloc(MonoConcurrency.restartable)
/// class SearchBloc extends _$SearchBloc<List<Result>> {
///   @event  // Uses restartable from bloc default
///   Future<List<Result>> _onSearch(String query) async {
///     return await api.search(query);
///   }
/// }
/// ```
///
/// ## Error Handling (@onError)
///
/// Errors are automatically caught and passed to error handlers with filtered
/// stack traces combining dispatch location and error location.
///
/// ### Handler Priority
///
/// 1. Event-specific handler: `_onError<EventName>`
/// 2. General handler: `_onError`
/// 3. Default behavior: rethrow
///
/// ### Method Signatures
///
/// **1. Error and Stack Trace**
/// ```dart
/// @onError
/// State _onError(Object error, StackTrace stack) {
///   return state.copyWith(error: error.toString());
/// }
/// ```
///
/// **2. Error Only**
/// ```dart
/// @onError
/// State _onError(Object error) {
///   return state.copyWith(error: error.toString());
/// }
/// ```
///
/// **3. With Event Reference**
/// ```dart
/// @onError
/// State _onError(Object error, StackTrace stack, _Event event) {
///   print('Error in: ${event.runtimeType}');
///   return state.copyWith(error: error.toString());
/// }
/// ```
///
/// **4. With Emitter**
/// ```dart
/// @onError
/// void _onError(Object error, _Emitter emit) {
///   emit(state.copyWith(error: error.toString()));
/// }
/// ```
///
/// **5. Return void (No State Change)**
/// ```dart
/// @onError
/// void _onError(Object error, StackTrace stack) {
///   logger.error('Event failed', error, stack);
///   // No state emission
/// }
/// ```
///
/// **6. Return Nullable State (Optional Recovery)**
/// ```dart
/// @onError
/// State? _onError(Object error) {
///   if (error is NetworkException) {
///     return state.copyWith(offline: true);
///   }
///   return null;  // Don't emit for other errors
/// }
/// ```
///
/// ### Event-Specific Handlers
///
/// ```dart
/// @MonoBloc()
/// class PaymentBloc extends _$PaymentBloc<PaymentState> {
///   @event
///   Future<PaymentState> _onProcessPayment() async {
///     return await paymentService.process();
///   }
///
///   @event
///   Future<PaymentState> _onRefund(String id) async {
///     return await paymentService.refund(id);
///   }
///
///   // Handles only processPayment errors
///   @onError
///   PaymentState _onErrorProcessPayment(Object error, StackTrace stack) {
///     if (error is InsufficientFundsException) {
///       return PaymentState.failed('Insufficient funds');
///     }
///     return PaymentState.failed('Payment failed');
///   }
///
///   // Handles only refund errors
///   @onError
///   PaymentState _onErrorRefund(Object error) {
///     return PaymentState.failed('Refund failed');
///   }
///
///   // General fallback for other events
///   @onError
///   PaymentState _onError(Object error, StackTrace stack) {
///     return state.copyWith(error: error.toString());
///   }
/// }
/// ```
///
/// ### With AsyncMonoBloc
///
/// ```dart
/// @AsyncMonoBloc()
/// class UserBloc extends _$UserBloc<User> {
///   @event
///   Future<User> _onLoadUser(String id) async {
///     return await api.fetchUser(id);
///   }
///
///   @onError
///   MonoAsyncValue<User> _onError(Object error, StackTrace stack) {
///     // Keep current data, add error
///     return withError(error, stack, state.dataOrNull);
///   }
/// }
/// ```
///
/// ### Stack Trace Filtering
///
/// MonoBloc automatically filters stack traces to remove:
/// - Dart core frames (`dart:async`, `dart:core`)
/// - Framework packages (`package:bloc`, `package:flutter`)
/// - MonoBloc internals (`package:mono_bloc`)
/// - Generated code (`.g.dart`)
///
/// The filtered trace combines:
/// 1. Where the event was dispatched (call site)
/// 2. Where the error occurred (implementation)
///
/// ## Actions (@MonoActions)
///
/// Actions represent side effects that don't modify state. They're dispatched
/// through a separate `actions` stream for handling in the UI layer.
///
/// ### Requirements
///
/// Actions must be defined in a **private mixin** annotated with `@MonoActions()`:
/// 1. Create a private mixin (name starts with `_`) with `@MonoActions()` annotation
/// 2. Define abstract void methods for each action
/// 3. The generated `_$Bloc` base class automatically includes the actions mixin
///
/// ```dart
/// // Define actions in a private mixin with @MonoActions()
/// @MonoActions()
/// mixin _MyBlocActions {
///   void myAction();
/// }
///
/// // The generated _$MyBloc includes _MyBlocActions automatically
/// @MonoBloc()
/// class MyBloc extends _$MyBloc<MyState> {
///   MyBloc() : super(initialState);
/// }
/// ```
///
/// ### Action Parameters
///
/// **No Parameters:**
/// ```dart
/// void navigateToHome();
/// ```
///
/// **Positional Parameters:**
/// ```dart
/// void showDialog(String title, String message);
/// ```
///
/// **Named Parameters:**
/// ```dart
/// void showNotification({
///   required String message,
///   required NotificationType type,
/// });
/// ```
///
/// **Mixed Parameters:**
/// ```dart
/// void trackEvent(
///   String eventName,
///   Map<String, dynamic> properties, {
///   required String category,
///   int? value,
/// });
/// ```
///
/// **Complex Types (Type Preservation):**
/// ```dart
/// // Typedef preserved
/// typedef OnComplete = void Function(bool success);
///
/// void showConfirmDialog({
///   required String message,
///   required OnComplete onComplete,
/// });
///
/// // Record type preserved
/// void updateLocation((double lat, double lng) coords);
/// ```
///
/// ### Pure Dart Usage
///
/// Listen to actions stream directly:
///
/// ```dart
/// // Define actions in a private mixin
/// @MonoActions()
/// mixin _LoggingBlocActions {
///   void logEvent(String eventName, Map<String, dynamic> params);
///
///   void trackPageView(String pageName);
/// }
///
/// // The generated base class includes the actions mixin automatically
/// @MonoBloc()
/// class LoggingBloc extends _$LoggingBloc<int> {
///   LoggingBloc() : super(0);
///
///   @event
///   int _onIncrement() {
///     logEvent('counter_incremented', {'value': state + 1});
///     return state + 1;
///   }
/// }
///
/// // Listen to actions using pattern matching
/// void main() {
///   final bloc = LoggingBloc();
///
///   bloc.actions.listen((action) {
///     switch (action) {
///       case _LogEventAction(:final eventName, :final params):
///         analytics.logEvent(eventName, parameters: params);
///       case _TrackPageViewAction(:final pageName):
///         analytics.logPageView(pageName);
///     }
///   });
///
///   bloc.increment();  // Triggers logEvent action
/// }
/// ```
///
/// ### Flutter Usage (requires mono_bloc_flutter)
///
/// Use `MonoBlocActionListener` widget:
///
/// ```dart
/// // Define actions in a private mixin
/// @MonoActions()
/// mixin _CartBlocActions {
///   void showNotification(String message, NotificationType type);
///
///   void navigateToCheckout();
///
///   void vibrate();
/// }
///
/// // The generated base class includes the actions mixin automatically
/// @MonoBloc()
/// class CartBloc extends _$CartBloc<CartState> {
///   CartBloc() : super(const CartState());
///
///   @event
///   CartState _onAddItem(CartItem item) {
///     showNotification('Added ${item.name}', NotificationType.success);
///     vibrate();
///     return state.copyWith(items: [...state.items, item]);
///   }
/// }
///
/// // In Flutter UI:
/// MonoBlocActionListener<CartBloc>(
///   actions: CartBlocActions.when(
///     showNotification: (context, message, type) {
///       final color = type == NotificationType.success
///           ? Colors.green
///           : Colors.red;
///       ScaffoldMessenger.of(context).showSnackBar(
///         SnackBar(content: Text(message), backgroundColor: color),
///       );
///     },
///     navigateToCheckout: (context) {
///       Navigator.of(context).push(
///         MaterialPageRoute(builder: (_) => CheckoutPage()),
///       );
///     },
///     vibrate: (context) {
///       HapticFeedback.mediumImpact();
///     },
///   ),
///   child: CartPage(),
/// )
/// ```
///
/// ### Using `of()` with Interface Implementation
///
/// For cleaner action handling, implement the generated actions interface:
///
/// ```dart
/// class CartPage extends StatelessWidget implements CartBlocActions {
///   const CartPage({super.key});
///
///   @override
///   void showNotification(BuildContext context, String message, NotificationType type) {
///     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
///   }
///
///   @override
///   void navigateToCheckout(BuildContext context) {
///     Navigator.of(context).push(MaterialPageRoute(builder: (_) => CheckoutPage()));
///   }
///
///   @override
///   void vibrate(BuildContext context) {
///     HapticFeedback.mediumImpact();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return MonoBlocActionListener<CartBloc>(
///       actions: CartBlocActions.of(this),  // Wire this instance as handler
///       child: CartContent(),
///     );
///   }
/// }
/// ```
///
/// **When to use which pattern:**
/// - **`when()`** - Inline callbacks, good for simple pages with few actions
/// - **`of()`** - Interface implementation, better for complex pages or reusable handlers
///
/// ### Generated Code
///
/// MonoBloc generates:
/// 1. Sealed action hierarchy for type safety
/// 2. Action stream in base class
/// 3. Implementation class with action methods
/// 4. Pattern matching with `when()` and `of()`
///
/// ### Use Cases
///
/// - Navigation between screens
/// - Showing dialogs, snackbars, bottom sheets
/// - Playing sounds, vibrations
/// - Logging and analytics
/// - Calling platform services (camera, file picker)
/// - External API calls that don't affect state
///
/// ## Event Queues
///
/// Group related events into named queues with independent transformers.
/// Events in different queues can run in parallel.
///
/// ### Basic Queue Setup
///
/// ```dart
/// @MonoBloc()
/// class FileTransferBloc extends _$FileTransferBloc<FileState> {
///   static const uploadQueue = 'upload';
///   static const downloadQueue = 'download';
///   static const syncQueue = 'sync';
///
///   FileTransferBloc() : super(
///     const FileState(),
///     queues: {
///       uploadQueue: MonoEventTransformer.sequential,
///       downloadQueue: MonoEventTransformer.sequential,
///       syncQueue: MonoEventTransformer.droppable,
///     },
///   );
///
///   // Upload queue (sequential)
///   @MonoEvent.queue(uploadQueue)
///   Future<FileState> _onUpload(File file) async {
///     await uploadApi.upload(file);
///     return state.copyWith(uploaded: [...state.uploaded, file]);
///   }
///
///   @MonoEvent.queue(uploadQueue)
///   Future<FileState> _onCancelUpload(String id) async {
///     await uploadApi.cancel(id);
///     return state.copyWith(
///       uploaded: state.uploaded.where((f) => f.id != id).toList(),
///     );
///   }
///
///   // Download queue (sequential, runs parallel to upload queue)
///   @MonoEvent.queue(downloadQueue)
///   Future<FileState> _onDownload(String url) async {
///     final file = await downloadApi.download(url);
///     return state.copyWith(downloaded: [...state.downloaded, file]);
///   }
///
///   // Sync queue (droppable)
///   @MonoEvent.queue(syncQueue)
///   Future<FileState> _onSync() async {
///     await api.syncAll();
///     return await _getCurrentState();
///   }
///
///   // No queue: Independent event
///   @restartableEvent
///   Stream<FileState> _onRefresh() async* {
///     yield state.copyWith(refreshing: true);
///     final data = await api.fetchAll();
///     yield state.copyWith(refreshing: false, data: data);
///   }
/// }
/// ```
///
/// ### Queue Transformers
///
/// Each queue can have its own transformer:
///
/// ```dart
/// static const queue1 = 'queue1';
/// static const queue2 = 'queue2';
/// static const queue3 = 'queue3';
/// static const queue4 = 'queue4';
///
/// queues: {
///   queue1: MonoEventTransformer.sequential,   // Process one at a time
///   queue2: MonoEventTransformer.concurrent,   // Process in parallel
///   queue3: MonoEventTransformer.restartable,  // Cancel previous
///   queue4: MonoEventTransformer.droppable,    // Ignore new
/// }
/// ```
///
/// ### Use Cases
///
/// - Separate upload/download queues
/// - Priority queues (high/low priority events)
/// - Transaction groups (read vs write operations)
/// - Resource-specific queues (network vs database)
///
/// ## Event Interception (@onEvent)
///
/// Intercept and filter events before they're processed. Return `false` to block.
///
/// ### Basic Interceptor
///
/// ```dart
/// @MonoBloc()
/// class TodoBloc extends _$TodoBloc<TodoState> {
///   @event
///   Future<TodoState> _onLoadTodos() async { ... }
///
///   @onEvent
///   bool _onEvents(_Event event) {
///     if (state.isLoading) {
///       return false;  // Block all events while loading
///     }
///     return true;  // Allow event
///   }
/// }
/// ```
///
/// ### Method Signatures
///
/// **Event Only:**
/// ```dart
/// @onEvent
/// bool _onEvents(_Event event) {
///   print('Event: ${event.runtimeType}');
///   return true;
/// }
/// ```
///
/// **With Emitter:**
/// ```dart
/// @onEvent
/// bool _onEvents(_Event event, _Emitter emit) {
///   if (event is _LoadEvent) {
///     emit(state.copyWith(loading: true));
///   }
///   return true;
/// }
/// ```
///
/// **Emitter Only:**
/// ```dart
/// @onEvent
/// bool _onEvents(_Emitter emit) {
///   emit(state.copyWith(eventCount: state.eventCount + 1));
///   return true;
/// }
/// ```
///
/// ### Use Cases
///
/// **Rate Limiting:**
/// ```dart
/// DateTime? _lastRequestTime;
///
/// @onEvent
/// bool _onEvents(_Event event) {
///   if (event is _FetchDataEvent) {
///     final now = DateTime.now();
///     if (_lastRequestTime != null &&
///         now.difference(_lastRequestTime!) < Duration(seconds: 1)) {
///       return false;  // Too soon
///     }
///     _lastRequestTime = now;
///   }
///   return true;
/// }
/// ```
///
/// **Loading Guard:**
/// ```dart
/// @onEvent
/// bool _onEvents(_Event event) {
///   if (state.isLoading) {
///     print('Blocked ${event.runtimeType}: already loading');
///     return false;
///   }
///   return true;
/// }
/// ```
///
/// **Permission Check:**
/// ```dart
/// @onEvent
/// bool _onEvents(_Event event) {
///   if (event is _DeleteEvent && !authService.canDelete) {
///     return false;
///   }
///   return true;
/// }
/// ```
///
/// ## Initialization (@onInit)
///
/// Run code automatically when bloc is created.
///
/// ```dart
/// @MonoBloc()
/// class TodoBloc extends _$TodoBloc<TodoState> {
///   TodoBloc() : super(const TodoState());
///
///   @onInit
///   void _onInit() {
///     // Called automatically after constructor
///     loadTodos();
///   }
///
///   @event
///   Future<TodoState> _onLoadTodos() async {
///     final todos = await repository.fetchTodos();
///     return state.copyWith(todos: todos);
///   }
/// }
/// ```
///
/// **Multiple Init Methods:**
/// ```dart
/// @onInit
/// void _initializeAnalytics() {
///   analytics.initialize();
/// }
///
/// @onInit
/// void _subscribeToNotifications() {
///   notificationService.stream.listen((n) => showNotification(n));
/// }
/// ```
///
/// ## Advanced Patterns
///
/// ### Progressive Stream Updates
///
/// ```dart
/// @restartableEvent
/// Stream<TodoState> _onSearchAcrossSources(String query) async* {
///   yield state.copyWith(loading: true, results: []);
///
///   for (final source in sources) {
///     final results = await source.search(query);
///     // Yield progressive results as each source completes
///     yield state.copyWith(
///       results: [...state.results, ...results],
///       loadedSources: [...state.loadedSources, source.name],
///     );
///   }
///
///   yield state.copyWith(loading: false);
/// }
/// ```
///
/// ### Multiple State Emissions with Emitter
///
/// ```dart
/// @event
/// Future<void> _onComplexOperation(_Emitter emit) async {
///   // Phase 1: Loading
///   emit(state.copyWith(loading: true, progress: 0.0));
///
///   // Phase 2: Fetch users
///   final users = await api.fetchUsers();
///   emit(state.copyWith(users: users, progress: 0.5));
///
///   // Phase 3: Fetch posts
///   final posts = await api.fetchPosts();
///   emit(state.copyWith(posts: posts, progress: 1.0));
///
///   // Phase 4: Complete
///   emit(state.copyWith(loading: false));
/// }
/// ```
///
/// ### Base Classes with Public Events
///
/// ```dart
/// // Base bloc with reusable events
/// abstract class AppBaseBloc<T> extends _$AppBaseBloc<AppState<T>> {
///   AppBaseBloc(AppState<T> initialState) : super(initialState);
///
///   @event
///   @protected  // Required for public events
///   AppState<T> onReset() {  // Must start with 'on'
///     return AppState(value: null);
///   }
///
///   @event
///   @protected
///   AppState<T> onSetValue(T value) {
///     return AppState(value: value);
///   }
/// }
///
/// // Child bloc can use base events
/// class CounterBloc extends AppBaseBloc<int> {
///   CounterBloc() : super(AppState(value: 0));
///
///   @event
///   AppState<int> _onIncrement() => AppState(value: state.value! + 1);
///
///   void reset() => onReset();  // Call base event
/// }
/// ```
///
/// ### Combining Multiple Features
///
/// ```dart
/// // Define actions in a private mixin
/// @MonoActions()
/// mixin _TodoBlocActions {
///   void showNotification(String message);
/// }
///
/// // The generated base class includes the actions mixin automatically
/// @AsyncMonoBloc(MonoConcurrency.restartable)
/// class TodoBloc extends _$TodoBloc<List<Todo>> {
///   TodoBloc() : super(const MonoAsyncValue.loading());
///
///   @onInit
///   void _onInit() {
///     loadTodos();
///   }
///
///   @event
///   Future<List<Todo>> _onLoadTodos() async {
///     return await repository.fetchTodos();
///   }
///
///   @restartableEvent
///   Stream<List<Todo>> _onSearch(String query) async* {
///     for (final source in sources) {
///       final results = await source.search(query);
///       yield results;
///     }
///   }
///
///   @event
///   Future<List<Todo>> _onAddTodo(String title) async {
///     await repository.add(Todo(title: title));
///     showNotification('Todo added');
///     return await repository.fetchTodos();
///   }
///
///   @onError
///   MonoAsyncValue<List<Todo>> _onError(Object error, StackTrace stack) {
///     showNotification('Error: $error');
///     return withError(error, stack, state.dataOrNull);
///   }
///
///   @onEvent
///   bool _onEvents(_Event event) {
///     if (state.isLoading && event is! _SearchEvent) {
///       return false;  // Block events while loading (except search)
///     }
///     return true;
///   }
/// }
/// ```
///
/// ## Type Preservation
///
/// MonoBloc preserves exact type notation from source code:
///
/// **Typedefs:**
/// ```dart
/// typedef OnComplete = void Function(bool success);
///
/// // In @MonoActions() mixin:
/// void showDialog({required String title, required OnComplete callback});
/// // Generated code preserves OnComplete, not expanded void Function(bool)
/// ```
///
/// **Records:**
/// ```dart
/// // In @MonoActions() mixin:
/// void processData((String name, int age) data);
/// // Preserves record type notation
/// ```
///
/// **Complex Generics:**
/// ```dart
/// @event
/// Future<Map<String, List<Todo>>> _onGroupByTag() async { ... }
/// // Exact generic notation preserved
/// ```
///
/// ## Shorthand Constants
///
/// ```dart
/// @event              // Same as @MonoEvent()
/// @restartableEvent   // Same as @MonoEvent(MonoConcurrency.restartable)
/// @sequentialEvent    // Same as @MonoEvent(MonoConcurrency.sequential)
/// @concurrentEvent    // Same as @MonoEvent(MonoConcurrency.concurrent)
/// @droppableEvent     // Same as @MonoEvent(MonoConcurrency.droppable)
/// @onError            // Same as @MonoOnError()
/// @MonoActions()      // Annotation for action mixins
/// ```
library;

export 'dart:async' show FutureOr, unawaited;

export 'package:bloc/bloc.dart';
export 'package:meta/meta.dart' show immutable, protected;

export 'src/actions/bloc_actions_base.dart';
export 'src/actions/mono_bloc_action_mixin.dart';

export 'src/annotations/async_mono_bloc.dart';
export 'src/annotations/constants.dart';
export 'src/annotations/error_handler.dart';
export 'src/annotations/mono_actions.dart';
export 'src/annotations/mono_bloc.dart';
export 'src/annotations/mono_concurrency.dart';
export 'src/annotations/mono_event.dart';
export 'src/annotations/mono_init.dart';
export 'src/annotations/on_event.dart';

export 'src/async/mono_async_emitter.dart';
export 'src/async/mono_async_value.dart';
export 'src/async/mono_seq_emitter.dart';

export 'src/utils/mono_bloc_transformers.dart';
export 'src/utils/mono_stack_trace.dart';
