import 'package:flutter/material.dart';
import 'package:unibond/widgets/styledButton.dart';

class PersonCard extends StatefulWidget {
  final String? profilePic;
  final String userName;
  final Future<dynamic> Function() onConnect;
  final Function()? onTap;
  final bool isRequestSent;
  final bool isRequesting;
  final bool isFriend;
  final Future<dynamic> Function()? onCancel;
  final Future<dynamic> Function()? onMessage;
  final Future<dynamic> Function()? onAccept;
  const PersonCard(
      {super.key,
      this.profilePic,
      required this.userName,
      required this.onConnect,
      required this.onTap,
      required this.isRequestSent,
      required this.isFriend,
      required this.isRequesting,
      this.onCancel,
      this.onMessage,
      this.onAccept});

  @override
  State<PersonCard> createState() => _PersonCardState();
}

class _PersonCardState extends State<PersonCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
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
                child: widget.profilePic != null
                    ? widget.profilePic!.isNotEmpty
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(widget.profilePic!),
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
              widget.userName,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(
              height: 10,
            ),
            StyledButton(
              textSize: 16,
              btnHeight: 40,
              btnColor: const Color(0xff00B0FF),
              noShadow: true,
              btnText: widget.isRequestSent
                  ? 'Cancel Request'
                  : (widget.isFriend
                      ? 'Message'
                      : (widget.isRequesting ? 'Accept' : 'Connect')),
              onClick: widget.isRequestSent
                  ? widget.onCancel
                  : (widget.isFriend
                      ? widget.onMessage
                      : (widget.isRequesting
                          ? widget.onAccept
                          : widget.onConnect)),
              btnIcon: widget.isFriend ? null : const Icon(Icons.person_add),
              borderRadius: widget.isFriend ? BorderRadius.circular(8) : null,
            ),
          ],
        ),
      ),
    );
  }
}
