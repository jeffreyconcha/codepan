import 'package:codepan/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingPlaceholder extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingPlaceholder({
    Key? key,
    required this.child,
    this.isLoading = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Shimmer.fromColors(
            baseColor: PanColors.grey4,
            highlightColor: PanColors.grey2,
            child: child,
          )
        : child;
  }
}
