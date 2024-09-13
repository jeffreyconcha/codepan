import 'package:codepan/bloc/parent_bloc.dart';
import 'package:codepan/transitions/route_transition.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension BuildContextUtils on BuildContext {
  void popAllRoutes() {
    final navigator = Navigator.of(this);
    while (navigator.canPop()) {
      navigator.pop();
    }
  }

  void pop<T>([T? result]) {
    final navigator = Navigator.of(this);
    if (navigator.canPop()) {
      navigator.pop(result);
    }
  }

  void popUntil(RoutePredicate predicate) {
    Navigator.of(this).popUntil(predicate);
  }

  void push({
    required Widget page,
    ValueChanged<Object?>? onExit,
    RouteSettings? settings,
  }) {
    final route = CupertinoPageRoute(
      settings: settings,
      builder: (context) {
        return page;
      },
    );
    Navigator.of(this).push(route).then((value) {
      onExit?.call(value);
    });
  }

  void replace({
    required Widget page,
    Duration? duration,
    ValueChanged<Object?>? onExit,
    RouteSettings? settings,
  }) {
    final route = FadeRoute(
      enter: page,
      duration: duration,
      settings: settings,
    );
    Navigator.of(this).pushReplacement(route).then((value) {
      onExit?.call(value);
    });
  }

  void fadeIn({
    required Widget page,
    Duration? duration,
    ValueChanged<Object?>? onExit,
    RouteSettings? settings,
  }) {
    final route = FadeRoute(
      enter: page,
      duration: duration,
      settings: settings,
    );
    Navigator.of(this).push(route).then((value) {
      onExit?.call(value);
    });
  }

  void slideToTop({
    required Widget page,
    Duration? duration,
    ValueChanged<Object?>? onExit,
    RouteSettings? settings,
  }) {
    final route = BottomModalRoute(
      enter: page,
      duration: duration,
      settings: settings,
    );
    Navigator.of(this).push(route).then((value) {
      onExit?.call(value);
    });
  }

  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }

  T blocOf<T extends ParentBloc>() {
    return BlocProvider.of<T>(this);
  }
}
