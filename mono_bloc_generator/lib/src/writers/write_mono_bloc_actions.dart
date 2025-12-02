part of 'write_mono_bloc.dart';

/// Helper to get parameter type string, preferring source code representation
/// This preserves typedefs and record types
String _getParamType(
  method_model.ActionMethodElement action,
  FormalParameterElement p,
) {
  return action.sourceParameterTypes?[p.name] ?? p.type.getDisplayString();
}

/// Generate abstract interface class with when() and of() factory methods
/// The class name is derived from the mixin name (e.g., _CartBlocActions -> CartBlocActions)
Code _writeBlocActionsClass(BlocElement bloc) {
  final buffer = StringBuffer();
  // Use mixin name without underscore prefix for the interface class name
  final mixinName = bloc.actionMixinName!;
  final className = mixinName.substring(1); // Remove leading underscore
  final hasFlutter = bloc.isFlutterProject;

  // Start abstract interface class
  buffer.writeln('abstract interface class $className {');

  // Generate abstract method signatures
  for (final action in bloc.actionMethods) {
    final params = action.parameters.cast<FormalParameterElement>();
    final camelCaseName = action.name;

    // Build method signature - include BuildContext only if Flutter is imported
    buffer.write('  FutureOr<void> $camelCaseName(');

    final positionalParams = params.where(
      (p) => p.isRequiredPositional || p.isOptionalPositional,
    );
    final namedParams = params.where((p) => p.isNamed);

    if (hasFlutter) {
      buffer.write('BuildContext context');
      if (params.isNotEmpty) {
        buffer.write(', ');
      }
    }

    if (positionalParams.isNotEmpty) {
      buffer.write(
        positionalParams
            .map((p) => '${_getParamType(action, p)} ${p.name}')
            .join(', '),
      );
    }
    if (namedParams.isNotEmpty) {
      if (positionalParams.isNotEmpty) buffer.write(', ');
      buffer.write('{');
      buffer.write(
        namedParams
            .map((p) {
              final required = p.isRequiredNamed ? 'required ' : '';
              return '$required${_getParamType(action, p)} ${p.name}';
            })
            .join(', '),
      );
      buffer.write('}');
    }

    buffer.writeln(');');
  }

  buffer.writeln();

  // Generate static 'when' factory method
  buffer.writeln('  static _\$$className when({');
  for (final action in bloc.actionMethods) {
    final params = action.parameters.cast<FormalParameterElement>();
    final camelCaseName = action.name;

    // Build parameter list for callback
    buffer.write('    FutureOr<void> Function(');

    final positionalParams = params.where(
      (p) => p.isRequiredPositional || p.isOptionalPositional,
    );
    final namedParams = params.where((p) => p.isNamed);

    if (hasFlutter) {
      buffer.write('BuildContext context');
      if (params.isNotEmpty) {
        buffer.write(', ');
      }
    }

    if (positionalParams.isNotEmpty) {
      buffer.write(
        positionalParams
            .map((p) => '${_getParamType(action, p)} ${p.name}')
            .join(', '),
      );
    }
    if (namedParams.isNotEmpty) {
      if (positionalParams.isNotEmpty) buffer.write(', ');
      buffer.write('{');
      buffer.write(
        namedParams
            .map((p) {
              final required = p.isRequiredNamed ? 'required ' : '';
              return '$required${_getParamType(action, p)} ${p.name}';
            })
            .join(', '),
      );
      buffer.write('}');
    }
    buffer.writeln(')? $camelCaseName,');
  }

  buffer.writeln('  }) => _\$$className(');
  if (hasFlutter) {
    buffer.writeln('    actions: (bloc, context, action) {');
  } else {
    buffer.writeln('    actions: (bloc, action) {');
  }
  buffer.writeln('      switch (action) {');

  // Generate switch cases for when() factory
  for (final action in bloc.actionMethods) {
    final actionClassName = action.actionClassName;
    final camelCaseName = action.name;
    final params = action.parameters.cast<FormalParameterElement>();

    // Build callback invocation
    final positionalArgs = params
        .where((p) => p.isRequiredPositional || p.isOptionalPositional)
        .map((p) => p.name!);
    final namedArgs = params
        .where((p) => p.isNamed)
        .map((p) => '${p.name!}: ${p.name!}');

    final allArgs = <String>[];
    if (hasFlutter) {
      allArgs.add('context');
    }
    allArgs.addAll(positionalArgs);
    allArgs.addAll(namedArgs);

    final callbackInvocation = '$camelCaseName(${allArgs.join(', ')})';

    if (params.isEmpty) {
      buffer.writeln('        case $actionClassName(:final trace):');
    } else {
      // Build pattern matching for parameters
      final patternFields = params.map((p) => ':final ${p.name!}').join(', ');
      buffer.writeln(
        '        case $actionClassName($patternFields, :final trace):',
      );
    }

    buffer.writeln('          if ($camelCaseName != null) {');
    buffer.writeln('            unawaited(Future.sync(() async {');
    buffer.writeln('              try {');
    buffer.writeln('                await $callbackInvocation;');
    buffer.writeln('              } catch (e, s) {');
    buffer.writeln(r'                bloc.onError(e, _$._$stack(trace, s));');
    buffer.writeln('              }');
    buffer.writeln('            }));');
    buffer.writeln('          }');
  }

  buffer.writeln('      }');
  buffer.writeln('    },');
  buffer.writeln('  );');
  buffer.writeln();

  // Generate static 'of' factory method
  buffer.writeln(
    '  static _\$$className of($className actions) => when(',
  );
  for (final action in bloc.actionMethods) {
    final camelCaseName = action.name;
    buffer.writeln('    $camelCaseName: actions.$camelCaseName,');
  }
  buffer.writeln('  );');

  buffer.writeln('}');
  buffer.writeln();

  // Generate private implementation class
  final baseClass = hasFlutter ? 'FlutterMonoBlocActions' : 'MonoBlocActions';
  buffer.writeln('class _\$$className extends $baseClass {');
  buffer.writeln('  @override');
  if (hasFlutter) {
    buffer.writeln(
      '  final void Function(BlocBase<dynamic> bloc, BuildContext context, dynamic action) actions;',
    );
  } else {
    buffer.writeln(
      '  final void Function(BlocBase<dynamic> bloc, dynamic action) actions;',
    );
  }
  buffer.writeln();
  buffer.writeln('  _\$$className({required this.actions});');
  buffer.writeln('}');

  return Code(buffer.toString());
}

/// Generate sealed action base class with stack trace capture
Code _writeActionBaseClass(BlocElement bloc) {
  final buffer = StringBuffer();

  // Start sealed class with trace field (like _Event)
  buffer.writeln('sealed class _Action {');
  buffer.writeln('  _Action() : trace = StackTrace.current;');
  buffer.writeln('  final StackTrace trace;');
  buffer.writeln('}');

  return Code(buffer.toString());
}

/// Generate concrete action classes for each action method in @MonoActions() mixin
List<Spec> _writeActionClasses(BlocElement bloc) {
  final actionClasses = <Class>[];

  for (final action in bloc.actionMethods) {
    final className = action.actionClassName;
    final params = action.parameters.cast<FormalParameterElement>();

    actionClasses.add(
      Class(
        (b) => b
          ..name = className
          ..modifier = ClassModifier.final$
          ..extend = refer('_Action')
          ..constructors.add(
            Constructor((c) {
              // Cannot be const - parent _Action captures StackTrace.current

              // Add parameters
              c.requiredParameters.addAll(
                params
                    .where((p) => p.isRequiredPositional)
                    .map<Parameter>(
                      (p) => Parameter(
                        (pb) => pb
                          ..name = p.name!
                          ..toThis = true,
                      ),
                    ),
              );

              c.optionalParameters.addAll(
                params
                    .where((p) => !p.isRequiredPositional)
                    .map<Parameter>(
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
              );
            }),
          )
          ..fields.addAll(
            params.map<Field>((p) {
              // Use source type if available (preserves typedefs and records)
              // Otherwise fall back to analyzer's resolved type
              final typeString =
                  action.sourceParameterTypes?[p.name] ??
                  p.type.getDisplayString();
              return Field(
                (b) => b
                  ..name = p.name
                  ..modifier = FieldModifier.final$
                  ..type = refer(typeString),
              );
            }),
          ),
      ),
    );
  }

  return actionClasses;
}

/// Generate action method implementations for the base class
/// These implement the abstract methods from the action mixin
List<Method> _buildActionMethodImplementations(BlocElement bloc) {
  return bloc.actionMethods.map((action) {
    final actionClassName = action.actionClassName;
    final params = action.parameters.cast<FormalParameterElement>();

    // Build parameter list for action instantiation
    final positionalArgs = params
        .where((p) => p.isRequiredPositional || p.isOptionalPositional)
        .map((p) => p.name!)
        .join(', ');

    final namedArgs = params
        .where((p) => p.isNamed)
        .map((p) => '${p.name}: ${p.name}')
        .join(', ');

    final allArgs = [
      positionalArgs,
      namedArgs,
    ].where((s) => s.isNotEmpty).join(', ');

    // Never use const - _Action captures StackTrace.current

    return Method(
      (b) => b
        ..annotations.add(refer('override'))
        ..name = action.name
        ..returns = refer('void')
        ..requiredParameters.addAll(
          params
              .where((p) => p.isRequiredPositional)
              .map<Parameter>(
                (p) => Parameter(
                  (pb) => pb
                    ..name = p.name!
                    ..type = refer(_getParamType(action, p)),
                ),
              ),
        )
        ..optionalParameters.addAll(
          params
              .where((p) => !p.isRequiredPositional)
              .map<Parameter>(
                (p) => Parameter((pb) {
                  pb
                    ..name = p.name!
                    ..type = refer(_getParamType(action, p))
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
        ..body = Code(
          'actionController?.add($actionClassName($allArgs));',
        ),
    );
  }).toList();
}
