import 'dart:convert';

import 'package:build/build.dart';

const mockPackagesWithHelpers = {
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
    export 'src/annotations/mono_bloc.dart';
    export 'src/annotations/mono_event.dart';
    export 'src/annotations/mono_init.dart';
    export 'src/annotations/error_handler.dart';
    export 'src/annotations/on_event.dart';
    export 'src/annotations/mono_action.dart';
    export 'src/annotations/async_mono_bloc.dart';
    export 'src/annotations/mono_concurrency.dart';
    export 'src/mono_bloc_base.dart';
    export 'src/mono_async_value.dart';
    export 'src/mono_async_emitter.dart';
  ''',
  'mono_bloc|lib/src/mono_bloc_base.dart': '''
    import 'package:bloc/bloc.dart';
    
    typedef EventTransformer<E> = Function();
    
    abstract class MonoBloc<Event, State> extends Bloc<Event, State> {
      final Map<String, EventTransformer<Event>> queues;
      
      MonoBloc(State initialState, {this.queues = const {}}) : super(initialState);
      
      void wrapEventHandler<E extends Event, S extends State>(
        E event,
        Emitter<S> emit,
        void Function() handler,
      ) {
        handler();
      }
    }
  ''',
  'mono_bloc|lib/src/mono_async_value.dart': '''
    class MonoAsyncValue<T> {
      const MonoAsyncValue(this.data, this.isLoading, this.error, this.stackTrace);
      const MonoAsyncValue.loading() : data = null, isLoading = true, error = null, stackTrace = null;
      const MonoAsyncValue.withData(T this.data) : isLoading = false, error = null, stackTrace = null;
      const MonoAsyncValue.withError(this.error, this.stackTrace, [this.data]) : isLoading = false;
      
      final T? data;
      final bool isLoading;
      final Object? error;
      final StackTrace? stackTrace;
      
      T? get dataOrNull => data;
    }
  ''',
  'mono_bloc|lib/src/mono_async_emitter.dart': '''
    import 'package:bloc/bloc.dart';
    import 'mono_async_value.dart';
    
    class MonoAsyncEmitter<T> {
      MonoAsyncEmitter(this._emitter, this._currentState);
      
      final Emitter<MonoAsyncValue<T>> _emitter;
      final MonoAsyncValue<T> _currentState;
      
      void call(T data) {}
      void loading() {}
      void loadingClearData() {}
      void error(Object error, StackTrace stackTrace) {}
    }
  ''',
  'mono_bloc|lib/src/annotations/mono_bloc.dart': '''
    import 'package:meta/meta_meta.dart';
    
    enum MonoConcurrency { sequential, concurrent, restartable, droppable }
    
    @Target({TargetKind.classType})
    final class MonoBloc {
      final MonoConcurrency? concurrency;
      const MonoBloc([this.concurrency]);
    }
    
    @Target({TargetKind.classType})
    final class AsyncMonoBloc {
      final MonoConcurrency? concurrency;
      const AsyncMonoBloc([this.concurrency]);
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
    
    @Target({TargetKind.method})
    final class MonoOnEvent {
      const MonoOnEvent();
    }
    
    @Target({TargetKind.method})
    final class Action {
      const Action();
    }
    
    const event = MonoEvent();
    const init = MonoInit();
    const onError = MonoOnError();
    const onEvent = MonoOnEvent();
    const action = Action();
    
    const restartableEvent = MonoEvent(MonoConcurrency.restartable);
    const sequentialEvent = MonoEvent(MonoConcurrency.sequential);
    const concurrentEvent = MonoEvent(MonoConcurrency.concurrent);
    const droppableEvent = MonoEvent(MonoConcurrency.droppable);
  ''',
  'bloc_concurrency|lib/bloc_concurrency.dart': '''
    typedef EventTransformer<T> = Function();
    
    EventTransformer<T> restartable<T>() => () {};
    EventTransformer<T> droppable<T>() => () {};
    EventTransformer<T> sequential<T>() => () {};
    EventTransformer<T> concurrent<T>() => () {};
  ''',
};

class MockBuildStep implements BuildStep {
  MockBuildStep({this.isFlutterProject = false});

  final bool isFlutterProject;

  @override
  AssetId get inputId => AssetId('pkg', 'lib/test.dart');

  @override
  Future<bool> canRead(AssetId id) async {
    if (id.path == 'pubspec.yaml') {
      return true;
    }
    return false;
  }

  @override
  Future<String> readAsString(AssetId id, {Encoding encoding = utf8}) async {
    if (id.path == 'pubspec.yaml') {
      if (isFlutterProject) {
        return '''
name: pkg
dependencies:
  flutter:
    sdk: flutter
''';
      } else {
        return '''
name: pkg
dependencies:
  mono_bloc: ^1.0.0
''';
      }
    }
    throw AssetNotFoundException(id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
