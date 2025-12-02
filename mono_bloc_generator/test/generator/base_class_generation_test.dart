import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - Base Class Generation', () {
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

    test('should generate base class with init method', () async {
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

      expect(generated, contains(r'abstract class _$SimpleBloc<_>'));
      expect(generated, contains('extends Bloc<_Event, TestState>'));
      expect(generated, contains(r'void _$init()'));
    });

    test('should register events in init method', () async {
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

      expect(generated, contains('on<_IncrementEvent>'));
      expect(generated, contains('emit(_onIncrement())'));
    });

    test(
      'should generate public methods without abstract declarations',
      () async {
        const source = r'''
        import 'package:mono_bloc/mono_bloc.dart';
        import 'package:mono_bloc/src/mono_bloc_annotations.dart';
        
        abstract class TestEvent {}
        abstract class TestState {}
        
        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());
          
          @MonoEvent()
          void _increment(Emitter<TestState> emit) {}
          
          @MonoEvent()
          TestState _reset() {
            return TestState();
          }
          
          @MonoEvent()
          Stream<TestState> _loadAsync() async* {
            yield TestState();
          }
        }
      ''';

        final generated = await generateForSource(source);

        // Should generate public methods
        expect(generated, contains('void increment()'));
        expect(generated, contains('void reset()'));
        expect(generated, contains('void loadAsync()'));
      },
    );
  });
}
