import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mono_bloc_flutter/mono_bloc_flutter.dart';

void useMonoBlocActionListener<B extends MonoBlocActionMixin<dynamic, dynamic>>(
  B bloc,
  FlutterMonoBlocActions onAction,
) {
  final context = useContext();
  useEffect(() {
    final subscription = bloc.actions.listen((action) {
      if (context.mounted) {
        onAction.actions(bloc, context, action);
      }
    });
    return subscription.cancel;
  }, [bloc, context]);
}
