import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PanScrollView extends StatelessWidget {
  final RefreshController refreshController;
  final ScrollController scrollController;
  final VoidCallback onRefresh;
  final bool enablePullDown;
  final Axis scrollDirection;
  final EdgeInsets padding;
  final Widget child;
  final Widget header;

  const PanScrollView({
    Key key,
    this.child,
    this.padding,
    this.scrollDirection = Axis.vertical,
    this.refreshController,
    this.scrollController,
    this.enablePullDown,
    this.header,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isVertical = scrollDirection == Axis.vertical;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SmartRefresher(
          enablePullDown: enablePullDown,
          controller: refreshController,
          header: header,
          onRefresh: onRefresh,
          child: SingleChildScrollView(
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
          ),
        );
      },
    );
  }
}
