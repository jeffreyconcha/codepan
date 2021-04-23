import 'package:codepan/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class PanTextField extends StatefulWidget {
  final Color? fontColor,
      borderColor,
      focusedBorderColor,
      hintFontColor,
      iconColor,
      cursorColor;
  final double? width,
      height,
      fontSize,
      fontHeight,
      radius,
      cursorHeight,
      borderWidth,
      focusedBorderWidth;
  final bool enabled,
      autofocus,
      enableInteractiveSelection,
      isPassword,
      showCursor,
      bottomBorderOnly;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines, minLines, maxLength;
  final ValueChanged<String>? onFieldSubmitted;
  final TextAlignVertical? textAlignVertical;
  final TextEditingController? controller;
  final EdgeInsetsGeometry? margin, padding;
  final FocusNode? focusNode, nextFocusNode;
  final ValueChanged<bool>? onFocusChange;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon, suffixIcon;
  final String? text, hint, fontFamily;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final Alignment alignment;
  final Color background;
  final TextAlign textAlign;

  const PanTextField({
    Key? key,
    this.fontStyle = FontStyle.normal,
    this.fontWeight = FontWeight.normal,
    this.alignment = Alignment.center,
    this.background = PanColors.none,
    this.textInputAction = TextInputAction.done,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.enabled = true,
    this.autofocus = false,
    this.isPassword = false,
    this.showCursor = true,
    this.bottomBorderOnly = false,
    this.enableInteractiveSelection = true,
    this.text,
    this.fontSize,
    this.fontHeight,
    this.fontColor,
    this.fontFamily,
    this.radius,
    this.margin,
    this.padding,
    this.hintFontColor,
    this.borderColor,
    this.borderWidth,
    this.focusedBorderColor,
    this.focusedBorderWidth,
    this.hint,
    this.controller,
    this.textAlignVertical,
    this.focusNode,
    this.nextFocusNode,
    this.onFieldSubmitted,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.width,
    this.height,
    this.prefixIcon,
    this.suffixIcon,
    this.iconColor,
    this.inputFormatters,
    this.keyboardType,
    this.onChanged,
    this.onFocusChange,
    this.cursorHeight,
    this.cursorColor,
  }) : super(key: key);

  @override
  _PanTextFieldState createState() => _PanTextFieldState();
}

class _PanTextFieldState extends State<PanTextField> {
  bool _obscureText = false;
  bool _hasFocus = false;

  Color? get borderColor => widget.borderColor;

  double? get borderWidth => widget.borderWidth;

  Color? get focusedBorderColor => widget.focusedBorderColor;

  double? get focusedBorderWidth => widget.focusedBorderWidth;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var border;
    if (borderWidth != null && borderColor != null) {
      final side = BorderSide(
        color: _hasFocus ? focusedBorderColor! : borderColor!,
        width: _hasFocus ? focusedBorderWidth! : borderWidth!,
      );
      border = widget.bottomBorderOnly
          ? Border(bottom: side)
          : Border.fromBorderSide(side);
    }
    final borderRadius =
        widget.radius != null ? BorderRadius.circular(widget.radius!) : null;
    var suffixIcon;
    if (widget.isPassword) {
      suffixIcon = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: widget.iconColor,
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
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      alignment: widget.alignment,
      decoration: BoxDecoration(
        color: widget.background,
        border: border,
        borderRadius: borderRadius,
      ),
      child: Focus(
        child: TextFormField(
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
          textInputAction: widget.textInputAction,
          focusNode: widget.focusNode,
          cursorHeight: widget.cursorHeight,
          cursorColor: widget.cursorColor,
          showCursor: widget.showCursor,
          onFieldSubmitted: (value) {
            if (widget.nextFocusNode != null) {
              FocusScope.of(context).requestFocus(widget.nextFocusNode);
            }
            widget.onFieldSubmitted!(value);
          },
          maxLines: widget.isPassword ? 1 : widget.maxLength,
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
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            contentPadding: widget.padding,
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
        ),
        onFocusChange: (hasFocus) {
          setState(() {
            _hasFocus = hasFocus;
          });
          widget.onFocusChange?.call(hasFocus);
        },
      ),
    );
  }
}
