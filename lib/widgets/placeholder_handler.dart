import 'package:flutter/material.dart';

class PlaceholderHandler extends StatelessWidget {
  final Widget child;
  final Widget placeholder;
  final bool condition;

  const PlaceholderHandler({
    Key key,
    @required this.child,
    this.placeholder,
    this.condition = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: condition ? child : placeholder,
    );
  }
}
