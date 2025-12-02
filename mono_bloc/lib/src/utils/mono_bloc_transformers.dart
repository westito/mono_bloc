import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart' as bc;

/// Wrapper for bloc_concurrency transformers to avoid type conflicts
/// and provide type-safe transformers for MonoBloc queues.
///
/// Use these in the `queues` parameter of your bloc's super constructor:
/// ```dart
/// MyBloc() : super(
///   initialState,
///   queues: {
///     'upload': MonoEventTransformer.sequential,
///     'sync': MonoEventTransformer.droppable,
///   },
/// );
/// ```
class MonoEventTransformer {
  const MonoEventTransformer._();

  /// Sequential transformer - processes events one at a time
  static EventTransformer<dynamic> get sequential => bc.sequential();

  /// Concurrent transformer - processes events concurrently
  static EventTransformer<dynamic> get concurrent => bc.concurrent();

  /// Restartable transformer - cancels previous event when new one arrives
  static EventTransformer<dynamic> get restartable => bc.restartable();

  /// Droppable transformer - drops new events while processing
  static EventTransformer<dynamic> get droppable => bc.droppable();
}

/// Deprecated alias for [MonoEventTransformer].
@Deprecated('Use MonoEventTransformer instead')
typedef MonoBlocConcurrency = MonoEventTransformer;
