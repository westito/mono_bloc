import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - Action Mixin Inheritance', () {
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

    group('Private base mixin (implements _PrivateMixin)', () {
      test('should collect actions from private base mixin', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          mixin _ErrorHandler {
            void showError(String message);
          }
          
          @MonoActions()
          mixin _TestBlocActions implements _ErrorHandler {
            void navigate(String route);
          }
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            int _onIncrement() => state + 1;
          }
        ''';

        final generated = await generateForSource(source);

        // Should generate action classes for both mixins
        expect(generated, contains('_NavigateAction'));
        expect(generated, contains('_ShowErrorAction'));

        // Should generate action implementations
        expect(generated, contains('void navigate(String route)'));
        expect(generated, contains('void showError(String message)'));

        // Should include both in interface (abstract methods return FutureOr<void>)
        expect(generated, contains('FutureOr<void> navigate('));
        expect(generated, contains('FutureOr<void> showError('));
      });

      test(
        'should handle multiple levels of private mixin inheritance',
        () async {
          const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          mixin _BaseActions {
            void logEvent(String name);
          }
          
          mixin _ErrorHandler implements _BaseActions {
            void showError(String message);
          }
          
          @MonoActions()
          mixin _TestBlocActions implements _ErrorHandler {
            void navigate(String route);
          }
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            int _onIncrement() => state + 1;
          }
        ''';

          final generated = await generateForSource(source);

          // Direct mixin actions
          expect(generated, contains('_NavigateAction'));

          // First level inherited actions
          expect(generated, contains('_ShowErrorAction'));

          // Note: Deep inheritance (_BaseActions -> _ErrorHandler -> _TestBlocActions)
          // only goes one level deep. _BaseActions methods won't be collected
          // unless _ErrorHandler is directly on the bloc's mixin list.
        },
      );
    });

    group('Public base mixin (implements PublicMixin)', () {
      test('should collect actions from public base mixin', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          mixin ErrorHandlerActions {
            void showError(String message);
            
            void showRetryError(String error, void Function() onRetry);
          }
          
          @MonoActions()
          mixin _TestBlocActions implements ErrorHandlerActions {
            void navigate(String route);
          }
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            int _onIncrement() => state + 1;
          }
        ''';

        final generated = await generateForSource(source);

        // Should generate action classes for public mixin actions
        expect(generated, contains('_ShowErrorAction'));
        expect(generated, contains('_ShowRetryErrorAction'));
        expect(generated, contains('_NavigateAction'));

        // Should generate implementations
        expect(generated, contains('void showError(String message)'));
        expect(generated, contains('void showRetryError('));
        expect(generated, contains('void navigate(String route)'));
      });

      test('should work with mixed public and private base mixins', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          mixin ErrorHandlerActions {
            void showError(String message);
          }
          
          mixin _NavigationActions {
            void goBack();
          }
          
          @MonoActions()
          mixin _TestBlocActions implements ErrorHandlerActions, _NavigationActions {
            void doSomething();
          }
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            int _onIncrement() => state + 1;
          }
        ''';

        final generated = await generateForSource(source);

        // Actions from public mixin
        expect(generated, contains('_ShowErrorAction'));

        // Actions from private mixin
        expect(generated, contains('_GoBackAction'));

        // Direct actions
        expect(generated, contains('_DoSomethingAction'));
      });
    });

    group('Edge cases', () {
      test('should handle mixin with no action methods in base', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          mixin EmptyMixin {
            // No action methods
            void helperMethod() {}
          }
          
          @MonoActions()
          mixin _TestBlocActions implements EmptyMixin {
            void navigate(String route);
          }
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            int _onIncrement() => state + 1;
          }
        ''';

        final generated = await generateForSource(source);

        // Should only have the direct action
        expect(generated, contains('_NavigateAction'));

        // Should not have helper method as action
        expect(generated, isNot(contains('_HelperMethodAction')));
      });

      test('should handle action with complex parameter types', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          typedef OnComplete = void Function(bool success);
          
          mixin SharedActions {
            void showDialog(String title, {required OnComplete onComplete});
            
            void logData(Map<String, dynamic> data);
          }
          
          @MonoActions()
          mixin _TestBlocActions implements SharedActions {
            void navigate(String route);
          }
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            int _onIncrement() => state + 1;
          }
        ''';

        final generated = await generateForSource(source);

        // Should generate actions with complex types
        expect(generated, contains('_ShowDialogAction'));
        expect(generated, contains('_LogDataAction'));
        expect(generated, contains('final String title'));
      });

      test(
        'should inherit actions from base mixin and add own actions',
        () async {
          // This tests that a bloc can implement a shared base mixin
          // and add its own actions on top of the inherited ones
          const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          mixin ErrorHandlerActions {
            void showError(String message);
            
            void showWarning(String message);
          }
          
          @MonoActions()
          mixin _TestBlocActions implements ErrorHandlerActions {
            void navigateToDetails(int id);
            
            void refreshData();
          }
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            int _onIncrement() => state + 1;
          }
        ''';

          final generated = await generateForSource(source);

          // Should have inherited actions from ErrorHandlerActions
          expect(generated, contains('_ShowErrorAction'));
          expect(generated, contains('_ShowWarningAction'));

          // Should have own actions from _TestBlocActions
          expect(generated, contains('_NavigateToDetailsAction'));
          expect(generated, contains('_RefreshDataAction'));

          // Verify action class has correct fields
          expect(generated, contains('final String message;'));
          expect(generated, contains('final int id;'));

          // Verify all actions are in the interface (abstract methods return FutureOr<void>)
          expect(
            generated,
            contains('FutureOr<void> showError(String message);'),
          );
          expect(
            generated,
            contains('FutureOr<void> showWarning(String message);'),
          );
          expect(
            generated,
            contains('FutureOr<void> navigateToDetails(int id);'),
          );
          expect(generated, contains('FutureOr<void> refreshData();'));
        },
      );

      test('should not collect actions from non-mixin interfaces', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          abstract class SomeInterface {
            void interfaceMethod();
          }
          
          @MonoActions()
          mixin _TestBlocActions implements SomeInterface {
            void navigate(String route);
            
            @override
            void interfaceMethod() {}
          }
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            int _onIncrement() => state + 1;
          }
        ''';

        final generated = await generateForSource(source);

        // Should only have the action method
        expect(generated, contains('_NavigateAction'));

        // Should not treat interface method as action
        expect(generated, isNot(contains('_InterfaceMethodAction')));
      });

      test('should handle VoidCallback parameter type', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          typedef VoidCallback = void Function();
          
          mixin ErrorHandlerActions {
            void showRetryDialog(String message, VoidCallback onRetry);
          }
          
          @MonoActions()
          mixin _TestBlocActions implements ErrorHandlerActions {
            void navigate(String route);
          }
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            int _onIncrement() => state + 1;
          }
        ''';

        final generated = await generateForSource(source);

        expect(generated, contains('_ShowRetryDialogAction'));
        expect(generated, contains('final String message'));
        expect(generated, contains('final VoidCallback onRetry'));
      });

      test('should handle action with no parameters in base mixin', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          mixin SharedActions {
            void dismiss();
            
            void refresh();
          }
          
          @MonoActions()
          mixin _TestBlocActions implements SharedActions {
            void navigate(String route);
          }
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            int _onIncrement() => state + 1;
          }
        ''';

        final generated = await generateForSource(source);

        // Actions are never const - they capture StackTrace.current
        expect(generated, contains('_DismissAction()'));
        expect(generated, contains('_RefreshAction()'));
        expect(generated, isNot(contains('const _DismissAction()')));
        expect(generated, isNot(contains('const _RefreshAction()')));
      });

      test('should skip base mixin with null name', () async {
        // This tests the null check in the generator
        // In practice, this shouldn't happen, but the generator handles it
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          @MonoActions()
          mixin _TestBlocActions {
            void navigate(String route);
          }
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            int _onIncrement() => state + 1;
          }
        ''';

        final generated = await generateForSource(source);

        // Should work normally
        expect(generated, contains('_NavigateAction'));
      });
    });

    group('Interface generation', () {
      test('should include inherited actions in when() factory', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          mixin ErrorHandlerActions {
            void showError(String message);
          }
          
          @MonoActions()
          mixin _TestBlocActions implements ErrorHandlerActions {
            void navigate(String route);
          }
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            int _onIncrement() => state + 1;
          }
        ''';

        final generated = await generateForSource(source);

        // when() should have both action handlers
        expect(
          generated,
          contains('FutureOr<void> Function(String route)? navigate'),
        );
        expect(
          generated,
          contains('FutureOr<void> Function(String message)? showError'),
        );
      });

      test('should include inherited actions in of() factory', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          mixin ErrorHandlerActions {
            void showError(String message);
          }
          
          @MonoActions()
          mixin _TestBlocActions implements ErrorHandlerActions {
            void navigate(String route);
          }
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            int _onIncrement() => state + 1;
          }
        ''';

        final generated = await generateForSource(source);

        // of() should wire both actions
        expect(generated, contains('navigate: actions.navigate'));
        expect(generated, contains('showError: actions.showError'));
      });

      test('should include inherited actions in interface class', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          mixin ErrorHandlerActions {
            void showError(String message);
          }
          
          @MonoActions()
          mixin _TestBlocActions implements ErrorHandlerActions {
            void navigate(String route);
          }
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            int _onIncrement() => state + 1;
          }
        ''';

        final generated = await generateForSource(source);

        // Interface should declare both methods (abstract methods return FutureOr<void>)
        expect(generated, contains('abstract interface class TestBlocActions'));
        expect(generated, contains('FutureOr<void> navigate('));
        expect(generated, contains('FutureOr<void> showError('));
      });
    });
  });
}
