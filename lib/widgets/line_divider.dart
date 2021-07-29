import 'package:codepan/resources/colors.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/widgets/placeholder_handler.dart';
import 'package:flutter/material.dart';

enum DividerType {
  horizontal,
  vertical,
}

class LineDivider extends StatelessWidget {
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    return PlaceholderHandler(
      margin: margin,
      condition: type == DividerType.horizontal,
      childBuilder: (context) {
        return Container(
          height: thickness ?? d.at(1),
          color: color,
        );
      },
      placeholderBuilder: (context) {
        return Container(
          width: thickness ?? d.at(1),
          color: color,
        );
      },
    );
  }
}
