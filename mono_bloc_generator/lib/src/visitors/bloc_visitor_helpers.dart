part of 'bloc_visitor.dart';

/// Generate public method name from source method name
/// _onIncrement -> increment, _deposit -> deposit, onSomething -> onSomething (unchanged)
String _generatePublicMethodNameFromSource(String methodName) {
  // If already public (does not start with "_"), keep as-is
  if (!methodName.startsWith('_')) {
    return methodName;
  }

  // Remove leading underscore
  var publicName = methodName.substring(1);

  // Remove "on" or "On" prefix if present and followed by uppercase letter
  if (publicName.startsWith('on') && publicName.length > 2) {
    final thirdChar = publicName[2];
    final isUppercase =
        thirdChar == thirdChar.toUpperCase() &&
        thirdChar != thirdChar.toLowerCase();
    if (isUppercase) {
      // _onIncrement -> Increment -> increment
      publicName = publicName.substring(2);
      publicName = publicName[0].toLowerCase() + publicName.substring(1);
      return publicName;
    }
  }

  return publicName;
}

/// Collects methods only from the direct class (no mixins, no superclasses)
/// Use services/repositories for shared logic instead
List<MethodElement> _collectMethodsFromHierarchy(ClassElement element) {
  // Only return methods from the direct class
  // Do NOT collect from mixins or superclasses
  return element.methods.toList();
}

/// Check specifically for @protected annotation usage.
/// Supports both the top-level const `protected` (PropertyAccessor) and
/// the underlying _Protected constructor type.
bool _hasProtectedAnnotation(MethodElement method) {
  for (final annotation in method.metadata.annotations) {
    // Try to read the annotation source (works for unresolved annotations)
    try {
      final src = annotation.toSource();
      if (src.contains('protected')) return true;
    } catch (_) {}

    final annotationElement = annotation.element;
    if (annotationElement == null) continue;

    // Top-level const accessor: `protected`
    if (annotationElement is PropertyAccessorElement) {
      final variable = annotationElement.variable;
      if (variable.name == 'protected') return true;
    }

    // Constructor of a class named '_Protected' or 'Protected'
    if (annotationElement is ConstructorElement) {
      final enclosing = annotationElement.enclosingElement;
      final enclosingName = enclosing.name;
      if (enclosingName == '_Protected' || enclosingName == 'Protected') {
        return true;
      }
    }
  }

  // Fallback: try safe TypeChecker match
  try {
    if (_safeHasAnnotationOf(protectedChecker, method)) return true;
  } catch (_) {}

  // Fallback: check by annotation type name
  if (_hasAnnotationOfType(method, 'Protected') ||
      _hasAnnotationOfType(method, '_Protected')) {
    return true;
  }

  // Last resort: read the source file and look for '@protected' text near the method
  try {
    final session = method.session;
    if (session != null) {
      final filePath = method.library.firstFragment.source.fullName;
      if (filePath.isNotEmpty) {
        final resourceProvider = session.resourceProvider;
        final file = resourceProvider.getFile(filePath);
        if (file.exists) {
          final content = file.readAsStringSync();
          final methodName = method.displayName;
          final idx = content.indexOf(methodName);
          if (idx != -1) {
            // Look back up to 300 chars for '@protected'
            final start = (idx - 300).clamp(0, content.length - 1);
            final snippet = content.substring(start, idx);
            if (snippet.contains('@protected')) return true;
          }
        }
      }
    }
  } catch (_) {}

  return false;
}

/// Check if an Element (class, mixin, etc.) has an annotation of the given type name
bool _hasAnnotationOfTypeOnElement(Element element, String typeName) {
  for (final meta in element.metadata.annotations) {
    try {
      final value = meta.computeConstantValue();
      if (value == null) continue;

      final annotationType = value.type;
      if (annotationType == null) continue;

      final displayString = annotationType.getDisplayString();
      if (displayString == typeName || displayString.startsWith('$typeName<')) {
        return true;
      }
    } catch (_) {
      continue;
    }
  }

  return false;
}

/// Check if an Element has an annotation by inspecting source text
/// This is a fallback for when annotation can't be resolved by the analyzer
bool _hasAnnotationBySource(Element element, String annotationName) {
  for (final meta in element.metadata.annotations) {
    try {
      final source = meta.toSource();
      if (source.contains('@$annotationName') ||
          source.contains('$annotationName()')) {
        return true;
      }
    } catch (_) {
      continue;
    }
  }
  return false;
}

/// Safely check if a TypeChecker matches an element
bool _safeHasAnnotationOf(TypeChecker checker, Element element) {
  try {
    return checker.hasAnnotationOf(element);
  } catch (_) {
    return false;
  }
}

/// Check if a method has an annotation of the given Dart type name
/// Works with both direct annotations (e.g. @MonoEvent()) and
/// constant aliases (e.g. @event, @onError, @onEvent).
bool _hasAnnotationOfType(MethodElement method, String typeName) {
  for (final meta in method.metadata.annotations) {
    try {
      final value = meta.computeConstantValue();
      if (value == null) continue;

      final annotationType = value.type;
      if (annotationType == null) continue;

      // Check if the type name matches (handles both 'MonoEvent' and 'MonoEvent<T>')
      final displayString = annotationType.getDisplayString();
      if (displayString == typeName || displayString.startsWith('$typeName<')) {
        return true;
      }
    } catch (_) {
      // If annotation can't be resolved (e.g. @protected without package:meta),
      // skip it and continue checking other annotations
      continue;
    }
  }

  return false;
}

/// Safely check if a TypeChecker matches a method, handling UnresolvedAnnotationException
/// Returns false if any annotation on the method can't be resolved
bool _safeHasAnnotationOfExact(TypeChecker checker, MethodElement method) {
  try {
    return checker.hasAnnotationOfExact(method);
  } catch (_) {
    // If we can't resolve annotations (e.g. @protected without package:meta),
    // return false and let caller try alternative checks
    return false;
  }
}

/// Match a parameter type by name, handling InvalidType for generated typedefs.
/// Generated typedefs like _Event, _Emitter, _State may not be resolved by the analyzer.
bool _matchesTypeName(String paramType, String expectedType) {
  // Direct match
  if (paramType == expectedType) return true;

  // Handle InvalidType - the type name might be embedded in the source
  if (paramType == 'InvalidType' || paramType.contains('InvalidType')) {
    // Can't reliably extract from InvalidType, so return false
    // Caller should use parameter name as fallback
    return false;
  }

  return false;
}

/// Read State type from source code string: class MyBloc extends _$MyBloc`<MyState>`
/// Extracts a generic type parameter by finding the matching closing bracket
/// Handles nested generics like `DataState<String>`, `Map<String, List<int>>`, etc.
String? _extractGenericType(String content, int startIndex) {
  var depth = 1; // We're already inside the first '<'
  var i = startIndex;

  while (i < content.length && depth > 0) {
    if (content[i] == '<') {
      depth++;
    } else if (content[i] == '>') {
      depth--;
    }
    i++;
  }

  if (depth == 0) {
    // Found matching bracket, extract the type
    return content.substring(startIndex, i - 1).trim();
  }

  return null;
}

String? _readStateTypeFromSourceCode(ClassElement element) {
  try {
    final className = element.name;
    if (className == null) return null;

    // Get the file path from library.source
    final filePath = element.library.firstFragment.source.fullName;
    if (filePath.isEmpty) return null;

    // Read the source file
    final session = element.session;
    if (session == null) return null;

    final resourceProvider = session.resourceProvider;
    final file = resourceProvider.getFile(filePath);
    if (!file.exists) return null;

    final content = file.readAsStringSync();

    // Find the class declaration line
    // Pattern: [abstract] [final] class ClassName[<GenericParams>] extends _$ClassName<StateType>
    final escapedClassName = RegExp.escape(className);
    final classPattern = RegExp(
      '(?:abstract\\s+)?(?:final\\s+)?class\\s+$escapedClassName(?:<[^>]+>)?\\s+extends\\s+_\\\$$escapedClassName<',
      multiLine: true,
    );

    final match = classPattern.firstMatch(content);
    if (match != null) {
      // Extract state type by finding matching closing bracket
      final startIndex = match.end; // Position after '<'
      final stateType = _extractGenericType(content, startIndex);
      if (stateType != null && stateType.isNotEmpty && stateType != 'dynamic') {
        return stateType;
      }
    }

    return null;
  } catch (e) {
    // Failed to read source file, return null to try other strategies
    return null;
  }
}

/// Read parameter type from source code for a given method and parameter name
/// This is useful when the analyzer shows InvalidType for generated event types
String? _readParameterTypeFromSource(MethodElement method, String paramName) {
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
    // Pattern: bool _methodName(TypeName paramName)
    // Also handle multi-line signatures
    final escapedMethodName = RegExp.escape(methodName);
    final methodPattern = RegExp(
      'bool\\s+$escapedMethodName\\s*\\(\\s*([^)]+)\\)',
      multiLine: true,
      dotAll: true,
    );

    final match = methodPattern.firstMatch(content);
    if (match != null) {
      final params = match.group(1);
      if (params == null) return null;

      // Parse parameters to find the one matching paramName
      // Handle: TypeName paramName, TypeName paramName2, etc.
      final paramParts = params.split(',').map((p) => p.trim()).toList();

      for (final param in paramParts) {
        // Split by whitespace to get type and name
        final parts = param.trim().split(RegExp(r'\s+'));
        if (parts.length >= 2) {
          final type = parts[0];
          final name = parts[1];
          if (name == paramName) {
            return type;
          }
        }
      }
    }

    return null;
  } catch (e) {
    // Failed to read source, return null
    return null;
  }
}

/// Read ALL parameter types from source code for a given method
/// Returns a map of parameter name -> type string as written in source
/// This handles typedefs, records, and other complex types that may not resolve correctly
Map<String, String> _readAllParameterTypesFromSource(MethodElement method) {
  try {
    final session = method.session;
    if (session == null) return {};

    final filePath = method.library.firstFragment.source.fullName;
    if (filePath.isEmpty) return {};

    final resourceProvider = session.resourceProvider;
    final file = resourceProvider.getFile(filePath);
    if (!file.exists) return {};

    final content = file.readAsStringSync();
    final methodName = method.displayName;

    // Find the method signature
    // Pattern: returnType methodName(...params...)
    // Must handle: void, Future<void>, generics, etc.
    final escapedMethodName = RegExp.escape(methodName);

    // Match method declaration with flexible return type pattern
    // Captures the parameter list between parentheses
    final methodPattern = RegExp(
      r'(?:@\w+\s+)*' // Optional annotations
      r'(?:\w+(?:<[^>]+>)?(?:\s+Function\s*\([^)]*\))?(?:\?)?\s+)' // Return type
      '$escapedMethodName\\s*\\(([^)]*)\\)',
      multiLine: true,
      dotAll: true,
    );

    final match = methodPattern.firstMatch(content);
    if (match == null) return {};

    final paramsStr = match.group(1);
    if (paramsStr == null || paramsStr.trim().isEmpty) return {};

    // Parse parameters - need to handle:
    // - Positional: Type name
    // - Named: {required Type name, Type name2}
    // - Optional positional: [Type name]
    // - Default values: Type name = value
    // - Records: (Type1, Type2) name
    // - Typedefs: OnComplete callback
    final result = <String, String>{};

    // Remove outer braces/brackets for named/optional params
    final params = paramsStr.trim();

    // Split by commas, but respect nesting (for records, generics, etc.)
    final paramList = <String>[];
    final current = StringBuffer();
    var depth = 0; // Track < > and ( ) nesting
    var parenDepth = 0;

    for (var i = 0; i < params.length; i++) {
      final char = params[i];

      if (char == '{' && depth == 0 && parenDepth == 0) {
        continue;
      } else if (char == '}' && depth == 0 && parenDepth == 0) {
        continue;
      } else if (char == '[' && depth == 0 && parenDepth == 0) {
        continue;
      } else if (char == ']' && depth == 0 && parenDepth == 0) {
        continue;
      }

      if (char == '<') depth++;
      if (char == '>') depth--;
      if (char == '(') parenDepth++;
      if (char == ')') parenDepth--;

      if (char == ',' && depth == 0 && parenDepth == 0) {
        paramList.add(current.toString().trim());
        current.clear();
      } else {
        current.write(char);
      }
    }

    // Don't forget the last parameter
    if (current.isNotEmpty) {
      paramList.add(current.toString().trim());
    }

    // Parse each parameter to extract type and name
    for (var param in paramList) {
      param = param.trim();
      if (param.isEmpty) continue;

      // Remove 'required' keyword if present
      param = param.replaceFirst(RegExp(r'^\s*required\s+'), '');

      // Handle default values: Type name = value
      // Split by '=' and take the left side
      if (param.contains('=')) {
        param = param.split('=')[0].trim();
      }

      // Now we have: Type name
      // Need to extract type and name, handling:
      // - Simple: String id
      // - Generic: List<int> items
      // - Function: void Function(bool) callback
      // - Record: (String, int) data
      // - Typedef: OnComplete onComplete

      // Find the parameter name (last identifier)
      // Work backwards from the end
      var nameStart = param.length - 1;
      while (nameStart >= 0 && _isIdentifierChar(param[nameStart])) {
        nameStart--;
      }
      nameStart++; // Move back to first char of name

      if (nameStart >= param.length) continue; // No name found

      final name = param.substring(nameStart).trim();
      final type = param.substring(0, nameStart).trim();

      if (name.isNotEmpty && type.isNotEmpty) {
        result[name] = type;
      }
    }

    return result;
  } catch (e) {
    // Failed to read source, return empty map
    return {};
  }
}

/// Check if a character is valid in a Dart identifier
bool _isIdentifierChar(String char) {
  if (char.isEmpty) return false;
  final code = char.codeUnitAt(0);
  return (code >= 65 && code <= 90) || // A-Z
      (code >= 97 && code <= 122) || // a-z
      (code >= 48 && code <= 57) || // 0-9
      code == 95; // _
}

ErrorHandler _parseErrorHandler(
  MethodElement method,
  String stateName,
  String eventName, {
  String? wrappedStateName,
}) {
  final returnType = method.returnType;
  final returnTypeStr = returnType.getDisplayString();

  // Validation: Error handlers can only return void, State, or State?
  // No Future or Stream allowed
  final returnTypeWithNullability = returnType.getDisplayString();

  // For async blocs, accept both wrapped (MonoAsyncValue<T>) and unwrapped (T) types
  var isValidReturn =
      returnTypeStr == 'void' ||
      returnTypeStr == stateName ||
      returnTypeWithNullability == '$stateName?';

  // If wrappedStateName is provided (async bloc), also accept the wrapped type
  if (wrappedStateName != null) {
    isValidReturn =
        isValidReturn ||
        returnTypeStr == wrappedStateName ||
        returnTypeWithNullability == '$wrappedStateName?';
  }

  // Check for explicitly disallowed types
  final isFuture =
      returnType.isDartAsyncFuture || returnType.isDartAsyncFutureOr;
  final isStream = returnTypeStr.startsWith('Stream<');

  if (!isValidReturn || isFuture || isStream) {
    throw InvalidGenerationSourceError(
      'Error handler "${method.displayName}" must return "$stateName", "$stateName?", or "void", but returns "$returnTypeWithNullability".\n\n'
      'Allowed return types:\n'
      '  - void (no state change)\n'
      '  - $stateName (synchronous state)\n'
      '  - $stateName? (nullable synchronous state)\n\n'
      'NOT allowed:\n'
      '  - Future<$stateName> or Future<$stateName?> (async not supported)\n'
      '  - Stream<$stateName> (streams not supported)\n'
      '  - Future<void> (async not supported)\n'
      '  - Any other type\n\n'
      'Error handlers must be synchronous.',
      element: method,
    );
  }

  // Detect if handler returns data or void
  final returnsVoid = returnTypeStr == 'void';

  // Parse parameters - can be Object, StackTrace, _Event, _Emitter in any order
  final params = method.formalParameters;
  var hasErrorParam = false;
  var hasStackParam = false;
  var hasEventParam = false;
  var hasEmitterParam = false;
  int? errorParamIndex;
  int? stackParamIndex;
  int? eventParamIndex;
  int? emitterParamIndex;

  for (var i = 0; i < params.length; i++) {
    final param = params[i];
    final paramType = param.type.getDisplayString();
    final paramName = param.name;

    var handled = false;

    if (paramType == 'Object' || paramType == 'dynamic') {
      if (hasErrorParam) {
        throw InvalidGenerationSourceError(
          'Error handler "${method.displayName}" has multiple error (Object) parameters.\n'
          'Only one Object parameter is allowed.',
          element: method,
        );
      }
      hasErrorParam = true;
      errorParamIndex = i;
      handled = true;
    } else if (paramType == 'StackTrace') {
      if (hasStackParam) {
        throw InvalidGenerationSourceError(
          'Error handler "${method.displayName}" has multiple StackTrace parameters.\n'
          'Only one StackTrace parameter is allowed.',
          element: method,
        );
      }
      hasStackParam = true;
      stackParamIndex = i;
      handled = true;
    } else if (_matchesTypeName(paramType, eventName) ||
        (paramType == 'InvalidType' && paramName == 'event')) {
      if (hasEventParam) {
        throw InvalidGenerationSourceError(
          'Error handler "${method.displayName}" has multiple event parameters.\n'
          'Only one $eventName parameter is allowed.',
          element: method,
        );
      }
      hasEventParam = true;
      eventParamIndex = i;
      handled = true;
    } else if (_matchesTypeName(paramType, '_Emitter') ||
        (paramType == 'InvalidType' &&
            (paramName == 'emit' || paramName == 'emitter'))) {
      if (hasEmitterParam) {
        throw InvalidGenerationSourceError(
          'Error handler "${method.displayName}" has multiple Emitter parameters.\n'
          'Only one _Emitter parameter is allowed.',
          element: method,
        );
      }
      hasEmitterParam = true;
      emitterParamIndex = i;
      handled = true;
    } else if (paramType.startsWith('Emitter<')) {
      // User is using Emitter<State> instead of _Emitter typedef
      throw InvalidGenerationSourceError(
        'Error handler "${method.displayName}" uses \'Emitter<$stateName>\' but should use typedef \'_Emitter\'.\n\n'
        'INVALID:\n'
        '  void ${method.displayName}(Emitter<$stateName> emit, ...) { ... }\n\n'
        'CORRECT:\n'
        '  void ${method.displayName}(_Emitter emit, ...) { ... }\n\n'
        "The typedef '_Emitter' is automatically generated and resolves to Emitter<YourStateType>.\n"
        'Using the typedef ensures consistency and cleaner code.',
        element: method,
      );
    }

    if (!handled) {
      throw InvalidGenerationSourceError(
        'Error handler "${method.displayName}" has invalid parameter: $paramName ($paramType)\n'
        'Allowed parameter types (exact types only):\n'
        '  - Object error (the error)\n'
        '  - StackTrace stack (the stack trace)\n'
        '  - $eventName event (the event that caused the error)\n'
        '  - _Emitter emit (to emit states - use typedef, not Emitter<T>)\n'
        'Parameters can be in any order and any combination.\n\n'
        'Note: Use standard parameter names (error/e, stack/stackTrace/s, event, emit/emitter)\n'
        'so types can be inferred during build_runner generation.',
        element: method,
      );
    }
  }

  // Check if return type is nullable
  final isNullable =
      !returnsVoid && returnType.nullabilitySuffix != NullabilitySuffix.none;

  return ErrorHandler(
    method,
    hasErrorParam: hasErrorParam,
    hasStackParam: hasStackParam,
    hasEventParam: hasEventParam,
    hasEmitterParam: hasEmitterParam,
    returnsData: !returnsVoid,
    isNullable: isNullable,
    errorParamIndex: errorParamIndex,
    stackParamIndex: stackParamIndex,
    eventParamIndex: eventParamIndex,
    emitterParamIndex: emitterParamIndex,
  );
}
