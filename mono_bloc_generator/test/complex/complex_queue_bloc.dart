import 'package:mono_bloc/mono_bloc.dart';

part 'complex_queue_bloc.g.dart';

const queue1 = 'queue1';
const queue2 = 'queue2';
const queue5 = 'queue5';

/// Complex test bloc demonstrating all queue features:
/// - Multiple queues (queue1, queue2, queue5)
/// - Multiple events per queue
/// - Mixed queued and non-queued events
/// - Different return types (sync, async, stream, emitter)
/// - Complex parameters (positional, named, optional, required)
/// - Transformers on non-queued events
@MonoBloc()
class ComplexQueueBloc extends _$ComplexQueueBloc<String> {
  static final _queuesConfig = <String, EventTransformer<dynamic>>{
    queue1: MonoEventTransformer.sequential,
    queue2: MonoEventTransformer.droppable,
    queue5: MonoEventTransformer.restartable,
  };

  ComplexQueueBloc() : super('initial', queues: _queuesConfig);

  // ========== QUEUE 1: SEQUENTIAL ==========
  // Basic sync return
  @MonoEvent.queue(queue1)
  String _q1Sync() => 'q1_sync';

  // Async return
  @MonoEvent.queue(queue1)
  Future<String> _q1Async(int delay) async {
    await Future<void>.delayed(Duration(milliseconds: delay));
    return 'q1_async_$delay';
  }

  // With parameters
  @MonoEvent.queue(queue1)
  String _q1WithParams(String value, {required int count, bool flag = false}) {
    return 'q1_params_${value}_${count}_$flag';
  }

  // ========== QUEUE 2: DROPPABLE ==========
  // Stream return
  @MonoEvent.queue(queue2)
  Stream<String> _q2Stream() async* {
    yield 'q2_stream_1';
    await Future<void>.delayed(const Duration(milliseconds: 10));
    yield 'q2_stream_2';
  }

  // Emitter with multiple params
  @MonoEvent.queue(queue2)
  Future<void> _q2Emitter(
    _Emitter emit,
    String msg,
    int times, {
    String? prefix,
  }) async {
    for (var i = 0; i < times; i++) {
      emit('${prefix ?? 'q2'}_${msg}_$i');
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  // Complex params
  @MonoEvent.queue(queue2)
  String _q2Complex(
    int a,
    int b, {
    required String operation,
    bool negate = false,
  }) {
    var result = operation == 'add' ? a + b : a - b;
    if (negate) result = -result;
    return 'q2_${operation}_$result';
  }

  // ========== QUEUE 5: RESTARTABLE ==========
  // Single event in queue (edge case)
  @MonoEvent.queue(queue5)
  Stream<String> _q5Single(int count) async* {
    for (var i = 0; i < count; i++) {
      yield 'q5_single_$i';
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  // ========== NON-QUEUED EVENTS ==========
  // Regular event
  @event
  String _onNormal() => 'normal';

  // With sequential transformer
  @MonoEvent(MonoConcurrency.sequential)
  Future<String> _onSequential(String value) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return 'sequential_$value';
  }

  // With concurrent transformer
  @MonoEvent(MonoConcurrency.concurrent)
  Future<String> _onConcurrent(int id) async {
    await Future<void>.delayed(const Duration(milliseconds: 5));
    return 'concurrent_$id';
  }

  // With restartable transformer
  @MonoEvent(MonoConcurrency.restartable)
  Stream<String> _onRestartable(String prefix) async* {
    for (var i = 0; i < 3; i++) {
      yield '${prefix}_$i';
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  // With droppable transformer
  @MonoEvent(MonoConcurrency.droppable)
  Future<String> _onDroppable(String msg) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return 'droppable_$msg';
  }

  // Init method
  @onInit
  void _initialize() {
    // Initialization logic
  }
}
