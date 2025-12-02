part of 'bloc_visitor.dart';

/// Validates that required imports are present in the file
void _validateRequiredImports(ClassElement element) {
  try {
    // Get the source file path
    final filePath = element.library.firstFragment.source.fullName;
    if (filePath.isEmpty) return;

    // Skip validation for test mock files (used by build_test)
    // Allows '/pkg/lib/' paths ONLY for import_tests directory
    if (filePath.contains('/pkg/lib/') && !filePath.contains('import_tests')) {
      return;
    }

    // Read the source file
    final session = element.session;
    if (session == null) return;

    final resourceProvider = session.resourceProvider;
    final file = resourceProvider.getFile(filePath);
    if (!file.exists) return;

    final content = file.readAsStringSync();

    // Extract filename for part directive validation
    final fileName = filePath.split('/').last;
    final expectedPartFile = fileName.replaceFirst('.dart', '.g.dart');

    // Check for required imports - only check for main library exports, not src/ imports
    final hasBlocImport = RegExp(
      r'''import\s+['"]package:bloc/bloc\.dart['"]''',
    ).hasMatch(content);
    final hasMonoBlocImport = RegExp(
      r'''import\s+['"]package:mono_bloc/mono_bloc\.dart['"]''',
    ).hasMatch(content);
    final hasMonoBlocFlutterImport = RegExp(
      r'''import\s+['"]package:mono_bloc_flutter/mono_bloc_flutter\.dart['"]''',
    ).hasMatch(content);
    final hasPartDirective = RegExp(
      '''part\\s+['"]$expectedPartFile['"];''',
    ).hasMatch(content);

    final errors = <String>[];

    // package:bloc/bloc.dart is required, either directly or through mono_bloc/mono_bloc_flutter
    // mono_bloc and mono_bloc_flutter both export bloc/bloc.dart
    final hasBlocAvailable =
        hasBlocImport || hasMonoBlocImport || hasMonoBlocFlutterImport;
    if (!hasBlocAvailable) {
      errors.add(
        'Missing import:\n'
        "  import 'package:bloc/bloc.dart';\n\n"
        'This import is REQUIRED for all @MonoBloc classes to extend Bloc.',
      );
    }

    // Either mono_bloc or mono_bloc_flutter is required
    if (!hasMonoBlocImport && !hasMonoBlocFlutterImport) {
      errors.add(
        'Missing import:\n'
        "  import 'package:mono_bloc/mono_bloc.dart';\n"
        'OR\n'
        "  import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';\n\n"
        'One of these imports is REQUIRED for @MonoBloc annotation and transformers.\n'
        'Use mono_bloc_flutter if you need @MonoActions with Flutter widgets.',
      );
    }

    // Check for part directive
    if (!hasPartDirective) {
      errors.add(
        'Missing part directive:\n'
        "  part '$expectedPartFile';\n\n"
        'The part directive is REQUIRED to include the generated code.\n'
        'Without it, the generated base class _\$${element.name} will not be available.',
      );
    }

    // Throw detailed error if any required imports/directives are missing
    if (errors.isNotEmpty) {
      final errorDetails = errors
          .asMap()
          .entries
          .map((e) => '${e.key + 1}. ${e.value}')
          .join('\n\n');

      throw InvalidGenerationSourceError(
        'Code generation failed for @MonoBloc class "${element.name}".\n\n'
        'File: $fileName\n\n'
        '$errorDetails\n\n'
        'Complete example:\n'
        "  import 'package:bloc/bloc.dart';\n"
        "  import 'package:mono_bloc/mono_bloc.dart';  // or mono_bloc_flutter\n"
        '  \n'
        "  part '$expectedPartFile';\n"
        '  \n'
        '  @MonoBloc()\n'
        '  class ${element.name} extends _\$${element.name}<YourState> {\n'
        '    ${element.name}() : super(initialState);\n'
        '    \n'
        '    @event\n'
        '    YourState _onSomeEvent() => state;\n'
        '  }',
        element: element,
      );
    }
  } catch (e) {
    // If validation fails for any reason (e.g., file access), skip it
    // The actual compilation will fail later with a clearer error if imports are truly missing
    if (e is InvalidGenerationSourceError) rethrow;
  }
}

/// Validates that @protected annotation has required imports
void _validateProtectedImports(MethodElement method) {
  try {
    // Get the source file path
    final filePath = method.library.firstFragment.source.fullName;
    if (filePath.isEmpty) return;

    // Read the source file
    final session = method.session;
    if (session == null) return;

    final resourceProvider = session.resourceProvider;
    final file = resourceProvider.getFile(filePath);
    if (!file.exists) return;

    final content = file.readAsStringSync();

    // Check if any of the required imports for @protected are present
    // mono_bloc and mono_bloc_flutter both export meta/meta.dart
    final hasMonoBlocImport = RegExp(
      r'''import\s+['"]package:mono_bloc/mono_bloc\.dart['"]''',
    ).hasMatch(content);
    final hasMonoBlocFlutterImport = RegExp(
      r'''import\s+['"]package:mono_bloc_flutter/mono_bloc_flutter\.dart['"]''',
    ).hasMatch(content);
    final hasFlutterMaterialImport = RegExp(
      r'''import\s+['"]package:flutter/material.dart['"]''',
    ).hasMatch(content);
    final hasFlutterCupertinoImport = RegExp(
      r'''import\s+['"]package:flutter/cupertino.dart['"]''',
    ).hasMatch(content);
    final hasFlutterFoundationImport = RegExp(
      r'''import\s+['"]package:flutter/foundation.dart['"]''',
    ).hasMatch(content);

    final hasAnyValidImport =
        hasMonoBlocImport ||
        hasMonoBlocFlutterImport ||
        hasFlutterMaterialImport ||
        hasFlutterCupertinoImport ||
        hasFlutterFoundationImport;

    if (!hasAnyValidImport) {
      throw InvalidGenerationSourceError(
        'Public @event method "${method.name}" uses @protected annotation but is missing required import.\n\n'
        'The @protected annotation is available from mono_bloc/mono_bloc_flutter or Flutter packages:\n'
        "  import 'package:mono_bloc/mono_bloc.dart';\n"
        "  import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';\n"
        "  import 'package:flutter/material.dart';\n"
        "  import 'package:flutter/foundation.dart';\n\n"
        'Add one of these imports at the top of your file.',
        element: method,
      );
    }
  } catch (e) {
    // If validation fails for any reason (e.g., file access), skip it
    if (e is InvalidGenerationSourceError) rethrow;
  }
}

/// Check for conflicts in generated public method names
/// Example: _onOnlyRics() -> onlyRics() might conflict with onLyrics()
void _checkForMethodNameConflicts(BlocElement blocElement) {
  final publicMethodNames =
      <String, String>{}; // methodName -> sourceMethodName
  const reservedNames = {
    'add',
    'on',
    'emit',
    'close',
    'isClosed',
    'state',
    'stream',
  };

  for (final method in blocElement.methods) {
    final sourceName = method.name;
    final publicName = _generatePublicMethodNameFromSource(sourceName);

    // Check for reserved name conflicts
    if (reservedNames.contains(publicName)) {
      throw InvalidGenerationSourceError(
        'Method "$sourceName" would generate a public method "$publicName()" which conflicts with a reserved BLoC method name.\n\n'
        'Reserved names: ${reservedNames.join(', ')}\n\n'
        'Solution: Rename your method to avoid this conflict.\n'
        'Example: _onAdd() -> _onAddAmount() generates addAmount()',
        element: method.method,
      );
    }

    // Check if this public name already exists
    if (publicMethodNames.containsKey(publicName)) {
      throw InvalidGenerationSourceError(
        'Method name conflict detected!\n\n'
        'Both "$sourceName" and "${publicMethodNames[publicName]}" would generate the same public method "$publicName()".\n\n'
        'This creates ambiguity. Please rename one of the methods to avoid the conflict.\n\n'
        'Example:\n'
        '  _onOnlyRics() -> onlyRics()\n'
        '  onLyrics() -> onLyrics()  // CONFLICT!\n\n'
        'Solution: Rename one method to something different.',
        element: method.method,
      );
    }

    publicMethodNames[publicName] = sourceName;
  }
}
