import 'package:code_builder/code_builder.dart';
import 'package:mono_bloc_generator/src/models/bloc_element.dart';
import 'package:mono_bloc_generator/src/writers/write_mono_bloc.dart';

List<Spec> writeFile(List<BlocElement> blocs) {
  // Return empty list if there are no blocs to generate
  if (blocs.isEmpty) {
    return [];
  }

  final specs = <Spec>[];

  // Generate code for all blocs, even if they have no events or init methods
  specs.addAll(writeMonoBloc(blocs));

  return specs;
}
