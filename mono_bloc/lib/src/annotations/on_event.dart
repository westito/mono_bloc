import 'package:meta/meta_meta.dart';

/// Marks a method as an event interceptor that runs before event processing.
///
/// Event interceptors can observe, log, or filter events before they reach handlers.
/// They return `bool` to indicate whether the event should proceed (`true`) or be
/// blocked (`false`).
///
/// ## Basic Event Interceptor
///
/// ```dart
/// @MonoBloc()
/// class TodoBloc extends _$TodoBloc<TodoState> {
///   @event
///   TodoState _onAddTodo(String title) {
///     final todo = Todo(title: title);
///     return state.copyWith(todos: [...state.todos, todo]);
///   }
///
///   @onEvent
///   bool _onEvents(_Event event) {
///     print('Event dispatched: ${event.runtimeType}');
///     return true;  // Allow all events
///   }
/// }
/// ```
///
/// ## Filtering Events
///
/// Block events based on conditions:
///
/// ```dart
/// @MonoBloc()
/// class GameBloc extends _$GameBloc<GameState> {
///   @event
///   GameState _onMove(int x, int y) {
///     return state.copyWith(position: Point(x, y));
///   }
///
///   @event
///   GameState _onAttack() {
///     return state.copyWith(attacking: true);
///   }
///
///   @onEvent
///   bool _onEvents(_Event event) {
///     // Block all events if game is paused
///     if (state.isPaused) {
///       print('Event blocked: ${event.runtimeType} (game paused)');
///       return false;
///     }
///
///     // Block attack if on cooldown
///     if (event is _AttackEvent && state.attackCooldown > 0) {
///       print('Attack blocked: on cooldown');
///       return false;
///     }
///
///     return true;
///   }
/// }
/// ```
///
/// ## Method Signatures
///
/// OnEvent handlers support flexible parameters:
///
/// ### Event Only
/// ```dart
/// @onEvent
/// bool _onEvents(_Event event) {
///   print('Event: ${event.runtimeType}');
///   return true;
/// }
/// ```
///
/// ### With Emitter
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
/// ### Emitter Only
/// ```dart
/// @onEvent
/// bool _onEvents(_Emitter emit) {
///   // Track all events
///   emit(state.copyWith(eventCount: state.eventCount + 1));
///   return true;
/// }
/// ```
///
/// ## Use Cases
///
/// ### Event Logging
/// ```dart
/// @MonoBloc()
/// class AnalyticsBloc extends _$AnalyticsBloc<AnalyticsState> {
///   AnalyticsBloc(this.analytics) : super(const AnalyticsState());
///
///   final Analytics analytics;
///
///   @onEvent
///   bool _onEvents(_Event event) {
///     // Log all events to analytics
///     analytics.logEvent(event.runtimeType.toString());
///     return true;
///   }
/// }
/// ```
///
/// ### Rate Limiting
/// ```dart
/// @MonoBloc()
/// class ApiBloc extends _$ApiBloc<ApiState> {
///   DateTime? _lastRequestTime;
///
///   @event
///   Future<ApiState> _onFetchData() async {
///     final data = await api.fetch();
///     return state.copyWith(data: data);
///   }
///
///   @onEvent
///   bool _onEvents(_Event event) {
///     if (event is _FetchDataEvent) {
///       final now = DateTime.now();
///       if (_lastRequestTime != null &&
///           now.difference(_lastRequestTime!) < Duration(seconds: 1)) {
///         print('Request blocked: rate limit');
///         return false;  // Too soon, block it
///       }
///       _lastRequestTime = now;
///     }
///     return true;
///   }
/// }
/// ```
///
/// ### Permission Checks
/// ```dart
/// @MonoBloc()
/// class DocumentBloc extends _$DocumentBloc<DocumentState> {
///   DocumentBloc(this.authService) : super(const DocumentState());
///
///   final AuthService authService;
///
///   @event
///   Future<DocumentState> _onDelete(String id) async {
///     await api.deleteDocument(id);
///     return state.copyWith(
///       documents: state.documents.where((d) => d.id != id).toList(),
///     );
///   }
///
///   @onEvent
///   bool _onEvents(_Event event) {
///     // Block delete events if user lacks permission
///     if (event is _DeleteEvent && !authService.canDelete) {
///       print('Delete blocked: insufficient permissions');
///       return false;
///     }
///     return true;
///   }
/// }
/// ```
///
/// ### Pre-loading State
/// ```dart
/// @MonoBloc()
/// class DataBloc extends _$DataBloc<DataState> {
///   @event
///   Future<DataState> _onLoadDetails(String id) async {
///     final details = await api.fetchDetails(id);
///     return state.copyWith(details: details, loading: false);
///   }
///
///   @onEvent
///   bool _onEvents(_Event event, _Emitter emit) {
///     // Set loading state before the event handler runs
///     if (event is _LoadDetailsEvent) {
///       emit(state.copyWith(loading: true));
///     }
///     return true;
///   }
/// }
/// ```
///
/// ### Event Count Tracking
/// ```dart
/// @MonoBloc()
/// class StatsBloc extends _$StatsBloc<StatsState> {
///   @onEvent
///   bool _onEvents(_Event event, _Emitter emit) {
///     // Track event statistics
///     final eventType = event.runtimeType.toString();
///     final counts = Map<String, int>.from(state.eventCounts);
///     counts[eventType] = (counts[eventType] ?? 0) + 1;
///
///     emit(state.copyWith(
///       eventCounts: counts,
///       totalEvents: state.totalEvents + 1,
///     ));
///
///     return true;
///   }
/// }
/// ```
///
/// ### Conditional Processing
/// ```dart
/// @MonoBloc()
/// class FormBloc extends _$FormBloc<FormState> {
///   @event
///   FormState _onSubmit() {
///     return state.copyWith(submitted: true);
///   }
///
///   @event
///   FormState _onUpdateField(String field, String value) {
///     return state.copyWith(
///       fields: {...state.fields, field: value},
///     );
///   }
///
///   @onEvent
///   bool _onEvents(_Event event) {
///     // Block all events if form is submitted
///     if (state.submitted) {
///       print('Event blocked: form already submitted');
///       return false;
///     }
///
///     // Block submit if form is invalid
///     if (event is _SubmitEvent && !state.isValid) {
///       print('Submit blocked: form invalid');
///       return false;
///     }
///
///     return true;
///   }
/// }
/// ```
///
/// ## Multiple Interceptors
///
/// You can have multiple @onEvent handlers. All must return `true` for the event
/// to proceed:
///
/// ```dart
/// @MonoBloc()
/// class SecureBloc extends _$SecureBloc<SecureState> {
///   @onEvent
///   bool _logEvents(_Event event) {
///     logger.log('Event: ${event.runtimeType}');
///     return true;
///   }
///
///   @onEvent
///   bool _checkPermissions(_Event event) {
///     if (event is _DeleteEvent && !hasDeletePermission) {
///       return false;
///     }
///     return true;
///   }
///
///   @onEvent
///   bool _rateLimit(_Event event) {
///     return !_isRateLimited();
///   }
/// }
/// ```
///
/// ## Stack Trace Access
///
/// Events capture stack traces at dispatch time, available in handlers:
///
/// ```dart
/// @onEvent
/// bool _onEvents(_Event event) {
///   // Event has a 'trace' property showing where it was dispatched
///   print('Event dispatched from:');
///   print(event.trace);
///   return true;
/// }
/// ```
///
/// ## Best Practices
///
/// 1. **Keep it fast** - Interceptors run before every event
/// 2. **Return quickly** - Don't perform slow operations
/// 3. **Be defensive** - Check conditions carefully before blocking
/// 4. **Log blocked events** - Help debugging when events are filtered
/// 5. **Use for cross-cutting concerns** - Logging, analytics, permissions
/// 6. **Don't mutate state directly** - Use emitter if you need to emit
///
/// ## Common Pitfalls
///
/// ### ❌ Blocking All Events
/// ```dart
/// @onEvent
/// bool _onEvents(_Event event) {
///   return false;  // Oops! Blocks everything
/// }
/// ```
///
/// ### ❌ Slow Operations
/// ```dart
/// @onEvent
/// bool _onEvents(_Event event) async {
///   await Future.delayed(Duration(seconds: 1));  // Don't do this!
///   return true;
/// }
/// ```
///
/// ### ✅ Fast Checks
/// ```dart
/// @onEvent
/// bool _onEvents(_Event event) {
///   if (!_canProceed(event)) {
///     logger.warn('Event blocked: ${event.runtimeType}');
///     return false;
///   }
///   return true;
/// }
///
/// bool _canProceed(_Event event) {
///   // Fast synchronous checks only
///   return !state.isLocked && _hasPermission(event);
/// }
/// ```
///
/// ## Integration Example
///
/// ```dart
/// @MonoBloc()
/// class ChatBloc extends _$ChatBloc<ChatState> {
///   ChatBloc(this.analytics) : super(const ChatState());
///
///   final Analytics analytics;
///   DateTime? _lastMessageTime;
///
///   @event
///   ChatState _onSendMessage(String text) {
///     final message = Message(text: text, timestamp: DateTime.now());
///     return state.copyWith(
///       messages: [...state.messages, message],
///     );
///   }
///
///   @event
///   ChatState _onTyping() {
///     return state.copyWith(isTyping: true);
///   }
///
///   @onEvent
///   bool _onEvents(_Event event, _Emitter emit) {
///     // Log all events
///     analytics.logEvent(event.runtimeType.toString());
///
///     // Rate limit messages (max 1 per second)
///     if (event is _SendMessageEvent) {
///       final now = DateTime.now();
///       if (_lastMessageTime != null &&
///           now.difference(_lastMessageTime!) < Duration(seconds: 1)) {
///         emit(state.copyWith(error: 'Please slow down'));
///         return false;
///       }
///       _lastMessageTime = now;
///     }
///
///     // Block all events if banned
///     if (state.isBanned) {
///       emit(state.copyWith(error: 'You are banned'));
///       return false;
///     }
///
///     return true;
///   }
/// }
/// ```
///
/// See also:
/// - [@event] for event methods
/// - [@onError] for error handling
/// - [@MonoBloc] for bloc configuration
@Target({TargetKind.method})
final class MonoOnEvent {
  /// Creates a MonoOnEvent annotation for marking event interceptor methods.
  const MonoOnEvent();
}
