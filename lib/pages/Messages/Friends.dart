import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/Messages/ProfileView.dart';
import 'package:unibond/provider/ProfileModel.dart';
import 'package:unibond/widgets/Friends/PersonCard.dart';
import 'package:unibond/widgets/styledTextFormField.dart';

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();

    return Scaffold(
      body: Consumer<ProfileModel>(builder: (context, value, child) {
        final userDetails = value.userDetails;
        return SafeArea(
            child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                        width:
                            50, // double the maxRadius to cover the entire CircleAvatar
                        height:
                            50, // double the maxRadius to cover the entire CircleAvatar
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
                        child: userDetails['profile_pic'] != null &&
                                (userDetails['profile_pic'] as String)
                                    .isNotEmpty
                            ? CircleAvatar(
                                backgroundImage:
                                    NetworkImage(userDetails['profile_pic']),
                                maxRadius: 25,
                              )
                            : const CircleAvatar(
                                backgroundImage: AssetImage(
                                    'lib/assets/default_profile_pic.png'),
                                maxRadius: 25,
                              )),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: StyledTextFormField(
                        prefixIcon: Icons.search,
                        fillColor: const Color(0xffD9D9D9),
                        controller: searchController,
                        hintText: 'Search',
                        hintSize: 14,
                        obscureText: false,
                        paddingBottom: 0,
                        paddingTop: 0,
                        paddingLeft: 16,
                        paddingRight: 16,
                        height: 35,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                const Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Color(0xffFF8C36),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Uni-Friends you may know',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    )
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Wrap(
                  runSpacing: 16,
                  spacing: 16,
                  children: [
                    FractionallySizedBox(
                      widthFactor: 0.47,
                      child: PersonCard(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const ProfileView(),
                            ),
                          );
                        },
                        onConnect: () {},
                        userName: 'Melvin Sentido',
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: 0.47,
                      child: PersonCard(
                        onTap: () {},
                        onConnect: () {},
                        userName: 'Melvin Sentido',
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: 0.47,
                      child: PersonCard(
                        onTap: () {},
                        onConnect: () {},
                        userName: 'Melvin ASDASDASDASD ASDA SDD Sentido',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
      }),
    );
  }
}
