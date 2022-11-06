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
import 'package:codepan/widgets/size_listener.dart';
import 'package:codepan/widgets/text.dart';
import 'package:codepan/widgets/text_field.dart';
import 'package:codepan/widgets/wrapper.dart';
import 'package:flutter/material.dart';

const _itemMinHeight = 45.0;

typedef MenuSearchBuilder = Widget Function(ValueChanged<String> onSearch);

typedef MenuAsyncItemBuilder<T extends Selectable> = Future<List<T>> Function();

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
    super.key,
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
  });

  @override
  State<MenuDialog> createState() => _MenuDialogState<T>();
}

class _MenuDialogState<T extends Selectable> extends State<MenuDialog<T>>
    with SearchHandlerMixin<MenuDialog<T>, T> {
  late Orientation _orientation;
  late List<T> _selectedItems;
  Size? _size;

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
    final contentHeight = d.at(_itemMinHeight) * allItems.length;
    return InformationDialog(
      title: widget.title,
      titleFont: widget.titleFont,
      fontColor: widget.fontColor,
      positive: isMultiple ? widget.positive : null,
      negative: isMultiple ?widget.negative : null,
      margin: EdgeInsets.all(d.at(10)),
      autoDismiss: false,
      withDivider: true,
      child: WrapperBuilder(
        condition: _size == null || _orientation != d.orientation,
        child: Material(
          color: Colors.white,
          child: Column(
            children: [
              IfElseBuilder(
                condition: showSuggestions || allItems.length > 10,
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
              WrapperBuilder(
                condition: _size == null || _orientation != d.orientation,
                child: SizeListener(
                  child: IfElseBuilder(
                    condition: allItems.isNotEmpty,
                    ifBuilder: (context) {
                      if (items.isEmpty) {
                        return placeholder;
                      }
                      return ListView.builder(
                        itemCount: items.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _MenuItem<T>(
                            item: item,
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
                        height: d.min,
                        child: placeholder,
                      );
                    },
                  ),
                  onSizeChange: (size, position) {
                    if (size.height > contentHeight) {
                      setState(() {
                        _size = size;
                        _orientation = d.orientation;
                      });
                    }
                  },
                ),
                builder: (context, child) {
                  return Expanded(
                    child: child,
                  );
                },
                fallback: (context, child) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: _size!.height,
                    ),
                    child: child,
                  );
                },
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
        builder: (context, child) {
          return Expanded(
            child: child,
          );
        },
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
  final T item;

  const _MenuItem({
    super.key,
    required this.item,
    this.withDivider = true,
    this.isDisabled = false,
    this.onSelectItem,
    this.fontColor = PanColors.text,
    this.checkedIcon,
    this.uncheckedIcon,
    this.isMultiple = false,
    this.isSelected = false,
  });

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
                Expanded(
                  child: PanText(
                    text: item.title,
                    fontSize: d.at(13),
                    fontColor:
                        isDisabled ? fontColor.withOpacity(0.4) : fontColor,
                    alignment: Alignment.centerLeft,
                    textAlign: TextAlign.left,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    padding: EdgeInsets.symmetric(
                      vertical: d.at(10),
                    ),
                    constraints:
                        BoxConstraints(minHeight: d.at(_itemMinHeight)),
                  ),
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
