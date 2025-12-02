part of 'write_mono_bloc.dart';

/// Generate event base class with stack trace
Class _writeEventBaseClass(BlocElement bloc) {
  const eventClassName = '_Event';

  return Class(
    (b) => b
      ..name = eventClassName
      ..abstract = true
      ..fields.add(
        Field(
          (f) => f
            ..name = 'trace'
            ..modifier = FieldModifier.final$
            ..type = refer('StackTrace'),
        ),
      )
      ..constructors.add(
        Constructor(
          (c) => c..initializers.add(const Code('trace = StackTrace.current')),
        ),
      ),
  );
}

/// Generate queue base classes for sequential and numbered queues
List<Spec> _writeQueueBaseClasses(BlocElement bloc) {
  final classes = <Class>[];

  // Create _$SequentialEvent base class if sequential mode is enabled
  if (bloc.sequential) {
    classes.add(
      Class(
        (b) => b
          ..name = r'_$SequentialEvent'
          ..extend = refer(bloc.eventName),
      ),
    );
  }

  // Collect all unique queue names (explicit queue assignments only)
  final queueNames = bloc.methods
      .map((m) => m.queueNumber)
      .where((q) => q != null)
      .toSet()
      .toList();

  classes.addAll(
    queueNames.map((queueName) {
      // Convert queue name to PascalCase for class name
      final pascalCaseName = _toPascalCase(queueName!);
      return Class(
        (b) => b
          ..name = '_\$${pascalCaseName}QueueEvent'
          ..extend = refer(bloc.eventName),
      );
    }),
  );

  return classes;
}

String _generateEventName(String methodName) {
  // Remove leading underscore
  var name = methodName.startsWith('_') ? methodName.substring(1) : methodName;

  // Remove "on" or "On" prefix if present, but only if followed by uppercase letter
  // This avoids removing "on" from words like "only", "one", etc.
  if (name.length > 2) {
    final startsWithOn = name.substring(0, 2).toLowerCase() == 'on';
    final thirdChar = name[2];
    final thirdCharIsUppercase =
        thirdChar.toUpperCase() == thirdChar &&
        thirdChar.toLowerCase() != thirdChar;

    if (startsWithOn && thirdCharIsUppercase) {
      // onDeposit -> Deposit, OnDeposit -> Deposit
      name = name.substring(2);
    }
  }

  return '_${name.toPascalCase()}Event';
}

/// Generate all event classes for each @event method
List<Spec> _writeEventClasses(BlocElement bloc) {
  final eventClasses = <Class>[];
  const eventClassName = '_Event';
  final eventNames =
      <
        String,
        String
      >{}; // Maps event name to method name for conflict detection

  for (final method in bloc.methods) {
    final className = _generateEventName(method.name);

    // Check for conflicts
    if (eventNames.containsKey(className)) {
      throw InvalidGenerationSourceError(
        'Event name conflict in ${bloc.bloc.name}: '
        'Methods "${eventNames[className]}" and "${method.name}" both generate the same event class "$className". '
        'Please rename one of the methods to avoid this conflict.',
        element: method.method,
      );
    }
    eventNames[className] = method.name;

    // Determine parent class: queue event, sequential event, or main event
    final queueName = method.queueNumber;
    final hasConcurrency = method.concurrency != null;

    final String parentClass;
    if (queueName != null) {
      // Explicit queue assignment - convert to PascalCase
      final pascalCaseName = _toPascalCase(queueName);
      parentClass = '_\$${pascalCaseName}QueueEvent';
    } else if (bloc.sequential && !hasConcurrency) {
      // Sequential mode: simple events extend _$SequentialEvent
      parentClass = r'_$SequentialEvent';
    } else {
      // Default: extend main event class
      parentClass = eventClassName;
    }

    eventClasses.add(
      Class(
        (b) => b
          ..name = className
          ..extend = refer(parentClass)
          ..constructors.add(_buildEventConstructor(method))
          ..fields.addAll(_buildEventFields(method)),
      ),
    );
  }

  // Generate event classes for @onInit methods (same as regular events)
  for (final method in bloc.initMethods) {
    final className = _generateEventName(method.name);

    // Check for conflicts with regular events
    if (eventNames.containsKey(className)) {
      throw InvalidGenerationSourceError(
        'Event name conflict in ${bloc.bloc.name}: '
        '@onInit method "${method.name}" generates the same event class "$className" as another method. '
        'Please rename one of the methods to avoid this conflict.',
        element: method.method,
      );
    }
    eventNames[className] = method.name;

    // @onInit events extend _$SequentialEvent in sequential mode, otherwise _Event
    final String parentClass;
    if (bloc.sequential) {
      parentClass = r'_$SequentialEvent';
    } else {
      parentClass = eventClassName;
    }

    eventClasses.add(
      Class(
        (b) => b
          ..name = className
          ..extend = refer(parentClass)
          ..constructors.add(_buildEventConstructor(method))
          ..fields.addAll(_buildEventFields(method)),
      ),
    );
  }

  return eventClasses;
}

Constructor _buildEventConstructor(method_model.BlocMethodElement method) {
  final params = method.parametersWithoutEmitter.cast<FormalParameterElement>();

  return Constructor(
    (b) => b
      ..requiredParameters.addAll(
        params
            .where((p) => p.isRequiredPositional)
            .map(
              (p) => Parameter(
                (pb) => pb
                  ..name = p.name!
                  ..toThis = true,
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
                  ..toThis = true
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
      ),
  );
}

List<Field> _buildEventFields(method_model.BlocMethodElement method) {
  final params = method.parametersWithoutEmitter.cast<FormalParameterElement>();

  return params.map((p) {
    return Field(
      (b) => b
        ..name = p.name
        ..modifier = FieldModifier.final$
        ..type = refer(p.type.getDisplayString()),
    );
  }).toList();
}

/// Convert a queue name to PascalCase for use in class names
/// Examples:
///   'upload' -> 'Upload'
///   'upload_file' -> 'UploadFile'
///   'my_queue_1' -> 'MyQueue1'
///   'myQueue' -> 'MyQueue'
///   'myQueueName' -> 'MyQueueName'
String _toPascalCase(String name) {
  if (name.isEmpty) return name;

  // Split by underscores first
  final parts = name.split('_');

  // For each part, handle camelCase by inserting boundaries before uppercase letters
  final allParts = <String>[];
  for (final part in parts) {
    if (part.isEmpty) continue;

    // Split camelCase words
    final camelParts = <String>[];
    final buffer = StringBuffer();

    for (var i = 0; i < part.length; i++) {
      final char = part[i];
      final isUpper = char.toUpperCase() == char && char.toLowerCase() != char;

      if (isUpper && buffer.isNotEmpty) {
        // Start of new word
        camelParts.add(buffer.toString());
        buffer.clear();
      }
      buffer.write(char);
    }

    if (buffer.isNotEmpty) {
      camelParts.add(buffer.toString());
    }

    allParts.addAll(camelParts);
  }

  // Capitalize first letter of each part
  final capitalized = allParts.map((part) {
    if (part.isEmpty) return part;
    return part[0].toUpperCase() + part.substring(1).toLowerCase();
  });

  return capitalized.join();
}
