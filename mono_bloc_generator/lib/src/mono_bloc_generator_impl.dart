import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:mono_bloc_generator/src/utils/formatter_options.dart';
import 'package:mono_bloc_generator/src/visitors/bloc_visitor.dart';
import 'package:mono_bloc_generator/src/writers/write_file.dart';
import 'package:source_gen/source_gen.dart';

/// Code generator for @MonoBloc annotated classes.
///
/// Generates event classes, handlers, and boilerplate code for bloc pattern.
final class MonoBlocGenerator extends Generator {
  /// Creates a new MonoBloc generator instance.
  MonoBlocGenerator();

  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    // Detect if this is a Flutter project by checking pubspec.yaml
    final isFlutterProject = await _isFlutterProject(buildStep);

    final visitor = BlocVisitor(isFlutterProject: isFlutterProject);

    library.element.visitChildren(visitor);

    final emitter = DartEmitter(useNullSafetySyntax: true);

    final generated = writeFile(visitor.blocs);

    if (generated.isEmpty) {
      return '';
    }

    // Add ignore directive as the first line of generated code
    const ignoreDirective =
        '// ignore_for_file: unused_element, prefer_foreach, library_private_types_in_public_api, always_put_control_body_on_new_line, invalid_use_of_protected_member, avoid_annotating_with_dynamic, avoid_futureor_void\n\n';

    final output = generated.map((e) => e.accept(emitter)).join('\n');

    // Read formatter options from analysis_options.yaml
    final formatterOptions = await FormatterOptions.fromBuildStep(buildStep);

    return DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
      pageWidth: formatterOptions.pageWidth,
    ).format(ignoreDirective + output);
  }

  /// Check if this is a Flutter project by reading pubspec.yaml
  Future<bool> _isFlutterProject(BuildStep buildStep) async {
    try {
      final pubspecId = AssetId(buildStep.inputId.package, 'pubspec.yaml');

      if (await buildStep.canRead(pubspecId)) {
        final content = await buildStep.readAsString(pubspecId);
        // Check for flutter SDK dependency:
        //   dependencies:
        //     flutter:
        //       sdk: flutter
        return RegExp(
          r'flutter:\s+sdk:\s*flutter',
          multiLine: true,
        ).hasMatch(content);
      }

      return false;
    } catch (e) {
      // If we can't read pubspec.yaml, assume pure Dart
      return false;
    }
  }
}
