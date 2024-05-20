import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/MyProfile/EditProfile.dart';
import 'package:unibond/provider/AuthModel.dart';
import 'package:unibond/provider/ProfileModel.dart';
import 'package:unibond/widgets/Profile/InterestContainer.dart';
import 'package:unibond/widgets/drawer/pageObject.dart';
import 'package:unibond/widgets/drawer/sideMenu.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text(
      //     'My Profile',
      //     style: TextStyle(fontWeight: FontWeight.bold),
      //   ),
      // ),
      body: Consumer2<ProfileModel, AuthModel>(
          builder: (context, profileModel, authModel, child) {
        final userDetails = profileModel.userDetails;

        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
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
                                color: Colors.black.withOpacity(
                                    0.20), // Shadow color with opacity
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
                          child: userDetails['profile_pic'] != null
                              ? CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(userDetails['profile_pic']),
                                  maxRadius: 60,
                                )
                              : const CircleAvatar(
                                  backgroundImage: AssetImage(
                                      'lib/assets/default_profile_pic.png'),
                                  maxRadius: 60,
                                )),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userDetails['full_name'] ?? 'Loading...',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        const EditProfile(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Edit Profile',
                                style: TextStyle(color: Color(0xffFF5B00)),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              userDetails['bio'] ?? 'Loading...',
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
                    height: 30,
                  ),
                  Interestcontainer(
                    title: "My",
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      drawer: SideMenu(pages: pages),
    );
  }
}
