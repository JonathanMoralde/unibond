import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/Messages/ProfileView.dart';
import 'package:unibond/provider/FriendsModel.dart';
import 'package:unibond/provider/ProfileModel.dart';
import 'package:unibond/widgets/Friends/PersonCard.dart';
import 'package:unibond/widgets/styledButton.dart';
import 'package:unibond/widgets/styledTextFormField.dart';

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final searchController = TextEditingController();
  final scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        // Fetch more data when the user scrolls to the bottom
        Provider.of<FriendsModel>(context, listen: false)
            .fetchFriendSuggestions(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<ProfileModel, FriendsModel>(
          builder: (context, profileModel, friendsModel, child) {
        final userDetails = profileModel.userDetails;

        // print(friendsModel.friendSuggestions);
        // print(friendsModel.friendsList);
        return SafeArea(
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      StyledButton(
                        btnText: 'Suggestion',
                        onClick: () {
                          if (friendsModel.activeDisplay != 'suggestion') {
                            friendsModel.resetState();
                            friendsModel.changeDisplay('suggestion');
                            friendsModel.fetchFriendSuggestions();
                          }
                        },
                        btnColor: friendsModel.activeDisplay == 'suggestion'
                            ? Colors.white
                            : null,
                        isBorder: friendsModel.activeDisplay == 'suggestion'
                            ? true
                            : null,
                        textColor: friendsModel.activeDisplay == 'suggestion'
                            ? const Color(0xff00B0FF)
                            : null,
                        btnHeight: 35,
                        textSize: 14,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      StyledButton(
                        btnText: 'Friend Requests',
                        onClick: () {
                          if (friendsModel.activeDisplay != 'requests') {
                            friendsModel.changeDisplay('requests');
                          }
                        },
                        btnColor: friendsModel.activeDisplay == 'requests'
                            ? Colors.white
                            : null,
                        isBorder: friendsModel.activeDisplay == 'requests'
                            ? true
                            : null,
                        textColor: friendsModel.activeDisplay == 'requests'
                            ? const Color(0xff00B0FF)
                            : null,
                        btnHeight: 35,
                        textSize: 14,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      StyledButton(
                        btnText: 'Friends ',
                        onClick: () async {
                          if (friendsModel.activeDisplay != 'friends') {
                            friendsModel.changeDisplay('friends');
                            friendsModel.fetchFriendsList();
                          }
                        },
                        btnColor: friendsModel.activeDisplay == 'friends'
                            ? Colors.white
                            : null,
                        isBorder: friendsModel.activeDisplay == 'friends'
                            ? true
                            : null,
                        textColor: friendsModel.activeDisplay == 'friends'
                            ? const Color(0xff00B0FF)
                            : null,
                        btnHeight: 35,
                        textSize: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Row(
            //   children: [
            //     Container(
            //         width:
            //             50, // double the maxRadius to cover the entire CircleAvatar
            //         height:
            //             50, // double the maxRadius to cover the entire CircleAvatar
            //         decoration: BoxDecoration(
            //           boxShadow: [
            //             BoxShadow(
            //               color: Colors.black
            //                   .withOpacity(0.20), // Shadow color with opacity
            //               spreadRadius: 0, // Spread radius
            //               blurRadius: 3, // Blur radius
            //               offset: const Offset(
            //                   0, 3), // Offset in x and y directions
            //             ),
            //           ],
            //           shape: BoxShape.circle,
            //           border: Border.all(
            //             color: const Color(0xff00B0FF), // Border color
            //             width: 2.0, // Border width
            //           ),
            //         ),
            //         child: userDetails['profile_pic'] != null &&
            //                 (userDetails['profile_pic'] as String).isNotEmpty
            //             ? CircleAvatar(
            //                 backgroundImage:
            //                     NetworkImage(userDetails['profile_pic']),
            //                 maxRadius: 25,
            //               )
            //             : const CircleAvatar(
            //                 backgroundImage: AssetImage(
            //                     'lib/assets/default_profile_pic.png'),
            //                 maxRadius: 25,
            //               )),
            //     const SizedBox(
            //       width: 10,
            //     ),
            //     Expanded(
            //       child: StyledTextFormField(
            //         prefixIcon: Icons.search,
            //         fillColor: const Color(0xffD9D9D9),
            //         controller: searchController,
            //         hintText: 'Search',
            //         hintSize: 14,
            //         obscureText: false,
            //         paddingBottom: 0,
            //         paddingTop: 0,
            //         paddingLeft: 16,
            //         paddingRight: 16,
            //         height: 35,
            //       ),
            //     )
            //   ],
            // ),
            const SizedBox(
              height: 20,
            ),
            if (friendsModel.activeDisplay == 'suggestion')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const Row(
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
              ),
            const SizedBox(
              height: 20,
            ),
            if (friendsModel.activeDisplay == 'suggestion')
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: friendsModel.friendSuggestions.length +
                      (friendsModel.hasMoreData ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < friendsModel.friendSuggestions.length) {
                      return PersonCard(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) => ProfileView(
                                userData: friendsModel.friendSuggestions[index],
                              ),
                            ),
                          );
                        },
                        onConnect: () {},
                        userName: friendsModel.friendSuggestions[index]
                            ['full_name'],
                        profilePic: friendsModel.friendSuggestions[index]
                            ['profile_pic'],
                      );
                    } else if (friendsModel.hasMoreData) {
                      // Show a loading indicator if there is more data to fetch
                      return Center(child: CircularProgressIndicator());
                    } else {
                      // No more data to fetch
                      return SizedBox.shrink();
                    }
                  },
                ),
              ),

            if (friendsModel.activeDisplay == 'friends')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  runSpacing: 16,
                  spacing: 16,
                  children: [
                    for (final friends in friendsModel.friendsList)
                      FractionallySizedBox(
                        widthFactor: 0.47,
                        child: PersonCard(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) => ProfileView(
                                  userData: friends,
                                ),
                              ),
                            );
                          },
                          onConnect: () {},
                          userName: friends['full_name'],
                          profilePic: friends['profile_pic'],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ));
      }),
    );
  }
}
