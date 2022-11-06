import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef OnWidgetSizeChange = void Function(Size size, Offset position);

class RenderBox extends RenderProxyBox {
  final OnWidgetSizeChange onSizeChange;

  RenderBox(this.onSizeChange);

  @override
  void performLayout() {
    super.performLayout();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = child?.size;
      final position = child?.localToGlobal(Offset.zero);
      if (size != null && position != null) {
        onSizeChange(size, position);
      }
    });
  }
}

class SizeListener extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onSizeChange;

  const SizeListener({
    super.key,
    required super.child,
    required this.onSizeChange,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBox(onSizeChange);
  }
}
