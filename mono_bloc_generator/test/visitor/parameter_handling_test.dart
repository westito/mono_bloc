import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/visitors/bloc_visitor.dart';
import 'package:test/test.dart';

import '../helpers/test_mocks.dart';

void main() {
  group('BlocVisitor - Parameter Handling', () {
    late BlocVisitor visitor;

    setUp(() {
      visitor = BlocVisitor();
    });

    test(
      'should correctly identify method parameters excluding Emitter',
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
  });
}
