import 'package:flutter/material.dart';

class StyledTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool? isReadOnly;
  final double? paddingTop;
  final double? paddingLeft;
  final double? paddingRight;
  final double? paddingBottom;
  final double? hintSize;
  final double? width;
  final double? height;
  final Color? fillColor;
  final IconData? prefixIcon;
  final int? maxLines;
  final int? minLines;

  const StyledTextFormField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText,
      this.keyboardType,
      this.isReadOnly,
      this.paddingBottom,
      this.paddingLeft,
      this.paddingRight,
      this.paddingTop,
      this.hintSize,
      this.height,
      this.width,
      this.fillColor,
      this.prefixIcon,
      this.maxLines,
      this.minLines});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: TextFormField(
        minLines: minLines ?? 1,
        maxLines: maxLines ?? 1,
        readOnly: isReadOnly ?? false,
        obscureText: obscureText,
        style: TextStyle(
            fontFamily: "Roboto",
            fontWeight: FontWeight.w400,
            fontSize: hintSize),
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Required';
          }
          return null;
        },
        keyboardType: keyboardType ?? TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          filled: true,
          fillColor: fillColor ?? Colors.white,
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xff00B0FF)),
              borderRadius: BorderRadius.all(Radius.circular(50))),
          border: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(50))),
          hintText: hintText,
          hintStyle: TextStyle(
              fontFamily: "Roboto",
              fontWeight: FontWeight.w300,
              fontSize: hintSize ?? 15),
          contentPadding: EdgeInsets.only(
              top: paddingTop ?? 15,
              right: paddingRight ?? 32,
              bottom: paddingBottom ?? 15,
              left: paddingLeft ?? 32),
          errorStyle: const TextStyle(
              fontSize: 12.0, // Customize the font size here
              fontFamily: "Roboto",
              fontWeight: FontWeight.w300,
              color: Colors.red),
        ),
      ),
    );
  }
}
