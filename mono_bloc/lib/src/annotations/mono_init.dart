import 'package:meta/meta_meta.dart';

/// Marks a method to be called during bloc initialization.
///
/// Methods annotated with @onInit are called automatically when the bloc is created,
/// before any events are processed. This is useful for:
/// - Setting up initial state
/// - Subscribing to streams
/// - Auto-loading data
/// - Initializing dependencies
///
/// ## Basic Usage
///
/// ```dart
/// @MonoBloc()
/// class TodoBloc extends _$TodoBloc<TodoState> {
///   TodoBloc() : super(const TodoState(todos: []));
///
///   @onInit
///   void _onInit() {
///     // Called automatically when bloc is created
///     loadTodos();  // Dispatch initial load event
///   }
///
///   @event
///   Future<TodoState> _onLoadTodos() async {
///     final todos = await api.fetchTodos();
///     return state.copyWith(todos: todos);
///   }
/// }
/// ```
///
/// ## Multiple Init Methods
///
/// You can have multiple @onInit methods. They are called in the order they appear:
///
/// ```dart
/// @MonoBloc()
/// class AppBloc extends _$AppBloc<AppState> {
///   @onInit
///   void _initializeAnalytics() {
///     analytics.initialize();
///   }
///
///   @onInit
///   void _loadUserData() {
///     loadUser();
///   }
///
///   @onInit
///   void _subscribeToNotifications() {
///     _notificationStream = notificationService.stream.listen((notification) {
///       showNotification(notification);
///     });
///   }
/// }
/// ```
///
/// ## Auto-loading Data
///
/// A common pattern is to dispatch events from init methods:
///
/// ```dart
/// @MonoBloc()
/// class UserBloc extends _$UserBloc<UserState> {
///   UserBloc() : super(const UserState.loading());
///
///   @onInit
///   void _onInit() {
///     // Automatically load user when bloc is created
///     loadCurrentUser();
///   }
///
///   @event
///   Future<UserState> _onLoadCurrentUser() async {
///     final user = await authService.getCurrentUser();
///     return UserState.loaded(user);
///   }
/// }
/// ```
///
/// ## Stream Subscriptions
///
/// Init methods are perfect for setting up stream subscriptions:
///
/// ```dart
/// @MonoBloc()
/// class ChatBloc extends _$ChatBloc<ChatState> {
///   ChatBloc(this.chatService) : super(const ChatState(messages: []));
///
///   final ChatService chatService;
///   StreamSubscription? _messageSubscription;
///
///   @onInit
///   void _onInit() {
///     // Subscribe to incoming messages
///     _messageSubscription = chatService.messageStream.listen((message) {
///       addMessage(message);
///     });
///   }
///
///   @event
///   ChatState _onAddMessage(Message message) {
///     return state.copyWith(
///       messages: [...state.messages, message],
///     );
///   }
///
///   @override
///   Future<void> close() {
///     _messageSubscription?.cancel();
///     return super.close();
///   }
/// }
/// ```
///
/// ## Initialization with Parameters
///
/// Init methods don't accept parameters. If you need to pass initialization data,
/// use constructor parameters and dispatch events:
///
/// ```dart
/// @MonoBloc()
/// class ProductBloc extends _$ProductBloc<ProductState> {
///   ProductBloc(this.categoryId) : super(const ProductState.loading());
///
///   final String categoryId;
///
///   @onInit
///   void _onInit() {
///     // Use constructor parameter in event
///     loadProducts(categoryId);
///   }
///
///   @event
///   Future<ProductState> _onLoadProducts(String category) async {
///     final products = await api.fetchProducts(category);
///     return ProductState.loaded(products);
///   }
/// }
/// ```
///
/// ## Accessing State
///
/// Init methods have access to the initial state:
///
/// ```dart
/// @MonoBloc()
/// class ConfigBloc extends _$ConfigBloc<ConfigState> {
///   ConfigBloc() : super(const ConfigState(initialized: false));
///
///   @onInit
///   void _onInit() {
///     if (!state.initialized) {
///       initialize();
///   }
///   }
///
///   @event
///   Future<ConfigState> _onInitialize() async {
///     final config = await configService.load();
///     return ConfigState(initialized: true, config: config);
///   }
/// }
/// ```
///
/// ## Lifecycle
///
/// Init methods are called in this order:
/// 1. Bloc constructor runs
/// 2. Initial state is set
/// 3. @onInit methods are called (in declaration order)
/// 4. Event handlers are registered
/// 5. Bloc is ready to receive events
///
/// ## Return Types
///
/// Init methods should return `void`. They cannot return values or futures:
///
/// ```dart
/// // CORRECT
/// @onInit
/// void _onInit() {
///   loadData();
/// }
///
/// // WRONG - don't await or return
/// @onInit
/// Future<void> _onInit() async {
///   await loadData();  // Just call loadData() instead
/// }
/// ```
///
/// ## Common Patterns
///
/// ### Auto-refresh Timer
/// ```dart
/// @MonoBloc()
/// class DashboardBloc extends _$DashboardBloc<DashboardState> {
///   Timer? _refreshTimer;
///
///   @onInit
///   void _onInit() {
///     // Load initial data
///     loadDashboard();
///
///     // Set up auto-refresh
///     _refreshTimer = Timer.periodic(
///       Duration(minutes: 5),
///       (_) => refresh(),
///     );
///   }
///
///   @override
///   Future<void> close() {
///     _refreshTimer?.cancel();
///     return super.close();
///   }
/// }
/// ```
///
/// ### Conditional Initialization
/// ```dart
/// @MonoBloc()
/// class AuthBloc extends _$AuthBloc<AuthState> {
///   AuthBloc(this.storage) : super(const AuthState.unauthenticated());
///
///   final SecureStorage storage;
///
///   @onInit
///   void _onInit() async {
///     final token = await storage.getToken();
///     if (token != null) {
///       validateToken(token);
///     }
///   }
/// }
/// ```
///
/// See also:
/// - [@event] for event handlers that init methods typically dispatch
/// - [@MonoBloc] for bloc configuration
@Target({TargetKind.method})
final class MonoInit {
  /// Creates a MonoInit annotation for marking initialization methods.
  const MonoInit();
}
