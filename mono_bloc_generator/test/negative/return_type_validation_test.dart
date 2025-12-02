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

    group('Action Methods', () {
      test('action method must return void', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          part 'test.g.dart';
          
          @MonoActions()
          mixin _TestBlocActions {
            int showMessage(String text);
          }
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
          }
        ''';

        await expectLater(
          generateForSource(source),
          throwsA(
            isA<InvalidGenerationSourceError>().having(
              (e) => e.message,
              'message',
              contains('Action method "showMessage" must return void'),
            ),
          ),
        );
      });

      test('action method cannot return String', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          part 'test.g.dart';
          
          @MonoActions()
          mixin _TestBlocActions {
            String navigate();
          }
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
          }
        ''';

        await expectLater(
          generateForSource(source),
          throwsA(
            isA<InvalidGenerationSourceError>().having(
              (e) => e.message,
              'message',
              contains('Action method "navigate" must return void'),
            ),
          ),
        );
      });

      test('action method cannot return Future<void>', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          part 'test.g.dart';
          
          @MonoActions()
          mixin _TestBlocActions {
            Future<void> showDialog();
          }
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
          }
        ''';

        await expectLater(
          generateForSource(source),
          throwsA(
            isA<InvalidGenerationSourceError>().having(
              (e) => e.message,
              'message',
              contains('Action method "showDialog" must return void'),
            ),
          ),
        );
      });

      test(
        'non-abstract methods in mixin are ignored (not treated as actions)',
        () async {
          const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          part 'test.g.dart';
          
          @MonoActions()
          mixin _TestBlocActions {
            void showMessage(String text) {
              print(text);
            }
          }
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            int _onIncrement() => state + 1;
          }
        ''';

          // Non-abstract methods are silently skipped, not treated as actions
          final result = await generateForSource(source);
          expect(result, isNotEmpty);
          // showMessage is not abstract, so no action class is generated for it
          expect(result, isNot(contains('_ShowMessageAction')));
        },
      );
    });

    group('onError Handler Methods', () {
      test('onError can return void (no state change)', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          part 'test.g.dart';
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            int _onIncrement() => state + 1;
            
            @onError
            void _onError(Object error, StackTrace stackTrace) {
            }
          }
        ''';

        // This should NOT throw - void is allowed
        final result = await generateForSource(source);
        expect(result, isNotEmpty);
      });

      test('onError must reject Future<State> (async not supported)', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          part 'test.g.dart';
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            int _onIncrement() => state + 1;
            
            @onError
            Future<int> _onError(Object error, StackTrace stackTrace) async {
              return 0;
            }
          }
        ''';

        await expectLater(
          generateForSource(source),
          throwsA(
            isA<InvalidGenerationSourceError>().having(
              (e) => e.message,
              'message',
              allOf(contains('must return'), contains('int')),
            ),
          ),
        );
      });

      test('onError can have flexible parameters', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          part 'test.g.dart';
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            int _onIncrement() => state + 1;
            
            @onError
            int _onError(Object error) {
              return 0;
            }
          }
        ''';

        // This should NOT throw - flexible parameters are allowed
        final result = await generateForSource(source);
        expect(result, isNotEmpty);
      });

      test('onError rejects invalid parameter types', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          part 'test.g.dart';
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            int _onIncrement() => state + 1;
            
            @onError
            int _onError(String error, StackTrace stackTrace) {
              return 0;
            }
          }
        ''';

        await expectLater(
          generateForSource(source),
          throwsA(
            isA<InvalidGenerationSourceError>().having(
              (e) => e.message,
              'message',
              contains('has invalid parameter'),
            ),
          ),
        );
      });

      test('onError rejects wrong second parameter type', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          part 'test.g.dart';
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            int _onIncrement() => state + 1;
            
            @onError
            int _onError(Object error, String stackTrace) {
              return 0;
            }
          }
        ''';

        await expectLater(
          generateForSource(source),
          throwsA(
            isA<InvalidGenerationSourceError>().having(
              (e) => e.message,
              'message',
              contains('has invalid parameter'),
            ),
          ),
        );
      });
    });

    group('Event Handler Methods', () {
      test('@event must reject invalid return type (Future<bool>)', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          part 'test.g.dart';
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            Future<bool> _onInvalidReturn() async {
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
                contains('has invalid return type'),
                contains('Future<bool>'),
              ),
            ),
          ),
        );
      });

      test('@event must reject invalid return type (String)', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          part 'test.g.dart';
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            String _onInvalidReturn() {
              return 'error';
            }
          }
        ''';

        await expectLater(
          generateForSource(source),
          throwsA(
            isA<InvalidGenerationSourceError>().having(
              (e) => e.message,
              'message',
              allOf(contains('has invalid return type'), contains('String')),
            ),
          ),
        );
      });

      test('@event must accept valid return types', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          part 'test.g.dart';
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            int _onSync() => state + 1;
            
            @event
            Future<int> _onAsync() async => state + 1;
            
            @event
            Stream<int> _onLoadStream() async* {
              yield state + 1;
            }
            
            @event
            void _onUpdate(_Emitter emit) {
              emit(state + 1);
            }
            
            @event
            Future<void> _onAsyncUpdate(_Emitter emit) async {
              emit(state + 1);
            }
          }
        ''';

        final result = await generateForSource(source);
        expect(result, isNotEmpty);
      });
    });

    group('onEvent Handler Methods', () {
      test('onEvent must return bool', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          part 'test.g.dart';
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            int _onIncrement() => state + 1;
            
            @onEvent
            void _filterEvent(_Event event) {
            }
          }
        ''';

        await expectLater(
          generateForSource(source),
          throwsA(
            isA<InvalidGenerationSourceError>().having(
              (e) => e.message,
              'message',
              contains('must return bool'),
            ),
          ),
        );
      });

      test('onEvent cannot return Future<bool>', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          part 'test.g.dart';
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            int _onIncrement() => state + 1;
            
            @onEvent
            Future<bool> _filterEvent(_Event event) async {
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
              contains('must return bool'),
            ),
          ),
        );
      });

      test('onEvent must have at least one parameter', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          part 'test.g.dart';
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            int _onIncrement() => state + 1;
            
            @onEvent
            bool _filterEvent() {
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
              contains('must have at least one parameter'),
            ),
          ),
        );
      });

      test('onEvent parameter must be valid event type', () async {
        const source = r'''
          import 'package:bloc/bloc.dart';
          import 'package:mono_bloc/mono_bloc.dart';
          
          part 'test.g.dart';
          
          @MonoBloc()
          class TestBloc extends _$TestBloc<int> {
            TestBloc() : super(0);
            
            @event
            int _onIncrement() => state + 1;
            
            @onEvent
            bool _filterEvent(String event) {
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
              contains('has invalid parameter'),
            ),
          ),
        );
      });
    });
  });
}
