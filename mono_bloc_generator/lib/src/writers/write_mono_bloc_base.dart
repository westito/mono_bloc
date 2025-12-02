part of 'write_mono_bloc.dart';

/// Generate the base class with event handlers and public methods
Class _writeBaseClass(BlocElement bloc) {
  final className = '_\$${bloc.bloc.name}';
  const eventClassName = '_Event';

  // Use _State typedef in async mode, stateName in normal mode
  final stateType = bloc.isAsync ? '_State' : bloc.stateName;
  final needsTransformers = _needsTransformerHelpers(bloc);

  // Determine what to extend: if user's class has a superclass with @MonoBloc,
  // extend that superclass. Otherwise extend Bloc directly.
  var extendsClause = 'Bloc<$eventClassName, $stateType>';

  final supertype = bloc.bloc.supertype;
  if (supertype != null) {
    final superElement = supertype.element;
    final superName = superElement.name;

    // Check if superclass is a generated base (starts with _$)
    // If so, the user is extending another MonoBloc base class
    if (superName != null && superName.startsWith(r'_$')) {
      // Extract the actual class name: _$AppBaseBloc -> AppBaseBloc
      final actualSuperName = superName.substring(2); // Remove _$
      extendsClause = '$actualSuperName<$stateType>';
    }
  }

  return Class((b) {
    b
      ..name = className
      ..abstract = true
      ..types.add(refer('_'))
      ..extend = refer(extendsClause)
      ..fields.addAll(_buildMonoBlocFields(bloc))
      ..constructors.add(_buildBaseConstructor(bloc))
      ..methods.addAll([
        if (needsTransformers) ..._buildTransformerHelpers(bloc),
        // _init method is now in helper extension
        if (bloc.isAsync) ..._buildAsyncHelperMethods(bloc),
        ..._buildPublicMethods(bloc),
        _buildProtectedAddMethod(bloc),
        _buildProtectedOnMethod(bloc),
        // Add action method implementations directly in base class
        if (bloc.hasActions) ..._buildActionMethodImplementations(bloc),
      ]);

    // Add MonoBlocActionMixin when actions are present
    if (bloc.hasActions) {
      b.mixins.add(refer('MonoBlocActionMixin<_Action, ${bloc.stateName}>'));
      // Also add the user's action mixin so it's implemented
      if (bloc.actionMixinName != null) {
        b.mixins.add(refer(bloc.actionMixinName!));
      }
    }
  });
}

List<Field> _buildMonoBlocFields(BlocElement bloc) {
  final fields = <Field>[];

  // Add queue fields if needed
  if (_hasQueuedMethods(bloc)) {
    fields.add(
      Field(
        (b) => b
          ..name = '_queues'
          ..modifier = FieldModifier.final$
          ..type = refer('Map<String, EventTransformer<dynamic>>'),
      ),
    );
  }

  return fields;
}

Constructor _buildBaseConstructor(BlocElement bloc) {
  final hasQueues = _hasQueuedMethods(bloc);

  return Constructor((b) {
    b
      ..requiredParameters.add(
        Parameter(
          (pb) => pb
            ..name = 'initialState'
            ..toSuper = true,
        ), // Use super parameter (type inferred)
      )
      ..body = const Code(
        r'_$(this)._$init();',
      ); // Always call init method from helper

    if (hasQueues) {
      b
        ..optionalParameters.add(
          Parameter(
            (pb) => pb
              ..name = 'queues'
              ..type = refer('Map<String, EventTransformer<dynamic>>?')
              ..named = true
              ..toThis = false,
          ), // Not toThis because field name is different
        )
        ..initializers.add(const Code('_queues = queues ?? const {}'));
    }
  });
}

/// Build @protected override for add() to hide it from public API
Method _buildProtectedAddMethod(BlocElement bloc) {
  const eventClassName = '_Event';

  return Method(
    (b) => b
      ..annotations.addAll([
        const CodeExpression(Code('override')),
        const CodeExpression(Code('protected')),
      ])
      ..name = 'add'
      ..returns = refer('void')
      ..requiredParameters.add(
        Parameter(
          (p) => p
            ..name = 'event'
            ..type = refer(eventClassName),
        ),
      )
      ..body = const Code('''
if (isClosed) {
  return;
}
super.add(event);'''),
  );
}

/// Build @protected override for on() to hide it from public API
Method _buildProtectedOnMethod(BlocElement bloc) {
  const eventClassName = '_Event';
  final stateType = bloc.isAsync ? '_State' : bloc.stateName;

  return Method(
    (b) => b
      ..annotations.addAll([
        const CodeExpression(Code('override')),
        const CodeExpression(Code('protected')),
      ])
      ..name = 'on'
      ..types.add(refer('E extends $eventClassName'))
      ..returns = refer('void')
      ..requiredParameters.add(
        Parameter(
          (p) => p
            ..name = 'handler'
            ..type = refer('EventHandler<E, $stateType>'),
        ),
      )
      ..optionalParameters.add(
        Parameter(
          (p) => p
            ..name = 'transformer'
            ..type = refer('EventTransformer<E>?')
            ..named = true,
        ),
      )
      ..body = const Code('super.on<E>(handler, transformer: transformer);'),
  );
}

/// Build public event dispatcher methods
List<Method> _buildPublicMethods(BlocElement bloc) {
  return bloc.methods.map((method) {
    // Event class name: uses same logic as _writeEventClasses
    final eventClassName = _generateEventName(method.name);
    final publicName = _generatePublicMethodName(method);
    final params = method.parametersWithoutEmitter
        .cast<FormalParameterElement>();

    return Method.returnsVoid(
      (b) => b
        ..name = publicName
        ..docs.add('/// [${bloc.bloc.name}.${method.name}]')
        ..requiredParameters.addAll(
          params
              .where((p) => p.isRequiredPositional)
              .map(
                (p) => Parameter(
                  (pb) => pb
                    ..name = p.name!
                    ..type = refer(p.type.getDisplayString()),
                ),
              ),
        )
        ..optionalParameters.addAll(
          params
              .where((p) => !p.isRequiredPositional)
              .map(
                (p) => Parameter((pb) {
                  pb
                    ..name = p.name!
                    ..type = refer(p.type.getDisplayString())
                    ..named = p.isNamed;

                  if (p.isRequiredNamed) {
                    pb.required = true;
                  }

                  final defaultValue = p.defaultValueCode;
                  if (defaultValue != null) {
                    pb.defaultTo = Code(defaultValue);
                  }
                }),
              ),
        )
        ..body = _buildPublicMethodBody(method, eventClassName),
    );
  }).toList();
}

Code _buildPublicMethodBody(
  method_model.BlocMethodElement method,
  String eventClassName,
) {
  final params = method.parametersWithoutEmitter.cast<FormalParameterElement>();

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

  // Generate event instantiation
  final eventInstantiation = allArgs.isEmpty
      ? '$eventClassName()'
      : '$eventClassName($allArgs)';

  return Code('add($eventInstantiation);');
}

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

String _generatePublicMethodName(method_model.BlocMethodElement method) {
  // Delegate to helper based on source method name
  final baseName = _generatePublicMethodNameFromSource(method.name);

  // For public @event methods, we already enforce "on" prefix and @protected,
  // so the base helper will currently return the original name (onSomething).
  // We still want public methods like "onMultiply" to become "multiply".
  if (method.isPublicEvent &&
      baseName.startsWith('on') &&
      baseName.length > 2) {
    final nameWithoutOn = baseName.substring(2);
    return nameWithoutOn[0].toLowerCase() + nameWithoutOn.substring(1);
  }

  return baseName;
}
