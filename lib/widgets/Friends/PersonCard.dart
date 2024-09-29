import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/Messages/Conversation.dart';
import 'package:unibond/provider/ConversationModel.dart';
import 'package:unibond/provider/FriendsModel.dart';
import 'package:unibond/provider/ProfileModel.dart';
import 'package:unibond/widgets/styledButton.dart';

class PersonCard extends StatefulWidget {
  final String uid;
  final List<String> currentUserRequestsList;
  final String currentUserUid;
  final String currentUserFullName;
  final Function()? onTap;
  const PersonCard({
    super.key,
    required this.uid,
    required this.currentUserRequestsList,
    required this.currentUserUid,
    required this.currentUserFullName,
    required this.onTap,
  });

  @override
  State<PersonCard> createState() => _PersonCardState();
}

class _PersonCardState extends State<PersonCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFBBBBBB)),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(35),
                    ),
                  ),
                  child: const Column(
                    children: [
                      CircularProgressIndicator(),
                    ],
                  ));
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

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                border: Border.all(color: const Color(0xFFBBBBBB)),
                borderRadius: const BorderRadius.all(
                  Radius.circular(35),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                      child: userData['profile_pic'] != null
                          ? (userData['profile_pic'] as String).isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(userData['profile_pic']!),
                                  maxRadius: 50,
                                )
                              : const CircleAvatar(
                                  backgroundImage: AssetImage(
                                      'lib/assets/default_profile_pic.png'),
                                  maxRadius: 50,
                                )
                          : const CircleAvatar(
                              backgroundImage: AssetImage(
                                  'lib/assets/default_profile_pic.png'),
                              maxRadius: 50,
                            )),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    userData['full_name'] ?? 'Loading',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // IF CURRENT USER SENT A FRIEND REQUEST
                  if (requestsList.contains(widget.currentUserUid))
                    StyledButton(
                      textSize: 16,
                      btnHeight: 40,
                      btnColor: const Color(0xff00B0FF),
                      noShadow: true,
                      btnText: 'Cancel Request',
                      onClick: () async {
                        final friendsModel =
                            Provider.of<FriendsModel>(context, listen: false);
                        friendsModel
                            .cancelRequest(userData['uid'] ?? '')
                            .then((_) {
                          friendsModel
                              .removeNotification(userData['uid'] ?? '');
                        });
                      },
                      btnIcon: friendsList.contains(widget.currentUserUid)
                          ? null
                          : const Icon(Icons.person_add),
                      borderRadius: friendsList.contains(widget.currentUserUid)
                          ? BorderRadius.circular(8)
                          : null,
                    ),

                  // IF CURRENT USER IS ALREADY FRIENDS WITH THIS USER
                  if (friendsList.contains(widget.currentUserUid))
                    StreamBuilder<QuerySnapshot>(
                        stream: Provider.of<ConversationModel>(context,
                                listen: false)
                            .fetchDoc(userData['uid'] ?? ''),
                        builder: (context, chatSnapshot) {
                          String? chatDocumentId;

                          if (chatSnapshot.hasData &&
                              chatSnapshot.data!.docs.isNotEmpty) {
                            chatDocumentId = chatSnapshot.data!.docs.first.id;
                          }

                          return StyledButton(
                            textSize: 16,
                            btnHeight: 40,
                            btnColor: const Color(0xff00B0FF),
                            noShadow: true,
                            btnText: 'Message',
                            onClick: () async {
                              Provider.of<ConversationModel>(context,
                                      listen: false)
                                  .setChatDocId(chatDocumentId);

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      Conversation(
                                    friendName: userData['full_name'] ?? '',
                                    friendProfilePic:
                                        userData['profile_pic'] ?? '',
                                    friendUid: userData['uid'] ?? '',
                                  ),
                                ),
                              );
                            },
                            btnIcon: friendsList.contains(widget.currentUserUid)
                                ? null
                                : const Icon(Icons.person_add),
                            borderRadius:
                                friendsList.contains(widget.currentUserUid)
                                    ? BorderRadius.circular(8)
                                    : null,
                          );
                        }),

                  // IF THIS USER HAS SENT FRIEND REQUEST TO CURRENT USER
                  if (widget.currentUserRequestsList
                      .contains(userData['uid'] ?? ''))
                    StyledButton(
                      textSize: 16,
                      btnHeight: 40,
                      btnColor: const Color(0xff00B0FF),
                      noShadow: true,
                      btnText: 'Accept Request',
                      onClick: () async {
                        final friendsModel =
                            Provider.of<FriendsModel>(context, listen: false);
                        friendsModel
                            .confirmRequest(userData['uid'] ?? '')
                            .then((_) {
                          friendsModel.confirmFriendNofitication(
                              widget.currentUserUid,
                              widget.currentUserFullName,
                              (userData['uid'] ?? ''));
                        });
                      },
                      btnIcon: friendsList.contains(widget.currentUserUid)
                          ? null
                          : const Icon(Icons.person_add),
                      borderRadius: friendsList.contains(widget.currentUserUid)
                          ? BorderRadius.circular(8)
                          : null,
                    ),

                  // CONNECT WITH THIS USER
                  if (!requestsList.contains(widget.currentUserUid) &&
                      !friendsList.contains(widget.currentUserUid) &&
                      !widget.currentUserRequestsList
                          .contains(userData['uid'] ?? ''))
                    StyledButton(
                      textSize: 16,
                      btnHeight: 40,
                      btnColor: const Color(0xff00B0FF),
                      noShadow: true,
                      btnText: 'Connect',
                      onClick: () async {
                        final friendsModel =
                            Provider.of<FriendsModel>(context, listen: false);
                        friendsModel.addFriend(userData['uid']).then((_) {
                          friendsModel.addFriendNofitication(
                              widget.currentUserUid,
                              widget.currentUserFullName,
                              userData['uid']);
                        });
                      },
                      btnIcon: friendsList.contains(widget.currentUserUid)
                          ? null
                          : const Icon(Icons.person_add),
                      borderRadius: friendsList.contains(widget.currentUserUid)
                          ? BorderRadius.circular(8)
                          : null,
                    ),

                  // StyledButton(
                  //   textSize: 16,
                  //   btnHeight: 40,
                  //   btnColor: const Color(0xff00B0FF),
                  //   noShadow: true,
                  //   btnText: widget.isRequestSent
                  //       ? 'Cancel Request'
                  //       : (widget.isFriend
                  //           ? 'Message'
                  //           : (widget.isRequesting ? 'Accept' : 'Connect')),
                  //   onClick: widget.isRequestSent
                  //       ? widget.onCancel
                  //       : (widget.isFriend
                  //           ? widget.onMessage
                  //           : (widget.isRequesting
                  //               ? widget.onAccept
                  //               : widget.onConnect)),
                  //   btnIcon:
                  //       widget.isFriend ? null : const Icon(Icons.person_add),
                  //   borderRadius:
                  //       widget.isFriend ? BorderRadius.circular(8) : null,
                  // ),
                ],
              ),
            );
          }),
    );
  }
}
