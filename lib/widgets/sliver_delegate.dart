import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final double? height, elevation;
  final Color background;
  final TabBar tabBar;

  SliverTabBarDelegate({
    required this.tabBar,
    this.height,
    this.background = Colors.white,
    this.elevation,
  });

  @override
  Widget build(BuildContext context, double offset, bool overlap) {
    return Material(
      color: background,
      elevation: elevation!,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => height ?? tabBar.preferredSize.height;

  @override
  double get minExtent => height ?? tabBar.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
