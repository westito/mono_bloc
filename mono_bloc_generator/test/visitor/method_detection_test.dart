import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/visitors/bloc_visitor.dart';
import 'package:test/test.dart';

import '../helpers/test_mocks.dart';

void main() {
  group('BlocVisitor - Method Detection', () {
    late BlocVisitor visitor;

    setUp(() {
      visitor = BlocVisitor();
    });

    test('should find private methods with Emitter parameter', () async {
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
            
            abstract class TestEvent {}
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
            
            abstract class TestEvent {}
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
