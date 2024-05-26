import 'package:flutter/material.dart';
import 'package:unibond/widgets/styledButton.dart';

class PersonCard extends StatelessWidget {
  final String? profilePic;
  final String userName;
  final dynamic Function()? onConnect;
  final Function()? onTap;
  const PersonCard(
      {super.key,
      this.profilePic,
      required this.userName,
      required this.onConnect,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFFBBBBBB)),
          borderRadius: const BorderRadius.all(
            Radius.circular(35),
          ),
        ),
        child: Column(
          children: [
            Container(
                width:
                    100, // double the maxRadius to cover the entire CircleAvatar
                height:
                    100, // double the maxRadius to cover the entire CircleAvatar
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xffFF6814), // Border color
                    width: 2.0, // Border width
                  ),
                ),
                child: profilePic != null
                    ? profilePic!.isNotEmpty
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(profilePic!),
                            maxRadius: 50,
                          )
                        : const CircleAvatar(
                            backgroundImage: AssetImage(
                                'lib/assets/default_profile_pic.png'),
                            maxRadius: 50,
                          )
                    : const CircleAvatar(
                        backgroundImage:
                            AssetImage('lib/assets/default_profile_pic.png'),
                        maxRadius: 50,
                      )),
            const SizedBox(
              height: 10,
            ),
            Text(
              userName,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 10,
            ),
            StyledButton(
              textSize: 16,
              btnHeight: 40,
              btnColor: const Color(0xff00B0FF),
              noShadow: true,
              btnText: 'Connect',
              onClick: onConnect,
              btnIcon: const Icon(Icons.person_add),
            )
          ],
        ),
      ),
    );
  }
}
