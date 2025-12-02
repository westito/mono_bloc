import 'package:analyzer/dart/element/element.dart';
import 'package:mono_bloc_generator/src/models/method_element.dart'
    as method_model;

/// Information about an @onEvent handler method.
class OnEventHandler {
  /// Creates an OnEventHandler with the given configuration.
  const OnEventHandler(
    this.method,
    this.eventType, {
    required this.hasEventParam,
    required this.hasEmitterParam,
    this.eventParamIndex,
    this.emitterParamIndex,
  });

  /// The method element representing the handler.
  final MethodElement method;

  /// Actual event type as declared in source.
  final String eventType;

  /// Whether the handler has an _Event parameter.
  final bool hasEventParam;

  /// Whether the handler has an _Emitter parameter.
  final bool hasEmitterParam;

  /// Position of event parameter if present.
  final int? eventParamIndex;

  /// Position of emitter parameter if present.
  final int? emitterParamIndex;
}

/// Information about an error handler method.
class ErrorHandler {
  /// Creates an ErrorHandler with the given configuration.
  const ErrorHandler(
    this.method, {
    required this.hasErrorParam,
    required this.hasStackParam,
    required this.hasEventParam,
    required this.hasEmitterParam,
    required this.returnsData,
    required this.isNullable,
    this.errorParamIndex,
    this.stackParamIndex,
    this.eventParamIndex,
    this.emitterParamIndex,
  });

  /// The method element representing the error handler.
  final MethodElement method;

  /// Whether the handler has an Object/dynamic parameter.
  final bool hasErrorParam;

  /// Whether the handler has a StackTrace parameter.
  final bool hasStackParam;

  /// Whether the handler has an _Event parameter.
  final bool hasEventParam;

  /// Whether the handler has an _Emitter parameter.
  final bool hasEmitterParam;

  /// Whether the handler returns T? (data) vs void.
  final bool returnsData;

  /// Whether the return type is nullable (T? vs T).
  final bool isNullable;

  /// Position of error parameter if present.
  final int? errorParamIndex;

  /// Position of stack parameter if present.
  final int? stackParamIndex;

  /// Position of event parameter if present.
  final int? eventParamIndex;

  /// Position of emitter parameter if present.
  final int? emitterParamIndex;
}

/// Represents a bloc class element with its configuration and methods.
class BlocElement {
  /// Creates a BlocElement with the given configuration.
  BlocElement({
    required this.eventName,
    required this.stateName,
    required this.bloc,
    required this.sourceFileName,
    this.sequential = false,
    this.defaultConcurrency,
    this.isAsync = false,
    this.unwrappedStateName,
    this.isFlutterProject = false,
    this.actionMixinName,
  });

  /// The name of the event base class.
  final String eventName;

  /// The name of the state type. For async: `MonoAsyncValue<T>`, for normal: T.
  final String stateName;

  /// The class element representing the bloc.
  final ClassElement bloc;

  /// The source file name (e.g., 'main.dart').
  final String sourceFileName;

  /// When true, all simple @event methods are grouped into a sequential queue.
  final bool sequential;

  /// Default concurrency for @event methods when sequential=false.
  final String? defaultConcurrency;

  /// Whether this is an async bloc using MonoAsyncValue.
  final bool isAsync;

  /// For async blocs: T, for normal: null.
  final String? unwrappedStateName;

  /// When true, project is a Flutter project (has flutter SDK in pubspec.yaml).
  /// BuildContext will be added to action handlers.
  final bool isFlutterProject;

  /// The name of the action mixin (e.g., '_CartBlocActions') if actions come from a mixin.
  String? actionMixinName;

  /// List of event handler methods.
  final List<method_model.BlocMethodElement> methods = [];

  /// List of initialization methods.
  final List<method_model.BlocMethodElement> initMethods = [];

  /// List of action methods.
  final List<method_model.ActionMethodElement> actionMethods = [];

  /// Map of event name to error handler.
  final Map<String, ErrorHandler> eventErrorHandlers = {};

  /// General error handler for all events.
  ErrorHandler? generalErrorHandler;

  /// Map of event type name to onEvent handler info.
  final Map<String, OnEventHandler> onEventHandlers = {};

  /// Adds an event handler method to the bloc.
  void addMethod(method_model.BlocMethodElement method) {
    methods.add(method);
  }

  /// Adds an initialization method to the bloc.
  void addInitMethod(method_model.BlocMethodElement method) {
    initMethods.add(method);
  }

  /// Adds an action method to the bloc.
  void addActionMethod(method_model.ActionMethodElement method) {
    actionMethods.add(method);
  }

  /// Sets the general error handler for the bloc.
  void setGeneralErrorHandler(ErrorHandler handler) {
    generalErrorHandler = handler;
  }

  /// Adds an error handler for a specific event.
  void addEventErrorHandler(String eventName, ErrorHandler handler) {
    eventErrorHandlers[eventName] = handler;
  }

  /// Adds an onEvent handler for a specific event type.
  void addOnEventHandler(String eventTypeKey, OnEventHandler handler) {
    onEventHandlers[eventTypeKey] = handler;
  }

  /// Whether the bloc has any onEvent handlers.
  bool get hasOnEventHandlers => onEventHandlers.isNotEmpty;

  /// Whether the bloc has any action methods.
  bool get hasActions => actionMethods.isNotEmpty;
}
