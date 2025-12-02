import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

const _mockPackages = {
  'bloc|lib/bloc.dart': '''
    class Emitter<S> {
      void call(S state) {}
    }

    abstract class Bloc<E, S> {
      Bloc(S initialState);
      void add(E event) {}
      void emit(S state) {}
      void on<T>(Function handler, {Function? transformer}) {}
    }
  ''',
  'mono_bloc|lib/mono_bloc.dart': '''
    export 'package:bloc/bloc.dart';
    export 'src/annotations/mono_bloc.dart';
    export 'src/annotations/mono_event.dart';
    export 'src/annotations/mono_init.dart';
    export 'src/annotations/error_handler.dart';
    export 'src/annotations/on_event.dart';
    export 'src/annotations/mono_action.dart';
    export 'src/annotations/async_mono_bloc.dart';
    export 'src/annotations/mono_concurrency.dart';
    export 'src/mono_bloc_transformers.dart';
    export 'src/utils/mono_stack_trace.dart';
  ''',
  'mono_bloc|lib/src/annotations/mono_event.dart': '''
    const event = MonoEvent();
  ''',
  'mono_bloc|lib/src/mono_bloc_transformers.dart': '''
    import 'package:bloc/bloc.dart';

    typedef EventTransformer<E> = Function();

    class MonoEventTransformer {
      const MonoEventTransformer();
      static EventTransformer<dynamic> get sequential => () {};
      static EventTransformer<dynamic> get concurrent => () {};
      static EventTransformer<dynamic> get restartable => () {};
      static EventTransformer<dynamic> get droppable => () {};
    }
  ''',
  'mono_bloc|lib/src/utils/mono_stack_trace.dart': '''
    class MonoStackTrace {
      MonoStackTrace._();

      static StackTrace filtered(StackTrace origin, StackTrace trace, String exclude) {
        return trace;
      }
    }
  ''',
  'stack_trace|lib/stack_trace.dart': '''
    class Trace implements StackTrace {
      Trace.from(StackTrace trace);
      Trace(Iterable<Frame> frames);
      final List<Frame> frames = const [];
      Trace get terse => this;
    }

    class Frame {
      final bool isCore = false;
      final String? package = null;
      final Uri uri = Uri();
    }

    class Chain {
      Chain(List<Trace> traces);
      Trace toTrace() => Trace([]);
    }
  ''',
  'mono_bloc|lib/src/annotations/mono_bloc.dart': '''
    import 'package:meta/meta_meta.dart';

    enum MonoConcurrency { sequential, concurrent, restartable, droppable }

    @Target({TargetKind.classType})
    final class MonoBloc {
      final bool sequential;
      const MonoBloc({this.sequential = false});
    }

    @Target({TargetKind.method})
    final class MonoEvent {
      final MonoConcurrency? concurrency;
      final String? queue;

      const MonoEvent([this.concurrency]) : queue = null;
      const MonoEvent.queue([this.queue]) : concurrency = null;
    }

    @Target({TargetKind.method})
    final class MonoInit {
      const MonoInit();
    }

    @Target({TargetKind.method})
    final class MonoOnError {
      const MonoOnError();
    }

    const event = MonoEvent();
    const init = MonoInit();
    const onError = MonoOnError();
    const restartableEvent = MonoEvent(MonoConcurrency.restartable);
    const sequentialEvent = MonoEvent(MonoConcurrency.sequential);
    const concurrentEvent = MonoEvent(MonoConcurrency.concurrent);
    const droppableEvent = MonoEvent(MonoConcurrency.droppable);
  ''',
  'meta|lib/meta.dart': '''
    class _Protected {
      const _Protected();
    }

    const protected = _Protected();
  ''',
};

class _MockBuildStep implements BuildStep {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Import Validation Tests', () {
    late MonoBlocGenerator generator;

    setUp(() {
      generator = MonoBlocGenerator();
    });

    Future<String> generateForSource(
      String source, {
      String fileName = 'test_bloc.dart',
    }) {
      return resolveSources(
        {..._mockPackages, 'test_package|lib/$fileName': source},
        (resolver) async {
          final lib = await resolver.libraryFor(
            AssetId.parse('test_package|lib/$fileName'),
          );
          final generated = await generator.generate(
            LibraryReader(lib),
            _MockBuildStep(),
          );
          return generated;
        },
      );
    }

    test(
      'should succeed when mono_bloc is imported (re-exports bloc)',
      () async {
        // mono_bloc re-exports bloc/bloc.dart, so it's sufficient
        final result = await generateForSource(r'''
import 'package:mono_bloc/mono_bloc.dart';

part 'test_bloc.g.dart';

@MonoBloc()
class TestBloc extends _$TestBloc<int> {
  TestBloc() : super(0);

  @event
  int _onIncrement() => state + 1;
}
''');

        expect(result, isNotEmpty);
        expect(result, contains(r'class _$TestBloc'));
      },
    );

    test('should fail when part directive is missing', () async {
      await expectLater(
        generateForSource(r'''
import 'package:bloc/bloc.dart';
import 'package:mono_bloc/mono_bloc.dart';

@MonoBloc()
class TestBloc extends _$TestBloc<int> {
  TestBloc() : super(0);

  @event
  int _onIncrement() => state + 1;
}
'''),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.toString(),
            'error message',
            allOf([
              contains('Missing part directive'),
              contains("part 'test_bloc.g.dart'"),
              contains(r'_$TestBloc will not be available'),
            ]),
          ),
        ),
      );
    });

    test(
      'should fail when both bloc import and part directive are missing',
      () async {
        await expectLater(
          generateForSource(r'''
import 'package:mono_bloc/src/annotations/mono_bloc.dart';
import 'package:mono_bloc/src/annotations/mono_event.dart';

@MonoBloc()
class TestBloc extends _$TestBloc<int> {
  TestBloc() : super(0);

  @event
  int _onIncrement() => state + 1;
}
'''),
          throwsA(
            isA<InvalidGenerationSourceError>().having(
              (e) => e.toString(),
              'error message',
              allOf([
                contains('Code generation failed'),
                contains('1. Missing import'),
                contains('package:bloc/bloc.dart'),
                contains('2. Missing import'),
                contains('package:mono_bloc/mono_bloc.dart'),
                contains('3. Missing part directive'),
                contains("part 'test_bloc.g.dart'"),
              ]),
            ),
          ),
        );
      },
    );

    test('should succeed with all required imports present', () async {
      final result = await generateForSource(r'''
import 'package:bloc/bloc.dart';
import 'package:mono_bloc/mono_bloc.dart';

part 'test_bloc.g.dart';

@MonoBloc()
class TestBloc extends _$TestBloc<int> {
  TestBloc() : super(0);

  @event
  int _onIncrement() => state + 1;

  @event
  int _onDecrement() => state - 1;
}
''');

      expect(result, isNotEmpty);
      expect(result, contains(r'class _$TestBloc'));
      // Base class is generated successfully - events are in extension type
      expect(result, contains(r'extension type _$'));
    });

    test('should succeed with mono_bloc import for @protected', () async {
      final result = await generateForSource(r'''
import 'package:mono_bloc/mono_bloc.dart';

part 'test_bloc.g.dart';

@MonoBloc()
class TestBloc extends _$TestBloc<int> {
  TestBloc() : super(0);

  @event
  @protected
  int onIncrement() => state + 1;
}
''');

      expect(result, isNotEmpty);
      expect(result, contains(r'class _$TestBloc'));
      expect(result, contains('@protected'));
    });

    test(
      'should provide detailed error message with complete example',
      () async {
        await expectLater(
          generateForSource(r'''
import 'package:mono_bloc/mono_bloc.dart';

@MonoBloc()
class MyCustomBloc extends _$MyCustomBloc<String> {
  MyCustomBloc() : super('');

  @event
  String _onUpdate() => 'updated';
}
''', fileName: 'my_custom_bloc.dart'),
          throwsA(
            isA<InvalidGenerationSourceError>().having(
              (e) => e.toString(),
              'error message',
              allOf([
                contains('Complete example:'),
                contains("import 'package:bloc/bloc.dart';"),
                contains("import 'package:mono_bloc/mono_bloc.dart';"),
                contains("part 'my_custom_bloc.g.dart';"),
                contains(r'class MyCustomBloc extends _$MyCustomBloc'),
                contains('@event'),
                contains('YourState _onSomeEvent() => state;'),
              ]),
            ),
          ),
        );
      },
    );

    test('should check correct part directive filename', () async {
      await expectLater(
        generateForSource(r'''
import 'package:bloc/bloc.dart';
import 'package:mono_bloc/mono_bloc.dart';

part 'wrong_name.g.dart';

@MonoBloc()
class MyBloc extends _$MyBloc<int> {
  MyBloc() : super(0);

  @event
  int _onIncrement() => state + 1;
}
''', fileName: 'my_bloc.dart'),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.toString(),
            'error message',
            allOf([
              contains('Missing part directive'),
              contains("part 'my_bloc.g.dart'"),
            ]),
          ),
        ),
      );
    });

    test('should validate file-specific part directive', () async {
      await expectLater(
        generateForSource(r'''
import 'package:bloc/bloc.dart';
import 'package:mono_bloc/mono_bloc.dart';

part 'some_other_file.g.dart';

@MonoBloc()
class UserBloc extends _$UserBloc<int> {
  UserBloc() : super(0);

  @event
  int _onUpdate() => state + 1;
}
''', fileName: 'user_bloc.dart'),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.toString(),
            'error message',
            allOf([
              contains('Missing part directive'),
              contains("part 'user_bloc.g.dart'"),
              contains(r'_$UserBloc will not be available'),
            ]),
          ),
        ),
      );
    });

    test('should include file name in error message', () async {
      await expectLater(
        generateForSource(r'''
import 'package:mono_bloc/mono_bloc.dart';

@MonoBloc()
class ProductBloc extends _$ProductBloc<int> {
  ProductBloc() : super(0);

  @event
  int _onUpdate() => state + 1;
}
''', fileName: 'product_bloc.dart'),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.toString(),
            'error message',
            allOf([
              contains('File: product_bloc.dart'),
              contains('class ProductBloc'),
            ]),
          ),
        ),
      );
    });

    test('should provide numbered error list for multiple issues', () async {
      await expectLater(
        generateForSource(r'''
import 'package:mono_bloc/src/annotations/mono_bloc.dart';
import 'package:mono_bloc/src/annotations/mono_event.dart';

@MonoBloc()
class ErrorBloc extends _$ErrorBloc<int> {
  ErrorBloc() : super(0);

  @event
  int _onUpdate() => state + 1;
}
''', fileName: 'error_bloc.dart'),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.toString(),
            'error message',
            allOf([
              contains('1. Missing import'),
              contains('2. Missing import'),
              contains('3. Missing part directive'),
            ]),
          ),
        ),
      );
    });
  });
}
