import 'package:meta/meta_meta.dart';

/// Marks a mixin as containing action methods for MonoBloc.
///
/// Actions are side-effect methods that don't modify bloc state, such as
/// navigation, showing dialogs, triggering analytics, or displaying notifications.
/// They're dispatched through a separate `actions` stream for handling in the UI layer.
///
/// ## Requirements
///
/// 1. The mixin must be private (name starts with `_`)
/// 2. All **abstract** `void` methods in the mixin are treated as actions (no need for individual annotations)
/// 3. Methods with a body are ignored and are not treated as actions
/// 4. Action methods must return `void`
///
/// The generator automatically:
/// - Detects the actions mixin by looking for `@MonoActions()` annotation
/// - Mixes the actions mixin into the generated base class
/// - Generates action implementations and the actions stream
///
/// ## Basic Usage
///
/// ```dart
/// import 'package:mono_bloc/mono_bloc.dart';
///
/// part 'checkout_bloc.g.dart';
///
/// // 1. Define actions in a private mixin with @MonoActions()
/// @MonoActions()
/// mixin _CheckoutActions {
///   void navigateToConfirmation(String orderId);
///   void showNotification(String message, NotificationType type);
///   void trackAnalyticsEvent(String eventName, Map<String, dynamic> properties);
/// }
///
/// // 2. Bloc class - the generated base class includes the actions mixin
/// @MonoBloc()
/// class CheckoutBloc extends _$CheckoutBloc<CheckoutState> {
///   CheckoutBloc() : super(CheckoutState());
///
///   @event
///   Future<CheckoutState> _onSubmitOrder(Order order) async {
///     final orderId = await repository.submitOrder(order);
///
///     // Call actions directly - they're mixed in by the generator
///     trackAnalyticsEvent('order_submitted', {'orderId': orderId});
///     navigateToConfirmation(orderId);
///     showNotification('Order submitted!', NotificationType.success);
///
///     return state.copyWith(isProcessing: false);
///   }
/// }
/// ```
///
/// ## Naming Convention
///
/// The mixin name should follow this pattern:
/// - Must start with `_` (private)
/// - Should end with `Actions` (recommended)
/// - Example: `_RegistrationActions`, `_CartActions`, `_AuthActions`
///
/// The generated interface class removes the underscore:
/// - `_RegistrationActions` → `RegistrationActions`
/// - `_CartActions` → `CartActions`
///
/// ## Flutter Usage
///
/// For Flutter projects, use `MonoBlocActionListener` widget:
///
/// ```dart
/// MonoBlocActionListener<CheckoutBloc>(
///   actions: CheckoutActions.when(
///     navigateToConfirmation: (context, orderId) {
///       Navigator.pushNamed(context, '/confirmation', arguments: orderId);
///     },
///     showNotification: (context, message, type) {
///       ScaffoldMessenger.of(context).showSnackBar(
///         SnackBar(content: Text(message)),
///       );
///     },
///     trackAnalyticsEvent: (context, eventName, properties) {
///       analytics.track(eventName, properties);
///     },
///   ),
///   child: CheckoutPage(),
/// )
/// ```
///
/// ## Action Parameters
///
/// Actions support all parameter types with exact type preservation:
///
/// ```dart
/// @MonoActions()
/// mixin _MyActions {
///   // Positional parameters
///   void logError(String message, int severity);
///
///   // Named parameters
///   void showDialog({
///     required String title,
///     required String message,
///     String? actionLabel,
///   });
///
///   // Typedef parameters (preserved, not expanded)
///   void showConfirmDialog({
///     required String message,
///     required OnComplete onComplete,  // typedef preserved
///   });
///
///   // Record type parameters
///   void processCoordinates((double lat, double lng) location);
/// }
/// ```
///
/// ## Inheritance
///
/// Share common actions across multiple blocs by having private action mixins
/// implement a public base mixin:
///
/// ```dart
/// // Shared actions interface
/// mixin ErrorHandlerActions {
///   void showError(String message);
///   void showRetryDialog(String message, VoidCallback onRetry);
/// }
///
/// // Bloc-specific actions that include shared ones
/// @MonoActions()
/// mixin _OrderActions implements ErrorHandlerActions {
///   void navigateToOrder(String orderId);
///   void showSuccess(String message);
/// }
/// ```
///
/// ## Generated Code
///
/// For a bloc with actions, MonoBloc generates:
///
/// 1. **Sealed Action Class** - Type-safe action hierarchy
/// 2. **Concrete Action Classes** - One per action method
/// 3. **Action Stream** - `Stream<Actions> get actions`
/// 4. **Action Implementations** - Methods that dispatch to stream
/// 5. **Pattern Matching** - `when()` and `of()` factories
///
/// The generated base class automatically includes the mixin:
/// ```dart
/// abstract class _$CheckoutBloc<_> extends Bloc<_Event, CheckoutState>
///     with MonoBlocActionMixin<_Action, CheckoutState>, _CheckoutActions {
///   // ...
/// }
/// ```
@Target({TargetKind.mixinType})
final class MonoActions {
  /// Creates a MonoActions annotation for marking action mixins.
  const MonoActions();
}
