import 'package:meta/meta_meta.dart';
import 'package:mono_bloc/src/annotations/mono_concurrency.dart';

/// Marks a class for MonoBloc code generation.
///
/// MonoBloc generates a BLoC with simplified event handling, automatic state management,
/// and advanced concurrency control. Methods annotated with [@event] become event handlers
/// with auto-generated public dispatch methods.
///
/// ## Basic Usage
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
/// }
/// ```
///
/// This generates:
/// - Event classes: `_IncrementEvent`, `_DecrementEvent`
/// - Public methods: `increment()`, `decrement()`
/// - Base class: `_$CounterBloc<int>`
///
/// ## Generated Code Structure
///
/// The generator creates:
///
/// 1. **Event Classes**: Sealed event hierarchy with stack trace capture
/// 2. **Base Class**: `_$YourBloc<State>` with event handling setup
/// 3. **Public Methods**: Clean API for dispatching events
/// 4. **Type Aliases**: `_Event`, `_State`, `_Emitter` for type safety
///
/// ## Sequential Mode
///
/// Process events one at a time in order. Useful for operations that must
/// complete sequentially (e.g., database transactions, state machines).
///
/// ```dart
/// @MonoBloc(sequential: true)
/// class BankAccountBloc extends _$BankAccountBloc<BankAccountState> {
///   BankAccountBloc() : super(const BankAccountState(balance: 0));
///
///   @event
///   Future<BankAccountState> _onDeposit(double amount) async {
///     await Future.delayed(Duration(seconds: 1)); // Simulates API call
///     return state.copyWith(balance: state.balance + amount);
///   }
///
///   @event
///   Future<BankAccountState> _onWithdraw(double amount) async {
///     if (state.balance < amount) {
///       throw InsufficientFundsException();
///     }
///     return state.copyWith(balance: state.balance - amount);
///   }
///
///   @restartableEvent  // Explicit concurrency bypasses sequential queue
///   Future<BankAccountState> _onRefresh() async {
///     final balance = await api.fetchBalance();
///     return state.copyWith(balance: balance);
///   }
/// }
/// ```
///
/// In sequential mode:
/// - Events without explicit concurrency are queued and processed one at a time
/// - Events with `@restartableEvent`, `@droppableEvent`, etc. bypass the queue
/// - Guarantees operations complete in dispatch order
///
/// ## Default Concurrency
///
/// Set a default concurrency mode for all events when not using sequential mode.
///
/// ```dart
/// @MonoBloc(concurrency: MonoConcurrency.restartable)
/// class SearchBloc extends _$SearchBloc<SearchState> {
///   SearchBloc() : super(const SearchState());
///
///   @event  // Uses restartable (from default)
///   Future<SearchState> _onSearch(String query) async {
///     final results = await api.search(query);
///     return state.copyWith(results: results, query: query);
///   }
///
///   @droppableEvent  // Explicit override: uses droppable instead
///   Future<SearchState> _onLoadMore() async {
///     final more = await api.loadMore(state.page + 1);
///     return state.copyWith(
///       results: [...state.results, ...more],
///       page: state.page + 1,
///     );
///   }
/// }
/// ```
///
/// ## Event Methods
///
/// Event handler methods can:
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
/// Future<CounterState> _onIncrementAsync() async {
///   await Future.delayed(Duration(seconds: 1));
///   return state.copyWith(count: state.count + 1);
/// }
/// ```
///
/// ### Accept Parameters
/// ```dart
/// @event
/// CounterState _onAdd(int value) {
///   return state.copyWith(count: state.count + value);
/// }
/// // Generates: bloc.add(5)
/// ```
///
/// ### Use Emitter for Multiple States
/// ```dart
/// @event
/// Future<void> _onLoadData(_Emitter emit) async {
///   emit(state.copyWith(loading: true));
///   final data = await api.fetchData();
///   emit(state.copyWith(loading: false, data: data));
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
/// ## Public vs Private Events
///
/// ### Private Events (Recommended)
/// ```dart
/// @event
/// MyState _onDoSomething() => state;  // Generates: bloc.doSomething()
/// ```
///
/// ### Public Events (Advanced)
/// For base classes that will be extended:
///
/// ```dart
/// @event
/// @protected
/// AppState<T> onMultiply(int factor) {
///   return state.copyWith(value: state.value * factor);
/// }
/// // Must start with 'on' and have @protected
/// ```
///
/// ## Integration with Other Features
///
/// ### With Error Handlers
/// ```dart
/// @MonoBloc(sequential: true)
/// class MyBloc extends _$MyBloc<MyState> {
///   @event
///   Future<MyState> _onRiskyOperation() async { ... }
///
///   @onError
///   MyState _onError(Object error, StackTrace stack) {
///     return state.copyWith(error: error.toString());
///   }
/// }
/// ```
///
/// ### With Actions (Side Effects)
/// ```dart
/// // Actions must be defined in a private mixin with @MonoActions()
/// @MonoActions()
/// mixin _MyBlocActions {
///   void showSuccessDialog(String message);
/// }
///
/// // The generated base class includes the actions mixin automatically
/// @MonoBloc()
/// class MyBloc extends _$MyBloc<MyState> {
///   MyBloc() : super(MyState.initial());
///
///   @event
///   Future<MyState> _onSubmit() async {
///     final success = await api.submit();
///     if (success) {
///       showSuccessDialog('Submitted!');
///     }
///     return state.copyWith(submitted: success);
///   }
/// }
/// ```
///
/// ### With Event Queues
/// ```dart
/// const uploadQueue = 'upload';
/// const downloadQueue = 'download';
///
/// @MonoBloc()
/// class FileBloc extends _$FileBloc<FileState> {
///   @MonoEvent.queue(uploadQueue)  // Upload queue
///   Future<FileState> _onUpload(File file) async { ... }
///
///   @MonoEvent.queue(downloadQueue)  // Download queue
///   Future<FileState> _onDownload(String url) async { ... }
/// }
/// ```
///
/// ## Requirements
///
/// Your file must include:
///
/// ```dart
/// import 'package:bloc/bloc.dart';
/// import 'package:mono_bloc/mono_bloc.dart';
///
/// part 'your_bloc.g.dart';  // Generated code
///
/// @MonoBloc()
/// class YourBloc extends _$YourBloc<YourState> {
///   YourBloc() : super(initialState);
/// }
/// ```
///
/// See also:
/// - [@event] for marking event handler methods
/// - [@AsyncMonoBloc] for async state management
/// - [MonoConcurrency] for concurrency modes
@Target({TargetKind.classType})
final class MonoBloc {
  /// When `true`, all simple @event methods (without explicit concurrency) are grouped
  /// into a single sequential queue and processed one at a time in order.
  ///
  /// Methods with explicit concurrency (`@restartableEvent`, `@droppableEvent`, etc.)
  /// are registered individually and bypass the sequential queue.
  ///
  /// **Default:** `false` (concurrent processing)
  ///
  /// **Example:**
  /// ```dart
  /// @MonoBloc(sequential: true)
  /// class BankBloc extends _$BankBloc<BankState> {
  ///   @event deposit() { ... }        // → queued sequentially
  ///   @event withdraw() { ... }       // → queued sequentially
  ///   @restartableEvent check() { ... } // → individual, bypasses queue
  /// }
  /// ```
  final bool sequential;

  /// Default concurrency mode for simple @event methods when [sequential] is `false`.
  ///
  /// When [sequential] is `true`, this is ignored for simple events (they use the sequential queue).
  /// Events with explicit concurrency annotations always use their specified mode.
  ///
  /// **Default:** `null` (uses MonoBloc's default concurrent behavior)
  ///
  /// **Example:**
  /// ```dart
  /// @MonoBloc(concurrency: MonoConcurrency.restartable)
  /// class MyBloc extends _$MyBloc<MyState> {
  ///   @event fetch() { ... }          // → uses restartable (from default)
  ///   @droppableEvent refresh() { ... } // → uses droppable (explicit override)
  /// }
  /// ```
  final MonoConcurrency? concurrency;

  /// Creates a MonoBloc annotation with optional sequential mode and concurrency.
  const MonoBloc({this.sequential = false, this.concurrency});
}
