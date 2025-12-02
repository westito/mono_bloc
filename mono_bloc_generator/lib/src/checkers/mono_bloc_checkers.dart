import 'package:source_gen/source_gen.dart' show TypeChecker;

const blocChecker = TypeChecker.fromUrl('package:bloc/bloc.dart#Bloc');

const monoBlocAnnotationChecker = TypeChecker.fromUrl(
  'package:mono_bloc/src/annotations/mono_bloc.dart#MonoBloc',
);

const asyncMonoBlocAnnotationChecker = TypeChecker.fromUrl(
  'package:mono_bloc/src/annotations/async_mono_bloc.dart#AsyncMonoBloc',
);

const ignoreChecker = TypeChecker.fromUrl(
  'package:mono_bloc/src/annotations/mono_bloc.dart#Ignore',
);

const createFactoryChecker = TypeChecker.fromUrl(
  'package:mono_bloc/src/annotations/mono_bloc.dart#CreateFactory',
);

const monoEventChecker = TypeChecker.fromUrl(
  'package:mono_bloc/src/annotations/mono_event.dart#MonoEvent',
);

const monoInitChecker = TypeChecker.fromUrl(
  'package:mono_bloc/src/annotations/mono_init.dart#MonoInit',
);

const errorHandlerChecker = TypeChecker.fromUrl(
  'package:mono_bloc/src/annotations/error_handler.dart#MonoOnError',
);

const onEventChecker = TypeChecker.fromUrl(
  'package:mono_bloc/src/annotations/on_event.dart#MonoOnEvent',
);

const protectedChecker = TypeChecker.fromUrl(
  'package:meta/meta.dart#_Protected',
);

// @MonoActions annotation marks a mixin as containing action methods
// All abstract void methods in the mixin become actions automatically
const monoActionsChecker = TypeChecker.fromUrl(
  'package:mono_bloc/src/annotations/mono_actions.dart#MonoActions',
);
