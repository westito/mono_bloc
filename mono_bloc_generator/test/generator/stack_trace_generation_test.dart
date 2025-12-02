import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - Stack Trace Generation', () {
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

    group('should generate event base class with trace field', () {
      test('generates trace field as StackTrace type', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';

          part 'test.g.dart';

          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);

            @event
            int _onIncrement() => 1;
          }
        ''';

        final result = await generateForSource(source);
        expect(result, contains('final StackTrace trace;'));
      });

      test(
        'generates trace field initialized with StackTrace.current',
        () async {
          const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';

          part 'test.g.dart';

          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);

            @event
            int _onIncrement() => 1;
          }
        ''';

          final result = await generateForSource(source);
          expect(result, contains('trace = StackTrace.current'));
        },
      );

      test('generates abstract event base class', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';

          part 'test.g.dart';

          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);

            @event
            int _onIncrement() => 1;
          }
        ''';

        final result = await generateForSource(source);
        expect(result, contains('abstract class _Event'));
      });
    });

    group('should generate _stack() helper method', () {
      test('generates _stack method in base class', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';

          part 'test.g.dart';

          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);

            @event
            int _onIncrement() => 1;
          }
        ''';

        final result = await generateForSource(source);
        expect(
          result,
          contains(
            r'static StackTrace _$stack(StackTrace origin, StackTrace trace)',
          ),
        );
      });

      test('_stack method calls MonoStackTrace.filtered', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';

          part 'test.g.dart';

          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);

            @event
            int _onIncrement() => 1;
          }
        ''';

        final result = await generateForSource(source);
        expect(result, contains('MonoStackTrace.filtered(origin, trace,'));
      });

      test('_stack method includes generated file name in filter', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';

          part 'test.g.dart';

          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);

            @event
            int _onIncrement() => 1;
          }
        ''';

        final result = await generateForSource(source);
        // Should use the source file name, not the class name
        expect(result, contains("'test.g.dart'"));
      });

      test(
        '_stack uses source filename not class name when they differ',
        () async {
          // This test verifies the fix for the bug where a bloc named
          // CounterBloc in main.dart would incorrectly generate
          // 'counter_bloc.g.dart' instead of 'main.g.dart'
          const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';

          part 'test.g.dart';

          @MonoBloc()
          class CounterBloc extends _$CounterBloc<int> {
            CounterBloc() : super(0);

            @event
            int _onIncrement() => state + 1;
          }
        ''';

          final result = await generateForSource(source);
          // Source file is 'test.dart', so generated file should be 'test.g.dart'
          // NOT 'counter_bloc.g.dart' (which would be derived from class name)
          expect(result, contains("'test.g.dart'"));
          expect(result, isNot(contains("'counter_bloc.g.dart'")));
        },
      );
    });

    group('should use _stack() in catch blocks', () {
      test('uses _stack in async mode catch blocks', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';

          part 'test.g.dart';

          @AsyncMonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(const MonoAsyncValue.withData(0));

            @event
            Future<int> _onIncrement() async {
              return (state.dataOrNull ?? 0) + 1;
            }
          }
        ''';

        final result = await generateForSource(source);
        expect(
          result,
          contains(r'final stack = _$stack(event.trace, stackTrace)'),
        );
      });

      test(
        'uses _stack in normal mode catch blocks with error handler',
        () async {
          const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';

          part 'test.g.dart';

          typedef _Emitter = Emitter<int>;

          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);

            @event
            void _onIncrement(_Emitter emit) {}

            @onError
            void _onError(Object error, StackTrace stackTrace) {}
          }
        ''';

          final result = await generateForSource(source);
          expect(result, contains(r'final stack = _$stack(eventTrace, s)'));
        },
      );

      test('passes filtered stack to onError', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';

          part 'test.g.dart';

          @AsyncMonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(const MonoAsyncValue.withData(0));

            @event
            Future<int> _onIncrement() async {
              return (state.dataOrNull ?? 0) + 1;
            }
          }
        ''';

        final result = await generateForSource(source);
        expect(result, contains('bloc.onError(error, stack);'));
      });

      test('passes filtered stack to withError', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';

          part 'test.g.dart';

          @AsyncMonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(const MonoAsyncValue.withData(0));

            @event
            Future<int> _onIncrement() async {
              return (state.dataOrNull ?? 0) + 1;
            }
          }
        ''';

        final result = await generateForSource(source);
        expect(
          result,
          contains('emit(withError(error, stack, bloc.state.dataOrNull));'),
        );
      });
    });

    group('should format generated code with proper spacing', () {
      test('has blank line after ignore_for_file directive', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';

          part 'test.g.dart';

          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);

            @event
            int _onIncrement() => 1;
          }
        ''';

        final result = await generateForSource(source);
        expect(result, startsWith('// ignore_for_file:'));
        expect(result, contains('// ignore_for_file: unused_element'));
      });
    });
  });
}
