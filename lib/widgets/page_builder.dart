import 'package:codepan/bloc/parent_bloc.dart';
import 'package:codepan/bloc/parent_event.dart';
import 'package:codepan/bloc/parent_state.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

typedef WidgetBuilder = Widget Function(
  BuildContext context,
  ParentState state,
);
enum ScrollBehaviour {
  whole,
  none,
}

class PageBuilder<E extends ParentEvent, B extends ParentBloc<E, S>,
    S extends ParentState> extends StatelessWidget {
  final Color background, statusBarColor;
  final WidgetBuilder child, topLayer;
  final Brightness brightness;
  final ScrollBehaviour behaviour;
  final Create<B> create;

  const PageBuilder({
    Key key,
    @required this.child,
    @required this.topLayer,
    this.background,
    this.statusBarColor = Colors.transparent,
    this.brightness = Brightness.dark,
    this.behaviour = ScrollBehaviour.whole,
    this.create,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context, isSafeArea: true);
    final t = Theme.of(context);
    return BlocProvider<B>(
      create: create,
      child: Scaffold(
        backgroundColor: background ?? t.backgroundColor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: AppBar(
            elevation: 0,
            brightness: brightness,
            backgroundColor: statusBarColor,
          ),
        ),
        body: _PageBody<E, B, S>(
          child: child,
          maxHeight: d.max,
          topLayer: topLayer,
          behaviour: behaviour,
        ),
      ),
    );
  }
}

class _PageBody<E extends ParentEvent, B extends ParentBloc<E, S>,
    S extends ParentState> extends StatelessWidget {
  final WidgetBuilder child, topLayer;
  final ScrollBehaviour behaviour;
  final double maxHeight;

  const _PageBody({
    Key key,
    @required this.child,
    @required this.maxHeight,
    @required this.behaviour,
    this.topLayer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, S>(
      builder: (context, state) {
        switch (behaviour) {
          case ScrollBehaviour.none:
            return Stack(
              children: [
                child.call(context, state),
                topLayer?.call(context, state),
              ],
            );
            break;
          default:
            return SingleChildScrollView(
              child: Stack(
                children: [
                  child.call(context, state),
                  SafeArea(
                    child: Container(
                      height: maxHeight,
                      child: topLayer?.call(context, state),
                    ),
                  ),
                ],
              ),
            );
            break;
        }
      },
    );
  }
}
