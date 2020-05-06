import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:codepan/properties.dart';
import 'package:codepan/resources/colors.dart';

// ignore: must_be_immutable
class PanTextField extends StatefulWidget {
  final Color fontColor,
      background,
      borderColor,
      focusedBorderColor,
      hintFontColor;
  final double width,
      height,
      fontSize,
      fontHeight,
      radius,
      borderWidth,
      focusedBorderWidth;
  final int maxLines, minLines, maxLength;
  final ValueChanged<String> onFieldSubmitted;
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final EdgeInsetsGeometry margin, padding;
  final FocusNode focusNode, nextFocusNode;
  final String text, hint, fontFamily;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final Alignment alignment;
  final bool isPassword;

  PanTextField(
      {Key key,
      this.text,
      this.fontSize,
      this.fontHeight,
      this.fontColor = Default.fontColor,
      this.fontFamily = Default.fontFamily,
      this.fontStyle = FontStyle.normal,
      this.fontWeight = FontWeight.normal,
      this.alignment = Alignment.center,
      this.background = C.none,
      this.margin,
      this.padding,
      this.radius,
      this.hintFontColor,
      this.borderColor,
      this.borderWidth,
      this.focusedBorderColor,
      this.focusedBorderWidth,
      this.hint,
      this.isPassword = false,
      this.controller,
      this.textInputAction = TextInputAction.done,
      this.focusNode,
      this.nextFocusNode,
      this.onFieldSubmitted,
      this.maxLines,
      this.minLines,
      this.maxLength,
      this.width,
      this.height})
      : super(key: key);

  @override
  _PanTextFieldState createState() => _PanTextFieldState();
}

class _PanTextFieldState extends State<PanTextField> {
  bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    var border;
    if (widget.borderColor != null || widget.borderWidth != null) {
      border = new OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.radius),
          borderSide: BorderSide(
              width: widget.borderWidth,
              color: widget.borderColor,
              style: BorderStyle.solid));
    } else {
      if (widget.radius != null) {
        border = new OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.radius));
      }
    }
    var focusedBorder;
    if (widget.focusedBorderColor != null ||
        widget.focusedBorderWidth != null) {
      focusedBorder = new OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.radius),
          borderSide: BorderSide(
              width: widget.focusedBorderWidth,
              color: widget.focusedBorderColor,
              style: BorderStyle.solid));
    } else {
      if (widget.radius != null) {
        focusedBorder = new OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.radius));
      }
    }
    var suffixIcon;
    if (widget.isPassword) {
      suffixIcon = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: Default.fontColor,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      alignment: widget.alignment,
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscureText,
        textInputAction: widget.textInputAction,
        focusNode: widget.focusNode,
        onFieldSubmitted: (value) {
          if (widget.textInputAction == TextInputAction.next) {
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
            border: border,
            focusedBorder: focusedBorder,
            fillColor: widget.background,
            contentPadding: widget.padding,
            hintText: widget.hint,
            hintStyle: TextStyle(
                color: widget.hintFontColor,
                fontFamily: widget.fontFamily,
                fontSize: widget.fontSize),
            suffixIcon: suffixIcon,
            filled: true),
      ),
    );
  }
}
