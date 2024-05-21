import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/provider/EditProfileModel.dart';

class InterestButton extends StatefulWidget {
  final String btnName;
  final void Function()? onTap;
  final bool isAdd;

  const InterestButton(
      {super.key, required this.btnName, this.onTap, required this.isAdd});

  @override
  State<InterestButton> createState() => _InterestButtonState();
}

class _InterestButtonState extends State<InterestButton> {
  bool isActive = false;
  @override
  Widget build(BuildContext context) {
    return Consumer<EditProfileModel>(builder: (context, value, child) {
      return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (value.selectedInterests.contains(widget.btnName)
                ? const Color(0xffFF6E00)
                : Colors.white),
            border: Border.all(
              color: value.selectedInterests.contains(widget.btnName)
                  ? const Color(0xffFF6E00)
                  : const Color(0xff00B0FF),
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(16),
            ),
          ),
          child: widget.isAdd
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add),
                    Text(
                      widget.btnName,
                      style: const TextStyle(fontSize: 16),
                    )
                  ],
                )
              : Text(
                  widget.btnName,
                  style: const TextStyle(fontSize: 16),
                ),
        ),
      );
    });
  }
}
