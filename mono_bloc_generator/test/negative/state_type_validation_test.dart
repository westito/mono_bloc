import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - State Type Validation', () {
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

    test('should require State type in generic parameter', () {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class CounterState {
          const CounterState(this.value);
          final int value;
        }
        
        @MonoBloc()
        class CounterBloc extends _$CounterBloc {
          CounterBloc() : super(const CounterState(0));
          
          @event
          CounterState _onIncrement() => CounterState(0);
        }
      ''';

      expect(
        () => generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains(r'must extend _$CounterBloc<State>'),
          ),
        ),
      );
    });

    test('should accept valid State type in generic parameter', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class CounterState {
          const CounterState(this.value);
          final int value;
        }
        
        @MonoBloc()
        class CounterBloc extends _$CounterBloc<CounterState> {
          CounterBloc() : super(const CounterState(0));
          
          @event
          CounterState _onIncrement() => CounterState(0);
        }
      ''';

      final result = await generateForSource(source);
      expect(result, isNotEmpty);
      expect(result, contains(r'abstract class _$CounterBloc<_>'));
      expect(result, contains('Bloc<_Event, CounterState>'));
    });

    test('should work with complex State types', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class DataState<T> {
          const DataState(this.data);
          final T data;
        }
        
        @MonoBloc()
        class DataBloc extends _$DataBloc<DataState<String>> {
          DataBloc() : super(const DataState(''));
          
          @event
          DataState<String> _onUpdate(String value) => DataState(value);
        }
      ''';

      final result = await generateForSource(source);
      expect(result, isNotEmpty);
      expect(result, contains(r'abstract class _$DataBloc<_>'));
      expect(result, contains('Bloc<_Event, DataState<String>>'));
    });

    test('should work with nullable State types', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class OptionalState {
          const OptionalState(this.value);
          final int? value;
        }
        
        @MonoBloc()
        class OptionalBloc extends _$OptionalBloc<OptionalState?> {
          OptionalBloc() : super(null);
          
          @event
          OptionalState? _onUpdate() => const OptionalState(1);
        }
      ''';

      final result = await generateForSource(source);
      expect(result, isNotEmpty);
      expect(result, contains(r'abstract class _$OptionalBloc<_>'));
      expect(result, contains('Bloc<_Event, OptionalState?>'));
    });

    test('should extract State type from source code pattern', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        sealed class MyState {}
        class Initial extends MyState {}
        class Loading extends MyState {}
        
        @MonoBloc()
        class MyBloc extends _$MyBloc<MyState> {
          MyBloc() : super(Initial());
          
          @event
          MyState _onStart() => Loading();
        }
      ''';

      final result = await generateForSource(source);
      expect(result, isNotEmpty);
      expect(result, contains('Emitter<MyState>'));
      expect(result, contains('Bloc<_Event, MyState>'));
    });

    test(
      'should generate correct Emitter typedef with actual State type',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        class TodoState {
          const TodoState();
        }
        
        @MonoBloc()
        class TodoBloc extends _$TodoBloc<TodoState> {
          TodoBloc() : super(const TodoState());
          
          @event
          TodoState _onLoad() => const TodoState();
        }
      ''';

        final result = await generateForSource(source);
        expect(result, contains('typedef _Emitter = Emitter<TodoState>'));
        expect(result, isNot(contains('Emitter<_>')));
        expect(result, isNot(contains('Emitter<State>')));
      },
    );
  });
}
