import 'dart:core';

import 'package:codepan/extensions/context.dart';
import 'package:codepan/resources/colors.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/resources/strings.dart';
import 'package:codepan/utils/search_handler.dart';
import 'package:codepan/widgets/dialogs/information_dialog.dart';
import 'package:codepan/widgets/icon.dart';
import 'package:codepan/widgets/if_else_builder.dart';
import 'package:codepan/widgets/line_divider.dart';
import 'package:codepan/widgets/text.dart';
import 'package:codepan/widgets/text_field.dart';
import 'package:flutter/material.dart';

typedef MenuSearchBuilder = Widget Function(ValueChanged<String> onSearch);

abstract class Selectable implements Searchable {
  dynamic get identifier;

  String? get title;
}

class MenuDialog<T extends Selectable> extends StatefulWidget {
  final MenuSearchBuilder? searchBuilder;
  final ValueChanged<T>? onSelectItem;
  final String? title, titleFont;
  final List<T>? disabledItems;
  final Widget? searchIcon;
  final Color fontColor;
  final List<T> items;

  const MenuDialog({
    Key? key,
    required this.items,
    this.disabledItems,
    this.title,
    this.onSelectItem,
    this.fontColor = PanColors.text,
    this.searchIcon,
    this.titleFont,
    this.searchBuilder,
  }) : super(key: key);

  @override
  _MenuDialogState<T> createState() => _MenuDialogState<T>();
}

class _MenuDialogState<T extends Selectable>
    extends StateWithSearch<MenuDialog<T>, T> {
  @override
  List<T> get allItems => widget.items;

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    final t = Theme.of(context);
    final height = d.at(45);
    final totalHeight = height * items.length;
    return InformationDialog(
      title: widget.title,
      titleFont: widget.titleFont,
      fontColor: widget.fontColor,
      withDivider: true,
      child: Material(
        color: Colors.white,
        child: IfElseBuilder(
          condition: showSuggestions || totalHeight > d.min,
          ifBuilder: (context) {
            return Column(
              children: [
                IfElseBuilder(
                  condition: widget.searchBuilder != null,
                  ifBuilder: (context) {
                    return widget.searchBuilder!.call(onSearch);
                  },
                  elseBuilder: (context) {
                    return PanTextField(
                      height: d.at(40),
                      prefixIcon: widget.searchIcon ??
                          PanIcon(
                            icon: 'search',
                            package: 'codepan',
                            width: d.at(15),
                            height: d.at(15),
                            color: widget.fontColor.withOpacity(0.5),
                          ),
                      maxLines: 1,
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.all(d.at(10)),
                      onChanged: onSearch,
                      textAlignVertical: TextAlignVertical.center,
                      textInputAction: TextInputAction.done,
                      borderWidth: d.at(1),
                      borderColor: PanColors.border,
                      focusedBorderWidth: d.at(1),
                      focusedBorderColor: t.primaryColor,
                      radius: d.at(5),
                    );
                  },
                ),
                LineDivider(),
                Container(
                  height: d.min,
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _MenuItem<T>(
                        item: item,
                        height: height,
                        fontColor: widget.fontColor,
                        onSelectItem: widget.onSelectItem,
                        withDivider: item != items.last,
                        isDisabled: _isDisabled(item),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          elseBuilder: (context) {
            return IfElseBuilder(
              condition: items.isNotEmpty,
              ifBuilder: (context) {
                return Column(
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    return _MenuItem<T>(
                      item: item,
                      height: height,
                      fontColor: widget.fontColor,
                      onSelectItem: widget.onSelectItem,
                      withDivider: item != items.last,
                      isDisabled: _isDisabled(item),
                    );
                  }),
                );
              },
              elseBuilder: (context) {
                return Container(
                  height: height * 3,
                  child: PanText(
                    text: Strings.noAvailableItems,
                    fontSize: d.at(11),
                    fontColor: PanColors.grey3,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  bool _isDisabled(T item) {
    if (widget.disabledItems?.isNotEmpty ?? false) {
      for (final _item in widget.disabledItems!) {
        if (_item.title == item.title) {
          return true;
        }
      }
    }
    return false;
  }
}

class _MenuItem<T extends Selectable> extends StatelessWidget {
  final ValueChanged<T>? onSelectItem;
  final bool withDivider, isDisabled;
  final Color fontColor;
  final double height;
  final T item;

  const _MenuItem({
    Key? key,
    required this.item,
    required this.height,
    this.withDivider = true,
    this.isDisabled = false,
    this.onSelectItem,
    this.fontColor = PanColors.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    return Column(
      children: [
        InkWell(
          child: PanText(
            height: height,
            text: item.title,
            fontSize: d.at(13),
            fontColor: isDisabled ? fontColor.withOpacity(0.4) : fontColor,
            alignment: Alignment.centerLeft,
            textAlign: TextAlign.left,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            padding: EdgeInsets.symmetric(
              horizontal: d.at(18),
            ),
          ),
          onTap: !isDisabled
              ? () {
                  context.pop();
                  onSelectItem?.call(item);
                }
              : null,
        ),
        IfElseBuilder(
          condition: withDivider,
          ifBuilder: (context) {
            return LineDivider();
          },
        ),
      ],
    );
  }
}
