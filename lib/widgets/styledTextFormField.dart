import 'package:flutter/material.dart';

class StyledTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  const StyledTextFormField(
      {super.key,
      required this.controller,
      required this.hintText,
      this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(fontFamily: "Roboto", fontWeight: FontWeight.w400),
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        return null;
      },
      keyboardType: keyboardType ?? TextInputType.text,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xff00B0FF)),
            borderRadius: BorderRadius.all(Radius.circular(50))),
        border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(50))),
        hintText: hintText,
        hintStyle: const TextStyle(
            fontFamily: "Roboto", fontWeight: FontWeight.w300, fontSize: 15),
        contentPadding:
            const EdgeInsets.only(top: 15, right: 32, bottom: 15, left: 32),
        errorStyle: const TextStyle(
            fontSize: 12.0, // Customize the font size here
            fontFamily: "Roboto",
            fontWeight: FontWeight.w300,
            color: Colors.red),
      ),
    );
  }
}
