import 'package:mono_bloc/src/annotations/error_handler.dart';
import 'package:mono_bloc/src/annotations/mono_concurrency.dart';
import 'package:mono_bloc/src/annotations/mono_event.dart';
import 'package:mono_bloc/src/annotations/mono_init.dart';
import 'package:mono_bloc/src/annotations/on_event.dart';

/// Shorthand constant for marking a method as an event handler
const event = MonoEvent();

/// Shorthand constant for marking a method as an initialization handler
const onInit = MonoInit();

/// Shorthand constant for marking a method as an error handler
const onError = MonoOnError();

/// Shorthand constant for marking a method as an event interceptor
const onEvent = MonoOnEvent();

/// Shorthand constant for a restartable event (cancels previous events)
const restartableEvent = MonoEvent(MonoConcurrency.restartable);

/// Shorthand constant for a sequential event (processes in order)
const sequentialEvent = MonoEvent(MonoConcurrency.sequential);

/// Shorthand constant for a concurrent event (processes in parallel)
const concurrentEvent = MonoEvent(MonoConcurrency.concurrent);

/// Shorthand constant for a droppable event (ignores new events while processing)
const droppableEvent = MonoEvent(MonoConcurrency.droppable);
