import 'package:codepan/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingPlaceholder extends StatelessWidget {
  final Color baseColor, highlightColor;
  final bool isLoading;
  final Widget child;

  const LoadingPlaceholder({
    super.key,
    required this.child,
    this.isLoading = true,
    this.baseColor = PanColors.grey4,
    this.highlightColor = PanColors.grey2,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: child,
          )
        : child;
  }
}
