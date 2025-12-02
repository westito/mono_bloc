import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - Stream @onInit Validation', () {
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

    test('should reject Stream return in @onInit for sequential bloc', () {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc(sequential: true)
        class SequentialBloc extends _$SequentialBloc<TestState> {
          SequentialBloc() : super(TestState());
          
          @onInit
          Stream<TestState> _initStream() async* {
            yield TestState();
          }
          
          @event
          TestState _onEvent() => TestState();
        }
      ''';

      expect(
        () => generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            allOf([
              contains('@onInit method "_initStream" returns Stream<...>'),
              contains('NOT allowed in sequential blocs'),
              contains('DEADLOCK'),
              contains('Use Future instead of Stream'),
            ]),
          ),
        ),
      );
    });

    test(
      'should allow Stream return in @onInit for NON-sequential bloc',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc()  // NOT sequential
        class ParallelBloc extends _$ParallelBloc<TestState> {
          ParallelBloc() : super(TestState());
          
          @onInit
          Stream<TestState> _initStream() async* {
            yield TestState();
          }
          
          @event
          TestState _onEvent() => TestState();
        }
      ''';

        // Should NOT throw - parallel blocs can use Stream in @onInit
        final generated = await generateForSource(source);
        expect(generated, isNotEmpty);
        expect(generated, contains('class _InitStreamEvent'));
      },
    );

    test('should allow Future return in @onInit for sequential bloc', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc(sequential: true)
        class SequentialBloc extends _$SequentialBloc<TestState> {
          SequentialBloc() : super(TestState());
          
          @onInit
          Future<TestState> _initAsync() async {
            return TestState();
          }
          
          @event
          TestState _onEvent() => TestState();
        }
      ''';

      // Should NOT throw - Future is allowed
      final generated = await generateForSource(source);
      expect(generated, isNotEmpty);
      expect(generated, contains('class _InitAsyncEvent'));
    });

    test('should allow sync return in @onInit for sequential bloc', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc(sequential: true)
        class SequentialBloc extends _$SequentialBloc<TestState> {
          SequentialBloc() : super(TestState());
          
          @onInit
          TestState _initSync() {
            return TestState();
          }
          
          @event
          TestState _onEvent() => TestState();
        }
      ''';

      // Should NOT throw - synchronous return is allowed
      final generated = await generateForSource(source);
      expect(generated, isNotEmpty);
      expect(generated, contains('class _InitSyncEvent'));
    });

    test(
      'should allow void with _Emitter in @onInit for sequential bloc',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc(sequential: true)
        class SequentialBloc extends _$SequentialBloc<TestState> {
          SequentialBloc() : super(TestState());
          
          @onInit
          Future<void> _initWithEmitter(_Emitter emit) async {
            emit(TestState());
          }
          
          @event
          TestState _onEvent() => TestState();
        }
      ''';

        // Should NOT throw - _Emitter pattern is allowed
        final generated = await generateForSource(source);
        expect(generated, isNotEmpty);
        expect(generated, contains('class _InitWithEmitterEvent'));
      },
    );

    test(
      'should reject multiple Stream @onInit methods in sequential bloc',
      () {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        abstract class TestState {}
        
        @MonoBloc(sequential: true)
        class SequentialBloc extends _$SequentialBloc<TestState> {
          SequentialBloc() : super(TestState());
          
          @onInit
          Stream<TestState> _initStream1() async* {
            yield TestState();
          }
          
          @onInit
          Stream<TestState> _initStream2() async* {
            yield TestState();
          }
          
          @event
          TestState _onEvent() => TestState();
        }
      ''';

        // Should throw on FIRST Stream @onInit found
        expect(
          () => generateForSource(source),
          throwsA(
            isA<InvalidGenerationSourceError>().having(
              (e) => e.message,
              'message',
              contains('returns Stream<...>'),
            ),
          ),
        );
      },
    );
  });
}
