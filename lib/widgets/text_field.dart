import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:codepan/config/properties.dart';
import 'package:codepan/resources/colors.dart';

class PanTextField extends StatefulWidget {
  final Color fontColor,
      background,
      borderColor,
      focusedBorderColor,
      hintFontColor,
      iconColor;
  final double width,
      height,
      fontSize,
      fontHeight,
      radius,
      borderWidth,
      focusedBorderWidth;
  final List<TextInputFormatter> inputFormatters;
  final int maxLines, minLines, maxLength;
  final ValueChanged<String> onFieldSubmitted;
  final TextAlignVertical textAlignVertical;
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final EdgeInsetsGeometry margin, padding;
  final FocusNode focusNode, nextFocusNode;
  final bool isPassword, bottomBorderOnly;
  final String text, hint, fontFamily;
  final TextInputType keyboardType;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final FontStyle fontStyle;
  final Alignment alignment;
  final Widget suffixIcon;

  const PanTextField({
    Key key,
    this.text,
    this.fontSize,
    this.fontHeight,
    this.fontColor,
    this.fontFamily,
    this.fontStyle = FontStyle.normal,
    this.fontWeight = FontWeight.normal,
    this.alignment = Alignment.center,
    this.background = PanColors.none,
    this.radius,
    this.margin,
    this.padding,
    this.hintFontColor,
    this.borderColor,
    this.borderWidth,
    this.focusedBorderColor,
    this.focusedBorderWidth,
    this.hint,
    this.isPassword = false,
    this.bottomBorderOnly = false,
    this.controller,
    this.textInputAction = TextInputAction.done,
    this.focusNode,
    this.nextFocusNode,
    this.onFieldSubmitted,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.width,
    this.height,
    this.suffixIcon,
    this.iconColor,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.inputFormatters,
    this.keyboardType,
  }) : super(key: key);

  @override
  _PanTextFieldState createState() => _PanTextFieldState();
}

class _PanTextFieldState extends State<PanTextField> {
  bool _obscureText;
  Color _borderColor;
  double _borderWidth;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _borderColor = widget.borderColor;
    _borderWidth = widget.borderWidth;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var border;
    if (_borderWidth != null && _borderColor != null) {
      final side = BorderSide(color: _borderColor, width: _borderWidth);
      border = widget.bottomBorderOnly
          ? new Border(bottom: side)
          : Border.fromBorderSide(side);
    }
    final borderRadius =
        widget.radius != null ? BorderRadius.circular(widget.radius) : null;
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
      decoration: BoxDecoration(
        color: widget.background,
        border: border,
        borderRadius: borderRadius,
      ),
      child: Focus(
        child: TextFormField(
          inputFormatters: widget.inputFormatters,
          keyboardType: widget.keyboardType,
          textAlign: widget.textAlign,
          textAlignVertical: widget.textAlignVertical,
          controller: widget.controller,
          obscureText: _obscureText,
          textInputAction: widget.textInputAction,
          focusNode: widget.focusNode,
          onFieldSubmitted: (value) {
            if (widget.nextFocusNode != null) {
              FocusScope.of(context).requestFocus(widget.nextFocusNode);
            }
            widget.onFieldSubmitted(value);
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
              hintText: widget.hint,
              hintStyle: TextStyle(
                  color: widget.hintFontColor,
                  fontFamily: widget.fontFamily,
                  fontSize: widget.fontSize),
              suffixIcon: suffixIcon),
        ),
        onFocusChange: (hasFocus) {
          setState(() {
            this._borderColor =
                hasFocus ? widget.focusedBorderColor : widget.borderColor;
            this._borderWidth =
                hasFocus ? widget.focusedBorderWidth : widget.borderWidth;
          });
        },
      ),
    );
  }
}
