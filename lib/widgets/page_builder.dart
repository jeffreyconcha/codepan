import 'package:codepan/bloc/parent_bloc.dart';
import 'package:codepan/bloc/parent_event.dart';
import 'package:codepan/bloc/parent_state.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as b;

typedef BlocBuilder<S extends ParentState> = Widget Function(
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
  final BlocBuilder<S>? bottom;
  final BlocBuilder<S> builder;
  final bool extendBody, bodyOnly;
  final BlocObserver<S> observer;
  final Brightness? brightness;
  final BlocCreator creator;

  const PageBlocBuilder({
    super.key,
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
    this.bodyOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    final backgroundColor = background ?? Colors.white;
    return b.BlocProvider<B>(
      create: creator as B Function(BuildContext),
      child: b.BlocListener<B, S>(
        listener: observer,
        child: b.BlocBuilder<B, S>(
          builder: (context, state) {
            final body = Builder(
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
            );
            if (bodyOnly) {
              return body;
            }
            return Scaffold(
              backgroundColor: backgroundColor,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(0),
                child: AppBar(
                  elevation: 0,
                  backgroundColor: statusBarColor ?? backgroundColor,
                  automaticallyImplyLeading: false,
                ),
              ),
              body: body,
              bottomNavigationBar: bottomNavigationBar ??
                  (bottom != null
                      ? Padding(
                          padding: EdgeInsets.only(
                            bottom: d.bottomPadding,
                          ),
                          child: bottom!.call(context, state),
                        )
                      : null),
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
  final bool extendBody, bodyOnly;
  final Brightness? brightness;
  final WidgetBuilder? bottom;
  final WidgetBuilder builder;

  const PageBuilder({
    super.key,
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
    this.bodyOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    final _background = background ?? Colors.white;
    final body = Builder(
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
    );
    if (bodyOnly) {
      return body;
    }
    return Scaffold(
      backgroundColor: _background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          elevation: 0,
          backgroundColor: statusBarColor ?? _background,
          automaticallyImplyLeading: false,
        ),
      ),
      body: body,
      bottomNavigationBar: bottomNavigationBar ??
          (bottom != null
              ? Padding(
                  padding: EdgeInsets.only(
                    bottom: d.bottomPadding,
                  ),
                  child: bottom!.call(context),
                )
              : null),
      persistentFooterButtons: persistentFooterButtons,
      bottomSheet: bottomSheet,
      extendBody: extendBody,
    );
  }
}

class WidgetBlocBuilder<E extends ParentEvent, B extends ParentBloc<E, S>,
    S extends ParentState> extends StatelessWidget {
  final BlocCreator creator;
  final BlocObserver<S> observer;
  final BlocBuilder<S> builder;

  const WidgetBlocBuilder({
    super.key,
    required this.creator,
    required this.observer,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return b.BlocProvider<B>(
      create: creator as B Function(BuildContext),
      child: b.BlocListener<B, S>(
        listener: observer,
        child: b.BlocBuilder<B, S>(
          builder: (context, state) {
            return builder.call(context, state);
          },
        ),
      ),
    );
  }
}
