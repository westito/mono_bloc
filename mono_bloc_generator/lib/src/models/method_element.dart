import 'package:analyzer/dart/element/element.dart';

/// Represents a bloc event handler method element.
class BlocMethodElement {
  /// Creates a BlocMethodElement with the given configuration.
  BlocMethodElement({
    required this.method,
    required this.eventTypeName,
    required this.stateName,
    this.unwrappedStateName,
    this.isPublicEvent = false,
  });

  /// The method element.
  final MethodElement method;

  /// The name of the event type.
  final String eventTypeName;

  /// The name of the state type.
  final String stateName;

  /// For async mode: the T in `MonoAsyncValue<T>`.
  final String? unwrappedStateName;

  /// True if method is public with @event.
  final bool isPublicEvent;

  /// The display name of the method.
  String get name => method.displayName;

  /// Get the specific event class name for this method
  String get eventClassName {
    final methodNameWithoutPrefix = name.startsWith('_')
        ? name.substring(1)
        : name;
    // Convert to PascalCase and add Event suffix
    final pascalCase =
        methodNameWithoutPrefix.substring(0, 1).toUpperCase() +
        methodNameWithoutPrefix.substring(1);
    return '_${pascalCase}Event';
  }

  List<dynamic> get parametersWithoutEmitter {
    // Skip first parameter if it's an Emitter
    final params = method.formalParameters;
    if (params.isEmpty) return const [];

    final firstParam = params.first;
    final firstParamType = firstParam.type;
    final firstParamTypeStr = firstParamType.getDisplayString();
    final firstParamName = firstParam.name;

    // Check if the type is directly an Emitter
    if (firstParamTypeStr.startsWith('Emitter<')) {
      return params.skip(1).toList();
    }

    // Check if the type name ends with "Emit" (convention for Emitter typedefs)
    // This handles both resolved typedefs like "_TodoEmit" and unresolved ones
    if (firstParamTypeStr.contains('Emit') ||
        firstParamName == 'emit' ||
        firstParamName == 'emitter') {
      // Additional validation: check if it looks like an emitter typedef pattern
      if (firstParamTypeStr.contains('Emit') || firstParamName == 'emit') {
        return params.skip(1).toList();
      }
    }

    // Check if the type is a typedef that aliases to an Emitter
    final alias = firstParamType.alias;
    if (alias != null) {
      final aliasedTypeStr = alias.element.aliasedType.getDisplayString();
      if (aliasedTypeStr.startsWith('Emitter<')) {
        return params.skip(1).toList();
      }
    }

    return params.toList();
  }

  List<dynamic> get allParameters {
    return method.formalParameters;
  }

  // Extract queue name from @MonoEvent.queue('name') annotation
  String? get queueNumber {
    for (final meta in method.metadata.annotations) {
      final value = meta.computeConstantValue();
      if (value == null) continue;

      // Check if this is a MonoEvent type by checking for the 'concurrency' or 'queue' field
      final hasConcurrencyField = value.getField('concurrency') != null;
      final hasQueueField = value.getField('queue') != null;

      if (!hasConcurrencyField && !hasQueueField) continue;

      final queueField = value.getField('queue');
      if (queueField != null && !queueField.isNull) {
        final queueName = queueField.toStringValue();
        if (queueName != null) {
          // Validate queue name is a valid Dart identifier
          if (!_isValidDartIdentifier(queueName)) {
            throw ArgumentError(
              'Invalid queue name "$queueName" in method "${method.displayName}". '
              'Queue names must be valid Dart identifiers: '
              'start with a letter or underscore, contain only letters, digits, and underscores.',
            );
          }
          return queueName;
        }
      }
    }

    return null;
  }

  // Validate that a string is a valid Dart identifier
  static bool _isValidDartIdentifier(String name) {
    if (name.isEmpty) return false;

    // Must start with letter or underscore
    final firstChar = name[0];
    if (!_isLetter(firstChar) && firstChar != '_') return false;

    // Rest can be letters, digits, or underscores
    for (var i = 1; i < name.length; i++) {
      final char = name[i];
      if (!_isLetter(char) && !_isDigit(char) && char != '_') {
        return false;
      }
    }

    return true;
  }

  static bool _isLetter(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }

  static bool _isDigit(String char) {
    final code = char.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }

  // Extract concurrency info from @MonoEvent annotation
  String? get concurrency {
    for (final meta in method.metadata.annotations) {
      final value = meta.computeConstantValue();
      if (value == null) continue;

      // Check if this is a MonoEvent type by checking for the 'concurrency' or 'queue' field
      final hasConcurrencyField = value.getField('concurrency') != null;
      final hasQueueField = value.getField('queue') != null;

      if (!hasConcurrencyField && !hasQueueField) continue;

      // Check for concurrency field
      final concurrencyField = value.getField('concurrency');
      if (concurrencyField != null && !concurrencyField.isNull) {
        final enumVariable = concurrencyField.variable;
        final enumName = enumVariable?.name;
        if (enumName != null) {
          // Use MonoEventTransformer static getter (restartable, concurrent, droppable, sequential)
          return 'MonoEventTransformer.${enumName.toLowerCase()}';
        }
      }
    }

    return null;
  }

  /// Read return type from source code for this method
  /// Returns the return type as written in source (e.g., "AppState" for typedefs)
  String? _readMethodReturnTypeFromSource() {
    try {
      final session = method.session;
      if (session == null) return null;

      final filePath = method.library.firstFragment.source.fullName;
      if (filePath.isEmpty) return null;

      final resourceProvider = session.resourceProvider;
      final file = resourceProvider.getFile(filePath);
      if (!file.exists) return null;

      final content = file.readAsStringSync();
      final methodName = method.displayName;

      // Find the method signature
      // Pattern: ReturnType methodName(...) or ReturnType methodName<T>(...)
      // Handle various return types including generics, nullable, and functions
      final escapedMethodName = RegExp.escape(methodName);

      // Look for the method declaration, capturing return type
      // Handle: ReturnType _methodName(...), async ReturnType _methodName(...), etc.
      final methodPattern = RegExp(
        r'(?:@\w+\s+)*' // Optional annotations
        r'(?:async\s+)?' // Optional async keyword
        r'([^\s]+(?:<[^>]+>)?(?:\s+Function\s*\([^)]*\))?(?:\?)?)\s+' // Return type (capture group 1)
        '$escapedMethodName\\s*(?:<[^>]*>)?\\s*\\(',
        multiLine: true,
      );

      final match = methodPattern.firstMatch(content);
      if (match != null && match.groupCount >= 1) {
        final returnTypeFromSource = match.group(1)?.trim();
        if (returnTypeFromSource != null && returnTypeFromSource.isNotEmpty) {
          return returnTypeFromSource;
        }
      }

      return null;
    } catch (e) {
      // Failed to read source, return null
      return null;
    }
  }

  // Check if method returns State (not void, not Future<void>)
  bool get returnsState {
    final returnType = method.returnType;
    final typeStr = returnType.getDisplayString();

    // Check if void or Future<void>
    if (typeStr == 'void' || typeStr == 'Future<void>') return false;

    // Check if it returns Stream
    if (returnsStream) return false;

    // Check exact match with state name (resolved type)
    if (typeStr == stateName || typeStr.startsWith('$stateName?')) return true;

    // Also check the source code representation to handle typedefs
    // For example, if stateName is "AppState" (a typedef for Map<String, dynamic>),
    // the resolved typeStr will be "Map<String, dynamic>", but the source will show "AppState"
    final sourceReturnType = _readMethodReturnTypeFromSource();
    if (sourceReturnType != null) {
      // Extract the base state name without wrapping (e.g., "MonoAsyncValue<AppState>" -> "AppState")
      final baseStateName = stateName.replaceFirst(
        RegExp(r'^MonoAsyncValue<(.+)>$'),
        r'$1',
      );
      if (sourceReturnType == baseStateName ||
          sourceReturnType == '$baseStateName?') {
        return true;
      }
    }

    // Check if it's a generic 'State' type (from mixins)
    // This handles cases where mixin methods return generic State parameter
    if (typeStr == 'State' ||
        typeStr == 'State?' ||
        typeStr.contains(' State') ||
        typeStr.contains('<State>')) {
      return true;
    }

    // Only the explicitly matched types above are valid state returns
    return false;
  }

  // Check if method returns Stream<State>
  bool get returnsStream {
    final returnType = method.returnType;
    final typeStr = returnType.getDisplayString();

    // Check if it's Stream<StateName> (resolved type)
    if (typeStr == 'Stream<$stateName>' ||
        typeStr.startsWith('Stream<$stateName>')) {
      return true;
    }

    // Check if it's Stream<_State> (async mode typedef for MonoAsyncValue<T>)
    if (typeStr == 'Stream<_State>' || typeStr.startsWith('Stream<_State>')) {
      return true;
    }

    // Also check source code representation to handle typedefs
    final sourceReturnType = _readMethodReturnTypeFromSource();
    if (sourceReturnType != null) {
      // Extract the base state name without wrapping
      final baseStateName = stateName.replaceFirst(
        RegExp(r'^MonoAsyncValue<(.+)>$'),
        r'$1',
      );
      if (sourceReturnType == 'Stream<$baseStateName>' ||
          sourceReturnType.startsWith('Stream<$baseStateName>')) {
        return true;
      }
    }

    // In async mode, accept any Stream<T> because _State typedef might not be resolved yet
    // The typedef _State may show as InvalidType or other unresolved type before code generation
    if (unwrappedStateName != null && typeStr.startsWith('Stream<')) {
      return true;
    }

    return false;
  }

  // Check if method returns Future<State>
  bool get returnsFutureState {
    final returnType = method.returnType;
    final typeStr = returnType.getDisplayString();

    // Check resolved type
    if (typeStr == 'Future<$stateName>' ||
        typeStr.startsWith('Future<$stateName>')) {
      return true;
    }

    // Also check source code representation to handle typedefs
    final sourceReturnType = _readMethodReturnTypeFromSource();
    if (sourceReturnType != null) {
      // Extract the base state name without wrapping
      final baseStateName = stateName.replaceFirst(
        RegExp(r'^MonoAsyncValue<(.+)>$'),
        r'$1',
      );
      if (sourceReturnType == 'Future<$baseStateName>' ||
          sourceReturnType.startsWith('Future<$baseStateName>')) {
        return true;
      }
    }

    return false;
  }

  // Check if method has Emitter parameter as first parameter
  bool get hasEmitterParam {
    final params = method.formalParameters;
    if (params.isEmpty) return false;

    final firstParam = params.first;
    final firstParamType = firstParam.type;
    final firstParamTypeStr = firstParamType.getDisplayString();
    final firstParamName = firstParam.name;

    // Check if the type is directly an Emitter
    if (firstParamTypeStr.startsWith('Emitter<')) return true;

    // Check if the type name ends with "Emit" (convention for Emitter typedefs)
    // This handles both resolved typedefs like "_TodoEmit" and unresolved ones
    if (firstParamTypeStr.contains('Emit') ||
        firstParamName == 'emit' ||
        firstParamName == 'emitter') {
      // Additional validation: check if it looks like an emitter typedef pattern
      if (firstParamTypeStr.contains('Emit') || firstParamName == 'emit') {
        return true;
      }
    }

    // Check if the type is a typedef that aliases to an Emitter
    final alias = firstParamType.alias;
    if (alias != null) {
      final aliasedTypeStr = alias.element.aliasedType.getDisplayString();
      if (aliasedTypeStr.startsWith('Emitter<')) return true;
    }

    return false;
  }

  // Check if method returns void or Future<void>
  bool get returnsVoid {
    final returnType = method.returnType;
    final typeStr = returnType.getDisplayString();
    return typeStr == 'void' || typeStr == 'Future<void>';
  }

  // Check if method returns Future<T> where T is NOT void and NOT wrapped State (for async mode)
  bool returnsUnwrappedFuture(String unwrappedStateName) {
    final returnType = method.returnType;
    final typeStr = returnType.getDisplayString();

    // Must start with Future<
    if (!typeStr.startsWith('Future<')) return false;

    // Check if it's Future<void>
    if (typeStr == 'Future<void>') return false;

    // Check if it's Future<MonoAsyncValue<...>> (wrapped state)
    if (typeStr.contains('MonoAsyncValue<')) return false;

    // Check if it's Future<UnwrappedType> (the actual data type, resolved type)
    // For List<Todo>, this would be Future<List<Todo>>
    if (typeStr.startsWith('Future<$unwrappedStateName') ||
        typeStr == 'Future<$unwrappedStateName>') {
      return true;
    }

    // Also check source code representation to handle typedefs
    // If UserList = List<String>, source shows Future<UserList> but analyzer resolves to Future<List<String>>
    final sourceReturnType = _readMethodReturnTypeFromSource();
    if (sourceReturnType != null &&
        (sourceReturnType == 'Future<$unwrappedStateName>' ||
            sourceReturnType.startsWith('Future<$unwrappedStateName'))) {
      return true;
    }

    return false;
  }

  // Check if method returns unwrapped T (not wrapped in async value) in async mode
  bool returnsUnwrappedData(String unwrappedStateName) {
    final returnType = method.returnType;
    final typeStr = returnType.getDisplayString();

    // Exclude void, Future, Stream
    if (typeStr == 'void' ||
        typeStr.startsWith('Future<') ||
        typeStr.startsWith('Stream<')) {
      return false;
    }

    // Exclude MonoAsyncValue (wrapped state)
    if (typeStr.contains('MonoAsyncValue<')) return false;

    // Check if it returns the unwrapped type directly (resolved type)
    // For List<Todo>, this matches List<Todo>
    if (typeStr == unwrappedStateName ||
        typeStr.startsWith('$unwrappedStateName<')) {
      return true;
    }

    // Also check source code representation to handle typedefs
    // If UserList = List<String>, source shows UserList but analyzer resolves to List<String>
    final sourceReturnType = _readMethodReturnTypeFromSource();
    if (sourceReturnType != null && sourceReturnType == unwrappedStateName) {
      return true;
    }

    return false;
  }

  // Check if method returns Stream<_State> in async mode (user returns wrapped state)
  bool returnsAsyncStateStream(String wrappedStateName) {
    final returnType = method.returnType;
    final typeStr = returnType.getDisplayString();

    // In async mode, check if it returns Stream<MonoAsyncValue<T>>
    // The typedef _State will be resolved to MonoAsyncValue<T> by the analyzer
    return typeStr.startsWith('Stream<') && typeStr.contains('MonoAsyncValue<');
  }

  // Validate method signature according to MonoBloc rules
  String? validate() {
    // If returns Stream, no Emitter param needed
    if (returnsStream) return null;

    // If returns State or Future<State>, no Emitter param needed
    if (returnsState || returnsFutureState) return null;

    // In async mode, also allow unwrapped types (T instead of MonoAsyncValue<T>)
    if (unwrappedStateName != null) {
      if (returnsUnwrappedData(unwrappedStateName!) ||
          returnsUnwrappedFuture(unwrappedStateName!) ||
          returnsAsyncStateStream(stateName)) {
        return null;
      }
    }

    // Only void/Future<void> methods MUST have Emitter parameter
    if (returnsVoid && !hasEmitterParam) {
      // In async mode, show _State in examples instead of the full type
      final exampleStateName = unwrappedStateName != null
          ? '_State'
          : stateName;

      return '''
Method '${method.displayName}' returns void and must have an _Emitter parameter.

MonoBloc requires one of these signatures:
  1. Stream<$exampleStateName> ${method.displayName}(...params...) async* { yield state; }
  2. $exampleStateName ${method.displayName}(...params...) { return state; }
  3. Future<$exampleStateName> ${method.displayName}(...params...) async { return state; }
  4. void ${method.displayName}(_Emitter emit, ...params...) { emit(state); }
  5. Future<void> ${method.displayName}(_Emitter emit, ...params...) async { emit(state); }

IMPORTANT: Use the typedef '_Emitter' not 'Emitter<$exampleStateName>'.

Fix: Add 'Emitter<$exampleStateName> emit' as the first parameter, OR return state directly.
''';
    }

    // If method has emitter parameter, validate it uses the typedef
    if (hasEmitterParam) {
      final typedefError = _validateEmitterUsesTypedef();
      if (typedefError != null) return typedefError;
    }

    // If we reach here and method doesn't return void, it must have an invalid return type
    // Valid return types are: Stream<State>, State, Future<State>, void, Future<void>
    if (!returnsVoid) {
      final returnType = method.returnType;
      final typeStr = returnType.getDisplayString();

      // In async mode, show _State in examples instead of the full type
      final exampleStateName = unwrappedStateName != null
          ? '_State'
          : stateName;

      return '''
Method '${method.displayName}' has invalid return type: $typeStr

MonoBloc @event methods MUST return one of these types:
  1. Stream<$exampleStateName> - for streaming events
  2. $exampleStateName - for synchronous state updates
  3. Future<$exampleStateName> - for asynchronous state updates
  4. void - with _Emitter parameter for manual emission
  5. Future<void> - with _Emitter parameter for async manual emission

Current: $typeStr
Expected: One of the types above

Fix: Change the return type to match one of the valid signatures.
''';
    }

    return null;
  }

  // Validate that emitter parameter uses _Emitter typedef
  String? _validateEmitterUsesTypedef() {
    final params = method.formalParameters;
    if (params.isEmpty) return null;

    final firstParam = params.first;
    final firstParamType = firstParam.type;
    final firstParamTypeStr = firstParamType.getDisplayString();

    // Check if the type is an Emitter
    if (!firstParamTypeStr.startsWith('Emitter<')) return null;

    // Check if it uses a typedef (alias will be non-null if typedef is used)
    final alias = firstParamType.alias;

    // If no alias AND it's Emitter<StateName>, then it's using the direct type
    if (alias == null && firstParamTypeStr == 'Emitter<$stateName>') {
      return '''
Method '${method.displayName}' uses 'Emitter<$stateName>' but should use the typedef '_Emitter' instead.

INVALID:
  void ${method.displayName}(Emitter<$stateName> emit, ...) { ... }

CORRECT:
  void ${method.displayName}(_Emitter emit, ...) { ... }

The typedef '_Emitter' is automatically generated and resolves to Emitter<YourStateType>.
Using the typedef ensures consistency and cleaner code.
''';
    }

    return null;
  }
}

/// Represents an action method element.
class ActionMethodElement {
  /// Creates an ActionMethodElement with the given method.
  ActionMethodElement({required this.method, this.sourceParameterTypes});

  /// The method element.
  final MethodElement method;

  /// Map of parameter name to type string as written in source code.
  final Map<String, String>? sourceParameterTypes;

  /// The display name of the method.
  String get name => method.displayName;

  /// Get the action class name for this method
  /// goToMainPage -> _GoToMainPageAction
  String get actionClassName {
    final pascalCase = name[0].toUpperCase() + name.substring(1);
    return '_${pascalCase}Action';
  }

  /// Get all parameters
  List<dynamic> get parameters {
    return method.formalParameters.toList();
  }
}
