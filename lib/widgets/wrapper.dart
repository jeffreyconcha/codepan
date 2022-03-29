import 'package:flutter/cupertino.dart';

typedef WrapperCallback = Widget Function(BuildContext context, Widget child);

class WrapperBuilder extends StatelessWidget {
  final WrapperCallback? fallback;
  final WrapperCallback builder;
  final Widget child;
  final bool condition;

  const WrapperBuilder({
    Key? key,
    required this.child,
    required this.condition,
    required this.builder,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (condition) {
      return builder.call(context, child);
    }
    if (fallback != null) {
      return fallback!.call(context, child);
    }
    return child;
  }
}
