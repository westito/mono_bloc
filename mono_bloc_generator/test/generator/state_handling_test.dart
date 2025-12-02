import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - State Handling', () {
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

    test('should handle State return type with simple return', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestEvent {}
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent()
          TestState _increment() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('emit(_increment())'));
    });

    test('should handle State return type - emit wrapper', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestEvent {}
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent()
          TestState _reset() {
            return TestState();
          }
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('emit(_reset())'));
    });

    test('should handle Stream<State> return type - emit.forEach', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestEvent {}
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent()
          Stream<TestState> _loadAsync() async* {
            yield TestState();
          }
        }
      ''';

      final generated = await generateForSource(source);

      expect(
        generated,
        contains(
          'await emit.forEach<TestState>(_loadAsync(), onData: (state) => state)',
        ),
      );
    });
  });
}
