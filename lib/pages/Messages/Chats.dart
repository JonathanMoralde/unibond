import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/model/MessageData.dart';
import 'package:unibond/pages/Messages/Conversation.dart';
import 'package:unibond/provider/ChatsModel.dart';
import 'package:unibond/provider/ConversationModel.dart';
import 'package:unibond/widgets/Chat/MessageCard.dart';

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<ChatsModel>(builder: (context, chatsModel, child) {
        return SingleChildScrollView(
          child: StreamBuilder<QuerySnapshot>(
              stream: chatsModel.fetchMessages(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No chats available.'),
                  );
                }

                //   List<MessageCardModel> msgs = [];

                //   if (snapshot.data != null) {
                //   msgs = snapshot.data!.docs.map((messageDoc) {
                //     return MessageCardModel(
                //       chatDocId: messageDoc.id,
                //       compositeId: messageDoc['composite_id'],
                //       latestChatMsg: messageDoc['latest_chat_message'],
                //       latestChatUser: messageDoc['latest_chat_user'],
                //       latestTimestamp: messageDoc['latest_timestamp'],
                //       usersId: messageDoc['users_id'],
                //     );
                //   }).toList();
                // }

                return Column(
                  children: [
                    for (final doc in snapshot.data!.docs)
                      StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(((doc.data()
                                          as Map<String, dynamic>)['users_id']
                                      as List<dynamic>)
                                  .map((item) => item.toString())
                                  .toList()
                                  .firstWhere((id) =>
                                      id !=
                                      FirebaseAuth.instance.currentUser!.uid))
                              .snapshots(),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (!userSnapshot.hasData ||
                                !userSnapshot.data!.exists) {
                              return const Center(
                                child: Text('User data not available.'),
                              );
                            }
                            return MessageCard(
                              isRead: (doc.data()
                                  as Map<String, dynamic>)['latest_chat_read'],
                              onTap: () async {
                                Provider.of<ConversationModel>(context,
                                        listen: false)
                                    .setChatDocId(doc.id);

                                try {
                                  await FirebaseFirestore.instance
                                      .collection('chats')
                                      .doc(doc.id)
                                      .update({'latest_chat_read': true});
                                } catch (e) {
                                  print(e);
                                }

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        Conversation(
                                      friendName: ((userSnapshot.data?.data()
                                                  as Map<String, dynamic>)[
                                              'full_name']) ??
                                          'Loading...',
                                      friendUid: ((userSnapshot.data?.data()
                                                  as Map<String, dynamic>)[
                                              'uid']) ??
                                          '',
                                      friendProfilePic:
                                          ((userSnapshot.data?.data() as Map<
                                                  String,
                                                  dynamic>)['profile_pic']) ??
                                              null,
                                    ),
                                  ),
                                );
                              },
                              userName: ((userSnapshot.data?.data()
                                      as Map<String, dynamic>)['full_name']) ??
                                  'Loading...',
                              latestMessage: (doc.data() as Map<String,
                                  dynamic>)['latest_chat_message'],
                              latestUser: (doc.data()
                                  as Map<String, dynamic>)['latest_chat_user'],
                              latestTimestamp: (doc.data()
                                  as Map<String, dynamic>)['latest_timestamp'],
                              profilePic: ((userSnapshot.data?.data() as Map<
                                      String, dynamic>)['profile_pic']) ??
                                  'null',
                              friendId: ((userSnapshot.data?.data()
                                      as Map<String, dynamic>)['uid']) ??
                                  'Loading...',
                            );
                          })
                  ],
                );

                // return FutureBuilder<List<MessageData>>(
                //     future: chatsModel.processMessageDocs(snapshot.data!.docs),
                //     builder: (BuildContext context,
                //         AsyncSnapshot<List<MessageData>> chatsSnapshot) {
                //       if (chatsSnapshot.connectionState ==
                //           ConnectionState.waiting) {
                //         return const Center(child: CircularProgressIndicator());
                //       }

                //       if (!chatsSnapshot.hasData ||
                //           chatsSnapshot.data!.isEmpty) {
                //         return const Center(
                //           child: Text('No chats available.'),
                //         );
                //       }

                //       List<MessageData> chats = chatsSnapshot.data!;

                //       return Column(
                //         children: [
                //           for (final chat in chats)
                //             MessageCard(
                //               isRead: chat.isRead,
                //               onTap: () {
                //                 Provider.of<ConversationModel>(context,
                //                         listen: false)
                //                     .setChatDocId(chat.chatDocId);

                //                 Navigator.of(context).push(
                //                   MaterialPageRoute(
                //                     builder: (BuildContext context) =>
                //                         Conversation(
                //                       friendName: chat.userName,
                //                       friendUid: chat.incomindId,
                //                       friendProfilePic: chat.userProfPic,
                //                     ),
                //                   ),
                //                 );
                //               },
                //               userName: chat.userName,
                //               latestMessage: chat.latestChatMsg,
                //               latestUser: chat.latestChatUser,
                //               latestTimestamp: chat.latestTimestamp,
                //               profilePic: chat.userProfPic,
                //               friendId: chat.incomindId,
                //             )
                //         ],
                //       );
                //     });
              }),
        );
      }),
    );
  }
}
