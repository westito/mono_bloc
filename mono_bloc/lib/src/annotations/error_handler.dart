import 'package:meta/meta_meta.dart';
import 'package:mono_bloc/mono_bloc.dart' show MonoStackTrace;
import 'package:mono_bloc/src/utils/mono_stack_trace.dart' show MonoStackTrace;

/// Marks a method as an error handler for event errors.
///
/// Error handlers are automatically called when event methods throw exceptions.
/// MonoBloc provides detailed stack traces that combine both the event dispatch
/// location and the error location, making debugging easier.
///
/// ## Basic Error Handler
///
/// Use `_onError` for a general error handler that catches all event errors:
///
/// ```dart
/// @MonoBloc()
/// class TodoBloc extends _$TodoBloc<TodoState> {
///   @event
///   Future<TodoState> _onLoadTodos() async {
///     // If this throws, _onError is called
///     final todos = await api.fetchTodos();
///     return state.copyWith(todos: todos);
///   }
///
///   @onError
///   TodoState _onError(Object error, StackTrace stack) {
///     print('Error: $error');
///     print('Stack: $stack');
///     return state.copyWith(error: error.toString());
///   }
/// }
/// ```
///
/// ## Event-Specific Error Handlers
///
/// Use `_onError<EventName>` to handle errors for specific events:
///
/// ```dart
/// @MonoBloc()
/// class UserBloc extends _$UserBloc<UserState> {
///   @event
///   Future<UserState> _onLoadUser(String id) async {
///     final user = await api.fetchUser(id);
///     return state.copyWith(user: user);
///   }
///
///   @event
///   Future<UserState> _onSaveUser(User user) async {
///     await api.saveUser(user);
///     return state.copyWith(user: user);
///   }
///
///   // Specific handler for loadUser errors
///   @onError
///   UserState _onErrorLoadUser(Object error, StackTrace stack) {
///     return state.copyWith(
///       error: 'Failed to load user: ${error.toString()}',
///     );
///   }
///
///   // Specific handler for saveUser errors
///   @onError
///   UserState _onErrorSaveUser(Object error, StackTrace stack) {
///     return state.copyWith(
///       error: 'Failed to save user: ${error.toString()}',
///       saveInProgress: false,
///     );
///   }
///
///   // General fallback for other errors
///   @onError
///   UserState _onError(Object error, StackTrace stack) {
///     return state.copyWith(error: 'An error occurred');
///   }
/// }
/// ```
///
/// ## Handler Priority
///
/// When an error occurs, MonoBloc looks for handlers in this order:
/// 1. Event-specific handler (`_onError<EventName>`)
/// 2. General handler (`_onError`)
/// 3. Default behavior (rethrow error)
///
/// ## Method Signatures
///
/// Error handlers support flexible parameter combinations:
///
/// ### Error and Stack Trace
/// ```dart
/// @onError
/// MyState _onError(Object error, StackTrace stack) {
///   return state.copyWith(error: error.toString());
/// }
/// ```
///
/// ### Error Only
/// ```dart
/// @onError
/// MyState _onError(Object error) {
///   return state.copyWith(error: error.toString());
/// }
/// ```
///
/// ### With Event Reference
/// ```dart
/// @onError
/// MyState _onError(Object error, StackTrace stack, _Event event) {
///   print('Error in event: ${event.runtimeType}');
///   return state.copyWith(error: error.toString());
/// }
/// ```
///
/// ### With Emitter
/// ```dart
/// @onError
/// void _onError(Object error, _Emitter emit) {
///   emit(state.copyWith(error: error.toString()));
/// }
/// ```
///
/// ### Return void (No State Change)
/// ```dart
/// @onError
/// void _onError(Object error, StackTrace stack) {
///   // Just log, don't change state
///   logger.error('Event failed', error, stack);
/// }
/// ```
///
/// ## Return Types
///
/// Error handlers must be **synchronous** and can return:
///
/// ### State (Synchronous Recovery)
/// ```dart
/// @onError
/// MyState _onError(Object error) {
///   return state.copyWith(error: error.toString());
/// }
/// ```
///
/// ### Nullable State (Optional Recovery)
/// ```dart
/// @onError
/// MyState? _onError(Object error) {
///   if (error is NetworkException) {
///     return state.copyWith(offline: true);
///   }
///   return null;  // Don't emit state for other errors
/// }
/// ```
///
/// ### void (No State Change)
/// ```dart
/// @onError
/// void _onError(Object error, StackTrace stack) {
///   crashlytics.recordError(error, stack);
/// }
/// ```
///
/// **Note:** Error handlers cannot be async (`Future<State>` is not allowed).
/// They must return the state synchronously to ensure immediate error recovery.
///
/// ## Stack Trace Filtering
///
/// MonoBloc automatically filters stack traces to show only relevant frames:
///
/// ```dart
/// @onError
/// void _onError(Object error, StackTrace stack) {
///   // Stack trace combines:
///   // 1. Where the event was dispatched (user action)
///   // 2. Where the error occurred (implementation)
///   // Filtered to remove framework noise
///   print(stack);
/// }
/// ```
///
/// ## Error Recovery Patterns
///
/// ### Retry with Exponential Backoff
/// ```dart
/// @MonoBloc()
/// class DataBloc extends _$DataBloc<DataState> {
///   int _retryCount = 0;
///
///   @event
///   Future<DataState> _onLoad() async {
///     final data = await api.fetchData();
///     _retryCount = 0;  // Reset on success
///     return state.copyWith(data: data);
///   }
///
///   @onError
///   DataState _onErrorLoad(Object error) {
///     if (_retryCount < 3) {
///       _retryCount++;
///       // Schedule retry (error handlers must be sync)
///       Future.delayed(Duration(seconds: _retryCount * 2), load);
///       return state.copyWith(retrying: true);
///     }
///     return state.copyWith(error: 'Failed after 3 retries');
///   }
/// }
/// ```
///
/// ### Fallback to Default State
/// ```dart
/// @onError
/// UserState _onErrorLoadUser(Object error) {
///   // Return a default/empty state when loading fails
///   return state.copyWith(
///     user: null,
///     error: 'Failed to load user: $error',
///   );
/// }
/// ```
///
/// ### Different Handling by Error Type
/// ```dart
/// @onError
/// MyState _onError(Object error, StackTrace stack) {
///   if (error is NetworkException) {
///     return state.copyWith(offline: true);
///   } else if (error is AuthException) {
///     return state.copyWith(needsReauth: true);
///   } else if (error is ValidationException) {
///     return state.copyWith(validationErrors: error.errors);
///   } else {
///     return state.copyWith(error: 'An unexpected error occurred');
///   }
/// }
/// ```
///
/// ## With AsyncMonoBloc
///
/// Error handlers work seamlessly with async blocs:
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
/// ## Complete Example
///
/// ```dart
/// @MonoBloc()
/// class PaymentBloc extends _$PaymentBloc<PaymentState> {
///   PaymentBloc(this.analytics) : super(const PaymentState.initial());
///
///   final Analytics analytics;
///
///   @event
///   Future<PaymentState> _onProcessPayment(PaymentDetails details) async {
///     final result = await paymentService.process(details);
///     return PaymentState.success(result);
///   }
///
///   @event
///   Future<PaymentState> _onRefund(String transactionId) async {
///     await paymentService.refund(transactionId);
///     return PaymentState.refunded();
///   }
///
///   // Specific handler for payment processing errors
///   @onError
///   PaymentState _onErrorProcessPayment(
///     Object error,
///     StackTrace stack,
///   ) {
///     // Log asynchronously (fire-and-forget)
///     analytics.logError('payment_failed', error);
///
///     if (error is InsufficientFundsException) {
///       return PaymentState.failed('Insufficient funds');
///     } else if (error is CardDeclinedException) {
///       return PaymentState.failed('Card declined');
///     }
///
///     return PaymentState.failed('Payment failed');
///   }
///
///   // Specific handler for refund errors
///   @onError
///   PaymentState _onErrorRefund(Object error) {
///     // Log asynchronously (fire-and-forget)
///     analytics.logError('refund_failed', error);
///     return PaymentState.failed('Refund failed');
///   }
///
///   // General handler for other errors
///   @onError
///   void _onError(Object error, StackTrace stack) {
///     analytics.logError('unknown_error', error);
///     crashlytics.recordError(error, stack);
///   }
/// }
/// ```
///
/// ## Best Practices
///
/// 1. **Log errors** for debugging and monitoring
/// 2. **Preserve user data** when possible (especially in async blocs)
/// 3. **Use event-specific handlers** for better error messages
/// 4. **Don't swallow errors** - at minimum log them
/// 5. **Consider retry logic** for transient failures
/// 6. **Test error paths** - they're often overlooked
///
/// See also:
/// - [@event] for event methods that can throw errors
/// - [@MonoBloc] for bloc configuration
/// - [MonoStackTrace] for filtered stack traces
@Target({TargetKind.method})
final class MonoOnError {
  /// Creates a MonoOnError annotation for marking error handler methods.
  const MonoOnError();
}
