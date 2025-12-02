import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - Helper Methods', () {
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

    test('should generate public helper methods', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent()
          TestState _onIncrement() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('void increment()'));
      expect(generated, contains('add(_IncrementEvent())'));
    });

    test('should generate public methods with parameters', () async {
      const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestEvent {}
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent()
          TestState _setValue(int value) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('void setValue(int value)'));
      expect(generated, contains('add(_SetValueEvent(value))'));
    });
  });
}
