/// Defines how events are processed when multiple events are dispatched.
///
/// MonoBloc provides four concurrency modes to handle event processing:
///
/// ## Sequential
/// Events are queued and processed one at a time in order. The next event waits
/// for the current one to complete before starting.
///
/// **Use Case:** Operations that must complete in order (e.g., database transactions).
///
/// ```dart
/// @MonoBloc(sequential: true)  // All events sequential by default
/// class BankBloc extends _$BankBloc<BankState> {
///   @event
///   Future<BankState> _onDeposit(double amount) async { ... }
///
///   @event
///   Future<BankState> _onWithdraw(double amount) async { ... }
/// }
/// ```
///
/// ## Concurrent
/// Events are processed in parallel. Multiple events can be running at the same time.
///
/// **Use Case:** Independent operations that don't interfere (e.g., loading different data).
///
/// ```dart
/// @MonoBloc()  // Concurrent by default
/// class DataBloc extends _$DataBloc<DataState> {
///   @event
///   Future<DataState> _onLoadUsers() async { ... }
///
///   @event
///   Future<DataState> _onLoadPosts() async { ... }
/// }
/// ```
///
/// ## Restartable
/// When a new event arrives, any ongoing event is cancelled and the new one starts.
///
/// **Use Case:** Search/filter operations where only the latest matters.
///
/// ```dart
/// class SearchBloc extends _$SearchBloc<SearchState> {
///   @restartableEvent  // or @event(MonoConcurrency.restartable)
///   Future<SearchState> _onSearch(String query) async {
///     // If user types again, this cancels and restarts with new query
///     final results = await searchApi.search(query);
///     return state.copyWith(results: results);
///   }
/// }
/// ```
///
/// ## Droppable
/// New events are ignored while an event is still processing. Only processes
/// one at a time, but drops subsequent events instead of queuing them.
///
/// **Use Case:** Rate-limiting user actions (e.g., preventing double-submit).
///
/// ```dart
/// class FormBloc extends _$FormBloc<FormState> {
///   @droppableEvent  // or @event(MonoConcurrency.droppable)
///   Future<FormState> _onSubmit() async {
///     // If user clicks submit again, ignore it until this completes
///     await api.submitForm(state.data);
///     return state.copyWith(submitted: true);
///   }
/// }
/// ```
///
/// ## Comparison Table
///
/// | Mode | New Event While Processing | Use Case |
/// |------|---------------------------|----------|
/// | Sequential | Queued | Ordered operations |
/// | Concurrent | Runs in parallel | Independent operations |
/// | Restartable | Cancels current, starts new | Search, filters |
/// | Droppable | Ignored | Rate limiting |
enum MonoConcurrency {
  /// Events are queued and processed one at a time in order.
  ///
  /// The next event waits for the current one to complete before starting.
  /// Guarantees events complete in the order they were dispatched.
  sequential,

  /// Events are processed in parallel without waiting for each other.
  ///
  /// Multiple events can run simultaneously. Use when events are independent
  /// and don't need to wait for each other.
  concurrent,

  /// New events cancel any ongoing event and start fresh.
  ///
  /// Perfect for operations where only the latest result matters, like search
  /// queries or filters. Previous operations are cancelled when a new one starts.
  restartable,

  /// New events are ignored while an event is processing.
  ///
  /// Only one event runs at a time. Additional events dispatched during processing
  /// are dropped. Useful for preventing double-submissions or rate-limiting.
  droppable,
}
