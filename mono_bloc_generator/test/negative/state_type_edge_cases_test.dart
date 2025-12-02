import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - State Type Edge Cases', () {
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

    test('should handle nullable state type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoBloc()
        class NullableBloc extends _$NullableBloc<int?> {
          NullableBloc() : super(null);
          
          @event
          int? _onEvent() => null;
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('int?'));
      expect(generated, isNotEmpty);
    });

    test('should handle complex generic state type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoBloc()
        class ComplexBloc extends _$ComplexBloc<Map<String, List<int>>> {
          ComplexBloc() : super({});
          
          @event
          Map<String, List<int>> _onEvent() => {};
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('Map<String, List<int>>'));
      expect(generated, isNotEmpty);
    });

    test('should handle record state type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoBloc()
        class RecordBloc extends _$RecordBloc<(int, String)> {
          RecordBloc() : super((0, ''));
          
          @event
          (int, String) _onEvent() => (1, 'test');
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('(int, String)'));
      expect(generated, isNotEmpty);
    });

    test('should handle named record state type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoBloc()
        class NamedRecordBloc extends _$NamedRecordBloc<({int id, String name})> {
          NamedRecordBloc() : super((id: 0, name: ''));
          
          @event
          ({int id, String name}) _onEvent() => (id: 1, name: 'test');
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('({int id, String name})'));
      expect(generated, isNotEmpty);
    });

    test('should handle typedef state type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        typedef AppState = Map<String, dynamic>;
        
        @MonoBloc()
        class TypedefBloc extends _$TypedefBloc<AppState> {
          TypedefBloc() : super({});
          
          @event
          AppState _onEvent() => {};
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, isNotEmpty);
    });

    test('should handle Function state type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoBloc()
        class FunctionBloc extends _$FunctionBloc<void Function()> {
          FunctionBloc() : super(() {});
          
          @event
          void Function() _onEvent() => () {};
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('void Function()'));
      expect(generated, isNotEmpty);
    });

    test('should handle Future state type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoBloc()
        class FutureBloc extends _$FutureBloc<Future<int>> {
          FutureBloc() : super(Future.value(0));
          
          @event
          Future<int> _onEvent() => Future.value(1);
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('Future<int>'));
      expect(generated, isNotEmpty);
    });

    test('should handle Stream state type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoBloc()
        class StreamBloc extends _$StreamBloc<Stream<int>> {
          StreamBloc() : super(Stream.value(0));
          
          @event
          Stream<int> _onEvent() => Stream.value(1);
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('Stream<int>'));
      expect(generated, isNotEmpty);
    });

    test('should handle enum state type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        enum Status { idle, loading, success, error }
        
        @MonoBloc()
        class EnumBloc extends _$EnumBloc<Status> {
          EnumBloc() : super(Status.idle);
          
          @event
          Status _onEvent() => Status.loading;
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('Status'));
      expect(generated, isNotEmpty);
    });

    test('should handle Set state type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoBloc()
        class SetBloc extends _$SetBloc<Set<String>> {
          SetBloc() : super({});
          
          @event
          Set<String> _onEvent() => {'item'};
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('Set<String>'));
      expect(generated, isNotEmpty);
    });

    test('should handle primitive int state type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoBloc()
        class IntBloc extends _$IntBloc<int> {
          IntBloc() : super(0);
          
          @event
          int _onIncrement() => state + 1;
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('int'));
      expect(generated, isNotEmpty);
    });

    test('should handle String state type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoBloc()
        class StringBloc extends _$StringBloc<String> {
          StringBloc() : super('');
          
          @event
          String _onUpdate(String value) => value;
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('String'));
      expect(generated, isNotEmpty);
    });

    test('should handle bool state type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoBloc()
        class BoolBloc extends _$BoolBloc<bool> {
          BoolBloc() : super(false);
          
          @event
          bool _onToggle() => !state;
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('bool'));
      expect(generated, isNotEmpty);
    });

    test('should handle double state type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoBloc()
        class DoubleBloc extends _$DoubleBloc<double> {
          DoubleBloc() : super(0.0);
          
          @event
          double _onUpdate(double value) => value;
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('double'));
      expect(generated, isNotEmpty);
    });

    test('should handle List state type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoBloc()
        class ListBloc extends _$ListBloc<List<int>> {
          ListBloc() : super([]);
          
          @event
          List<int> _onAddItem(int value) => [...state, value];
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('List<int>'));
      expect(generated, isNotEmpty);
    });

    test('should handle deeply nested generic state type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @MonoBloc()
        class DeepBloc extends _$DeepBloc<Map<String, Map<int, List<String>>>> {
          DeepBloc() : super({});
          
          @event
          Map<String, Map<int, List<String>>> _onEvent() => {};
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('Map<String, Map<int, List<String>>>'));
      expect(generated, isNotEmpty);
    });
  });
}
