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
  final Widget? searchIcon, checkedIcon, uncheckedIcon;
  final String? title, titleFont, positive, negative;
  final ValueChanged<List<T>>? onSelectItems;
  final MenuSearchBuilder? searchBuilder;
  final ValueChanged<T>? onSelectItem;
  final List<T>? disabledItems;
  final List<T>? selectedItems;
  final bool isMultiple;
  final Color fontColor;
  final List<T> items;

  const MenuDialog({
    Key? key,
    required this.items,
    this.disabledItems,
    this.selectedItems,
    this.title,
    this.onSelectItem,
    this.onSelectItems,
    this.fontColor = PanColors.text,
    this.searchIcon,
    this.titleFont,
    this.searchBuilder,
    this.checkedIcon,
    this.uncheckedIcon,
    this.positive,
    this.negative,
    this.isMultiple = false,
  }) : super(key: key);

  @override
  _MenuDialogState<T> createState() => _MenuDialogState<T>();
}

class _MenuDialogState<T extends Selectable>
    extends StateWithSearch<MenuDialog<T>, T> {
  late List<T> _selectedItems;

  bool get isMultiple => widget.isMultiple;

  List<T>? get disabledItems => widget.disabledItems;

  @override
  List<T> get allItems => widget.items;

  @override
  void initState() {
    super.initState();
    _selectedItems = widget.selectedItems ?? [];
    if (isMultiple) {
      assert(widget.checkedIcon != null, 'No widget for checked icon.');
      assert(widget.uncheckedIcon != null, 'No widget for unchecked icon.');
      assert(widget.positive != null, 'No text for positive button.');
      assert(widget.negative != null, 'No text for negative button.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    final t = Theme.of(context);
    final itemHeight = d.at(45);
    final totalHeight = itemHeight * allItems.length;
    return InformationDialog(
      title: widget.title,
      titleFont: widget.titleFont,
      fontColor: widget.fontColor,
      positive: widget.positive,
      negative: widget.negative,
      autoDismiss: false,
      withDivider: true,
      child: Material(
        color: Colors.white,
        child: Column(
          children: [
            IfElseBuilder(
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
                  ],
                );
              },
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: d.min,
              ),
              child: IfElseBuilder(
                condition: allItems.isNotEmpty,
                ifBuilder: (context) {
                  if (items.isEmpty) {
                    return placeholder;
                  }
                  return ListView.builder(
                    itemCount: items.length,
                    shrinkWrap: totalHeight < d.min,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _MenuItem<T>(
                        item: item,
                        height: itemHeight,
                        fontColor: widget.fontColor,
                        withDivider: item != items.last,
                        checkedIcon: widget.checkedIcon,
                        uncheckedIcon: widget.uncheckedIcon,
                        isMultiple: isMultiple,
                        isSelected: _selectedItems.contains(item),
                        isDisabled: disabledItems?.contains(item) ?? false,
                        onSelectItem: _onSelectItem,
                      );
                    },
                  );
                },
                elseBuilder: (context) {
                  return SizedBox(
                    height: d.at(100),
                    child: placeholder,
                  );
                },
              ),
            ),
            IfElseBuilder(
              condition: isMultiple,
              ifBuilder: (context) {
                return LineDivider();
              },
            ),
          ],
        ),
      ),
      onPositiveTap: () {
        context.pop();
        widget.onSelectItems?.call(_selectedItems);
      },
      onNegativeTap: () {
        setState(() {
          _selectedItems.clear();
        });
      },
    );
  }

  Widget get placeholder {
    final d = Dimension.of(context);
    return PanText(
      text: Strings.noAvailableItems,
      fontSize: d.at(12),
      fontColor: PanColors.grey3,
      alignment: Alignment.center,
    );
  }

  void _onSelectItem(T item) {
    if (widget.isMultiple) {
      setState(() {
        if (_selectedItems.contains(item)) {
          _selectedItems.remove(item);
        } else {
          _selectedItems.add(item);
        }
      });
    } else {
      context.pop();
      widget.onSelectItem?.call(item);
    }
  }
}

class _MenuItem<T extends Selectable> extends StatelessWidget {
  final bool withDivider, isDisabled, isMultiple, isSelected;
  final Widget? checkedIcon, uncheckedIcon;
  final ValueChanged<T>? onSelectItem;
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
    this.checkedIcon,
    this.uncheckedIcon,
    this.isMultiple = false,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    return Column(
      children: [
        InkWell(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: d.at(18),
            ),
            child: Row(
              children: [
                IfElseBuilder(
                  condition: isMultiple,
                  ifBuilder: (context) {
                    return IfElseBuilder(
                      condition: isSelected,
                      margin: EdgeInsets.only(
                        right: d.at(10),
                      ),
                      ifBuilder: (context) {
                        return checkedIcon!;
                      },
                      elseBuilder: (context) {
                        return uncheckedIcon!;
                      },
                    );
                  },
                ),
                PanText(
                  height: height,
                  text: item.title,
                  fontSize: d.at(13),
                  fontColor:
                      isDisabled ? fontColor.withOpacity(0.4) : fontColor,
                  alignment: Alignment.centerLeft,
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          onTap: !isDisabled ? () => onSelectItem?.call(item) : null,
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
