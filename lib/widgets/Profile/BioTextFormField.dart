import 'package:flutter/material.dart';

class BioTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  const BioTextFormField(
      {super.key, required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // style: TextStyle(fontSize: 12),
      controller: controller,
      minLines: 1,
      maxLines: 4,
      maxLength: 101,
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText,
        // hintStyle: TextStyle(fontSize: 12),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xff00B0FF)),
            borderRadius: BorderRadius.all(Radius.circular(16))),
        border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your bio';
        }
        return null;
      },
    );
  }
}
