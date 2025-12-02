import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:mono_bloc_generator/src/mono_bloc_generator_impl.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_mocks.dart';

void main() {
  group('MonoBlocGenerator - Generated Code Structure', () {
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

    test('should generate base class with <_> placeholder', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        class CounterState {
          const CounterState();
        }

        @MonoBloc()
        class CounterBloc extends _$CounterBloc<CounterState> {
          CounterBloc() : super(const CounterState());

          @event
          CounterState _onIncrement() => const CounterState();
        }
      ''';

      final result = await generateForSource(source);
      expect(result, contains(r'abstract class _$CounterBloc<_>'));
      expect(
        result,
        isNot(contains(r'abstract class _$CounterBloc<CounterState>')),
      );
    });

    test(
      'should extend Bloc with actual State type, not placeholder',
      () async {
        const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        class MyState {
          const MyState();
        }

        @MonoBloc()
        class MyBloc extends _$MyBloc<MyState> {
          MyBloc() : super(const MyState());

          @event
          MyState _onEvent() => const MyState();
        }
      ''';

        final result = await generateForSource(source);
        expect(result, contains('extends Bloc<_Event, MyState>'));
        expect(result, isNot(contains('extends Bloc<_Event, _>')));
      },
    );

    test('should generate Emitter typedef with actual State type', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        class TodoState {
          const TodoState();
        }

        @MonoBloc()
        class TodoBloc extends _$TodoBloc<TodoState> {
          TodoBloc() : super(const TodoState());

          @event
          TodoState _onLoad() => const TodoState();
        }
      ''';

      final result = await generateForSource(source);
      expect(result, contains('typedef _Emitter = Emitter<TodoState>'));
      expect(result, isNot(contains('Emitter<_>')));
    });

    test('should generate event base class', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        class MyState {
          const MyState();
        }

        @MonoBloc()
        class MyBloc extends _$MyBloc<MyState> {
          MyBloc() : super(const MyState());

          @event
          MyState _onEvent() => const MyState();
        }
      ''';

      final result = await generateForSource(source);
      expect(result, contains('abstract class _Event'));
      expect(result, contains('final StackTrace trace;'));
    });

    test('should generate event classes extending base event', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        class MyState {
          const MyState();
        }

        @MonoBloc()
        class MyBloc extends _$MyBloc<MyState> {
          MyBloc() : super(const MyState());

          @event
          MyState _onIncrement() => const MyState();

          @event
          MyState _onDecrement() => const MyState();
        }
      ''';

      final result = await generateForSource(source);
      expect(result, contains('class _IncrementEvent extends _Event'));
      expect(result, contains('class _DecrementEvent extends _Event'));
    });

    test('should generate queue event classes', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        class MyState {
          const MyState();
        }

        @MonoBloc()
        class MyBloc extends _$MyBloc<MyState> {
          MyBloc() : super(const MyState(), queues: {'queue1': MonoEventTransformer.sequential});

          @MonoEvent.queue('queue1')
          MyState _onQueuedEvent() => const MyState();
        }
      ''';

      final result = await generateForSource(source);
      expect(result, contains(r'class _$Queue1QueueEvent extends _Event'));
      expect(
        result,
        contains(r'class _QueuedEventEvent extends _$Queue1QueueEvent'),
      );
    });

    test('should generate public methods for events', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        class MyState {
          const MyState();
        }

        @MonoBloc()
        class MyBloc extends _$MyBloc<MyState> {
          MyBloc() : super(const MyState());

          @event
          MyState _onIncrement() => const MyState();
        }
      ''';

      final result = await generateForSource(source);
      expect(result, contains('void increment()'));
      expect(result, contains('add(_IncrementEvent())'));
    });

    test('should generate public methods with parameters', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        class MyState {
          const MyState();
        }

        @MonoBloc()
        class MyBloc extends _$MyBloc<MyState> {
          MyBloc() : super(const MyState());

          @event
          MyState _onSetValue(int value, {bool absolute = false}) {
            return const MyState();
          }
        }
      ''';

      final result = await generateForSource(source);
      expect(result, contains('void setValue('));
      expect(result, contains('int value'));
      expect(result, contains('bool absolute = false'));
    });

    test(r'should generate _$init method', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        class MyState {
          const MyState();
        }

        @MonoBloc()
        class MyBloc extends _$MyBloc<MyState> {
          MyBloc() : super(const MyState());

          @event
          MyState _onIncrement() => const MyState();
        }
      ''';

      final result = await generateForSource(source);
      expect(result, contains(r'void _$init()'));
      expect(result, contains('on<_IncrementEvent>'));
    });

    test('should generate extension type helper', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        class MyState {
          const MyState();
        }

        @MonoBloc()
        class MyBloc extends _$MyBloc<MyState> {
          MyBloc() : super(const MyState());

          @event
          MyState _onEvent() => const MyState();
        }
      ''';

      final result = await generateForSource(source);
      expect(
        result,
        contains(r'extension type _$._(MyBloc bloc) implements MyBloc'),
      );
      expect(
        result,
        contains(r'_$(_$MyBloc<dynamic> base) : bloc = base as MyBloc'),
      );
    });

    test('should generate constructor with super parameter', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        class MyState {
          const MyState();
        }

        @MonoBloc()
        class MyBloc extends _$MyBloc<MyState> {
          MyBloc() : super(const MyState());

          @event
          MyState _onEvent() => const MyState();
        }
      ''';

      final result = await generateForSource(source);
      expect(result, contains(r'_$MyBloc('));
      expect(result, contains('super.initialState'));
      expect(result, contains(r'_$(this)._$init()'));
    });

    test('should generate queues field when queue methods exist', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        class MyState {
          const MyState();
        }

        @MonoBloc()
        class MyBloc extends _$MyBloc<MyState> {
          MyBloc() : super(const MyState(), queues: {'queue1': MonoEventTransformer.sequential});

          @MonoEvent.queue('queue1')
          MyState _onQueuedEvent() => const MyState();
        }
      ''';

      final result = await generateForSource(source);
      expect(
        result,
        contains('final Map<String, EventTransformer<dynamic>> _queues'),
      );
      expect(result, contains('_queues = queues'));
    });

    test('should generate transformer helper methods when needed', () async {
      const source = r'''
        import 'package:bloc/bloc.dart';
        import 'package:mono_bloc/mono_bloc.dart';

        class MyState {
          const MyState();
        }

        @MonoBloc()
        class MyBloc extends _$MyBloc<MyState> {
          MyBloc() : super(const MyState(), queues: {'queue1': MonoEventTransformer.sequential});

          @MonoEvent.queue('queue1')
          MyState _onQueuedEvent() => const MyState();
        }
      ''';

      final result = await generateForSource(source);
      expect(result, contains('EventTransformer<E>? _getTransformer<E>'));
      expect(result, contains('EventTransformer<E> _castTransformer<E>'));
    });
  });
}
