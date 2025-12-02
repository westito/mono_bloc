/// Common mock packages for tests with correct structure after reorganization
const mockPackages = {
  'bloc|lib/bloc.dart': '''
    abstract class Bloc<E, S> {}
    abstract class Emitter<S> {}
  ''',
  'meta|lib/meta.dart': '''
    class _Protected {
      const _Protected();
    }
    const protected = _Protected();

    // Minimal Target/TargetKind mocks used by annotation tests
    class TargetKind {
      static const classType = 0;
      static const method = 1;
      static const mixin = 2;
    }

    class Target {
      final List<int> kinds;
      const Target(List<int> kinds) : kinds = kinds;
    }
  ''',
  'mono_bloc|lib/mono_bloc.dart': '''
    export 'src/annotations/mono_bloc.dart';
    export 'src/annotations/mono_event.dart';
    export 'src/annotations/mono_init.dart';
    export 'src/annotations/error_handler.dart';
    export 'src/annotations/on_event.dart';
    export 'src/annotations/mono_actions.dart';
    export 'src/annotations/async_mono_bloc.dart';
    export 'src/annotations/mono_concurrency.dart';
    export 'src/annotations/constants.dart';
    export 'src/async/mono_async_value.dart';
  ''',
  'mono_bloc|lib/src/annotations/mono_concurrency.dart': '''
    enum MonoConcurrency { sequential, concurrent, restartable, droppable }
  ''',
  'mono_bloc|lib/src/annotations/mono_bloc.dart': '''
    import 'package:meta/meta_meta.dart';
    
    @Target({TargetKind.classType})
    final class MonoBloc {
      final bool sequential;
      const MonoBloc({this.sequential = false});
    }
  ''',
  'mono_bloc|lib/src/annotations/async_mono_bloc.dart': '''
    import 'package:meta/meta_meta.dart';
    import 'package:mono_bloc/src/annotations/mono_concurrency.dart';
    
    @Target({TargetKind.classType})
    final class AsyncMonoBloc {
      final MonoConcurrency concurrency;
      final bool sequential;
      const AsyncMonoBloc({this.sequential = false, this.concurrency = MonoConcurrency.concurrent});
    }
  ''',
  'mono_bloc|lib/src/annotations/mono_event.dart': '''
    import 'package:meta/meta_meta.dart';
    import 'package:mono_bloc/src/annotations/mono_concurrency.dart';
    
    @Target({TargetKind.method})
    final class MonoEvent {
      final MonoConcurrency? concurrency;
      final String? queue;
      const MonoEvent([this.concurrency]) : queue = null;
      const MonoEvent.queue([this.queue]) : concurrency = null;
    }
  ''',
  'mono_bloc|lib/src/annotations/mono_init.dart': '''
    import 'package:meta/meta_meta.dart';
    
    @Target({TargetKind.method})
    final class MonoInit {
      const MonoInit();
    }
  ''',
  'mono_bloc|lib/src/annotations/error_handler.dart': '''
    import 'package:meta/meta_meta.dart';
    
    @Target({TargetKind.method})
    final class MonoOnError {
      const MonoOnError();
    }
  ''',
  'mono_bloc|lib/src/annotations/on_event.dart': '''
    import 'package:meta/meta_meta.dart';
    
    @Target({TargetKind.method})
    final class MonoOnEvent {
      const MonoOnEvent();
    }
  ''',
  'mono_bloc|lib/src/annotations/mono_actions.dart': '''
    final class MonoActions {
      const MonoActions();
    }
  ''',
  'mono_bloc|lib/src/annotations/constants.dart': '''
    import 'package:mono_bloc/src/annotations/mono_event.dart';
    import 'package:mono_bloc/src/annotations/mono_init.dart';
    import 'package:mono_bloc/src/annotations/error_handler.dart';
    import 'package:mono_bloc/src/annotations/on_event.dart';
    import 'package:mono_bloc/src/annotations/mono_concurrency.dart';
    
    const event = MonoEvent();
    const onInit = MonoInit();
    const onError = MonoOnError();
    const onEvent = MonoOnEvent();
    const restartableEvent = MonoEvent(MonoConcurrency.restartable);
    const sequentialEvent = MonoEvent(MonoConcurrency.sequential);
    const concurrentEvent = MonoEvent(MonoConcurrency.concurrent);
    const droppableEvent = MonoEvent(MonoConcurrency.droppable);
  ''',
  'mono_bloc|lib/src/async/mono_async_value.dart': '''
    sealed class MonoAsyncValue<T> {
      const MonoAsyncValue();
      const MonoAsyncValue.withData(T data);
      const MonoAsyncValue.withError(Object error, StackTrace stackTrace);
      T? get dataOrNull;
    }
    
    typedef MonoAsyncEmitter<T> = void Function(T);
  ''',
};
