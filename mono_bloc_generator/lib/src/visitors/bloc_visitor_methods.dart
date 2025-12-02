part of 'bloc_visitor.dart';

void _findPrivateMethodsWithEmitter(
  ClassElement element,
  BlocElement blocElement,
  String eventTypeName,
  String stateTypeName,
  String? unwrappedStateTypeName,
) {
  // Collect methods from class hierarchy (including superclasses)
  final allMethods = _collectMethodsFromHierarchy(element);

  for (final method in allMethods) {
    final methodName = method.name;
    final hasMonoEvent =
        _safeHasAnnotationOfExact(monoEventChecker, method) ||
        _hasAnnotationOfType(method, 'MonoEvent');
    final hasMonoInit = _safeHasAnnotationOfExact(monoInitChecker, method);

    // Handle @MonoEvent annotation
    if (hasMonoEvent) {
      final isPrivate = methodName != null && methodName.startsWith('_');
      final isPublic = methodName != null && !methodName.startsWith('_');

      // Validate public vs private @event methods
      if (isPublic) {
        // Rule: Public @event methods MUST have BOTH @protected AND start with "on"
        final hasProtected = _hasProtectedAnnotation(method);
        final startsWithOn = methodName.startsWith('on');

        // Check BOTH conditions - throw error for ANY violation
        if (!hasProtected && !startsWithOn) {
          throw InvalidGenerationSourceError(
            'Public method "$methodName" has @event annotation but is invalid.\n'
            'Public @event methods MUST have BOTH:\n'
            '  1. @protected annotation\n'
            '  2. Method name starting with "on"\n\n'
            'Current method:\n'
            '  - Missing @protected annotation\n'
            '  - Does not start with "on"\n\n'
            'Required syntax:\n'
            '@event\n'
            '@protected\n'
            'AppState<T> on${methodName[0].toUpperCase()}${methodName.substring(1)}() { ... }',
            element: method,
          );
        } else if (!hasProtected) {
          throw InvalidGenerationSourceError(
            'Public method "$methodName" has @event annotation but is missing @protected annotation.\n'
            'Public @event methods MUST have @protected annotation.\n\n'
            'Required syntax:\n'
            '@event\n'
            '@protected\n'
            'AppState<T> $methodName() { ... }',
            element: method,
          );
        } else if (!startsWithOn) {
          throw InvalidGenerationSourceError(
            'Public method "$methodName" has @event annotation but does not start with "on".\n'
            'Public @event methods MUST start with "on".\n\n'
            'Required syntax:\n'
            '@event\n'
            '@protected\n'
            'AppState<T> on${methodName[0].toUpperCase()}${methodName.substring(1)}() { ... }',
            element: method,
          );
        }

        // If we get here, both conditions are met
        // Validate that @protected import is present
        _validateProtectedImports(method);
      } else if (!isPrivate) {
        // This shouldn't happen but just in case
        throw InvalidGenerationSourceError(
          'Method "$methodName" has @event annotation but has invalid visibility.\n'
          '@event methods must be either:\n'
          '  1. Private (start with _), OR\n'
          '  2. Public with @protected and start with "on".',
          element: method,
        );
      }

      // Validate: method name cannot contain $
      if (methodName.contains(r'$')) {
        throw InvalidGenerationSourceError(
          'Method "$methodName" contains "\$" character which is reserved for generated code. '
          r'Please rename the method without using "$".',
          element: method,
        );
      }

      final methodElement = method_model.BlocMethodElement(
        method: method,
        eventTypeName: eventTypeName,
        stateName: stateTypeName,
        unwrappedStateName: unwrappedStateTypeName,
        isPublicEvent: isPublic, // Mark if it's a public event method
      );

      // Validate method signature
      final validationError = methodElement.validate();
      if (validationError != null) {
        throw InvalidGenerationSourceError(validationError, element: method);
      }

      blocElement.addMethod(methodElement);
      continue;
    }

    // Check if method has @MonoInit annotation
    if (hasMonoInit) {
      // Validate: method name cannot contain $
      if (methodName != null && methodName.contains(r'$')) {
        throw InvalidGenerationSourceError(
          'Method "$methodName" contains "\$" character which is reserved for generated code. '
          r'Please rename the method without using "$".',
          element: method,
        );
      }

      // Validate: Stream return type is NOT allowed for @onInit in sequential blocs
      // because it would cause a deadlock - the stream never completes and blocks
      // all subsequent events in the sequential queue forever.
      if (blocElement.sequential) {
        final returnType = method.returnType;
        final returnTypeStr = returnType.getDisplayString();

        if (returnTypeStr.startsWith('Stream<')) {
          throw InvalidGenerationSourceError(
            '@onInit method "$methodName" returns Stream<...> which is NOT allowed in sequential blocs.\n\n'
            'WHY THIS IS FORBIDDEN:\n'
            'In sequential mode, events are processed one at a time. A Stream-returning\n'
            '@onInit method holds the queue until the stream completes. If the stream never\n'
            'completes (e.g., broadcast streams, infinite streams), it causes a DEADLOCK:\n'
            '  - All subsequent @onInit methods will NEVER run\n'
            '  - All events dispatched to the bloc will be BLOCKED forever\n\n'
            'SOLUTIONS:\n\n'
            '1. Use Future instead of Stream:\n'
            '   @onInit\n'
            '   Future<${blocElement.stateName}> $methodName() async {\n'
            '     final data = await fetchData();\n'
            '     return state.copyWith(data: data);\n'
            '   }\n\n'
            '2. Use _Emitter for multiple emissions (still completes):\n'
            '   @onInit\n'
            '   Future<void> $methodName(_Emitter emit) async {\n'
            '     emit(state.copyWith(loading: true));\n'
            '     final data = await fetchData();\n'
            '     emit(state.copyWith(loading: false, data: data));\n'
            '   }\n\n'
            '3. If you need Stream, use a non-sequential bloc:\n'
            '   @MonoBloc()  // Remove sequential: true\n'
            '   class ${blocElement.bloc.name} extends ...',
            element: method,
          );
        }
      }

      blocElement.addInitMethod(
        method_model.BlocMethodElement(
          method: method,
          eventTypeName: eventTypeName,
          stateName: stateTypeName,
          unwrappedStateName: unwrappedStateTypeName,
        ),
      );
    }
  }
}

void _findErrorHandlers(ClassElement element, BlocElement blocElement) {
  // Collect error handlers from class hierarchy (including superclasses)
  final allMethods = _collectMethodsFromHierarchy(element);

  for (final method in allMethods) {
    final methodName = method.name;
    if (methodName == null || !methodName.startsWith('_')) continue;

    final hasErrorHandlerAnnotation =
        _safeHasAnnotationOfExact(errorHandlerChecker, method) ||
        _hasAnnotationOfType(method, 'MonoOnError');
    final hasEventAnnotation =
        _safeHasAnnotationOfExact(monoEventChecker, method) ||
        _hasAnnotationOfType(method, 'MonoEvent');
    final hasOnEventAnnotation =
        _safeHasAnnotationOfExact(onEventChecker, method) ||
        _hasAnnotationOfType(method, 'MonoOnEvent');

    // Validation: Method cannot have both @event and @onError
    if (hasErrorHandlerAnnotation && hasEventAnnotation) {
      throw InvalidGenerationSourceError(
        'Method "$methodName" cannot have both @event and @onError annotations.\n'
        'A method must be either an event handler or an error handler, not both.',
        element: method,
      );
    }

    // Validation: Method cannot have both @onEvent and @onError
    if (hasErrorHandlerAnnotation && hasOnEventAnnotation) {
      throw InvalidGenerationSourceError(
        'Method "$methodName" cannot have both @onError and @onEvent annotations.\n'
        '@onEvent is for filtering events, while @onError is for handling errors.\n\n'
        'These are separate concerns and should be in different methods.',
        element: method,
      );
    }

    // Skip if this is an event handler (already processed)
    if (hasEventAnnotation) continue;

    // Only find methods with @onError annotation
    if (hasErrorHandlerAnnotation) {
      // For async blocs, error handlers can return either wrapped (MonoAsyncValue<T>) or unwrapped (T) type
      final stateNameForValidation =
          blocElement.isAsync && blocElement.unwrappedStateName != null
          ? blocElement.unwrappedStateName!
          : blocElement.stateName;
      final wrappedStateName = blocElement.isAsync
          ? blocElement.stateName
          : null;
      final handler = _parseErrorHandler(
        method,
        stateNameForValidation,
        blocElement.eventName,
        wrappedStateName: wrappedStateName,
      );
      if (methodName == '_onError') {
        blocElement.setGeneralErrorHandler(handler);
      } else if (methodName.startsWith('_onError') && methodName.length > 8) {
        final eventNamePart = methodName.substring(8);
        for (final eventMethod in blocElement.methods) {
          final eventMethodName = eventMethod.name.startsWith('_on')
              ? eventMethod.name.substring(3)
              : eventMethod.name.startsWith('on')
              ? eventMethod.name.substring(2)
              : eventMethod.name.substring(1);

          if (eventNamePart.toLowerCase() == eventMethodName.toLowerCase()) {
            blocElement.addEventErrorHandler(eventMethod.name, handler);
            break;
          }
        }
      }
    }
  }
}

void _findOnEventHandlers(ClassElement element, BlocElement blocElement) {
  // Collect methods from class hierarchy
  final allMethods = _collectMethodsFromHierarchy(element);

  for (final method in allMethods) {
    final methodName = method.name;
    if (methodName == null) continue;

    final hasOnEventAnnotation =
        _safeHasAnnotationOfExact(onEventChecker, method) ||
        _hasAnnotationOfType(method, 'MonoOnEvent');

    if (!hasOnEventAnnotation) continue;

    // Validate: @onEvent cannot have @event or @onError annotations
    final hasEventAnnotation =
        _safeHasAnnotationOfExact(monoEventChecker, method) ||
        _hasAnnotationOfType(method, 'MonoEvent');
    final hasErrorHandlerAnnotation =
        _safeHasAnnotationOfExact(errorHandlerChecker, method) ||
        _hasAnnotationOfType(method, 'MonoOnError');

    if (hasEventAnnotation) {
      throw InvalidGenerationSourceError(
        'Method "$methodName" cannot have both @onEvent and @event annotations.\n'
        '@onEvent is for filtering events, while @event is for handling events.\n\n'
        'Use @event for handling events, and optionally add @onEvent on a separate method for filtering.',
        element: method,
      );
    }

    if (hasErrorHandlerAnnotation) {
      throw InvalidGenerationSourceError(
        'Method "$methodName" cannot have both @onEvent and @onError annotations.\n'
        '@onEvent is for filtering events, while @onError is for handling errors.\n\n'
        'These are separate concerns and should be in different methods.',
        element: method,
      );
    }

    // Validate: method must be private
    if (!methodName.startsWith('_')) {
      throw InvalidGenerationSourceError(
        '@onEvent method "$methodName" must be private (start with _).\n\n'
        'Required syntax:\n'
        '@onEvent\n'
        'bool _onEvents(${blocElement.eventName} event) { ... }',
        element: method,
      );
    }

    // Validate: return type must be bool
    final returnType = method.returnType;
    final returnTypeStr = returnType.getDisplayString();

    if (returnTypeStr != 'bool') {
      throw InvalidGenerationSourceError(
        '@onEvent method "$methodName" must return bool, but returns $returnTypeStr.\n\n'
        'Required syntax:\n'
        '@onEvent\n'
        'bool $methodName(_Event event) { ... }',
        element: method,
      );
    }

    // Validate: must not be async
    if (returnType.isDartAsyncFuture || returnType.isDartAsyncFutureOr) {
      throw InvalidGenerationSourceError(
        '@onEvent method "$methodName" must be synchronous (return bool, not Future<bool>).\n\n'
        'Required syntax:\n'
        '@onEvent\n'
        'bool $methodName(_Event event) { ... }',
        element: method,
      );
    }

    // Parse parameters - can be _Event (or specific event type) and/or _Emitter in any order
    final params = method.formalParameters;
    var hasEventParam = false;
    var hasEmitterParam = false;
    int? eventParamIndex;
    int? emitterParamIndex;
    var eventType = blocElement.eventName; // Default to _Event

    for (var i = 0; i < params.length; i++) {
      final param = params[i];
      final paramType = param.type.getDisplayString();
      final paramName = param.name;

      var handled = false;

      // Accept _Event (base event type) or specific event types (e.g., _LoadEvent, _$SequentialEvent)
      final isBaseEventType = _matchesTypeName(
        paramType,
        blocElement.eventName,
      );
      final isSpecificEventType =
          (paramType.startsWith('_') && paramType.endsWith('Event')) ||
          (paramType.startsWith(r'_$') && paramType.endsWith('Event'));

      // Fallback: If analyzer can't resolve the type (InvalidType), read from source code
      final isInvalidType =
          paramType == 'InvalidType' || paramType.contains('InvalidType');
      final isEventByName = isInvalidType && paramName == 'event';

      if (isBaseEventType || isSpecificEventType || isEventByName) {
        if (hasEventParam) {
          throw InvalidGenerationSourceError(
            '@onEvent method "$methodName" has multiple event parameters.\n'
            'Only one event parameter is allowed.',
            element: method,
          );
        }
        hasEventParam = true;
        eventParamIndex = i;

        // Store the actual event type for specific handlers, or base _Event for generic handlers
        if (isEventByName && paramName != null) {
          // Try to read the actual type from source code
          final sourceType = _readParameterTypeFromSource(method, paramName);
          eventType = sourceType ?? blocElement.eventName;
        } else {
          eventType = paramType;
        }
        handled = true;
      } else if (_matchesTypeName(paramType, '_Emitter') ||
          (isInvalidType && (paramName == 'emit' || paramName == 'emitter'))) {
        if (hasEmitterParam) {
          throw InvalidGenerationSourceError(
            '@onEvent method "$methodName" has multiple Emitter parameters.\n'
            'Only one _Emitter parameter is allowed.',
            element: method,
          );
        }
        hasEmitterParam = true;
        emitterParamIndex = i;
        handled = true;
      } else if (paramType.startsWith('Emitter<') ||
          paramType.startsWith('MonoAsyncEmitter<')) {
        // User is using Emitter<State> instead of _Emitter typedef
        throw InvalidGenerationSourceError(
          '@onEvent method "$methodName" uses \'$paramType\' but should use typedef \'_Emitter\'.\n\n'
          'INVALID:\n'
          '  bool $methodName($paramType emit) { ... }\n\n'
          'CORRECT:\n'
          '  bool $methodName(_Emitter emit) { ... }\n\n'
          "The typedef '_Emitter' is automatically generated and resolves to Emitter<YourStateType>.\n"
          'Using the typedef ensures consistency and cleaner code.',
          element: method,
        );
      }

      if (!handled) {
        throw InvalidGenerationSourceError(
          '@onEvent method "$methodName" has invalid parameter: $paramName ($paramType)\n'
          'Allowed parameter types (exact types only):\n'
          '  - ${blocElement.eventName} event (the base event type for all events)\n'
          '  - Specific event types like _LoadEvent, _SaveEvent (for event-specific filtering)\n'
          '  - Event group types like _\$SequentialEvent, _\$Queue1Event (for group filtering)\n'
          '  - _Emitter emit (to emit states - use typedef, not Emitter<T>)\n'
          'Parameters can be in any order.\n\n'
          'Note: Use the typedef _Emitter, not Emitter<State> or MonoAsyncEmitter<T>.\n'
          'Use standard parameter names (event, emit/emitter) so types can be inferred.',
          element: method,
        );
      }
    }

    // Must have at least event parameter OR emitter parameter
    if (!hasEventParam && !hasEmitterParam) {
      throw InvalidGenerationSourceError(
        '@onEvent method "$methodName" must have at least one parameter.\n\n'
        'Required syntax:\n'
        '@onEvent\n'
        'bool $methodName(_Event event) { ... }  // With event\n'
        'bool $methodName(_Emitter emit) { ... }  // With emitter\n'
        'bool $methodName(_Event event, _Emitter emit) { ... }  // With both',
        element: method,
      );
    }

    // Store the onEvent handler
    final handler = OnEventHandler(
      method,
      eventType,
      hasEventParam: hasEventParam,
      hasEmitterParam: hasEmitterParam,
      eventParamIndex: eventParamIndex,
      emitterParamIndex: emitterParamIndex,
    );

    // Use eventType as key for duplicate detection
    blocElement.addOnEventHandler(eventType, handler);
  }
}

void _findActionMethods(
  ClassElement element,
  BlocElement blocElement,
  String filePath,
  MixinElement? actionsMixin,
) {
  // If no @MonoActions mixin found in this file, no actions to process
  if (actionsMixin == null) return;

  final mixinName = actionsMixin.name;
  if (mixinName == null) return;

  // Record the mixin name for the generator
  blocElement.actionMixinName = mixinName;

  // Collect ALL abstract methods from the @MonoActions mixin
  // All abstract void methods in the @MonoActions mixin become actions
  final actionMethods = <MethodElement>[];

  // First, collect from directly declared methods in the mixin
  final declaredMethods = actionsMixin.methods;

  for (final method in declaredMethods) {
    // Skip non-abstract methods - they could be:
    // 1. Override implementations for interface methods (valid - just skip)
    // 2. Concrete helper methods in the mixin (just skip, not actions)
    // Only abstract methods become actions
    if (!method.isAbstract) {
      continue;
    }
    actionMethods.add(method);
  }

  // Also collect abstract methods from superInterfaces (implemented mixins)
  // Only collect from mixins, NOT from classes - this prevents abstract classes from being treated as actions
  for (final interface in actionsMixin.interfaces) {
    final interfaceElement = interface.element;
    // Skip if it's a class - only process mixins
    if (interfaceElement is! MixinElement) continue;

    for (final method in interfaceElement.methods) {
      final alreadyDeclared = actionMethods.any((m) => m.name == method.name);
      if (!alreadyDeclared && method.isAbstract) {
        actionMethods.add(method);
      }
    }
  }

  // Process each action method
  for (final method in actionMethods) {
    final methodName = method.name;

    // Validate: method name cannot contain $
    if (methodName != null && methodName.contains(r'$')) {
      throw InvalidGenerationSourceError(
        'Action method "$methodName" contains "\$" character which is reserved for generated code. '
        r'Please rename the method without using "$".',
        element: method,
      );
    }

    // Validate: method must return void
    final returnType = method.returnType;
    final returnTypeStr = returnType.getDisplayString();

    if (returnTypeStr != 'void') {
      throw InvalidGenerationSourceError(
        'Action method "$methodName" must return void. '
        'Found: $returnTypeStr. '
        'Action methods in mixin "$mixinName" should not return values.\n\n'
        'Required syntax:\n'
        '@MonoActions()\n'
        'mixin $mixinName {\n'
        '  void $methodName(...params...);  // Must return void\n'
        '}\n\n'
        'Actions are side effects and should not return values.',
        element: method,
      );
    }

    // This is an action method!
    // Read parameter types from source to preserve typedefs and records
    final sourceTypes = _readAllParameterTypesFromSource(method);
    final actionMethod = method_model.ActionMethodElement(
      method: method,
      sourceParameterTypes: sourceTypes.isNotEmpty ? sourceTypes : null,
    );
    blocElement.addActionMethod(actionMethod);
  }
}
