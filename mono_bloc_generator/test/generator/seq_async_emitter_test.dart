import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoAsyncSeqEmitter Generation', () {
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

    test('should generate MonoAsyncSeqEmitter for sequential async bloc', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class MyData {
          const MyData(this.value);
          final int value;
        }
        
        @AsyncMonoBloc(sequential: true)
        class SequentialAsyncBloc extends _$SequentialAsyncBloc<MyData> {
          SequentialAsyncBloc() : super(const MonoAsyncValue.withData(MyData(0)));
          
          @event
          Future<void> _onFetch(_Emitter emit) async {
            emit(const MyData(1));
          }
        }
      ''';

      final generated = await generateForSource(source);

      // Should generate MonoAsyncSeqEmitter typedef (not MonoAsyncEmitter)
      // MonoAsyncSeqEmitter has call(), loading(), error() but NO forEach/onEach
      expect(
        generated,
        contains('typedef _Emitter = MonoAsyncSeqEmitter<MyData>'),
        reason: 'Sequential async bloc should use MonoAsyncSeqEmitter',
      );

      // Should NOT use MonoAsyncEmitter (which has forEach/onEach)
      expect(
        generated,
        isNot(contains('typedef _Emitter = MonoAsyncEmitter<MyData>')),
        reason: 'Sequential bloc should not use MonoAsyncEmitter',
      );

      // Should generate _$wrapEmit with MonoAsyncSeqEmitter
      expect(
        generated,
        contains(r'MonoAsyncSeqEmitter<MyData> _$wrapEmit'),
        reason: 'Should wrap emitter with MonoAsyncSeqEmitter',
      );

      // Should pass emit and bloc (MonoAsyncSeqEmitter needs bloc for loading()/error())
      expect(
        generated,
        contains('return MonoAsyncSeqEmitter<MyData>(emit, bloc)'),
        reason:
            'MonoAsyncSeqEmitter needs bloc reference for loading()/error()',
      );
    });

    test('should generate MonoAsyncEmitter for parallel async bloc', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class MyData {
          const MyData(this.value);
          final int value;
        }
        
        @AsyncMonoBloc()  // NOT sequential
        class ParallelAsyncBloc extends _$ParallelAsyncBloc<MyData> {
          ParallelAsyncBloc() : super(const MonoAsyncValue.withData(MyData(0)));
          
          @event
          Future<void> _onFetch(_Emitter emit) async {
            emit(const MyData(1));
          }
        }
      ''';

      final generated = await generateForSource(source);

      // Should generate MonoAsyncEmitter typedef (not MonoAsyncSeqEmitter)
      expect(
        generated,
        contains('typedef _Emitter = MonoAsyncEmitter<MyData>'),
        reason: 'Parallel async bloc should use MonoAsyncEmitter',
      );

      // Should NOT use MonoAsyncSeqEmitter
      expect(
        generated,
        isNot(contains('typedef _Emitter = MonoAsyncSeqEmitter<MyData>')),
        reason: 'Parallel bloc should not use MonoAsyncSeqEmitter',
      );

      // Should generate _$wrapEmit with MonoAsyncEmitter
      expect(
        generated,
        contains(r'MonoAsyncEmitter<MyData> _$wrapEmit'),
        reason: 'Should wrap emitter with MonoAsyncEmitter',
      );

      // Should pass emit and bloc (for loading/error methods)
      expect(
        generated,
        contains('return MonoAsyncEmitter<MyData>(emit, bloc)'),
        reason: 'MonoAsyncEmitter needs bloc reference for loading()/error()',
      );
    });
  });
}
