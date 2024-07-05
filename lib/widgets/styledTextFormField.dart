import 'package:flutter/material.dart';

class StyledTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  bool obscureText;
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
  final bool? isPassword;

  final int? maxLines;
  final int? minLines;
  void Function(String)? onChanged;

  StyledTextFormField(
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
      this.isPassword,
      this.maxLines,
      this.minLines,
      this.onChanged});

  @override
  State<StyledTextFormField> createState() => _StyledTextFormFieldState();
}

class _StyledTextFormFieldState extends State<StyledTextFormField> {
  bool isTextFieldEmpty = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_textListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_textListener);
    super.dispose();
  }

  void _textListener() {
    setState(() {
      isTextFieldEmpty = widget.controller.text.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: TextFormField(
        onChanged: widget.onChanged,
        minLines: widget.minLines ?? 1,
        maxLines: widget.maxLines ?? 1,
        readOnly: widget.isReadOnly ?? false,
        obscureText: widget.obscureText,
        style: TextStyle(
            fontFamily: "Roboto",
            fontWeight: FontWeight.w400,
            fontSize: widget.hintSize),
        controller: widget.controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Required';
          }
          return null;
        },
        keyboardType: widget.keyboardType ?? TextInputType.text,
        decoration: InputDecoration(
          suffixIcon: widget.isPassword != null &&
                  widget.isPassword == true &&
                  !isTextFieldEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      widget.obscureText = !widget.obscureText;
                    });
                  },
                  icon: Icon(
                    widget.obscureText
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                )
              : null,
          prefixIcon:
              widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
          filled: true,
          fillColor: widget.fillColor ?? Colors.white,
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xff00B0FF)),
              borderRadius: BorderRadius.all(Radius.circular(50))),
          border: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(50))),
          hintText: widget.hintText,
          hintStyle: TextStyle(
              fontFamily: "Roboto",
              fontWeight: FontWeight.w300,
              fontSize: widget.hintSize ?? 15),
          contentPadding: EdgeInsets.only(
              top: widget.paddingTop ?? 15,
              right: widget.paddingRight ?? 32,
              bottom: widget.paddingBottom ?? 15,
              left: widget.paddingLeft ?? 32),
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
