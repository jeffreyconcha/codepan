import 'package:codepan/extensions/extensions.dart';
import 'package:codepan/resources/colors.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/utils/codepan_utils.dart';
import 'package:codepan/widgets/dialogs/menu_dialog.dart';
import 'package:codepan/widgets/line_divider.dart';
import 'package:codepan/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PanTextField extends StatefulWidget {
  final Color? borderColor,
      cursorColor,
      focusedBorderColor,
      disabledBorderColor,
      hintFontColor,
      iconColor,
      fontColor;
  final double? borderWidth,
      cursorHeight,
      focusedBorderWidth,
      disabledBorderWidth,
      fontHeight,
      fontSize,
      height,
      radius,
      width;
  final bool autofocus,
      bottomBorderOnly,
      enableInteractiveSelection,
      isPassword,
      showCursor,
      expands,
      enabled,
      obscureText;

  final String? text, hint, fontFamily;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onFieldSubmitted;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode, nextFocusNode;
  final TextAlignVertical? textAlignVertical;
  final int? maxLines, minLines, maxLength;
  final TextEditingController? controller;
  final ValueChanged<bool>? onFocusChange;
  final ValueChanged<String>? onChanged;
  final TextInputAction textInputAction;
  final Widget? prefixIcon, suffixIcon;
  final TextInputType? keyboardType;
  final String obscuringCharacter;
  final FontWeight fontWeight;
  final Alignment alignment;
  final FontStyle fontStyle;
  final TextAlign textAlign;
  final EdgeInsets? margin;
  final EdgeInsets padding;
  final Color background;

  const PanTextField({
    super.key,
    this.alignment = Alignment.center,
    this.autofocus = false,
    this.background = PanColors.none,
    this.borderColor,
    this.borderWidth,
    this.bottomBorderOnly = false,
    this.controller,
    this.cursorColor,
    this.cursorHeight,
    this.disabledBorderColor,
    this.disabledBorderWidth,
    this.enabled = true,
    this.enableInteractiveSelection = true,
    this.obscureText = false,
    this.focusedBorderColor,
    this.focusedBorderWidth,
    this.focusNode,
    this.fontColor,
    this.fontFamily,
    this.fontHeight,
    this.fontSize,
    this.fontStyle = FontStyle.normal,
    this.fontWeight = FontWeight.normal,
    this.height,
    this.hint,
    this.hintFontColor,
    this.iconColor,
    this.inputFormatters,
    this.isPassword = false,
    this.keyboardType,
    this.margin,
    this.maxLength,
    this.maxLines,
    this.minLines,
    this.nextFocusNode,
    this.onChanged,
    this.onFieldSubmitted,
    this.onFocusChange,
    this.padding = EdgeInsets.zero,
    this.prefixIcon,
    this.radius,
    this.showCursor = true,
    this.suffixIcon,
    this.text,
    this.textAlign = TextAlign.start,
    this.textAlignVertical = TextAlignVertical.center,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.done,
    this.width,
    this.expands = false,
    this.obscuringCharacter = '•',
  });

  @override
  _PanTextFieldState createState() => _PanTextFieldState();
}

class _PanTextFieldState extends State<PanTextField> {
  bool _obscureText = false;

  Color? get borderColor => widget.borderColor;

  double? get borderWidth => widget.borderWidth;

  Color? get focusedBorderColor => widget.focusedBorderColor;

  double? get focusedBorderWidth => widget.focusedBorderWidth;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword || widget.obscureText;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var suffixIcon;
    if (widget.isPassword) {
      final d = Dimension.of(context);
      suffixIcon = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: widget.iconColor,
          size: d.at(18),
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    } else {
      suffixIcon = widget.suffixIcon;
    }
    return Container(
      margin: widget.margin,
      alignment: widget.alignment,
      child: Focus(
        child: Container(
          width: widget.width,
          height: widget.height,
          child: TextFormField(
            expands: widget.expands,
            autofocus: widget.autofocus,
            initialValue: widget.text,
            enabled: widget.enabled,
            enableInteractiveSelection: widget.enableInteractiveSelection,
            textCapitalization: widget.textCapitalization,
            onChanged: widget.onChanged,
            inputFormatters: widget.inputFormatters,
            keyboardType: widget.keyboardType,
            textAlign: widget.textAlign,
            textAlignVertical: widget.textAlignVertical,
            controller: widget.controller,
            obscureText: _obscureText,
            obscuringCharacter: widget.obscuringCharacter,
            textInputAction: widget.textInputAction,
            focusNode: widget.focusNode,
            cursorHeight: widget.cursorHeight,
            cursorColor: widget.cursorColor,
            showCursor: widget.showCursor,
            onFieldSubmitted: (value) {
              if (widget.nextFocusNode != null) {
                FocusScope.of(context).requestFocus(widget.nextFocusNode);
              } else {
                FocusScope.of(context).nextFocus();
              }
              widget.onFieldSubmitted?.call(value);
            },
            maxLines: _obscureText ? 1 : widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            style: TextStyle(
              color: widget.fontColor,
              fontFamily: widget.fontFamily,
              fontStyle: widget.fontStyle,
              fontWeight: widget.fontWeight,
              fontSize: widget.fontSize,
              height: widget.fontHeight,
            ),
            decoration: InputDecoration(
              fillColor: widget.background,
              enabledBorder: _getBorder(
                color: widget.borderColor,
                width: widget.borderWidth,
                radius: widget.radius,
                isUnderlined: widget.bottomBorderOnly,
              ),
              focusedBorder: _getBorder(
                color: widget.focusedBorderColor,
                width: widget.focusedBorderWidth,
                radius: widget.radius,
                isUnderlined: widget.bottomBorderOnly,
              ),
              disabledBorder: _getBorder(
                color: widget.disabledBorderColor,
                width: widget.disabledBorderWidth,
                radius: widget.radius,
                isUnderlined: widget.bottomBorderOnly,
              ),
              contentPadding: widget.padding,
              filled: true,
              isDense: true,
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: widget.hintFontColor,
                fontFamily: widget.fontFamily,
                fontSize: widget.fontSize,
              ),
              suffixIcon: suffixIcon,
              prefixIcon: widget.prefixIcon,
            ),
            onTapOutside: (event) {
              context.hideKeyboard();
            },
          ),
        ),
        onFocusChange: widget.onFocusChange,
      ),
    );
  }

  InputBorder _getBorder({
    Color? color,
    double? width,
    double? radius,
    bool isUnderlined = false,
  }) {
    if (color != null && width != null) {
      if (isUnderlined) {
        return UnderlineInputBorder(
          borderSide: BorderSide(
            color: color,
            width: width,
          ),
        );
      } else {
        return OutlineInputBorder(
          borderSide: BorderSide(
            color: color,
            width: width,
          ),
          borderRadius: BorderRadius.circular(radius ?? 0),
        );
      }
    }
    return InputBorder.none;
  }
}

typedef OnLoadSuggestions<T> = Future<List<T>> Function();
typedef FieldViewBuilder = Widget Function(
  BuildContext context,
  TextEditingController controller,
  FocusNode node,
  VoidCallback onSelected,
  ValueChanged<String> onChanged,
);

class AutocompleteHandler<T extends Selectable> extends StatefulWidget {
  final OnLoadSuggestions<T> onLoadSuggestions;
  final FieldViewBuilder fieldBuilder;
  final Widget? listItem, listDivider;
  final ValueChanged<T>? onSelected;
  final Color color;

  const AutocompleteHandler({
    super.key,
    required this.onLoadSuggestions,
    required this.fieldBuilder,
    this.listItem,
    this.listDivider,
    this.color = PanColors.grey2,
    this.onSelected,
  });

  @override
  _AutocompleteHandlerState<T> createState() => _AutocompleteHandlerState<T>();
}

class _AutocompleteHandlerState<T extends Selectable>
    extends State<AutocompleteHandler<T>> {
  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return StreamBuilder<List<T>>(
          stream: _loadSuggestions(),
          builder: (context, snapshot) {
            return Autocomplete<T>(
              optionsBuilder: (value) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final input = value.text.toLowerCase();
                  if (input.isNotEmpty && snapshot.hasData) {
                    return snapshot.data!.where(
                      (element) {
                        for (final search in element.searchable) {
                          if (search != null) {
                            final lower = search.toLowerCase();
                            if (lower.contains(input)) {
                              return true;
                            }
                          }
                        }
                        return false;
                      },
                    );
                  }
                }
                return <T>[];
              },
              fieldViewBuilder: (context, controller, node, onSelected) {
                return widget.fieldBuilder(
                  context,
                  controller,
                  node,
                  onSelected,
                  _onChanged,
                );
              },
              displayStringForOption: (item) => item.title!,
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: d.at(5),
                    shadowColor: PanColors.border,
                    child: Container(
                      color: widget.color,
                      width: constraints.maxWidth,
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: options.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final item = options.elementAt(index);
                          return Material(
                            child: InkWell(
                              child: widget.listItem ??
                                  PanText(
                                    text: item.title,
                                    height: d.at(40),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: d.at(10),
                                    ),
                                    alignment: Alignment.centerLeft,
                                  ),
                              onTap: () {
                                onSelected(item);
                              },
                            ),
                          );
                        },
                        separatorBuilder: (context, int) {
                          return widget.listDivider ?? LineDivider();
                        },
                      ),
                    ),
                  ),
                );
              },
              onSelected: widget.onSelected,
            );
          },
        );
      },
    );
  }

  void _onChanged(String text) {}

  Stream<List<T>>? _loadSuggestions() async* {
    yield await widget.onLoadSuggestions.call();
  }
}
