import 'package:flutter/cupertino.dart';

typedef NullableWidgetBuilder = Widget? Function(BuildContext context);

class DefaultBuilder extends StatelessWidget {
  final NullableWidgetBuilder builder;
  final WidgetBuilder fallback;

  const DefaultBuilder({
    super.key,
    required this.builder,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return builder.call(context) ?? fallback.call(context);
  }
}
