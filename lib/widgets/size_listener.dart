import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef OnWidgetSizeChange = void Function(Size size);

class RenderBox extends RenderProxyBox {
  final OnWidgetSizeChange onSizeChange;

  RenderBox(this.onSizeChange);

  @override
  void performLayout() {
    super.performLayout();
    Size? size = child?.size;
    if (size != null) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        onSizeChange(size);
      });
    }
  }
}

class SizeListener extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onSizeChange;

  const SizeListener({
    Key? key,
    required this.onSizeChange,
    required Widget child,
  }) : super(
          key: key,
          child: child,
        );

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBox(onSizeChange);
  }
}
