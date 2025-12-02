import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - Action Edge Cases', () {
    late MonoBlocGenerator generator;

    setUp(() {
      generator = MonoBlocGenerator();
    });

    Future<String> generateForSource(String source) {
      return resolveSources({...mockPackages, 'pkg|lib/test.dart': source}, (
        resolver,
      ) async {
        final lib = await resolver.libraryFor(
          AssetId.parse('pkg|lib/test.dart'),
        );
        final generated = await generator.generate(
          LibraryReader(lib),
          MockBuildStep(),
        );
        return generated;
      });
    }

    test('should handle actions with nullable parameters', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoActions()
        mixin _TestBlocActions {
          void showMessage(String? message, int? duration);
        }
        
        @MonoBloc()
        class TestBloc extends _$TestBloc<int> {
          TestBloc() : super(0);
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('final String? message;'));
      expect(generated, contains('final int? duration;'));
      expect(generated, contains('_ShowMessageAction'));
    });

    test('should handle actions with generic type parameters', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoActions()
        mixin _TestBlocActions {
          void navigate<T>(List<T> items, Map<String, T> data);
        }
        
        @MonoBloc()
        class TestBloc extends _$TestBloc<int> {
          TestBloc() : super(0);
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('final List<'));
      expect(generated, contains('final Map<String,'));
      expect(generated, contains('_NavigateAction'));
    });

    test('should handle actions with complex nested types', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoActions()
        mixin _TestBlocActions {
          void process(Map<String, List<int>> data, Future<void> Function(String) callback);
        }
        
        @MonoBloc()
        class TestBloc extends _$TestBloc<int> {
          TestBloc() : super(0);
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('final Map<String, List<int>> data;'));
      expect(
        generated,
        contains('final Future<void> Function(String) callback;'),
      );
      expect(generated, contains('_ProcessAction'));
    });

    test('should handle actions with named parameters only', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoActions()
        mixin _TestBlocActions {
          void showDialog({required String title, String? message, int timeout = 5});
        }
        
        @MonoBloc()
        class TestBloc extends _$TestBloc<int> {
          TestBloc() : super(0);
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('required this.title'));
      expect(generated, contains('this.message'));
      expect(generated, contains('this.timeout = 5'));
      expect(generated, contains('_ShowDialogAction'));
    });

    test(
      'should handle actions with mixed positional and named parameters',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoActions()
        mixin _TestBlocActions {
          void navigate(String route, {Map<String, dynamic>? arguments, bool replace = false});
        }
        
        @MonoBloc()
        class TestBloc extends _$TestBloc<int> {
          TestBloc() : super(0);
        }
      ''';

        final generated = await generateForSource(source);

        expect(generated, contains('final String route;'));
        expect(generated, contains('final Map<String, dynamic>? arguments;'));
        expect(generated, contains('final bool replace;'));
        expect(generated, contains('_NavigateAction'));
      },
    );

    test('should handle action with no parameters', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoActions()
        mixin _TestBlocActions {
          void showSuccess();
        }
        
        @MonoBloc()
        class TestBloc extends _$TestBloc<int> {
          TestBloc() : super(0);
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('_ShowSuccessAction'));
      expect(generated, contains('void showSuccess()'));
    });

    test('should reject action with non-void return type in mixin', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoActions()
        mixin _TestBlocActions {
          String navigate();
        }
        
        @MonoBloc()
        class TestBloc extends _$TestBloc<int> {
          TestBloc() : super(0);
        }
      ''';

      await expectLater(
        generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains('Action method "navigate" must return void'),
          ),
        ),
      );
    });

    test('should reject action with Future<void> return type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoActions()
        mixin _TestBlocActions {
          Future<void> showDialog();
        }
        
        @MonoBloc()
        class TestBloc extends _$TestBloc<int> {
          TestBloc() : super(0);
        }
      ''';

      await expectLater(
        generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains('Action method "showDialog" must return void'),
          ),
        ),
      );
    });

    test('should skip non-abstract methods in action mixin', () async {
      // Non-abstract methods are silently skipped, not treated as actions
      // This allows:
      // 1. Override implementations for interface methods
      // 2. Concrete helper methods in the mixin
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoActions()
        mixin _TestBlocActions {
          void showMessage(String text) {
            print(text);
          }
          
          // Abstract method - this becomes an action
          void navigate(String route);
        }
        
        @MonoBloc()
        class TestBloc extends _$TestBloc<int> {
          TestBloc() : super(0);
          
          @event
          int _onIncrement() => state + 1;
        }
      ''';

      final result = await generateForSource(source);
      expect(result, isNotEmpty);
      // showMessage is not abstract, so no action class is generated for it
      expect(result, isNot(contains('_ShowMessageAction')));
      // navigate IS abstract, so it becomes an action
      expect(result, contains('_NavigateAction'));
    });

    test('should handle multiple actions in same bloc', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoActions()
        mixin _TestBlocActions {
          void navigate(String route);
          
          void showDialog(String message);
          
          void showSnackbar({required String text, int duration = 3});
        }
        
        @MonoBloc()
        class TestBloc extends _$TestBloc<int> {
          TestBloc() : super(0);
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('_NavigateAction'));
      expect(generated, contains('_ShowDialogAction'));
      expect(generated, contains('_ShowSnackbarAction'));
      expect(generated, contains('sealed class _Action'));
    });

    test('should handle action with enum parameters', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        enum NotificationType { success, error, info }
        
        @MonoActions()
        mixin _TestBlocActions {
          void showNotification(String message, NotificationType type);
        }
        
        @MonoBloc()
        class TestBloc extends _$TestBloc<int> {
          TestBloc() : super(0);
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('final String message;'));
      expect(generated, contains('final NotificationType type;'));
      expect(generated, contains('_ShowNotificationAction'));
    });

    test('should handle action with record type parameters', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoActions()
        mixin _TestBlocActions {
          void navigate((String route, Map<String, dynamic> args) data);
        }
        
        @MonoBloc()
        class TestBloc extends _$TestBloc<int> {
          TestBloc() : super(0);
        }
      ''';

      final generated = await generateForSource(source);

      // Should preserve record type from source (field names are normalized by the parser)
      // The important thing is that it uses the record syntax, not the analyzer's resolved type
      expect(generated, contains('final (String, Map<String, dynamic>) data;'));
      expect(generated, contains('_NavigateAction'));
      expect(
        generated,
        contains('void navigate((String, Map<String, dynamic>) data)'),
      );
    });

    test('should handle action with typedef callback parameter', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        typedef OnComplete = void Function(bool success);
        
        @MonoActions()
        mixin _TestBlocActions {
          void performAction(String id, OnComplete onComplete);
        }
        
        @MonoBloc()
        class TestBloc extends _$TestBloc<int> {
          TestBloc() : super(0);
        }
      ''';

      final generated = await generateForSource(source);

      // Should preserve typedef from source instead of resolving to Function type
      expect(generated, contains('final String id;'));
      expect(generated, contains('final OnComplete onComplete;'));
      expect(generated, contains('_PerformActionAction'));
    });
  });
}
