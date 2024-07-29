import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/Messages/Conversation.dart';
import 'package:unibond/provider/ConversationModel.dart';
import 'package:unibond/provider/FriendsModel.dart';
import 'package:unibond/provider/ProfileModel.dart';
import 'package:unibond/widgets/Profile/InterestContainer.dart';
import 'package:unibond/widgets/styledButton.dart';

class ProfileView extends StatefulWidget {
  final String uid;
  final String currentUserUid;
  final String currentUserFullName;
  final List<String> currentUserRequestsList;
  final List<String> currentUserFriendsList;

  const ProfileView(
      {super.key,
      required this.currentUserRequestsList,
      required this.currentUserUid,
      required this.currentUserFullName,
      required this.uid,
      required this.currentUserFriendsList});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffFF6814),
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (userSnapshot.hasError) {
              return Center(child: Text('Error: ${userSnapshot.error}'));
            }

            if (!userSnapshot.hasData && userSnapshot.data != null) {
              return const Center(child: Text('No user data'));
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            final requestsList = (userData['requests'] as List<dynamic>)
                .map((e) => e.toString())
                .toList();
            final friendsList = (userData['friends'] as List<dynamic>)
                .map((e) => e.toString())
                .toList();

            final interestList = (userData['interests'] as List<dynamic>)
                .map((e) => e.toString())
                .toList();

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
                            child: userData['profile_pic'] != null &&
                                    (userData['profile_pic'] as String)
                                        .isNotEmpty
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(userData['profile_pic']),
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
                                userData['full_name'] ?? 'Loading...',
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                userData['bio'] ?? "Loading...",
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
                        // IF CURRENT USER SENT A FRIEND REQUEST
                        if (requestsList.contains(widget.currentUserUid))
                          Expanded(
                            child: StyledButton(
                              btnColor: const Color(0xff00B0FF),
                              textColor: Colors.black,
                              noShadow: true,
                              isBorder: true,
                              borderColor: Colors.black,
                              btnHeight: 40,
                              textSize: 20,
                              btnText: 'Cancel Request',
                              btnIcon: const Icon(Icons.person_remove),
                              onClick: () async {
                                final friendsModel = Provider.of<FriendsModel>(
                                    context,
                                    listen: false);
                                friendsModel
                                    .cancelRequest(userData['uid'] ?? '')
                                    .then((_) {
                                  friendsModel.removeNotification(
                                      userData['uid'] ?? '');
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),

                        // IF CURRENT USER IS ALREADY FRIENDS WITH THIS USER
                        if (friendsList.contains(widget.currentUserUid))
                          Expanded(
                            child: StyledButton(
                              btnColor: const Color(0xff00B0FF),
                              textColor: Colors.black,
                              noShadow: true,
                              isBorder: true,
                              borderColor: Colors.black,
                              btnHeight: 40,
                              textSize: 20,
                              btnText: 'Disconnect',
                              btnIcon: const Icon(Icons.person_remove),
                              onClick: () async {
                                final friendsModel = Provider.of<FriendsModel>(
                                    context,
                                    listen: false);
                                friendsModel.removeFriend(userData['uid']);
                              },
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),

                        // IF THIS USER HAS SENT FRIEND REQUEST TO CURRENT USER
                        if (widget.currentUserRequestsList
                            .contains(userData['uid'] ?? ''))
                          Expanded(
                            child: StyledButton(
                              btnColor: const Color(0xff00B0FF),
                              textColor: Colors.black,
                              noShadow: true,
                              isBorder: true,
                              borderColor: Colors.black,
                              btnHeight: 40,
                              textSize: 20,
                              btnText: 'Accept Request',
                              btnIcon: const Icon(Icons.person_add),
                              onClick: () async {
                                final friendsModel = Provider.of<FriendsModel>(
                                    context,
                                    listen: false);
                                friendsModel
                                    .cancelRequest(userData['uid'] ?? '')
                                    .then((_) {
                                  friendsModel.removeNotification(
                                      userData['uid'] ?? '');
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),

                        // CONNECT WITH THIS USER
                        if (!requestsList.contains(widget.currentUserUid) &&
                            !friendsList.contains(widget.currentUserUid) &&
                            !widget.currentUserRequestsList
                                .contains(userData['uid'] ?? ''))
                          Expanded(
                            child: StyledButton(
                              btnColor: const Color(0xff00B0FF),
                              textColor: Colors.black,
                              noShadow: true,
                              isBorder: true,
                              borderColor: Colors.black,
                              btnHeight: 40,
                              textSize: 20,
                              btnText: 'Connect',
                              btnIcon: const Icon(Icons.person_add),
                              onClick: () async {
                                final friendsModel = Provider.of<FriendsModel>(
                                    context,
                                    listen: false);
                                friendsModel
                                    .addFriend(userData['uid'])
                                    .then((_) {
                                  friendsModel.addFriendNofitication(
                                      widget.currentUserUid,
                                      widget.currentUserFullName,
                                      userData['uid']);
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        const SizedBox(
                          width: 10,
                        ),
                        StreamBuilder<QuerySnapshot>(
                            stream: Provider.of<ConversationModel>(context,
                                    listen: false)
                                .fetchDoc(userData['uid']),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              String? chatDocumentId;

                              if (snapshot.hasData &&
                                  snapshot.data!.docs.isNotEmpty) {
                                chatDocumentId = snapshot.data!.docs.first.id;
                              }

                              print('chat doc id: $chatDocumentId');
                              return Expanded(
                                child: StyledButton(
                                  btnColor: Colors.white,
                                  textColor: Colors.black,
                                  noShadow: true,
                                  isBorder: true,
                                  borderColor: Colors.black,
                                  btnHeight: 40,
                                  textSize: 20,
                                  btnText: 'Message',
                                  btnIcon: const Icon(Icons.chat_bubble),
                                  onClick: widget.currentUserFriendsList
                                          .contains(userData['uid'])
                                      ? () {
                                          Provider.of<ConversationModel>(
                                                  context,
                                                  listen: false)
                                              .setChatDocId(chatDocumentId);
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  Conversation(
                                                friendName:
                                                    userData['full_name'],
                                                friendProfilePic:
                                                    userData['profile_pic'],
                                                friendUid: userData['uid'],
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              );
                            }),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Interestcontainer(
                      headerColor: const Color(0xff00B0FF),
                      title:
                          '${userData['full_name'].toString().split(' ')[0]}\'s',
                      isDisplayOnly: true,
                      options: interestList,
                    ),
                  ],
                ),
              ),
            ));
          }),
    );
  }
}
