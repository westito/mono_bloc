import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - Event Generation', () {
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

    test('should generate Event classes for @MonoEvent methods', () async {
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

      expect(generated, contains('abstract class _Event'));
      expect(generated, contains('class _IncrementEvent extends _Event'));
    });

    test('should generate Event classes with parameters', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent()
          TestState _onSetValue(int value, String label) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('class _SetValueEvent extends _Event'));
      expect(generated, contains('final int value;'));
      expect(generated, contains('final String label;'));
      expect(generated, contains('_SetValueEvent(this.value, this.label)'));
    });

    test('should generate Event classes with named parameters', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent()
          TestState _onSetValues(
            int value, {
            required String label,
            bool enabled = false,
          }) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('class _SetValuesEvent extends _Event'));
      expect(generated, contains('final int value;'));
      expect(generated, contains('final String label;'));
      expect(generated, contains('final bool enabled;'));
      expect(generated, contains('required this.label'));
      expect(generated, contains('this.enabled = false'));
    });

    test('should handle multiple methods', () async {
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
          
          @MonoEvent()
          TestState _decrement() => TestState();
          
          @MonoEvent()
          TestState _reset() => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('class _IncrementEvent'));
      expect(generated, contains('class _DecrementEvent'));
      expect(generated, contains('class _ResetEvent'));
    });
  });
}
