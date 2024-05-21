//preconfigured with pageObject.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/Login/Login.dart';
import 'package:unibond/provider/AuthModel.dart';
import 'package:unibond/provider/NavigationModel.dart';
import 'package:unibond/provider/ProfileModel.dart';
import 'package:unibond/widgets/drawer/pageObject.dart';

class SideMenu extends StatelessWidget {
  final List<SideMenuPage> pages;

  const SideMenu({
    super.key,
    required this.pages,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthModel, ProfileModel, NavigationModel>(
        builder: (context, authModel, profileModel, navigationModel, child) {
      final userDetails = profileModel.userDetails;
      return Drawer(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: <Widget>[
            // HEADER
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50),
              child: Row(
                children: [
                  Container(
                      width:
                          90, // double the maxRadius to cover the entire CircleAvatar
                      height:
                          90, // double the maxRadius to cover the entire CircleAvatar
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
                      child: userDetails['profile_pic'] != null
                          ? CircleAvatar(
                              backgroundImage:
                                  NetworkImage(userDetails['profile_pic']),
                              maxRadius: 45,
                            )
                          : const CircleAvatar(
                              backgroundImage: AssetImage(
                                  'lib/assets/default_profile_pic.png'),
                              maxRadius: 45,
                            )),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userDetails['full_name'] ?? 'Loading...',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            navigationModel.changeIndex(4);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'View Profile',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // DYNAMIC PAGES
            ...pages.map((page) {
              return ListTile(
                contentPadding: EdgeInsets.only(left: 24),
                iconColor: const Color(0xff252525),
                leading: page.icon,
                title: Text(
                  page.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                onTap: () async {
                  int newIndex = pages.indexOf(page);
                  navigationModel.changeIndex(newIndex);
                  Navigator.pop(context);
                },
                minLeadingWidth: 0,
              );
            }).toList(),

            // LOGOUT
            ListTile(
              contentPadding: const EdgeInsets.only(left: 24),
              iconColor: const Color(0xff252525),
              leading: const Icon(Icons.exit_to_app),
              title: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onTap: () {
                authModel.signOut().then((_) {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (BuildContext context) => const Login()),
                      (route) => false);
                });
              },
              minLeadingWidth: 0,
            ),
          ],
        ),
      );
    });
  }
}
