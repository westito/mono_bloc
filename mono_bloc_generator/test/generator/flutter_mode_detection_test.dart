import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - Flutter Mode Detection', () {
    late MonoBlocGenerator generator;

    setUp(() {
      generator = MonoBlocGenerator();
    });

    Future<String> generateForSource(
      String source, {
      bool isFlutterProject = false,
    }) {
      return resolveSources({...mockPackages, 'pkg|lib/test.dart': source}, (
        resolver,
      ) async {
        final lib = await resolver.libraryFor(
          AssetId.parse('pkg|lib/test.dart'),
        );
        final generated = await generator.generate(
          LibraryReader(lib),
          MockBuildStep(isFlutterProject: isFlutterProject),
        );
        return generated;
      });
    }

    test('Pure Dart project: actions should NOT have BuildContext', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';

        class TestState {
          const TestState();
        }

        @MonoActions()
        mixin _TestBlocActions {
          void showMessage(String message);
        }

        @MonoBloc()
        class TestBloc extends _$TestBloc<TestState> {
          TestBloc() : super(const TestState());

          @event
          TestState _onTest() => const TestState();
        }
      ''';

      final output = await generateForSource(source);

      // Check action interface does NOT have BuildContext (returns FutureOr<void>)
      expect(output, contains('abstract interface class TestBlocActions'));
      expect(output, contains('FutureOr<void> showMessage('));
      expect(output, contains('String message'));
      expect(output, isNot(contains('BuildContext context')));

      // Check when() factory does NOT have BuildContext (callback returns FutureOr<void>)
      expect(
        output,
        contains('FutureOr<void> Function(String message)? showMessage'),
      );

      // Check implementation class extends MonoBlocActions (not Flutter version)
      expect(
        output,
        contains(r'class _$TestBlocActions extends MonoBlocActions'),
      );
      // Check actions field has BlocBase and dynamic action (may span multiple lines)
      expect(output, contains('final void Function('));
      expect(output, contains('BlocBase<dynamic> bloc'));
      expect(output, contains('dynamic action'));
      // Ensure no BuildContext in pure Dart
      expect(output, isNot(contains('BuildContext')));
    });

    test('Flutter project: actions should have BuildContext', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';

        class TestState {
          const TestState();
        }

        @MonoActions()
        mixin _TestBlocActions {
          void showMessage(String message);
        }

        @MonoBloc()
        class TestBloc extends _$TestBloc<TestState> {
          TestBloc() : super(const TestState());

          @event
          TestState _onTest() => const TestState();
        }
      ''';

      final output = await generateForSource(source, isFlutterProject: true);

      // Check action interface HAS BuildContext (returns FutureOr<void>)
      expect(output, contains('abstract interface class TestBlocActions'));
      expect(output, contains('FutureOr<void> showMessage('));
      expect(output, contains('BuildContext context'));
      expect(output, contains('String message'));

      // Check when() factory HAS BuildContext (callback returns FutureOr<void>)
      expect(
        output,
        contains(
          'FutureOr<void> Function(BuildContext context, String message)? showMessage',
        ),
      );

      // Check implementation class extends FlutterMonoBlocActions
      expect(
        output,
        contains(r'class _$TestBlocActions extends FlutterMonoBlocActions'),
      );
      // Check actions field has BlocBase, BuildContext and dynamic action (may span multiple lines)
      expect(output, contains('final void Function('));
      expect(output, contains('BlocBase<dynamic> bloc'));
      expect(output, contains('BuildContext context'));
      expect(output, contains('dynamic action'));
    });

    test(
      'Flutter project: multiple action parameters should all have BuildContext first',
      () async {
        const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';

        class TestState {
          const TestState();
        }

        @MonoActions()
        mixin _TestBlocActions {
          void action1(String param1);
          
          void action2(String param1, int param2);
          
          void action3({required String param1, int? param2});
        }

        @MonoBloc()
        class TestBloc extends _$TestBloc<TestState> {
          TestBloc() : super(const TestState());

          @event
          TestState _onTest() => const TestState();
        }
      ''';

        final output = await generateForSource(source, isFlutterProject: true);

        // Check all actions have BuildContext as first parameter (returns FutureOr<void>)
        expect(
          output,
          contains(
            'FutureOr<void> action1(BuildContext context, String param1)',
          ),
        );
        expect(
          output,
          contains(
            'FutureOr<void> action2(BuildContext context, String param1, int param2)',
          ),
        );
        // action3 has named params, generator splits it across lines
        expect(output, contains('FutureOr<void> action3('));
        expect(output, contains('BuildContext context, {'));
        expect(output, contains('required String param1,'));
        expect(output, contains('int? param2,'));
      },
    );

    test(
      'Pure Dart project: multiple action parameters should NOT have BuildContext',
      () async {
        const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';

        class TestState {
          const TestState();
        }

        @MonoActions()
        mixin _TestBlocActions {
          void action1(String param1);
          
          void action2(String param1, int param2);
          
          void action3({required String param1, int? param2});
        }

        @MonoBloc()
        class TestBloc extends _$TestBloc<TestState> {
          TestBloc() : super(const TestState());

          @event
          TestState _onTest() => const TestState();
        }
      ''';

        final output = await generateForSource(source);

        // Check actions do NOT have BuildContext (returns FutureOr<void>)
        expect(output, contains('FutureOr<void> action1(String param1)'));
        expect(
          output,
          contains('FutureOr<void> action2(String param1, int param2)'),
        );
        // action3 has named params, check parts
        expect(output, contains('FutureOr<void> action3('));
        expect(output, contains('required String param1,'));
        expect(
          output,
          contains(
            'FutureOr<void> action3({required String param1, int? param2}',
          ),
        );

        // Verify no BuildContext anywhere in actions
        final actionsSection = output.substring(
          output.indexOf('abstract interface class TestBlocActions'),
          output.indexOf(r'class _$TestBlocActions'),
        );
        expect(actionsSection, isNot(contains('BuildContext')));
      },
    );

    test(
      'Flutter project detection is based on pubspec, not file imports',
      () async {
        // Source that imports mono_bloc_flutter (but should use project type)
        const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';

        class TestState {
          const TestState();
        }

        @MonoActions()
        mixin _TestBlocActions {
          void showMessage(String message);
        }

        @MonoBloc()
        class TestBloc extends _$TestBloc<TestState> {
          TestBloc() : super(const TestState());

          @event
          TestState _onTest() => const TestState();
        }
      ''';

        // Test 1: Pure Dart project (from pubspec) - no BuildContext
        final dartOutput = await generateForSource(source);
        expect(dartOutput, isNot(contains('BuildContext context')));
        expect(dartOutput, contains('extends MonoBlocActions'));

        // Test 2: Flutter project (from pubspec) - has BuildContext
        final flutterOutput = await generateForSource(
          source,
          isFlutterProject: true,
        );
        expect(flutterOutput, contains('BuildContext context'));
        expect(flutterOutput, contains('extends FlutterMonoBlocActions'));
      },
    );
  });
}
