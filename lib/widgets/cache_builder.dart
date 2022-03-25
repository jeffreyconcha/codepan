import 'package:codepan/utils/cache_manager.dart';
import 'package:flutter/cupertino.dart';

typedef CacheWidgetBuilder<V> = Widget Function(
  BuildContext context,
  V value,
);

class FutureCachedBuilder<K, V> extends StatefulWidget {
  final CacheAsyncManager<K, V> manager;
  final CacheWidgetBuilder<V> builder;
  final WidgetBuilder? placeholder;
  final K keys;

  const FutureCachedBuilder({
    Key? key,
    required this.builder,
    required this.manager,
    required this.keys,
    this.placeholder,
  }) : super(key: key);

  @override
  State<FutureCachedBuilder<K, V>> createState() => _FutureCachedBuilderState<K, V>();
}

class _FutureCachedBuilderState<K, V> extends State<FutureCachedBuilder<K, V>> {
  CacheAsyncManager<K, V> get manager => widget.manager;
  V? _value;

  @override
  void initState() {
    super.initState();
    _value = manager.tryGet(widget.keys, (value) {
      _value = value;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_value != null) {
      return widget.builder.call(context, _value!);
    }
    if (widget.placeholder != null) {
      return widget.placeholder!.call(context);
    }
    return Container();
  }
}
