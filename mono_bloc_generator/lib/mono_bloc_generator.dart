/// Code generator for MonoBloc state management library.
///
/// This library provides build_runner integration for generating boilerplate code
/// for @MonoBloc annotated classes.
library;

import 'package:build/build.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';

/// The entry point for the MonoBloc generator.
Builder monoBlocGenerator(BuilderOptions options) {
  return SharedPartBuilder([MonoBlocGenerator()], 'mono_bloc_generator');
}
