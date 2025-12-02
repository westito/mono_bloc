import 'package:analyzer/dart/element/element.dart';
import 'package:change_case/change_case.dart';
import 'package:code_builder/code_builder.dart';
import 'package:mono_bloc_generator/src/models/bloc_element.dart';
import 'package:mono_bloc_generator/src/models/method_element.dart'
    as method_model;
import 'package:source_gen/source_gen.dart';

part 'write_mono_bloc_actions.dart';
part 'write_mono_bloc_base.dart';
part 'write_mono_bloc_events.dart';
part 'write_mono_bloc_helpers.dart';

List<Spec> writeMonoBloc(List<BlocElement> blocs) {
  final specs = <Spec>[];

  for (final bloc in blocs) {
    // Generate typedefs
    if (bloc.isAsync) {
      specs.add(_writeStateTypedef(bloc));
    }
    specs.add(_writeEmitterTypedef(bloc));

    specs.add(_writeEventBaseClass(bloc));
    specs.addAll(_writeQueueBaseClasses(bloc));
    specs.addAll(_writeEventClasses(bloc));

    // Always generate base class with all methods (including action implementations)
    specs.add(_writeBaseClass(bloc));

    // If there are actions, generate action classes (no Impl class needed)
    if (bloc.hasActions) {
      specs.addAll(_writeActionClasses(bloc));
      specs.add(_writeBlocActionsClass(bloc));
      specs.add(_writeActionBaseClass(bloc));
    }

    // Generate helper extension type at the end (after all types are defined)
    if (_needsHelperExtensionType(bloc)) {
      specs.add(_writeHelperExtensionType(bloc));
    }
  }

  return specs;
}

/// Generate _State typedef for async mode only
TypeDef _writeStateTypedef(BlocElement bloc) {
  return TypeDef(
    (b) => b
      ..name = '_State'
      ..definition = refer(bloc.stateName), // MonoAsyncValue<T>
  );
}

/// Generate _Emitter typedef for both async and normal modes
TypeDef _writeEmitterTypedef(BlocElement bloc) {
  if (bloc.isAsync && bloc.sequential) {
    // Sequential async mode: typedef _Emitter = MonoAsyncSeqEmitter<T>
    // MonoAsyncSeqEmitter only has call() method to prevent forEach/onEach deadlocks
    return TypeDef(
      (b) => b
        ..name = '_Emitter'
        ..definition = refer('MonoAsyncSeqEmitter<${bloc.unwrappedStateName}>'),
    );
  } else if (bloc.isAsync) {
    // Parallel async mode: typedef _Emitter = MonoAsyncEmitter<T>
    return TypeDef(
      (b) => b
        ..name = '_Emitter'
        ..definition = refer('MonoAsyncEmitter<${bloc.unwrappedStateName}>'),
    );
  } else if (bloc.sequential) {
    // Sequential non-async mode: typedef _Emitter = MonoSeqEmitter<State>
    // MonoSeqEmitter only has call() method to prevent forEach/onEach deadlocks
    return TypeDef(
      (b) => b
        ..name = '_Emitter'
        ..definition = refer('MonoSeqEmitter<${bloc.stateName}>'),
    );
  } else {
    // Parallel non-async mode: typedef _Emitter = Emitter<State>
    return TypeDef(
      (b) => b
        ..name = '_Emitter'
        ..definition = refer('Emitter<${bloc.stateName}>'),
    );
  }
}
