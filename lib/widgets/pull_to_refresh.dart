import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PullToRefresh extends StatelessWidget {
  final Widget? header, loading, placeholder;
  final VoidCallback? onRefresh, onLoading;
  final bool isLoading, enablePullDown;
  final RefreshController controller;
  final int? itemCount;
  final Widget child;

  const PullToRefresh({
    Key? key,
    required this.controller,
    required this.child,
    this.placeholder,
    this.header,
    this.loading,
    this.isLoading = false,
    this.enablePullDown = true,
    this.itemCount,
    this.onRefresh,
    this.onLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      header: header,
      controller: controller,
      enablePullDown: enablePullDown,
      child: isLoading && itemCount == 0
          ? loading ?? child
          : itemCount == 0
              ? placeholder ?? child
              : child,
      physics:
          isLoading && itemCount != 0 ? NeverScrollableScrollPhysics() : null,
      onRefresh: onRefresh,
      onLoading: onLoading,
    );
  }
}
