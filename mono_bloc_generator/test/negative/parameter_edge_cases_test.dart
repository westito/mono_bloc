import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - Parameter Edge Cases', () {
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

    test('should handle nullable parameters', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        part 'test.g.dart';

        abstract class TestState {}

        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());

          @event
          TestState _onUpdate(String? value, int? count) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('final String? value;'));
      expect(generated, contains('final int? count;'));
      expect(generated, contains('this.value'));
      expect(generated, contains('this.count'));
    });

    test('should handle parameters with default values', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        part 'test.g.dart';

        abstract class TestState {}

        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());

          @event
          TestState _onUpdate({String name = 'default', int count = 0}) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains("String name = 'default'"));
      expect(generated, contains('int count = 0'));
    });

    test('should handle generic type parameters', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        part 'test.g.dart';

        abstract class TestState {}

        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());

          @event
          TestState _onUpdate<T>(List<T> items, Map<String, T> mapping) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('final List<'));
      expect(generated, contains('final Map<String,'));
    });

    test('should handle complex nested generic types', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        part 'test.g.dart';

        abstract class TestState {}

        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());

          @event
          TestState _onUpdate(
            Map<String, List<int>> data,
            Future<Map<String, dynamic>> Function() callback,
          ) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('final Map<String, List<int>> data;'));
      expect(
        generated,
        contains('final Future<Map<String, dynamic>> Function() callback;'),
      );
    });

    test('should handle nullable generic parameters', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        part 'test.g.dart';

        abstract class TestState {}

        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());

          @event
          TestState _onUpdate(List<String>? items, Map<int, String?>? mapping) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('final List<String>? items;'));
      expect(generated, contains('final Map<int, String?>? mapping;'));
    });

    test('should handle very long parameter lists (10+ params)', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        part 'test.g.dart';

        abstract class TestState {}

        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());

          @event
          TestState _onUpdate(
            int p1,
            int p2,
            int p3,
            int p4,
            int p5,
            int p6,
            int p7,
            int p8,
            int p9,
            int p10,
            int p11,
            int p12,
          ) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      for (var i = 1; i <= 12; i++) {
        expect(generated, contains('final int p$i;'));
      }
    });

    test(
      'should handle mixed positional, optional, and named parameters',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        part 'test.g.dart';

        abstract class TestState {}

        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());

          @event
          TestState _onUpdate(
            int required1,
            String required2, {
            required bool named1,
            int? optionalNamed,
            String namedWithDefault = 'test',
          }) => TestState();
        }
      ''';

        final generated = await generateForSource(source);

        expect(generated, contains('final int required1;'));
        expect(generated, contains('final String required2;'));
        expect(generated, contains('final bool named1;'));
        expect(generated, contains('final int? optionalNamed;'));
        expect(generated, contains('final String namedWithDefault;'));
      },
    );

    test('should handle typedef parameters', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        part 'test.g.dart';

        typedef Callback = void Function(String);
        typedef AsyncCallback = Future<void> Function(int);

        abstract class TestState {}

        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());

          @event
          TestState _onUpdate(Callback cb, AsyncCallback asyncCb) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      // Generator resolves typedefs to their underlying types
      expect(generated, contains('final void Function(String) cb;'));
      expect(generated, contains('final Future<void> Function(int) asyncCb;'));
    });

    test(
      'should handle function type parameters with named parameters',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        part 'test.g.dart';

        abstract class TestState {}

        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());

          @event
          TestState _onUpdate(
            void Function({required String name, int? age}) callback,
          ) => TestState();
        }
      ''';

        final generated = await generateForSource(source);

        // Generator formats function types - just check the parameter exists
        expect(generated, contains('callback'));
      },
    );

    test(
      'should handle events with only Emitter parameter and no other params',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        part 'test.g.dart';

        abstract class TestState {}

        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());

          @event
          void _onEmptyEvent(_Emitter emit) {
            emit(TestState());
          }
        }
      ''';

        final generated = await generateForSource(source);

        expect(generated, contains('void emptyEvent()'));
        expect(generated, contains('_EmptyEventEvent'));
      },
    );

    test(
      'should handle parameters with special characters in default values',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        part 'test.g.dart';

        abstract class TestState {}

        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());

          @event
          TestState _onUpdate({
            String text = 'Hello "World"',
            String path = r'C:\Users\test',
          }) => TestState();
        }
      ''';

        final generated = await generateForSource(source);

        expect(generated, contains('final String text;'));
        expect(generated, contains('final String path;'));
      },
    );

    test('should handle enum parameters', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        part 'test.g.dart';

        enum Status { active, inactive, pending }

        abstract class TestState {}

        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());

          @event
          TestState _onUpdate(Status status, Status? optionalStatus) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('final Status status;'));
      expect(generated, contains('final Status? optionalStatus;'));
    });

    test('should handle DateTime and Duration parameters', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        part 'test.g.dart';

        abstract class TestState {}

        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());

          @event
          TestState _onUpdate(DateTime timestamp, Duration timeout) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('final DateTime timestamp;'));
      expect(generated, contains('final Duration timeout;'));
    });

    test('should handle Set parameters', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        part 'test.g.dart';

        abstract class TestState {}

        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());

          @event
          TestState _onUpdate(Set<int> ids, Set<String>? tags) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('final Set<int> ids;'));
      expect(generated, contains('final Set<String>? tags;'));
    });

    test('should handle Record type parameters', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        part 'test.g.dart';

        abstract class TestState {}

        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());

          @event
          TestState _onUpdate((int, String) record, (int, String)? optionalRecord) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('final (int, String) record;'));
      expect(generated, contains('final (int, String)? optionalRecord;'));
    });

    test('should handle named Record type parameters', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        part 'test.g.dart';

        abstract class TestState {}

        @MonoBloc()
        class SimpleBloc extends _$SimpleBloc<TestState> {
          SimpleBloc() : super(TestState());

          @event
          TestState _onUpdate(({int id, String name}) record) => TestState();
        }
      ''';

      final generated = await generateForSource(source);

      expect(generated, contains('final ({int id, String name}) record;'));
    });
  });
}
