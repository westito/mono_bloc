import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/visitors/bloc_visitor.dart';
import 'package:test/test.dart';

import 'helpers/test_mocks.dart';

void main() {
  group('BlocVisitor', () {
    late BlocVisitor visitor;

    setUp(() {
      visitor = BlocVisitor();
    });

    test('should find Bloc classes', () async {
      await resolveSources(
        {
          'bloc|lib/bloc.dart': '''
            abstract class Bloc<E, S> {}
            abstract class Emitter<S> {}
          ''',
          ...mockPackages,
          'pkg|lib/test.dart': r'''
            import 'package:bloc/bloc.dart';
            import 'package:mono_bloc/mono_bloc.dart';
            
            abstract class TestState {}
            typedef _Emitter = Emitter<TestState>;
            
            @MonoBloc()
            class SimpleBloc extends _$SimpleBloc<TestState> {
              SimpleBloc() : super(TestState());
              
              @MonoEvent()
              TestState _onTest(_Emitter emit) => TestState();
            }
          ''',
        },
        (resolver) async {
          final lib = await resolver.libraryFor(
            AssetId.parse('pkg|lib/test.dart'),
          );
          lib.visitChildren(visitor);

          expect(visitor.blocs, hasLength(1));
          expect(visitor.blocs.first.bloc.name, equals('SimpleBloc'));
        },
      );
    });

    test('should extract Event and State types from Bloc', () async {
      await resolveSources(
        {
          ...mockPackages,
          'pkg|lib/test.dart': r'''
            import 'package:bloc/bloc.dart';
            import 'package:mono_bloc/mono_bloc.dart';
            
            abstract class MyState {}
            typedef _Emitter = Emitter<MyState>;
            
            @MonoBloc()
            class MyBloc extends _$MyBloc<MyState> {
              MyBloc() : super(MyState());
              
              @MonoEvent()
              MyState _onTest(_Emitter emit) => MyState();
            }
          ''',
        },
        (resolver) async {
          final lib = await resolver.libraryFor(
            AssetId.parse('pkg|lib/test.dart'),
          );
          lib.visitChildren(visitor);

          expect(visitor.blocs, hasLength(1));
          final bloc = visitor.blocs.first;
          expect(bloc.eventName, equals('_Event'));
          expect(bloc.stateName, equals('MyState'));
        },
      );
    });

    test('should find private methods with Emitter parameter', () async {
      await resolveSources(
        {
          ...mockPackages,
          'pkg|lib/test.dart': r'''
            import 'package:bloc/bloc.dart';
            import 'package:mono_bloc/mono_bloc.dart';
            
            abstract class TestState {}
            typedef _Emitter = Emitter<TestState>;
            
            @MonoBloc()
            class SimpleBloc extends _$SimpleBloc<TestState> {
              SimpleBloc() : super(TestState());
              
              @MonoEvent()
              void _increment(_Emitter emit) {}
              
              @MonoEvent()
              void _decrement(_Emitter emit) {}
            }
          ''',
        },
        (resolver) async {
          final lib = await resolver.libraryFor(
            AssetId.parse('pkg|lib/test.dart'),
          );
          lib.visitChildren(visitor);

          expect(visitor.blocs, hasLength(1));
          final bloc = visitor.blocs.first;
          expect(bloc.methods, hasLength(2));
          expect(
            bloc.methods.map((m) => m.name),
            containsAll(['_increment', '_decrement']),
          );
        },
      );
    });

    test('should ignore public methods with Emitter parameter', () async {
      await resolveSources(
        {
          ...mockPackages,
          'pkg|lib/test.dart': r'''
            import 'package:bloc/bloc.dart';
            import 'package:mono_bloc/mono_bloc.dart';
            
            abstract class TestState {}
            typedef _Emitter = Emitter<TestState>;
            
            @MonoBloc()
            class SimpleBloc extends _$SimpleBloc<TestState> {
              SimpleBloc() : super(TestState());
              
              @MonoEvent()
              void _privateMethod(_Emitter emit) {}
              
              void publicMethod(_Emitter emit) {}
            }
          ''',
        },
        (resolver) async {
          final lib = await resolver.libraryFor(
            AssetId.parse('pkg|lib/test.dart'),
          );
          lib.visitChildren(visitor);

          expect(visitor.blocs, hasLength(1));
          final bloc = visitor.blocs.first;
          expect(bloc.methods, hasLength(1));
          expect(bloc.methods.first.name, equals('_privateMethod'));
        },
      );
    });

    test(
      'should ignore private methods without @MonoEvent annotation',
      () async {
        await resolveSources(
          {
            ...mockPackages,
            'pkg|lib/test.dart': r'''
            import 'package:bloc/bloc.dart';
            import 'package:mono_bloc/mono_bloc.dart';
            
            abstract class TestState {}
            typedef _Emitter = Emitter<TestState>;
            
            @MonoBloc()
            class SimpleBloc extends _$SimpleBloc<TestState> {
              SimpleBloc() : super(TestState());
              
              @MonoEvent()
              void _privateWithAnnotation(_Emitter emit) {}
              
              void _privateWithoutAnnotation() {}
            }
          ''',
          },
          (resolver) async {
            final lib = await resolver.libraryFor(
              AssetId.parse('pkg|lib/test.dart'),
            );
            lib.visitChildren(visitor);

            expect(visitor.blocs, hasLength(1));
            final bloc = visitor.blocs.first;
            expect(bloc.methods, hasLength(1));
            expect(bloc.methods.first.name, equals('_privateWithAnnotation'));
          },
        );
      },
    );

    test(
      'should correctly identify method parameters excluding Emitter',
      () async {
        await resolveSources(
          {
            ...mockPackages,
            'pkg|lib/test.dart': r'''
            import 'package:bloc/bloc.dart';
            import 'package:mono_bloc/mono_bloc.dart';
            
            abstract class TestState {}
            typedef _Emitter = Emitter<TestState>;
            
            @MonoBloc()
            class SimpleBloc extends _$SimpleBloc<TestState> {
              SimpleBloc() : super(TestState());
              
              @MonoEvent()
              void _setValue(_Emitter emit, int value, String label) {}
            }
          ''',
          },
          (resolver) async {
            final lib = await resolver.libraryFor(
              AssetId.parse('pkg|lib/test.dart'),
            );
            lib.visitChildren(visitor);

            expect(visitor.blocs, hasLength(1));
            final bloc = visitor.blocs.first;
            expect(bloc.methods, hasLength(1));

            final method = bloc.methods.first;
            expect(method.parametersWithoutEmitter, hasLength(2));
            expect(
              method.parametersWithoutEmitter
                  .cast<FormalParameterElement>()
                  .map((p) => p.name),
              containsAll(['value', 'label']),
            );
          },
        );
      },
    );

    test('should handle methods with named parameters', () async {
      await resolveSources(
        {
          ...mockPackages,
          'pkg|lib/test.dart': r'''
            import 'package:bloc/bloc.dart';
            import 'package:mono_bloc/mono_bloc.dart';
            
            abstract class TestEvent {}
            abstract class TestState {}
            typedef _Emitter = Emitter<TestState>;
            
            @MonoBloc()
            class SimpleBloc extends _$SimpleBloc<TestState> {
              SimpleBloc() : super(TestState());
              
              @MonoEvent()
              void _setValues(
                _Emitter emit,
                int value, {
                required String label,
                bool enabled = false,
              }) {}
            }
          ''',
        },
        (resolver) async {
          final lib = await resolver.libraryFor(
            AssetId.parse('pkg|lib/test.dart'),
          );
          lib.visitChildren(visitor);

          expect(visitor.blocs, hasLength(1));
          final bloc = visitor.blocs.first;
          expect(bloc.methods, hasLength(1));

          final method = bloc.methods.first;
          expect(method.parametersWithoutEmitter, hasLength(3));

          final params = method.parametersWithoutEmitter;
          expect(
            params.where((p) => (p as dynamic).isRequiredPositional as bool),
            hasLength(1),
          );
          expect(
            params.where((p) => (p as dynamic).isNamed as bool),
            hasLength(2),
          );
          expect(
            params.where((p) => (p as dynamic).isRequiredNamed as bool),
            hasLength(1),
          );
        },
      );
    });

    test(
      'should handle multiple Blocs in different files of same library',
      () async {
        await resolveSources(
          {
            ...mockPackages,
            'pkg|lib/first_bloc.dart': r'''
            import 'package:bloc/bloc.dart';
            import 'package:mono_bloc/mono_bloc.dart';
            
            part 'first_bloc.g.dart';
            
            abstract class Event1 {}
            abstract class State1 {}
            typedef _Emitter = Emitter<State1>;
            
            @MonoBloc()
            class FirstBloc extends _$FirstBloc<State1> {
              FirstBloc() : super(State1());
              
              @MonoEvent()
              void _method1(_Emitter emit) {}
            }
          ''',
            'pkg|lib/second_bloc.dart': r'''
            import 'package:bloc/bloc.dart';
            import 'package:mono_bloc/mono_bloc.dart';
            
            part 'second_bloc.g.dart';
            
            abstract class Event2 {}
            abstract class State2 {}
            typedef _Emitter = Emitter<State2>;
            
            @MonoBloc()
            class SecondBloc extends _$SecondBloc<State2> {
              SecondBloc() : super(State2());
              
              @MonoEvent()
              void _method2(_Emitter emit) {}
            }
          ''',
          },
          (resolver) async {
            final lib1 = await resolver.libraryFor(
              AssetId.parse('pkg|lib/first_bloc.dart'),
            );
            final lib2 = await resolver.libraryFor(
              AssetId.parse('pkg|lib/second_bloc.dart'),
            );

            lib1.visitChildren(visitor);
            lib2.visitChildren(visitor);

            expect(visitor.blocs, hasLength(2));
            expect(
              visitor.blocs.map((b) => b.bloc.name),
              containsAll(['FirstBloc', 'SecondBloc']),
            );
            expect(visitor.blocs[0].methods, hasLength(1));
            expect(visitor.blocs[1].methods, hasLength(1));
          },
        );
      },
    );

    test('should handle Bloc with no @MonoEvent methods', () async {
      await resolveSources(
        {
          ...mockPackages,
          'pkg|lib/test.dart': r'''
            import 'package:bloc/bloc.dart';
            import 'package:mono_bloc/mono_bloc.dart';
            
            abstract class TestEvent {}
            abstract class TestState {}
            
            @MonoBloc()
            class SimpleBloc extends _$SimpleBloc<TestState> {
              SimpleBloc() : super(TestState());
              
              @MonoEvent()
              TestState _dummy() => TestState();
              
              void publicMethod() {}
            }
          ''',
        },
        (resolver) async {
          final lib = await resolver.libraryFor(
            AssetId.parse('pkg|lib/test.dart'),
          );
          lib.visitChildren(visitor);

          expect(visitor.blocs, hasLength(1));
          final bloc = visitor.blocs.first;
          expect(bloc.methods, hasLength(1));
          expect(bloc.methods.first.name, equals('_dummy'));
        },
      );
    });

    test('should store eventTypeName for each method', () async {
      await resolveSources(
        {
          ...mockPackages,
          'pkg|lib/test.dart': r'''
            import 'package:bloc/bloc.dart';
            import 'package:mono_bloc/mono_bloc.dart';
            
            abstract class MyCustomEvent {}
            abstract class MyCustomState {}
            typedef _Emitter = Emitter<MyCustomState>;
            
            @MonoBloc()
            class MyBloc extends _$MyBloc<MyCustomState> {
              MyBloc() : super(MyCustomState());
              
              @MonoEvent()
              void _doSomething(_Emitter emit) {}
            }
          ''',
        },
        (resolver) async {
          final lib = await resolver.libraryFor(
            AssetId.parse('pkg|lib/test.dart'),
          );
          lib.visitChildren(visitor);

          expect(visitor.blocs, hasLength(1));
          final bloc = visitor.blocs.first;
          expect(bloc.methods, hasLength(1));
          expect(bloc.methods.first.eventTypeName, equals('_Event'));
        },
      );
    });
  });
}
