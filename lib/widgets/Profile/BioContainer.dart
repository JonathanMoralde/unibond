import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/provider/EditProfileModel.dart';
import 'package:unibond/widgets/Profile/BioTextFormField.dart';

class BioContainer extends StatefulWidget {
  const BioContainer({super.key});

  @override
  State<BioContainer> createState() => _BioContainerState();
}

class _BioContainerState extends State<BioContainer> {
  @override
  Widget build(BuildContext context) {
    return Consumer<EditProfileModel>(builder: (context, value, child) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(
            Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.20), // Shadow color with opacity
              spreadRadius: 0, // Spread radius
              blurRadius: 3, // Blur radius
              offset: const Offset(0, 5), // Offset in x and y directions
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              width: double.infinity,
              decoration: const BoxDecoration(
                  color: Color(0xffFF6E00),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16))),
              child: const Text(
                'Bio',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
              child: BioTextFormField(
                  controller: value.bioController,
                  hintText: 'Bio. Describe yourself'),
            )
          ],
        ),
      );
    });
  }
}
