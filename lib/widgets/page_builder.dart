import 'package:codepan/bloc/parent_bloc.dart';
import 'package:codepan/bloc/parent_event.dart';
import 'package:codepan/bloc/parent_state.dart';
import 'package:codepan/widgets/if_else_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef WidgetBlocBuilder<S extends ParentState> = Widget Function(
  BuildContext context,
  S state,
);
typedef BlocObserver<S extends ParentState> = void Function(
  BuildContext context,
  S state,
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
  final Widget? bottomNavigationBar, bottomSheet;
  final List<Widget>? persistentFooterButtons;
  final Color? background, statusBarColor;
  final PageScrollBehaviour behaviour;
  final WidgetBlocBuilder<S>? bottom;
  final WidgetBlocBuilder<S> builder;
  final BlocObserver<S> observer;
  final Brightness? brightness;
  final BlocCreator creator;
  final bool extendBody;

  const PageBlocBuilder({
    Key? key,
    required this.creator,
    required this.observer,
    required this.builder,
    this.background,
    this.brightness,
    this.bottom,
    this.statusBarColor,
    this.behaviour = PageScrollBehaviour.whole,
    this.bottomSheet,
    this.bottomNavigationBar,
    this.persistentFooterButtons,
    this.extendBody = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final _background = background ?? t.backgroundColor;
    return BlocProvider<B>(
      create: creator as B Function(BuildContext),
      child: BlocListener<B, S>(
        listener: observer,
        child: BlocBuilder<B, S>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: _background,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(0),
                child: AppBar(
                  elevation: 0,
                  backgroundColor: statusBarColor ?? _background,
                ),
              ),
              body: Builder(
                builder: (context) {
                  switch (behaviour) {
                    case PageScrollBehaviour.none:
                      return builder.call(context, state);
                    default:
                      return SingleChildScrollView(
                        child: builder.call(context, state),
                      );
                  }
                },
              ),
              bottomNavigationBar:
                  bottomNavigationBar ?? bottom?.call(context, state),
              persistentFooterButtons: persistentFooterButtons,
              bottomSheet: bottomSheet,
              extendBody: extendBody,
            );
          },
        ),
      ),
    );
  }
}

class PageBuilder extends StatelessWidget {
  final Widget? bottomNavigationBar, bottomSheet;
  final List<Widget>? persistentFooterButtons;
  final Color? background, statusBarColor;
  final PageScrollBehaviour behaviour;
  final Brightness? brightness;
  final WidgetBuilder? bottom;
  final WidgetBuilder builder;
  final bool extendBody;

  const PageBuilder({
    Key? key,
    required this.builder,
    this.background,
    this.brightness,
    this.bottom,
    this.statusBarColor,
    this.behaviour = PageScrollBehaviour.whole,
    this.bottomSheet,
    this.bottomNavigationBar,
    this.persistentFooterButtons,
    this.extendBody = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final _background = background ?? t.backgroundColor;
    return Scaffold(
      backgroundColor: _background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          elevation: 0,
          backgroundColor: statusBarColor ?? _background,
        ),
      ),
      body: Builder(
        builder: (context) {
          switch (behaviour) {
            case PageScrollBehaviour.none:
              return builder.call(context);
            default:
              return SingleChildScrollView(
                child: builder.call(context),
              );
          }
        },
      ),
      bottomNavigationBar: bottomNavigationBar ?? bottom?.call(context),
      persistentFooterButtons: persistentFooterButtons,
      bottomSheet: bottomSheet,
      extendBody: extendBody,
    );
  }
}