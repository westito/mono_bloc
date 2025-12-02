import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - Async Bloc Edge Cases', () {
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

    test('should handle async bloc with unwrapped return type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @AsyncMonoBloc()
        class DataBloc extends _$DataBloc<List<String>> {
          DataBloc() : super(const MonoAsyncValue.initial());
          
          @event
          List<String> _onLoad() => ['item1', 'item2'];
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('MonoAsyncValue'));
      expect(generated, isNotEmpty);
    });

    test('should handle async bloc with Future unwrapped return', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @AsyncMonoBloc()
        class DataBloc extends _$DataBloc<List<String>> {
          DataBloc() : super(const MonoAsyncValue.initial());
          
          @event
          Future<List<String>> _onLoad() async => ['item1', 'item2'];
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('MonoAsyncValue'));
      expect(generated, isNotEmpty);
    });

    test('should handle async bloc with wrapped return type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @AsyncMonoBloc()
        class DataBloc extends _$DataBloc<List<String>> {
          DataBloc() : super(const MonoAsyncValue.initial());
          
          @event
          MonoAsyncValue<List<String>> _onLoad() => const MonoAsyncValue.data(['item1']);
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('MonoAsyncValue'));
      expect(generated, isNotEmpty);
    });

    test('should handle async bloc with Stream return', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @AsyncMonoBloc()
        class DataBloc extends _$DataBloc<List<String>> {
          DataBloc() : super(const MonoAsyncValue.initial());
          
          @event
          Stream<MonoAsyncValue<List<String>>> _onLoad() async* {
            yield const MonoAsyncValue.loading();
            yield const MonoAsyncValue.data(['item1']);
          }
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('MonoAsyncValue'));
      expect(generated, isNotEmpty);
    });

    test('should handle async bloc with nullable data type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @AsyncMonoBloc()
        class DataBloc extends _$DataBloc<String?> {
          DataBloc() : super(const MonoAsyncValue.initial());
          
          @event
          String? _onLoad() => null;
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('MonoAsyncValue'));
      expect(generated, isNotEmpty);
    });

    test('should handle async bloc with complex generic type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @AsyncMonoBloc()
        class DataBloc extends _$DataBloc<Map<String, List<int>>> {
          DataBloc() : super(const MonoAsyncValue.initial());
          
          @event
          Map<String, List<int>> _onLoad() => {};
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('MonoAsyncValue'));
      expect(generated, contains('Map<String, List<int>>'));
    });

    test('should handle async bloc with void Emitter method', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @AsyncMonoBloc()
        class DataBloc extends _$DataBloc<List<String>> {
          DataBloc() : super(const MonoAsyncValue.initial());
          
          @event
          void _onLoad(_Emitter emit) {
            emit(const MonoAsyncValue.data(['item1']));
          }
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('MonoAsyncValue'));
      expect(generated, isNotEmpty);
    });

    test('should handle async bloc with error handler', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @AsyncMonoBloc()
        class DataBloc extends _$DataBloc<List<String>> {
          DataBloc() : super(const MonoAsyncValue.initial());
          
          @event
          List<String> _onLoad() => ['item1'];
          
          @onError
          MonoAsyncValue<List<String>> _onError(Object error, StackTrace stack) {
            return MonoAsyncValue.error(error, stack);
          }
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('MonoAsyncValue'));
      expect(generated, contains('_onError'));
    });

    test('should handle async bloc with actions', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @AsyncMonoBloc()
        class DataBloc extends _$DataBloc<List<String>> {
          DataBloc() : super(const MonoAsyncValue.initial());
          
          @event
          List<String> _onLoad() => ['item1'];
        }
        
        @MonoActions()
        mixin _DataBlocActions {
          void showError(String message);
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('MonoAsyncValue'));
      expect(generated, contains('_ShowErrorAction'));
      expect(generated, contains('MonoBlocActionMixin'));
    });

    test('should handle async bloc with sequential mode', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @AsyncMonoBloc(sequential: true)
        class DataBloc extends _$DataBloc<List<String>> {
          DataBloc() : super(const MonoAsyncValue.initial());
          
          @event
          List<String> _onLoad() => ['item1'];
          
          @event
          Future<List<String>> _onRefresh() async => ['item2'];
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('MonoAsyncValue'));
      expect(generated, contains('_LoadEvent'));
      expect(generated, contains('_RefreshEvent'));
    });

    test('should handle async bloc with multiple event types', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @AsyncMonoBloc()
        class DataBloc extends _$DataBloc<List<String>> {
          DataBloc() : super(const MonoAsyncValue.initial());
          
          @event
          List<String> _onSync() => ['sync'];
          
          @event
          Future<List<String>> _onAsync() async => ['async'];
          
          @event
          Stream<MonoAsyncValue<List<String>>> _onStreamData() async* {
            yield const MonoAsyncValue.loading();
          }
          
          @event
          void _onEmitter(_Emitter emit) {
            emit(const MonoAsyncValue.data(['emitter']));
          }
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('MonoAsyncValue'));
      expect(generated, isNotEmpty);
    });

    test('should handle async bloc with custom type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        class User {
          const User(this.name);
          final String name;
        }
        
        @AsyncMonoBloc()
        class UserBloc extends _$UserBloc<User> {
          UserBloc() : super(const MonoAsyncValue.initial());
          
          @event
          User _onLoad() => const User('John');
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('MonoAsyncValue'));
      expect(generated, contains('User'));
    });

    test('should handle async bloc with typedef state', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        typedef UserList = List<String>;
        
        @AsyncMonoBloc()
        class UserBloc extends _$UserBloc<UserList> {
          UserBloc() : super(const MonoAsyncValue.initial());
          
          @event
          UserList _onLoad() => ['user1'];
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('MonoAsyncValue'));
      expect(generated, isNotEmpty);
    });

    test('should handle async bloc with record type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @AsyncMonoBloc()
        class DataBloc extends _$DataBloc<(int, String)> {
          DataBloc() : super(const MonoAsyncValue.initial());
          
          @event
          (int, String) _onLoad() => (1, 'test');
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('MonoAsyncValue'));
      expect(generated, contains('(int, String)'));
    });

    test('should handle async bloc with named record type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';
        
        part 'test.g.dart';
        
        @AsyncMonoBloc()
        class DataBloc extends _$DataBloc<({int id, String name})> {
          DataBloc() : super(const MonoAsyncValue.initial());
          
          @event
          ({int id, String name}) _onLoad() => (id: 1, name: 'test');
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('MonoAsyncValue'));
      expect(generated, contains('({int id, String name})'));
    });
  });
}
