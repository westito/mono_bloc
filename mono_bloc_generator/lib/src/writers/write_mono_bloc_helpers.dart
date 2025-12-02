part of 'write_mono_bloc.dart';

bool _hasQueuedMethods(BlocElement bloc) {
  return bloc.methods.any((method) => method.queueNumber != null);
}

bool _needsTransformerHelpers(BlocElement bloc) {
  // Need transformer helpers if there are queued methods OR methods with concurrency transformers OR onEvent handlers
  // OR sequential mode with any methods (including @onInit methods)
  return bloc.methods.any(
        (method) => method.queueNumber != null || method.concurrency != null,
      ) ||
      bloc.hasOnEventHandlers ||
      (bloc.sequential &&
          (bloc.methods.isNotEmpty || bloc.initMethods.isNotEmpty));
}

List<Method> _buildTransformerHelpers(BlocElement bloc) {
  final methods = <Method>[];
  final hasQueues = _hasQueuedMethods(bloc);

  // Only generate _getTransformer if there are queued methods (uses _queues field)
  if (hasQueues) {
    methods.add(
      Method(
        (b) => b
          ..name = '_getTransformer'
          ..types.add(refer('E'))
          ..requiredParameters.add(
            Parameter(
              (pb) => pb
                ..name = 'queueName'
                ..type = refer('String'),
            ),
          )
          ..returns = refer('EventTransformer<E>?')
          ..body = const Code(r'''
final $ = _$(this);
assert(_queues.containsKey(queueName), 'Queue "$queueName" does not exist. Add it in super constructor queues parameter.');
final transformer = _queues[queueName];
if (transformer == null) return null;
return $._castTransformer<E>(transformer);
'''),
      ),
    );
  }

  // No longer generate _filterEvent, _wrapWithOnEvent, _castTransformer
  // They are now in the helper extension type

  return methods;
}

/// Build init method code for helper extension (returns String)
String _buildInitMethodHelperExtension(BlocElement bloc) {
  final buffer = StringBuffer();
  buffer.writeln(r'  void _$init() {');

  // Group methods by handling strategy
  final sequentialMethods = <method_model.BlocMethodElement>[];
  final queuedMethods = <String, List<method_model.BlocMethodElement>>{};
  final nonQueuedMethods = <method_model.BlocMethodElement>[];

  for (final method in bloc.methods) {
    final queueName = method.queueNumber;
    final hasConcurrency = method.concurrency != null;

    if (queueName != null) {
      // Explicit queue assignment
      queuedMethods.putIfAbsent(queueName, () => []).add(method);
    } else if (bloc.sequential && !hasConcurrency) {
      // Sequential mode: simple events go to main event handler
      sequentialMethods.add(method);
    } else {
      // Non-queued methods (either has concurrency transformer or sequential is disabled)
      nonQueuedMethods.add(method);
    }
  }

  // Collect @onInit methods that belong in sequential queue (in sequential mode)
  final sequentialInitMethods = bloc.sequential
      ? bloc.initMethods
      : <method_model.BlocMethodElement>[];

  // Register sequential event handler (applies to all simple events in sequential mode)
  // This includes both regular @event methods and @onInit methods when in sequential mode
  final allSequentialMethods = [...sequentialMethods, ...sequentialInitMethods];
  if (allSequentialMethods.isNotEmpty) {
    final cases = allSequentialMethods
        .map((method) {
          final eventClass = _generateEventName(method.name);
          final handlerBody = _buildEventHandlerBody(bloc, method);

          return 'if (event is $eventClass) {\n'
              '  $handlerBody\n'
              '}';
        })
        .join(' else ');

    final handler = '(event, emit) async {\n$cases\n}';
    const transformer =
        r'_castTransformer<_$SequentialEvent>(MonoEventTransformer.sequential)';
    final wrappedTransformer = bloc.hasOnEventHandlers
        ? '_wrapWithOnEvent($transformer)'
        : transformer;

    buffer.writeln(
      '    bloc.on<_\$SequentialEvent>($handler, transformer: $wrappedTransformer);',
    );
  }

  // Register queue handlers
  for (final entry in queuedMethods.entries) {
    final queueName = entry.key;
    final methods = entry.value;

    final cases = methods
        .map((method) {
          final eventClass = _generateEventName(method.name);
          final handlerBody = _buildEventHandlerBody(bloc, method);

          return 'if (event is $eventClass) {\n'
              '  $handlerBody\n'
              '}';
        })
        .join(' else ');

    final handler = '(event, emit) async {\n$cases\n}';
    // Convert queue name to PascalCase for class name
    final pascalCaseName = _toPascalCase(queueName);
    final transformer =
        "bloc._getTransformer<_\$${pascalCaseName}QueueEvent>('$queueName')";
    final wrappedTransformer = bloc.hasOnEventHandlers
        ? '_wrapWithOnEvent($transformer)'
        : transformer;

    buffer.writeln(
      '    bloc.on<_\$${pascalCaseName}QueueEvent>($handler, transformer: $wrappedTransformer);',
    );
  }

  // Register non-queued handlers
  for (final method in nonQueuedMethods) {
    final eventClass = _generateEventName(method.name);
    final wrapperCode = _buildEventHandlerWrapper(bloc, method);

    final concurrency = method.concurrency;

    if (bloc.hasOnEventHandlers) {
      // Wrap transformer with onEvent
      final baseTransformer = concurrency != null
          ? '_castTransformer<$eventClass>($concurrency)'
          : 'null';
      final wrappedTransformer = baseTransformer == 'null'
          ? '_wrapWithOnEvent<$eventClass>((events, mapper) => events.asyncExpand(mapper))'
          : '_wrapWithOnEvent($baseTransformer)';

      buffer.writeln(
        '    bloc.on<$eventClass>($wrapperCode, transformer: $wrappedTransformer);',
      );
    } else {
      // No onEvent wrapper needed
      final concurrencyArg = concurrency != null
          ? ', transformer: _castTransformer<$eventClass>($concurrency)'
          : '';

      buffer.writeln('    bloc.on<$eventClass>($wrapperCode$concurrencyArg);');
    }
  }

  // Register handlers for @onInit methods (treated as events)
  // Note: In sequential mode, @onInit handlers are already registered via the _$SequentialEvent handler above
  if (!bloc.sequential) {
    for (final method in bloc.initMethods) {
      final eventClass = _generateEventName(method.name);
      final wrapperCode = _buildEventHandlerWrapper(bloc, method);

      buffer.writeln('    bloc.on<$eventClass>($wrapperCode);');
    }
  }

  // Dispatch @onInit events AFTER all handlers are registered
  if (bloc.initMethods.isNotEmpty) {
    buffer.writeln();
    buffer.writeln('    // Dispatch @onInit events');
    for (final method in bloc.initMethods) {
      final eventClass = _generateEventName(method.name);
      final params = method.parametersWithoutEmitter
          .cast<FormalParameterElement>();

      // Build parameter list for event instantiation
      final positionalArgs = params
          .where((p) => p.isRequiredPositional || p.isOptionalPositional)
          .map((p) => p.name!)
          .join(', ');

      final namedArgs = params
          .where((p) => p.isNamed)
          .map((p) => '${p.name!}: ${p.name!}')
          .join(', ');

      final allArgs = [
        positionalArgs,
        namedArgs,
      ].where((s) => s.isNotEmpty).join(', ');

      final eventInstantiation = allArgs.isEmpty
          ? '$eventClass()'
          : '$eventClass($allArgs)';

      buffer.writeln('    bloc.add($eventInstantiation);');
    }
  }

  buffer.writeln('  }');
  return buffer.toString();
}

/// Builds the handler body (without the wrapper function) for queue event handlers
String _buildEventHandlerBody(
  BlocElement bloc,
  method_model.BlocMethodElement method,
) {
  final methodName = method.name;
  final params = _buildMethodCallParams(method);

  // For async blocs, handle unwrapped types differently
  if (bloc.isAsync) {
    final returnType = method.method.returnType;
    final returnTypeStr = returnType.getDisplayString();

    // Check for Stream first (before other checks)
    if (returnTypeStr.startsWith('Stream<')) {
      final methodCall = '$methodName($params)';
      // For async blocs, use bloc.stateName (wrapped) not method.stateName (unwrapped)
      return 'await emit.forEach<${bloc.stateName}>($methodCall, onData: (state) => state);';
    }

    // Check if returns unwrapped type (Future<T> or T, not Future<_State> or_State)
    final returnsUnwrapped = !returnTypeStr.contains('MonoAsyncValue<');

    // Check if method returns unwrapped Future<T> or T in async mode
    final returnsUnwrappedFuture =
        bloc.unwrappedStateName != null &&
        method.returnsUnwrappedFuture(bloc.unwrappedStateName!);
    final returnsUnwrappedData =
        bloc.unwrappedStateName != null &&
        method.returnsUnwrappedData(bloc.unwrappedStateName!);

    if (returnsUnwrapped &&
        (method.returnsFutureState ||
            method.returnsState ||
            returnsUnwrappedFuture ||
            returnsUnwrappedData)) {
      // Returns Future<T> or T - wrap with MonoAsyncValue
      final methodCall = '$methodName($params)';

      // Find error handler for this method
      final errorHandler =
          bloc.eventErrorHandlers[methodName] ?? bloc.generalErrorHandler;

      if (method.returnsFutureState || returnsUnwrappedFuture) {
        // Emit loading state before executing, then wrap result in withData or error in withError
        if (errorHandler != null) {
          // Error handler available - call it to get fallback data
          final errorHandlerName = errorHandler.method.displayName;
          return '''
emit(loading());
try {
  emit(withData(await $methodCall));
} catch (error, stackTrace) {
  final stack = _\$stack(event.trace, stackTrace);
  bloc.onError(error, stack);
  final data = $errorHandlerName(error, stack);
  emit(withError(error, stack, data));
}''';
        } else {
          // No error handler - use current state data
          return '''
emit(loading());
try {
  emit(withData(await $methodCall));
} catch (error, stackTrace) {
  final stack = _\$stack(event.trace, stackTrace);
  bloc.onError(error, stack);
  emit(withError(error, stack, bloc.state.dataOrNull));
}''';
        }
      } else {
        // Sync method in async mode - wrap in try-catch if error handler exists
        if (errorHandler != null) {
          final errorHandlerName = errorHandler.method.displayName;
          return '''
try {
  emit(withData($methodCall));
} catch (error, stackTrace) {
  final stack = _\$stack(event.trace, stackTrace);
  bloc.onError(error, stack);
  final data = $errorHandlerName(error, stack);
  emit(withError(error, stack, data));
}''';
        } else {
          return 'emit(withData($methodCall));';
        }
      }
    }

    // Method with _Emitter parameter - pass wrapped emitter
    if (method.hasEmitterParam) {
      const wrappedEmit = r'_$wrapEmit(emit, bloc.state)';
      final emitAndParams = params.isEmpty
          ? wrappedEmit
          : '$wrappedEmit, $params';
      final methodCall = '$methodName($emitAndParams)';

      // Find error handler for this method
      final errorHandler =
          bloc.eventErrorHandlers[methodName] ?? bloc.generalErrorHandler;

      if (method.method.returnType.isDartAsyncFuture) {
        if (errorHandler != null) {
          final errorHandlerName = errorHandler.method.displayName;
          return '''
try {
  await $methodCall;
} catch (error, stackTrace) {
  final stack = _\$stack(event.trace, stackTrace);
  bloc.onError(error, stack);
  final data = $errorHandlerName(error, stack);
  emit(withError(error, stack, data));
}''';
        } else {
          return 'await $methodCall;';
        }
      } else {
        if (errorHandler != null) {
          final errorHandlerName = errorHandler.method.displayName;
          return '''
try {
  $methodCall;
} catch (error, stackTrace) {
  final stack = _\$stack(event.trace, stackTrace);
  bloc.onError(error, stack);
  final data = $errorHandlerName(error, stack);
  emit(withError(error, stack, data));
}''';
        } else {
          return '$methodCall;';
        }
      }
    }

    // Future<_State> or _State - already wrapped
    final methodCall = '$methodName($params)';
    if (method.returnsFutureState) {
      return 'emit(await $methodCall);';
    } else if (method.returnsState) {
      return 'emit($methodCall);';
    }
  }

  // Normal bloc handling
  final String methodCall;
  if (method.hasEmitterParam) {
    // Pass emit as first parameter
    final emitAndParams = params.isEmpty ? 'emit' : 'emit, $params';
    methodCall = '$methodName($emitAndParams)';
  } else {
    methodCall = '$methodName($params)';
  }

  String body;

  if (method.returnsStream) {
    // For Stream<State>, use emit.forEach for proper cancellation support
    body =
        'await emit.forEach<${method.stateName}>($methodCall, onData: (state) => state);';
  } else if (method.returnsFutureState) {
    // For Future<State>, await and emit the result
    body = 'emit(await $methodCall);';
  } else if (method.returnsState) {
    // For State, emit the returned state
    body = 'emit($methodCall);';
  } else if (method.method.returnType.isDartAsyncFuture) {
    // For Future<void> with Emitter param, await the call
    body = 'await $methodCall;';
  } else {
    // For void with Emitter param, just call
    body = '$methodCall;';
  }

  // Wrap in error handler if provided, otherwise wrap with default error handling
  final errorHandler =
      bloc.eventErrorHandlers[methodName] ?? bloc.generalErrorHandler;
  if (errorHandler != null) {
    body = _wrapWithErrorHandler(body, errorHandler, method, bloc);
  } else {
    // Always wrap in try/catch to filter stack traces
    body = _wrapWithDefaultErrorHandler(body);
  }

  return body;
}

/// Build parameter list for error handler call based on its signature
String _buildErrorHandlerParams(
  ErrorHandler handler, {
  String emitterName = 'wrappedEmit',
}) {
  // Build parameters in the order they appear in the handler signature
  final paramCount = [
    handler.errorParamIndex,
    handler.stackParamIndex,
    handler.eventParamIndex,
    handler.emitterParamIndex,
  ].where((idx) => idx != null).length;

  // Create list with correct size
  final orderedParams = List<String?>.filled(paramCount, null);

  if (handler.hasErrorParam && handler.errorParamIndex != null) {
    orderedParams[handler.errorParamIndex!] = 'e';
  }
  if (handler.hasStackParam && handler.stackParamIndex != null) {
    orderedParams[handler.stackParamIndex!] = 'stack';
  }
  if (handler.hasEventParam && handler.eventParamIndex != null) {
    orderedParams[handler.eventParamIndex!] = 'event';
  }
  if (handler.hasEmitterParam && handler.emitterParamIndex != null) {
    orderedParams[handler.emitterParamIndex!] = emitterName;
  }

  return orderedParams.whereType<String>().join(', ');
}

/// Build parameter list for onEvent handler call based on its signature
String _buildOnEventHandlerParams(
  OnEventHandler handler, {
  bool needsCast = false,
}) {
  // Build parameters in the order they appear in the handler signature
  final paramCount = [
    handler.eventParamIndex,
    handler.emitterParamIndex,
  ].where((idx) => idx != null).length;

  // Create list with correct size
  final orderedParams = List<String?>.filled(paramCount, null);

  if (handler.hasEventParam && handler.eventParamIndex != null) {
    // Cast only if needed (fallback handler without type guard)
    orderedParams[handler.eventParamIndex!] = needsCast
        ? 'event as ${handler.eventType}'
        : 'event';
  }
  if (handler.hasEmitterParam && handler.emitterParamIndex != null) {
    orderedParams[handler.emitterParamIndex!] = 'emit';
  }

  return orderedParams.whereType<String>().join(', ');
}

/// Builds the complete event handler wrapper for non-queue events
String _buildEventHandlerWrapper(
  BlocElement bloc,
  method_model.BlocMethodElement method,
) {
  final body = _buildEventHandlerBody(bloc, method);

  // Check if async keyword is needed
  final returnType = method.method.returnType;
  final returnTypeStr = returnType.getDisplayString();

  final isAsync =
      method.returnsStream ||
      method.returnsFutureState ||
      returnType.isDartAsyncFuture ||
      returnTypeStr.startsWith('Stream<') ||
      body.contains('await ');

  final asyncKeyword = isAsync ? 'async' : '';

  return '(event, emit) $asyncKeyword { $body }';
}

String _buildMethodCallParams(method_model.BlocMethodElement method) {
  final params = method.parametersWithoutEmitter.cast<FormalParameterElement>();
  if (params.isEmpty) {
    return '';
  }

  final positional = params
      .where((p) => p.isRequiredPositional || p.isOptionalPositional)
      .map((p) => 'event.${p.name}');
  final named = params
      .where((p) => p.isNamed)
      .map((p) => '${p.name}: event.${p.name}');

  return [...positional, ...named].join(', ');
}

/// Build async helper methods: loading(), loadingClearData(), withData(), withError()
List<Method> _buildAsyncHelperMethods(BlocElement bloc) {
  final unwrappedType = bloc.unwrappedStateName!;

  return [
    // loading() - Returns loading state with current data preserved
    Method(
      (b) => b
        ..name = 'loading'
        ..annotations.add(refer('protected'))
        ..returns = refer('_State')
        ..lambda = true
        ..body = Code(
          'MonoAsyncValue<$unwrappedType>(state.dataOrNull, true, null, null)',
        ),
    ),

    // loadingClearData() - Returns loading state without data
    Method(
      (b) => b
        ..name = 'loadingClearData'
        ..annotations.add(refer('protected'))
        ..returns = refer('_State')
        ..lambda = true
        ..body = const Code('const MonoAsyncValue.loading()'),
    ),

    // withData(T data) - Wraps data in success state
    Method(
      (b) => b
        ..name = 'withData'
        ..annotations.add(refer('protected'))
        ..returns = refer('_State')
        ..requiredParameters.add(
          Parameter(
            (pb) => pb
              ..name = 'data'
              ..type = refer(unwrappedType),
          ),
        )
        ..lambda = true
        ..body = const Code('MonoAsyncValue.withData(data)'),
    ),

    // withError(Object error, StackTrace stackTrace, [T? data]) - Wraps error in error state
    Method(
      (b) => b
        ..name = 'withError'
        ..annotations.add(refer('protected'))
        ..returns = refer('_State')
        ..requiredParameters.addAll([
          Parameter(
            (pb) => pb
              ..name = 'error'
              ..type = refer('Object'),
          ),
          Parameter(
            (pb) => pb
              ..name = 'stackTrace'
              ..type = refer('StackTrace'),
          ),
        ])
        ..optionalParameters.add(
          Parameter(
            (pb) => pb
              ..name = 'data'
              ..type = refer(
                unwrappedType.endsWith('?') ? unwrappedType : '$unwrappedType?',
              ),
          ),
        )
        ..lambda = true
        ..body = const Code(
          'MonoAsyncValue.withError(error, stackTrace, data)',
        ),
    ),
  ];
}

/// Build _$handleError helper method for normal blocs
String _buildHandleErrorHelperNormal(BlocElement bloc) {
  return r'''
  void _$handleError(
    Object e,
    StackTrace s,
    StackTrace eventTrace,
    void Function(StackTrace stack)? errorHandler,
  ) {
    final stack = _$stack(eventTrace, s);
    bloc.onError(e, stack);
    if (errorHandler != null) {
      try {
        errorHandler(stack);
      } catch (e2, s2) {
        bloc.onError(e2, s2);
      }
    }
  }''';
}

String _wrapWithErrorHandler(
  String originalBody,
  ErrorHandler errorHandler,
  method_model.BlocMethodElement method,
  BlocElement bloc,
) {
  final errorHandlerName = errorHandler.method.displayName;
  final params = _buildErrorHandlerParams(errorHandler, emitterName: 'emit');

  final returnType = errorHandler.method.returnType;
  final returnTypeStr = returnType.getDisplayString();
  final isNullable = returnTypeStr.endsWith('?') || errorHandler.isNullable;

  final errorHandlerCall = '$errorHandlerName($params)';

  final returnsState =
      returnTypeStr == method.stateName ||
      returnTypeStr.startsWith('${method.stateName}?');
  final returnsStream = returnTypeStr.startsWith('Stream<');
  final returnsFutureState =
      returnTypeStr.startsWith('Future<${method.stateName}>') ||
      returnTypeStr.startsWith('Future<${method.stateName}?>');
  final isAsync = returnType.isDartAsyncFuture || returnsStream;

  // Build the error handler callback body
  String callbackBody;
  if (returnsStream) {
    callbackBody =
        'await emit.forEach<${method.stateName}>($errorHandlerCall, onData: (state) => state);';
  } else if (returnsFutureState) {
    if (isNullable) {
      callbackBody =
          'final result = await $errorHandlerCall; if (result != null) emit(result);';
    } else {
      callbackBody = 'emit(await $errorHandlerCall);';
    }
  } else if (returnsState) {
    if (isNullable) {
      callbackBody =
          'final result = $errorHandlerCall; if (result != null) emit(result);';
    } else {
      callbackBody = 'emit($errorHandlerCall);';
    }
  } else if (isAsync) {
    callbackBody = 'await $errorHandlerCall;';
  } else {
    callbackBody = '$errorHandlerCall;';
  }

  // Use helper method to handle error
  return 'try { $originalBody } catch (e, s) { _\$handleError(e, s, event.trace, (stack) { $callbackBody }); }';
}

/// Wrap event handler body with default error handling (no custom handler)
/// This filters the stack trace and calls bloc.onError
String _wrapWithDefaultErrorHandler(String originalBody) {
  return '''
try {
  $originalBody
} catch (e, s) {
  final stack = _\$stack(event.trace, s);
  bloc.onError(e, stack);
  rethrow;
}''';
}

/// Determine if we need to generate helper extension type
bool _needsHelperExtensionType(BlocElement bloc) {
  // Always generate helper extension type for:
  // 1. Static _$stack method (needed for error handling)
  // 2. _init() method (called by constructor, even if empty)
  // 3. Async bloc helpers (_$wrapEmit, _$onError)
  // 4. Transformer helpers (_castTransformer, etc.)
  return true;
}

/// Generate helper extension type (callable via _$(this))
Code _writeHelperExtensionType(BlocElement bloc) {
  final blocName = bloc.bloc.name!;
  final buffer = StringBuffer();

  // Start extension type declaration - implements bloc, casts in constructor
  buffer.writeln(
    'extension type _\$._ ($blocName bloc) implements $blocName {',
  );
  buffer.writeln(
    '  _\$(_\$$blocName<dynamic> base): bloc = base as $blocName;',
  );
  buffer.writeln();

  // Add async helpers if async bloc
  if (bloc.isAsync) {
    buffer.writeln(_buildWrapEmitHelperExtension(bloc));
    buffer.writeln();
    buffer.writeln(_buildOnErrorHelperExtension(bloc));
    buffer.writeln();
    buffer.writeln(_buildHandleErrorHelperExtension(bloc));
    buffer.writeln();
  }

  // Add normal bloc helpers if not async but has error handlers
  if (!bloc.isAsync &&
      (bloc.generalErrorHandler != null ||
          bloc.eventErrorHandlers.isNotEmpty)) {
    buffer.writeln(_buildHandleErrorHelperNormal(bloc));
    buffer.writeln();
  }

  // Add transformer helpers (_castTransformer)
  if (_needsTransformerHelpers(bloc)) {
    buffer.writeln(_buildCastTransformerHelperExtension(bloc));
    buffer.writeln();
  }

  // Add onEvent helpers (_filterEvent, _wrapWithOnEvent)
  if (bloc.hasOnEventHandlers) {
    buffer.writeln(_buildFilterEventHelperExtension(bloc));
    buffer.writeln();
    buffer.writeln(_buildWrapWithOnEventHelperExtension(bloc));
    buffer.writeln();
  }

  // Add _init method (always needed since constructor always calls it)
  buffer.writeln(_buildInitMethodHelperExtension(bloc));
  buffer.writeln();

  // Add static stack helper (always needed)
  buffer.writeln(_buildStackHelperStaticExtension(bloc));

  // Close extension type
  buffer.writeln('}');

  return Code(buffer.toString());
}

/// Build _$wrapEmit helper for async blocs
String _buildWrapEmitHelperExtension(BlocElement bloc) {
  final unwrappedType = bloc.unwrappedStateName!;

  // Sequential async blocs use MonoAsyncSeqEmitter (call(), loading(), error() - NO forEach/onEach)
  // Parallel async blocs use MonoAsyncEmitter (same plus forEach(), onEach())
  // Both need bloc reference for loading()/error() to read current state
  if (bloc.sequential) {
    return '''
  MonoAsyncSeqEmitter<$unwrappedType> _\$wrapEmit(Emitter<_State> emit, _State state) {
    return MonoAsyncSeqEmitter<$unwrappedType>(emit, bloc);
  }''';
  } else {
    return '''
  MonoAsyncEmitter<$unwrappedType> _\$wrapEmit(Emitter<_State> emit, _State state) {
    return MonoAsyncEmitter<$unwrappedType>(emit, bloc);
  }''';
  }
}

/// Build _$onError helper for async blocs - creates stack and calls bloc.onError
String _buildOnErrorHelperExtension(BlocElement bloc) {
  return r'''
  StackTrace _$onError(StackTrace eventTrace, Object e, StackTrace s) {
    final stack = _$stack(eventTrace, s);
    bloc.onError(e, stack);
    return stack;
  }''';
}

/// Build _$handleError helper for async blocs - complete error handling with callback
String _buildHandleErrorHelperExtension(BlocElement bloc) {
  return r'''
  void _$handleError(
    Object e,
    StackTrace s,
    StackTrace eventTrace,
    void Function(StackTrace stack)? errorHandler,
  ) {
    final stack = _$onError(eventTrace, e, s);
    if (errorHandler != null) {
      try {
        errorHandler(stack);
      } catch (e2, s2) {
        bloc.onError(e2, s2);
      }
    }
  }''';
}

/// Build static _$stack helper for extension type
String _buildStackHelperStaticExtension(BlocElement bloc) {
  final generatedFileName = bloc.sourceFileName.replaceFirst(
    '.dart',
    '.g.dart',
  );
  return '''
  static StackTrace _\$stack(StackTrace origin, StackTrace trace) {
    return MonoStackTrace.filtered(origin, trace, '$generatedFileName');
  }''';
}

/// Build _castTransformer helper for extension type
String _buildCastTransformerHelperExtension(BlocElement bloc) {
  return '''
  EventTransformer<E> _castTransformer<E>(
    EventTransformer<dynamic> transformer,
  ) {
    return (events, mapper) => transformer(
      events.cast<dynamic>(),
      (event) => mapper(event as E).cast<dynamic>(),
    ).cast<E>();
  }''';
}

/// Build _filterEvent helper for extension type
String _buildFilterEventHelperExtension(BlocElement bloc) {
  final handlers = bloc.onEventHandlers;
  final buffer = StringBuffer();

  buffer.writeln('  // ignore: avoid_annotating_with_dynamic');
  buffer.writeln('  bool _filterEvent(dynamic event) {');
  buffer.writeln(r'    final $ = bloc;');

  // Build type-specific filtering logic
  final specificChecks = <String>[];
  final groupChecks = <String>[];
  String? fallbackCheck;

  handlers.forEach((eventTypeKey, handler) {
    final actualEventType = handler.eventType;
    final methodName = handler.method.displayName;

    if (actualEventType == bloc.eventName) {
      // All events handler - fallback (cast needed since parameter is dynamic)
      final handlerParams = _buildOnEventHandlerParams(
        handler,
        needsCast: true,
      );
      fallbackCheck = 'return \$.$methodName($handlerParams);';
    } else if (actualEventType.startsWith(r'_$')) {
      // Event group handler
      final handlerParams = _buildOnEventHandlerParams(handler);
      groupChecks.add(
        'if (event is $actualEventType) return \$.$methodName($handlerParams);',
      );
    } else {
      // Specific event handler
      final handlerParams = _buildOnEventHandlerParams(handler);
      specificChecks.add(
        'if (event is $actualEventType) return \$.$methodName($handlerParams);',
      );
    }
  });

  // Add specific checks first (highest priority)
  if (specificChecks.isNotEmpty) {
    buffer.writeln('    // Check specific event type first');
    for (final check in specificChecks) {
      buffer.writeln('    $check');
    }
  }

  // Add group checks (medium priority)
  for (final check in groupChecks) {
    buffer.writeln('    $check');
  }

  // Add fallback (lowest priority)
  if (fallbackCheck != null) {
    buffer.writeln('    // Fallback to all events handler');
    buffer.writeln('    $fallbackCheck');
  } else {
    buffer.writeln('    // No matching handler, allow event');
    buffer.writeln('    return true;');
  }

  buffer.writeln('  }');

  return buffer.toString();
}

/// Build _wrapWithOnEvent helper for extension type
String _buildWrapWithOnEventHelperExtension(BlocElement bloc) {
  final buffer = StringBuffer();

  buffer.writeln(
    '  EventTransformer<E> _wrapWithOnEvent<E>(EventTransformer<E> transformer) {',
  );
  buffer.writeln('    return (events, mapper) {');
  buffer.writeln('      // ignore: unnecessary_lambdas');
  buffer.writeln(
    '      final filteredEvents = events.where((event) => _filterEvent(event));',
  );
  buffer.writeln('      return transformer(filteredEvents, mapper);');
  buffer.writeln('    };');
  buffer.writeln('  }');

  return buffer.toString();
}
