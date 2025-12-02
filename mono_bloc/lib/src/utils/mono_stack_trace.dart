import 'package:stack_trace/stack_trace.dart';

const _excludePackages = {'async', 'bloc', 'stack_trace', 'flutter'};

/// Utility for filtering and combining stack traces in MonoBloc error handling.
///
/// MonoBloc captures stack traces at event dispatch time and combines them with
/// error stack traces to provide complete debugging information.
class MonoStackTrace {
  MonoStackTrace._();

  /// Creates a filtered stack trace combining origin and error traces.
  ///
  /// Filters out:
  /// - Core Dart frames
  /// - Framework packages (bloc, flutter, etc.)
  /// - Generated code files (specified by [exclude])
  ///
  /// Returns a clean trace showing:
  /// 1. Where the event was dispatched ([origin])
  /// 2. Where the error occurred ([trace])
  static StackTrace filtered(
    StackTrace origin,
    StackTrace trace,
    String exclude,
  ) {
    final chain = Chain([Trace.from(trace), Trace.from(origin)]).toTrace();

    return Trace(
      chain.terse.frames.where(
        (frame) =>
            !frame.isCore &&
            !_excludePackages.contains(frame.package) &&
            !frame.uri.path.contains(exclude),
      ),
    );
  }
}
