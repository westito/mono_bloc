import 'package:build/build.dart';
import 'package:yaml/yaml.dart';

/// Reads formatter options from analysis_options.yaml
class FormatterOptions {
  const FormatterOptions({this.pageWidth = 80});

  final int pageWidth;

  /// Reads formatter options from analysis_options.yaml using BuildStep
  static Future<FormatterOptions> fromBuildStep(BuildStep buildStep) async {
    try {
      // Try to read analysis_options.yaml from the package root
      final packageId = AssetId(
        buildStep.inputId.package,
        'analysis_options.yaml',
      );

      if (await buildStep.canRead(packageId)) {
        final content = await buildStep.readAsString(packageId);
        return FormatterOptions._parseAnalysisOptions(content);
      }

      return const FormatterOptions();
    } catch (e) {
      // If anything goes wrong, return default options
      return const FormatterOptions();
    }
  }

  /// Parse analysis_options.yaml content
  factory FormatterOptions._parseAnalysisOptions(String content) {
    try {
      final yaml = loadYaml(content) as Map?;

      if (yaml == null) {
        return const FormatterOptions();
      }

      // Read formatter.page_width
      final formatter = yaml['formatter'] as Map?;
      if (formatter != null) {
        final pageWidth = formatter['page_width'] as int?;
        if (pageWidth != null) {
          return FormatterOptions(pageWidth: pageWidth);
        }
      }

      return const FormatterOptions();
    } catch (e) {
      return const FormatterOptions();
    }
  }
}
