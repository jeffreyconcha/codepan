import 'package:codepan/resources/colors.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/widgets/if_else_builder.dart';
import 'package:flutter/material.dart';

enum DividerType {
  horizontal,
  vertical,
}

class LineDivider extends StatelessWidget {
  final Alignment? alignment;
  final EdgeInsets? margin;
  final double? thickness;
  final DividerType type;
  final Color color;

  const LineDivider({
    Key? key,
    this.color = PanColors.divider,
    this.margin,
    this.thickness,
    this.type = DividerType.horizontal,
    this.alignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    return IfElseBuilder(
      margin: margin,
      condition: type == DividerType.horizontal,
      alignment: alignment,
      ifBuilder: (context) {
        return Container(
          height: thickness ?? d.at(1),
          color: color,
        );
      },
      elseBuilder: (context) {
        return Container(
          width: thickness ?? d.at(1),
          color: color,
        );
      },
    );
  }
}
