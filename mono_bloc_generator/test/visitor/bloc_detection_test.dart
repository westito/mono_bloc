import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/visitors/bloc_visitor.dart';
import 'package:test/test.dart';

import '../helpers/test_mocks.dart';

void main() {
  group('BlocVisitor - Bloc Detection', () {
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
            
            abstract class TestEvent {}
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
            
            abstract class MyEvent {}
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
  });
}
