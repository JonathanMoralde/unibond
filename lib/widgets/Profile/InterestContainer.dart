import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/provider/EditProfileModel.dart';
import 'package:unibond/widgets/Profile/InterestButton.dart';

class Interestcontainer extends StatefulWidget {
  final String title;
  const Interestcontainer({super.key, required this.title});

  @override
  State<Interestcontainer> createState() => _InterestcontainerState();
}

class _InterestcontainerState extends State<Interestcontainer> {
  List<String> tempOptions = [
    'music',
    'dance',
    'food',
    'sing',
    'sports',
    'travel'
  ];

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
              offset: Offset(0, 5), // Offset in x and y directions
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
              child: Text(
                '${widget.title} Interests',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
              child: Wrap(
                runSpacing: 10,
                spacing: 5,
                children: [
                  for (final interest in tempOptions)
                    InterestButton(
                      btnName: interest,
                      onTap: () {
                        print('clicked $interest');
                        final editProfileProvider =
                            context.read<EditProfileModel>();

                        setState(() {
                          editProfileProvider.addInterest(interest);
                        });
                      },
                    ),
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}