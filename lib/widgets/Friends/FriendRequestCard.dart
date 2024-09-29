import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/provider/FriendsModel.dart';
import 'package:unibond/widgets/styledButton.dart';

class FriendRequestCard extends StatelessWidget {
  final String uid;
  final String fullName;
  final String? profilePic;
  final dynamic Function() onAccept;
  final dynamic Function() onDeclince;
  final void Function() onTap;

  const FriendRequestCard(
      {super.key,
      required this.uid,
      required this.fullName,
      this.profilePic,
      required this.onAccept,
      required this.onDeclince,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
                width:
                    70, // double the maxRadius to cover the entire CircleAvatar
                height:
                    70, // double the maxRadius to cover the entire CircleAvatar
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.20), // Shadow color with opacity
                      spreadRadius: 0, // Spread radius
                      blurRadius: 3, // Blur radius
                      offset:
                          const Offset(0, 3), // Offset in x and y directions
                    ),
                  ],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xff00B0FF), // Border color
                    width: 2.0, // Border width
                  ),
                ),
                child: profilePic != null && (profilePic as String).isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(profilePic!),
                        maxRadius: 35,
                      )
                    : const CircleAvatar(
                        backgroundImage:
                            AssetImage('lib/assets/default_profile_pic.png'),
                        maxRadius: 35,
                      )),
            const SizedBox(
              width: 10,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName ?? 'Loading...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    StyledButton(
                      btnText: 'Accept',
                      onClick: onAccept,
                      btnHeight: 35,
                      borderRadius: BorderRadius.circular(8),
                      noShadow: true,
                      textSize: 15,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    StyledButton(
                      btnText: 'Decline',
                      onClick: onDeclince,
                      btnHeight: 35,
                      borderRadius: BorderRadius.circular(8),
                      btnColor: Colors.white,
                      textColor: const Color(0xff00B0FF),
                      isBorder: true,
                      noShadow: true,
                      textSize: 15,
                    ),
                  ],
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
