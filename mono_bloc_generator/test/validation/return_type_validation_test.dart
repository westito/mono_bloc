import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('Return Type Validation', () {
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

    test('should reject Future<bool> return type', () async {
      const source = r'''
import 'package:bloc/bloc.dart';
import 'package:mono_bloc/mono_bloc.dart';

part 'test.g.dart';

class TestState {
  const TestState({this.value = 0});
  final int value;
}

@MonoBloc()
class TestBloc extends _$TestBloc<TestState> {
  TestBloc() : super(const TestState());
  
  @event
  Future<bool> _onInvalidReturnType(int value) async {
    return true;
  }
}
''';

      await expectLater(
        generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains(
              "Method '_onInvalidReturnType' has invalid return type: Future<bool>",
            ),
          ),
        ),
      );
    });

    test('should reject String return type', () async {
      const source = r'''
import 'package:bloc/bloc.dart';
import 'package:mono_bloc/mono_bloc.dart';

part 'test.g.dart';

class TestState {
  const TestState({this.value = 0});
  final int value;
}

@MonoBloc()
class TestBloc extends _$TestBloc<TestState> {
  TestBloc() : super(const TestState());
  
  @event
  String _onInvalidString() {
    return 'invalid';
  }
}
''';

      await expectLater(
        generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains(
              "Method '_onInvalidString' has invalid return type: String",
            ),
          ),
        ),
      );
    });

    test('should reject int return type', () async {
      const source = r'''
import 'package:bloc/bloc.dart';
import 'package:mono_bloc/mono_bloc.dart';

part 'test.g.dart';

class TestState {
  const TestState({this.value = 0});
  final int value;
}

@MonoBloc()
class TestBloc extends _$TestBloc<TestState> {
  TestBloc() : super(const TestState());
  
  @event
  int _onInvalidInt() {
    return 42;
  }
}
''';

      await expectLater(
        generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains("Method '_onInvalidInt' has invalid return type: int"),
          ),
        ),
      );
    });

    test('should reject Future<String> return type', () async {
      const source = r'''
import 'package:bloc/bloc.dart';
import 'package:mono_bloc/mono_bloc.dart';

part 'test.g.dart';

class TestState {
  const TestState({this.value = 0});
  final int value;
}

@MonoBloc()
class TestBloc extends _$TestBloc<TestState> {
  TestBloc() : super(const TestState());
  
  @event
  Future<String> _onInvalidFutureString() async {
    return 'invalid';
  }
}
''';

      await expectLater(
        generateForSource(source),
        throwsA(
          isA<InvalidGenerationSourceError>().having(
            (e) => e.message,
            'message',
            contains(
              "Method '_onInvalidFutureString' has invalid return type: Future<String>",
            ),
          ),
        ),
      );
    });

    test(
      'should provide helpful error message with valid return types',
      () async {
        const source = r'''
import 'package:bloc/bloc.dart';
import 'package:mono_bloc/mono_bloc.dart';

part 'test.g.dart';

class TestState {
  const TestState({this.value = 0});
  final int value;
}

@MonoBloc()
class TestBloc extends _$TestBloc<TestState> {
  TestBloc() : super(const TestState());
  
  @event
  Future<bool> _onInvalidReturnType(int value) async {
    return true;
  }
}
''';

        await expectLater(
          generateForSource(source),
          throwsA(
            isA<InvalidGenerationSourceError>().having(
              (e) => e.message,
              'message',
              allOf(
                contains(
                  'MonoBloc @event methods MUST return one of these types:',
                ),
                contains('Stream<TestState>'),
                contains('TestState'),
                contains('Future<TestState>'),
                contains('void - with _Emitter parameter'),
                contains('Future<void> - with _Emitter parameter'),
              ),
            ),
          ),
        );
      },
    );
  });
}
