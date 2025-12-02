import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('Multiple Blocs Validation', () {
    late MonoBlocGenerator generator;

    setUp(() {
      generator = MonoBlocGenerator();
    });

    test('should reject multiple @MonoBloc in one file', () {
      const source = r'''
import 'package:mono_bloc/mono_bloc.dart';

part 'test.g.dart';

@MonoBloc()
class CounterBloc extends _$CounterBloc<int> {
  CounterBloc() : super(0);
  
  @event
  int _onIncrement() => state + 1;
}

@MonoBloc()
class TodoBloc extends _$TodoBloc<String> {
  TodoBloc() : super('');
  
  @event
  String _onUpdate(String value) => value;
}
''';

      expect(
        () => resolveSources({...mockPackages, 'pkg|lib/test.dart': source}, (
          resolver,
        ) async {
          final lib = await resolver.libraryFor(
            AssetId.parse('pkg|lib/test.dart'),
          );
          await generator.generate(LibraryReader(lib), MockBuildStep());
        }),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            allOf([
              contains(
                'Only ONE @MonoBloc or @AsyncMonoBloc annotation is allowed per file',
              ),
              contains('First bloc: CounterBloc'),
              contains('Second bloc: TodoBloc'),
            ]),
          ),
        ),
      );
    });

    test('should reject multiple @AsyncMonoBloc in one file', () {
      const source = r'''
import 'package:mono_bloc/mono_bloc.dart';

part 'test.g.dart';

@AsyncMonoBloc()
class AsyncCounterBloc extends _$AsyncCounterBloc<int> {
  AsyncCounterBloc() : super(const MonoAsyncValue.withData(0));
  
  @event
  Future<int> _onIncrement() async => state.data + 1;
}

@AsyncMonoBloc()
class AsyncTodoBloc extends _$AsyncTodoBloc<String> {
  AsyncTodoBloc() : super(const MonoAsyncValue.withData(''));
  
  @event
  Future<String> _onUpdate(String value) async => value;
}
''';

      expect(
        () => resolveSources({...mockPackages, 'pkg|lib/test.dart': source}, (
          resolver,
        ) async {
          final lib = await resolver.libraryFor(
            AssetId.parse('pkg|lib/test.dart'),
          );
          await generator.generate(LibraryReader(lib), MockBuildStep());
        }),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains(
              'Only ONE @MonoBloc or @AsyncMonoBloc annotation is allowed per file',
            ),
          ),
        ),
      );
    });

    test('should reject mixed @MonoBloc and @AsyncMonoBloc in one file', () {
      const source = r'''
import 'package:mono_bloc/mono_bloc.dart';

part 'test.g.dart';

@MonoBloc()
class CounterBloc extends _$CounterBloc<int> {
  CounterBloc() : super(0);
  
  @event
  int _onIncrement() => state + 1;
}

@AsyncMonoBloc()
class AsyncTodoBloc extends _$AsyncTodoBloc<String> {
  AsyncTodoBloc() : super(const MonoAsyncValue.withData(''));
  
  @event
  Future<String> _onUpdate(String value) async => value;
}
''';

      expect(
        () => resolveSources({...mockPackages, 'pkg|lib/test.dart': source}, (
          resolver,
        ) async {
          final lib = await resolver.libraryFor(
            AssetId.parse('pkg|lib/test.dart'),
          );
          await generator.generate(LibraryReader(lib), MockBuildStep());
        }),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains(
              'Only ONE @MonoBloc or @AsyncMonoBloc annotation is allowed per file',
            ),
          ),
        ),
      );
    });

    test('should allow single @MonoBloc per file', () async {
      const source = r'''
import 'package:mono_bloc/mono_bloc.dart';

part 'test.g.dart';

@MonoBloc()
class CounterBloc extends _$CounterBloc<int> {
  CounterBloc() : super(0);
  
  @event
  int _onIncrement() => state + 1;
}
''';

      // Should succeed - no exception thrown
      await resolveSources({...mockPackages, 'pkg|lib/test.dart': source}, (
        resolver,
      ) async {
        final lib = await resolver.libraryFor(
          AssetId.parse('pkg|lib/test.dart'),
        );
        final result = await generator.generate(
          LibraryReader(lib),
          MockBuildStep(),
        );
        expect(result, isNotEmpty);
      });
    });
  });
}
