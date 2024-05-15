import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class PanScrollView extends StatelessWidget {
  final RefreshController? refreshController;
  final ScrollController? scrollController;
  final VoidCallback? onRefresh;
  final Widget? child, header;
  final Axis scrollDirection;
  final bool? enablePullDown;
  final EdgeInsets? padding;

  const PanScrollView({
    super.key,
    this.child,
    this.enablePullDown,
    this.header,
    this.onRefresh,
    this.padding,
    this.refreshController,
    this.scrollController,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final isVertical = scrollDirection == Axis.vertical;
    return LayoutBuilder(
      builder: (context, constraints) {
        final scrollview = SingleChildScrollView(
          padding: padding,
          scrollDirection: scrollDirection,
          controller: scrollController,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: isVertical ? constraints.maxHeight : 0,
              minWidth: !isVertical ? constraints.maxWidth : 0,
            ),
            child: isVertical
                ? IntrinsicHeight(
                    child: child,
                  )
                : IntrinsicWidth(
                    child: child,
                  ),
          ),
        );
        if (refreshController != null) {
          return SmartRefresher(
            enablePullDown: enablePullDown!,
            controller: refreshController!,
            header: header!,
            onRefresh: onRefresh!,
            child: scrollview,
          );
        } else {
          return scrollview;
        }
      },
    );
  }
}
