import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/Messages/Conversation.dart';
import 'package:unibond/pages/Messages/ProfileView.dart';
import 'package:unibond/provider/ConversationModel.dart';
import 'package:unibond/provider/FriendsModel.dart';
import 'package:unibond/provider/ProfileModel.dart';
import 'package:unibond/widgets/Friends/FriendRequestCard.dart';
import 'package:unibond/widgets/Friends/PersonCard.dart';
import 'package:unibond/widgets/styledButton.dart';
import 'package:unibond/widgets/styledTextFormField.dart';

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
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
                            friendsModel.resetState();
                            friendsModel.changeDisplay('requests');
                            friendsModel.fetchRequestUserDetails();
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
                            friendsModel.resetState();
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
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Color(0xffFF8C36),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  if (friendsModel.activeDisplay == 'suggestion')
                    Text(
                      'Uni-Friends you may know',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  if (friendsModel.activeDisplay == 'friends')
                    Text(
                      'All Uni-Friends',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  if (friendsModel.activeDisplay == 'requests')
                    Text(
                      'Uni-Friend Requests',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            if (friendsModel.activeDisplay == 'suggestion')
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                          friendsModel.viewProfile(
                              friendsModel.friendSuggestions[index]);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) => ProfileView(
                                  // userData: friendsModel.friendSuggestions[index],
                                  ),
                            ),
                          );
                        },
                        isRequestSent: (friendsModel.friendSuggestions[index]
                                    ['requests'] as List<dynamic>)
                                .map((e) => e.toString())
                                .toList()
                                .contains(profileModel.userDetails['uid']) ||
                            friendsModel.requestsList.contains(
                                friendsModel.friendSuggestions[index]['uid']),
                        isFriend: false,
                        isRequesting: (profileModel.userDetails['requests']
                                as List<dynamic>)
                            .map((e) => e.toString())
                            .toList()
                            .contains(
                                friendsModel.friendSuggestions[index]['uid']),
                        onCancel: () async {
                          friendsModel
                              .cancelRequest(
                                  friendsModel.friendSuggestions[index]['uid'])
                              .then((_) {
                            friendsModel.removeNotification(
                                friendsModel.friendSuggestions[index]['uid']);
                          });
                        },
                        onConnect: () async {
                          friendsModel
                              .addFriend(
                                  friendsModel.friendSuggestions[index]['uid'])
                              .then((_) {
                            friendsModel.addFriendNofitication(
                                profileModel.userDetails['uid'],
                                profileModel.userDetails['full_name'],
                                friendsModel.friendSuggestions[index]['uid']);
                          });
                        },
                        onAccept: () async {
                          friendsModel
                              .confirmRequest(
                                  friendsModel.friendSuggestions[index]['uid'])
                              .then((_) {
                            friendsModel.confirmFriendNofitication(
                                profileModel.userDetails['uid'],
                                profileModel.userDetails['full_name'],
                                friendsModel.friendSuggestions[index]['uid']);
                          });
                        },
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
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: friendsModel.friendsList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final friends = friendsModel.friendsList[index];
                    return StreamBuilder<QuerySnapshot>(
                      stream:
                          Provider.of<ConversationModel>(context, listen: false)
                              .fetchDoc(friends['uid']),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        String? chatDocumentId;

                        if (snapshot.hasData &&
                            snapshot.data!.docs.isNotEmpty) {
                          chatDocumentId = snapshot.data!.docs.first.id;
                        }

                        print('chat doc id: $chatDocumentId');
                        return PersonCard(
                          onTap: () {
                            friendsModel.viewProfile(friends);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) => ProfileView(
                                    // userData: friends,
                                    ),
                              ),
                            );
                          },
                          isRequestSent: false,
                          isRequesting: false,
                          isFriend: true,
                          onMessage: () async {
                            Provider.of<ConversationModel>(context,
                                    listen: false)
                                .setChatDocId(chatDocumentId);

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) => Conversation(
                                  friendName: friends['full_name'],
                                  friendProfilePic: friends['profile_pic'],
                                  friendUid: friends['uid'],
                                ),
                              ),
                            );
                          },
                          onConnect: () async {},
                          userName: friends['full_name'],
                          profilePic: friends['profile_pic'],
                        );
                      },
                    );
                  },
                ),
              ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: SingleChildScrollView(
            //     child: Wrap(
            //       runSpacing: 16,
            //       spacing: 16,
            //       children: [
            //         for (final friends in friendsModel.friendsList)
            //           FractionallySizedBox(
            //             widthFactor: 0.47,
            //             child: StreamBuilder<QuerySnapshot>(
            //                 stream: Provider.of<ConversationModel>(context,
            //                         listen: false)
            //                     .fetchDoc(friends['uid']),
            //                 builder: (BuildContext context,
            //                     AsyncSnapshot<QuerySnapshot> snapshot) {
            //                   String? chatDocumentId;

            //                   if (snapshot.hasData &&
            //                       snapshot.data!.docs.isNotEmpty) {
            //                     chatDocumentId = snapshot.data!.docs.first.id;
            //                   }

            //                   print('chat doc id: $chatDocumentId');
            //                   return PersonCard(
            //                     onTap: () {
            //                       friendsModel.viewProfile(friends);
            //                       Navigator.of(context).push(
            //                         MaterialPageRoute(
            //                           builder: (BuildContext context) =>
            //                               ProfileView(
            //                                   // userData: friends,
            //                                   ),
            //                         ),
            //                       );
            //                     },
            //                     isRequestSent: false,
            //                     isRequesting: false,
            //                     isFriend: true,
            //                     onMessage: () async {
            //                       Provider.of<ConversationModel>(context,
            //                               listen: false)
            //                           .setChatDocId(chatDocumentId);

            //                       Navigator.of(context).push(
            //                         MaterialPageRoute(
            //                           builder: (BuildContext context) =>
            //                               Conversation(
            //                             friendName: friends['full_name'],
            //                             friendProfilePic:
            //                                 friends['profile_pic'],
            //                             friendUid: friends['uid'],
            //                           ),
            //                         ),
            //                       );
            //                     },
            //                     onConnect: () async {},
            //                     userName: friends['full_name'],
            //                     profilePic: friends['profile_pic'],
            //                   );
            //                 }),
            //           ),
            //       ],
            //     ),
            //   ),
            // ),
            if (friendsModel.activeDisplay == 'requests')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    for (final user in friendsModel.requestsDataList)
                      FriendRequestCard(
                        uid: user['uid'],
                        profilePic: user['profile_pic'],
                        fullName: user['full_name'],
                        onAccept: () {
                          friendsModel.confirmRequest(user['uid']);
                        },
                        onDeclince: () {
                          friendsModel.declineRequest(user['uid']);
                        },
                        onTap: () {
                          friendsModel.viewProfile(user);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) => ProfileView(
                                  // userData: user
                                  ),
                            ),
                          );
                        },
                      )
                  ],
                ),
              )
          ],
        ));
      }),
    );
  }
}
