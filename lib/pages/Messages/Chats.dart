import 'package:cloud_firestore/cloud_firestore.dart';
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

                return FutureBuilder<List<MessageData>>(
                    future: chatsModel.processMessageDocs(snapshot.data!.docs),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<MessageData>> chatsSnapshot) {
                      if (chatsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!chatsSnapshot.hasData ||
                          chatsSnapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('No chats available.'),
                        );
                      }

                      List<MessageData> chats = chatsSnapshot.data!;

                      return Column(
                        children: [
                          for (final chat in chats)
                            MessageCard(
                              isRead: chat.isRead,
                              onTap: () {
                                Provider.of<ConversationModel>(context,
                                        listen: false)
                                    .setChatDocId(chat.chatDocId);

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        Conversation(
                                      friendName: chat.userName,
                                      friendUid: chat.incomindId,
                                      friendProfilePic: chat.userProfPic,
                                    ),
                                  ),
                                );
                              },
                              userName: chat.userName,
                              latestMessage: chat.latestChatMsg,
                              latestUser: chat.latestChatUser,
                              latestTimestamp: chat.latestTimestamp,
                              profilePic: chat.userProfPic,
                              friendId: chat.incomindId,
                            )
                        ],
                      );
                    });
              }),
        );
      }),
    );
  }
}
