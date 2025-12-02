import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/visitor2.dart';
import 'package:mono_bloc_generator/src/checkers/mono_bloc_checkers.dart';
import 'package:mono_bloc_generator/src/models/bloc_element.dart';
import 'package:mono_bloc_generator/src/models/method_element.dart'
    as method_model;
import 'package:source_gen/source_gen.dart';

part 'bloc_visitor_validation.dart';

part 'bloc_visitor_helpers.dart';

part 'bloc_visitor_methods.dart';

class BlocVisitor extends RecursiveElementVisitor2<void> {
  BlocVisitor({this.isFlutterProject = false});

  /// Whether this is a Flutter project (detected from pubspec.yaml)
  final bool isFlutterProject;

  final blocs = <BlocElement>[];
  var _importsValidated = false;
  String? _firstBlocFile;
  String? _firstBlocName;

  /// Stores @MonoActions mixins found in the current file
  /// Key: file path, Value: MixinElement with @MonoActions
  MixinElement? _actionsMixin;
  String? _actionsMixinFile;

  @override
  void visitMixinElement(MixinElement element) {
    super.visitMixinElement(element);

    final mixinName = element.name;

    // Check if mixin has @MonoActions annotation
    final hasMonoActionsAnnotation =
        _safeHasAnnotationOf(monoActionsChecker, element) ||
        _hasAnnotationOfTypeOnElement(element, 'MonoActions') ||
        _hasAnnotationBySource(element, 'MonoActions');

    if (hasMonoActionsAnnotation) {
      // Validate: mixin must be private
      if (mixinName == null || !mixinName.startsWith('_')) {
        throw InvalidGenerationSourceError(
          '@MonoActions mixin "$mixinName" must be private (start with _).\n\n'
          'Required syntax:\n'
          '@MonoActions()\n'
          'mixin _${mixinName ?? 'YourActions'} {\n'
          '  void showNotification(String message);\n'
          '}',
          element: element,
        );
      }

      // Store the actions mixin for later use by the bloc visitor
      final filePath = element.library.firstFragment.source.fullName;

      // Validate: only one @MonoActions per file
      if (_actionsMixin != null && _actionsMixinFile == filePath) {
        throw InvalidGenerationSourceError(
          'Only ONE @MonoActions mixin is allowed per file.\n\n'
          'File: ${filePath.split('/').last}\n'
          'First mixin: ${_actionsMixin!.name}\n'
          'Second mixin: $mixinName\n\n'
          'Solution: Combine your actions into a single mixin or move to separate files.',
          element: element,
        );
      }

      _actionsMixin = element;
      _actionsMixinFile = filePath;
      return;
    }

    // Check if mixin has @MonoBloc annotation (not allowed)
    final hasAnnotation = monoBlocAnnotationChecker.hasAnnotationOf(element);

    if (hasAnnotation) {
      throw InvalidGenerationSourceError(
        '@MonoBloc cannot be used on mixins.\n\n'
        'Mixins should not contain BLoC logic. Use services/repositories for shared business logic instead.\n\n'
        'Example:\n'
        '  // ❌ BAD: Mixin with @MonoBloc\n'
        '  @MonoBloc()\n'
        '  mixin CommonMixin { ... }\n\n'
        '  // ✅ GOOD: Service for shared logic\n'
        '  class AuthService {\n'
        '    Future<User> login(String email, String password) { ... }\n'
        '  }',
        element: element,
      );
    }
  }

  @override
  void visitClassElement(ClassElement element) {
    super.visitClassElement(element);

    // Only process classes that have @MonoBloc or @AsyncMonoBloc annotation on the class itself (not inherited)
    final hasMonoBlocAnnotation = monoBlocAnnotationChecker.hasAnnotationOf(
      element,
    );
    final hasAsyncMonoBlocAnnotation = asyncMonoBlocAnnotationChecker
        .hasAnnotationOf(element);

    if (!hasMonoBlocAnnotation && !hasAsyncMonoBlocAnnotation) {
      return;
    }

    // Validate only one @MonoBloc or @AsyncMonoBloc per file
    final filePath = element.library.firstFragment.source.fullName;
    final fileName = filePath.split('/').last;

    if (_firstBlocFile == null) {
      // First bloc found - remember it
      _firstBlocFile = filePath;
      _firstBlocName = element.name;
    } else if (_firstBlocFile == filePath) {
      // Multiple blocs in same file - ERROR
      throw InvalidGenerationSourceError(
        'Only ONE @MonoBloc or @AsyncMonoBloc annotation is allowed per file.\n\n'
        'File: $fileName\n'
        'First bloc: $_firstBlocName\n'
        'Second bloc: ${element.name}\n\n'
        'Reason: Each file generates shared typedefs (_State, _Emitter) which would\n'
        'conflict if multiple blocs exist in the same file.\n\n'
        'Solution: Move each bloc to its own file:\n'
        '  ${_firstBlocName?.toLowerCase() ?? 'first_bloc'}.dart\n'
        '  ${element.name?.toLowerCase() ?? 'second_bloc'}.dart',
        element: element,
      );
    }

    // Validate imports on first @MonoBloc/@AsyncMonoBloc class found
    if (!_importsValidated) {
      _validateRequiredImports(element);
      _importsValidated = true;
    }

    // Read sequential flag and default concurrency from @MonoBloc or @AsyncMonoBloc annotation
    var sequential = false;
    String? defaultConcurrency;
    final isAsync = hasAsyncMonoBlocAnnotation;

    for (final meta in element.metadata.annotations) {
      final value = meta.computeConstantValue();
      if (value == null) continue;

      // Check for sequential field (boolean)
      final sequentialField = value.getField('sequential');
      if (sequentialField != null && !sequentialField.isNull) {
        sequential = sequentialField.toBoolValue() ?? false;
      }

      // Check for concurrency field (enum)
      final concurrencyField = value.getField('concurrency');
      if (concurrencyField != null && !concurrencyField.isNull) {
        // Read enum value (e.g., 'MonoConcurrency.restartable')
        final enumValue = concurrencyField.variable?.name;
        defaultConcurrency =
            enumValue; // Will be 'restartable', 'concurrent', etc.
      }
    }

    // REQUIRED: Read State type from class generic parameter
    // Must be: class MyBloc extends _$MyBloc<MyState>
    var stateName = _readStateTypeFromSourceCode(element);

    // For abstract classes with generic type parameters, use a placeholder
    if (stateName == null &&
        element.isAbstract &&
        element.typeParameters.isNotEmpty) {
      stateName =
          'dynamic'; // Temporary - will be overridden by concrete classes
    }

    // If we don't have a state type, fail generation
    if (stateName == null) {
      final className = element.name;

      // Check if the class extends the correct base class
      final supertype = element.supertype;
      final superElement = supertype?.element;
      final superName = superElement?.name ?? '';
      final expectedBase = '_\$$className';

      // Allow extending either _$ClassName or another @MonoBloc class
      final extendsGeneratedBase = superName == expectedBase;
      final extendsMonoBlocClass =
          superElement != null &&
          monoBlocAnnotationChecker.hasAnnotationOf(superElement);

      if (!extendsGeneratedBase && !extendsMonoBlocClass) {
        throw InvalidGenerationSourceError(
          '@MonoBloc class $className must extend $expectedBase<State> or another @MonoBloc class.\n\n'
          'Option 1 - Extend generated base:\n'
          'class $className extends $expectedBase<MyState> {\n'
          '  $className() : super(MyState.initial());\n'
          '}\n\n'
          'Option 2 - Extend another @MonoBloc class:\n'
          'class $className extends MyBaseBloc<MyState> {\n'
          '  $className() : super(MyState.initial());\n'
          '}\n\n'
          'Current superclass: $superName',
          element: element,
        );
      }

      // If extending another @MonoBloc class, need to find the actual state type
      // Example: UserBloc extends AppBaseBloc<User>
      //          AppBaseBloc<T> extends _$AppBaseBloc<AppState<T>>
      // We need to get AppState<User>, not User
      if (extendsMonoBlocClass) {
        // Look at the parent's supertype to find the state type pattern
        final parentSupertype = superElement.supertype;
        if (parentSupertype != null &&
            parentSupertype.typeArguments.isNotEmpty) {
          // Parent's state type might have generics: AppState<T>
          // Get the display string which will show the pattern
          final parentStatePattern = parentSupertype.typeArguments.first
              .getDisplayString();

          // Now substitute the generic from our extends clause
          // If supertype is AppBaseBloc<User>, get "User"
          if (supertype != null && supertype.typeArguments.isNotEmpty) {
            final ourGeneric = supertype.typeArguments.first.getDisplayString();

            // Replace T with the actual type: AppState<T> -> AppState<User>
            stateName = parentStatePattern.replaceAll(
              RegExp(r'\bT\b'),
              ourGeneric,
            );
          } else {
            stateName = parentStatePattern;
          }
        }
      }

      // If still no state type, fail
      if (stateName == null) {
        throw InvalidGenerationSourceError(
          'State type must be provided as generic parameter for @MonoBloc class $className.\n\n'
          'Required syntax:\n'
          'class $className extends $expectedBase<MyState> {\n'
          '  $className() : super(MyState.initial());\n'
          '}\n\n'
          'The State type MUST be explicitly provided in the class extends clause.\n'
          'Do not use dynamic or omit the generic parameter.',
          element: element,
        );
      }
    }

    // We have a state type and @MonoBloc/@AsyncMonoBloc annotation - generate the base class

    // Event type will be generated as _Event
    const eventName = '_Event';

    // For async blocs, wrap the state in MonoAsyncValue
    final wrappedStateName = isAsync ? 'MonoAsyncValue<$stateName>' : stateName;

    // Determine if this should use Flutter mode (BuildContext in actions).
    // Flutter mode is enabled if the project is a Flutter project (detected from pubspec.yaml).
    // Individual file imports don't matter - only project type.
    final blocElement = BlocElement(
      eventName: eventName,
      stateName: wrappedStateName,
      bloc: element,
      sourceFileName: fileName,
      sequential: sequential,
      defaultConcurrency: defaultConcurrency,
      isAsync: isAsync,
      unwrappedStateName: isAsync ? stateName : null,
      isFlutterProject: isFlutterProject,
    );

    _findPrivateMethodsWithEmitter(
      element,
      blocElement,
      eventName,
      wrappedStateName,
      isAsync ? stateName : null,
    );
    _findErrorHandlers(element, blocElement);
    _findOnEventHandlers(element, blocElement);

    // Find @MonoActions mixin in this file
    final actionsMixin = _findActionsMixinInLibrary(element.library, filePath);
    _findActionMethods(element, blocElement, filePath, actionsMixin);
    _checkForMethodNameConflicts(blocElement);

    blocs.add(blocElement);
  }

  /// Find the @MonoActions mixin in the same library as the bloc
  MixinElement? _findActionsMixinInLibrary(
    LibraryElement library,
    String filePath,
  ) {
    // Use the stored mixin if it's from the same file
    if (_actionsMixin != null && _actionsMixinFile == filePath) {
      return _actionsMixin;
    }

    // Search through all mixins declared in the library's fragments
    for (final fragment in library.fragments) {
      for (final mixinFragment in fragment.mixins) {
        // Get the element from the fragment
        final mixin = mixinFragment.element;

        final hasMonoActionsAnnotation =
            _safeHasAnnotationOf(monoActionsChecker, mixin) ||
            _hasAnnotationOfTypeOnElement(mixin, 'MonoActions') ||
            _hasAnnotationBySource(mixin, 'MonoActions');

        if (hasMonoActionsAnnotation) {
          // Verify it's private (starts with _)
          final mixinName = mixin.name;
          if (mixinName != null && mixinName.startsWith('_')) {
            return mixin;
          }
        }
      }
    }

    return null;
  }
}
