import 'package:codepan/bloc/parent_bloc.dart';
import 'package:codepan/bloc/parent_event.dart';
import 'package:codepan/bloc/parent_state.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef WidgetBlocBuilder = Widget Function(
  BuildContext context,
  ParentState state,
);
typedef BlocObserver = void Function(
  BuildContext context,
  ParentState state,
);
typedef BlocCreator = ParentBloc Function(
  BuildContext context,
);
enum PageScrollBehaviour {
  whole,
  none,
}

class PageBlocBuilder<E extends ParentEvent, B extends ParentBloc<E, S>,
    S extends ParentState> extends StatelessWidget {
  final Color? background, statusBarColor;
  final PageScrollBehaviour behaviour;
  final Widget? bottomNavigationBar;
  final WidgetBlocBuilder builder;
  final WidgetBlocBuilder? layer;
  final Brightness? brightness;
  final BlocObserver observer;
  final BlocCreator creator;

  const PageBlocBuilder({
    Key? key,
    required this.creator,
    required this.observer,
    required this.builder,
    this.layer,
    this.background,
    this.brightness,
    this.statusBarColor = Colors.transparent,
    this.behaviour = PageScrollBehaviour.whole,
    this.bottomNavigationBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context, isSafeArea: true);
    final t = Theme.of(context);
    final a = t.appBarTheme;
    PreferredSize? appBar;
    if (bottomNavigationBar == null) {
      appBar = PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          elevation: 0,
          brightness: brightness ?? a.brightness,
          backgroundColor: statusBarColor,
        ),
      );
    }
    return BlocProvider<B>(
      create: creator as B Function(BuildContext),
      child: Scaffold(
        backgroundColor: background ?? t.backgroundColor,
        appBar: appBar,
        body: _PageBlocBody<E, B, S>(
          builder: builder,
          maxHeight: d.max,
          layer: layer,
          behaviour: behaviour,
          observer: observer,
        ),
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}

class _PageBlocBody<E extends ParentEvent, B extends ParentBloc<E, S>,
    S extends ParentState> extends StatelessWidget {
  final PageScrollBehaviour behaviour;
  final WidgetBlocBuilder? layer;
  final WidgetBlocBuilder builder;
  final BlocObserver observer;
  final double maxHeight;

  const _PageBlocBody({
    Key? key,
    required this.observer,
    required this.builder,
    required this.maxHeight,
    required this.behaviour,
    this.layer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<B, S>(
      listener: observer,
      child: BlocBuilder<B, S>(
        builder: (context, state) {
          switch (behaviour) {
            case PageScrollBehaviour.none:
              return Stack(
                children: [
                  builder.call(context, state),
                  Container(
                    child: layer?.call(context, state),
                  ),
                ],
              );
            default:
              return SingleChildScrollView(
                child: Stack(
                  children: [
                    builder.call(context, state),
                    SafeArea(
                      child: Container(
                        height: maxHeight,
                        child: layer?.call(context, state),
                      ),
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}

class PageBuilder extends StatelessWidget {
  final Color? background, statusBarColor;
  final WidgetBuilder? builder, layer;
  final PageScrollBehaviour behaviour;
  final Widget? bottomNavigationBar;
  final Brightness? brightness;

  const PageBuilder({
    Key? key,
    this.background,
    this.builder,
    this.layer,
    this.brightness,
    this.bottomNavigationBar,
    this.statusBarColor = Colors.transparent,
    this.behaviour = PageScrollBehaviour.whole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context, isSafeArea: true);
    final t = Theme.of(context);
    final a = t.appBarTheme;
    PreferredSize? appBar;
    if (bottomNavigationBar == null) {
      appBar = PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          elevation: 0,
          brightness: brightness ?? a.brightness,
          backgroundColor: statusBarColor,
        ),
      );
    }
    return Scaffold(
      backgroundColor: background ?? t.backgroundColor,
      appBar: appBar,
      body: _PageBody(
        builder: builder,
        maxHeight: d.max,
        layer: layer,
        behaviour: behaviour,
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class _PageBody extends StatelessWidget {
  final WidgetBuilder? builder, layer;
  final PageScrollBehaviour? behaviour;
  final double? maxHeight;

  const _PageBody({
    Key? key,
    this.builder,
    this.layer,
    this.behaviour,
    this.maxHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (behaviour) {
      case PageScrollBehaviour.none:
        return Stack(
          children: [
            builder!.call(context),
            Container(
              child: layer?.call(context),
            ),
          ],
        );
      default:
        return SingleChildScrollView(
          child: Stack(
            children: [
              builder!.call(context),
              SafeArea(
                child: Container(
                  height: maxHeight,
                  child: layer?.call(context),
                ),
              ),
            ],
          ),
        );
    }
  }
}
