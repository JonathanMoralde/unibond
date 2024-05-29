import 'package:flutter/material.dart';
import 'package:unibond/pages/Messages/Conversation.dart';
import 'package:unibond/widgets/Profile/InterestContainer.dart';
import 'package:unibond/widgets/styledButton.dart';

class ProfileView extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ProfileView({super.key, required this.userData});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    List<dynamic> dynamicList = widget.userData['interests'];
    List<String> interestList =
        dynamicList.map((item) => item.toString()).toList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffFF6814),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                      width:
                          120, // double the maxRadius to cover the entire CircleAvatar
                      height:
                          120, // double the maxRadius to cover the entire CircleAvatar
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.20), // Shadow color with opacity
                            spreadRadius: 0, // Spread radius
                            blurRadius: 3, // Blur radius
                            offset: const Offset(
                                0, 3), // Offset in x and y directions
                          ),
                        ],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xff00B0FF), // Border color
                          width: 2.0, // Border width
                        ),
                      ),
                      child: widget.userData['profile_pic'] != null &&
                              (widget.userData['profile_pic'] as String)
                                  .isNotEmpty
                          ? CircleAvatar(
                              backgroundImage:
                                  NetworkImage(widget.userData['profile_pic']),
                              maxRadius: 25,
                            )
                          : const CircleAvatar(
                              backgroundImage: AssetImage(
                                  'lib/assets/default_profile_pic.png'),
                              maxRadius: 25,
                            )),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userData['full_name'] ?? 'Loading...',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          widget.userData['bio'] ?? "Loading...",
                          style: TextStyle(fontSize: 12),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        )
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: StyledButton(
                      btnColor: Color(0xff00B0FF),
                      textColor: Colors.black,
                      noShadow: true,
                      isBorder: true,
                      borderColor: Colors.black,
                      btnHeight: 40,
                      textSize: 20,
                      btnText: 'Connect',
                      onClick: () {},
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: StyledButton(
                      btnColor: Colors.white,
                      textColor: Colors.black,
                      noShadow: true,
                      isBorder: true,
                      borderColor: Colors.black,
                      btnHeight: 40,
                      textSize: 20,
                      btnText: 'Message',
                      onClick: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const Conversation(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Interestcontainer(
                headerColor: const Color(0xff00B0FF),
                title:
                    '${widget.userData['full_name'].toString().split(' ')[0]}\'s',
                isDisplayOnly: true,
                options: interestList,
              ),
            ],
          ),
        ),
      )),
    );
  }
}
