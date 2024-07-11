import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/Messages/Conversation.dart';
import 'package:unibond/pages/Messages/ProfileView.dart';
import 'package:unibond/provider/ConversationModel.dart';
import 'package:unibond/provider/FriendsModel.dart';
import 'package:unibond/provider/NavigationModel.dart';
import 'package:unibond/provider/ProfileModel.dart';
import 'package:unibond/widgets/Chat/MessageCard.dart';
import 'package:unibond/widgets/Friends/PersonCard.dart';
import 'package:unibond/widgets/Group/GroupCard.dart';
import 'package:unibond/widgets/styledButton.dart';
import 'package:unibond/widgets/styledTextFormField.dart';

class SearchPage extends StatefulWidget {
  final int initialIndex;
  const SearchPage({super.key, required this.initialIndex});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final searchController = TextEditingController();
  String searchText = '';
  bool isLoading = false;

  late TabController? _tabController;

  String initialDisplay = 'Search Unibond';

  @override
  void initState() {
    super.initState();
    // Initialize the TabController with the initial length and vsync
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.initialIndex);

    _tabController?.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    // if (_tabController?.index == 2) {
    //   print('friends');
    // }
    switch (_tabController!.index) {
      case 0:
        setState(() {
          initialDisplay = 'Search Messages';
        });
        break;
      case 1:
        setState(() {
          initialDisplay = 'Search other group chats';
        });
        break;
      case 2:
        final friendsModel = Provider.of<FriendsModel>(context, listen: false);

        if (friendsModel.activeDisplay == 'suggestion') {
          setState(() {
            initialDisplay = 'Search Unibond';
          });
        } else if (friendsModel.activeDisplay == 'requests') {
          setState(() {
            initialDisplay = 'Search requests';
          });
        } else {
          setState(() {
            initialDisplay = 'Search Uni-Friends';
          });
        }

        break;
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationModel>(
        builder: (context, navigationModel, child) {
      return Scaffold(
        appBar: AppBar(
          title: StyledTextFormField(
            height: 40,
            paddingBottom: 0,
            paddingTop: 0,
            paddingLeft: 16,
            paddingRight: 16,
            controller: searchController,
            hintText: 'Search Unibond',
            obscureText: false,
            onChanged: (val) {
              setState(() {
                searchText = val;
              });
            },
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              color: Color(0xffFC852B),
              child: TabBar(
                unselectedLabelColor: Colors.white,
                labelColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.tab,
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Chats'),
                  Tab(text: 'Groups'),
                  Tab(text: 'Friends'),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          child: Column(
            children: [
              if (searchText.isNotEmpty &&
                  _tabController != null &&
                  _tabController!.index == 0)
                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .where('full_name_lowercase',
                          isGreaterThanOrEqualTo: searchText.toLowerCase())
                      .where('full_name_lowercase',
                          isLessThan: searchText.toLowerCase() + 'z')
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      print(snapshot.data!.docs);
                      print(snapshot.data!.docs.first.data()['uid']);

                      List<Widget> userWidgets = [];
                      for (final doc in snapshot.data!.docs) {
                        userWidgets.add(
                          FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection('chats')
                                .where('users_id',
                                    arrayContains: doc.data()['uid'])
                                .get(),
                            builder: (context, chatSnapshot) {
                              if (chatSnapshot.hasData &&
                                  chatSnapshot.data!.docs.isNotEmpty) {
                                print('chat snapshot');
                                print(chatSnapshot.data!.docs);

                                List<Widget> chatWidgets = [];
                                for (final chatDoc in chatSnapshot.data!.docs) {
                                  bool isRead = false;

                                  final latestMessageQuery = FirebaseFirestore
                                      .instance
                                      .collection('chats')
                                      .doc(chatDoc.id)
                                      .collection('messages')
                                      .where('sender_id',
                                          isNotEqualTo:
                                              Provider.of<ProfileModel>(context,
                                                      listen: false)
                                                  .userDetails['uid'])
                                      .orderBy('timestamp', descending: true)
                                      .limit(1)
                                      .get();

                                  latestMessageQuery.then((_) {
                                    if (_.docs.isNotEmpty) {
                                      final latestMessageData =
                                          _.docs.first.data();
                                      isRead =
                                          latestMessageData['is_read'] ?? false;
                                    }
                                  });

                                  chatWidgets.add(
                                    MessageCard(
                                      isRead: isRead,
                                      onTap: () {
                                        Provider.of<ConversationModel>(context,
                                                listen: false)
                                            .setChatDocId(chatDoc.id);

                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                Conversation(
                                              friendName:
                                                  doc.data()['full_name'],
                                              friendUid: doc.data()['uid'],
                                              friendProfilePic:
                                                  doc.data()['profile_pic'],
                                            ),
                                          ),
                                        );
                                      },
                                      userName: doc.data()['full_name'],
                                      latestMessage:
                                          chatDoc['latest_chat_message'],
                                      latestUser: chatDoc['latest_chat_user'],
                                      latestTimestamp:
                                          chatDoc['latest_timestamp'],
                                      profilePic: doc.data()['profile_pic'],
                                      friendId: doc.data()['uid'],
                                    ),
                                  );
                                }
                                return Column(children: chatWidgets);
                              }

                              return SizedBox.shrink();
                            },
                          ),
                        );
                      }
                      return Column(children: userWidgets);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              if (searchText.isNotEmpty &&
                  _tabController != null &&
                  _tabController!.index == 1)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Expanded(
                    child: FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('groups')
                          .where('group_name_lowercase',
                              isGreaterThanOrEqualTo: searchText.toLowerCase())
                          .where('group_name_lowercase',
                              isLessThan: searchText.toLowerCase() + 'z')
                          .get(),
                      builder: (context, groupSnapshot) {
                        if (groupSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (groupSnapshot.hasData &&
                            groupSnapshot.data!.docs.isNotEmpty) {
                          List<Widget> groups = [];
                          for (final doc in groupSnapshot.data!.docs) {
                            groups.add(FractionallySizedBox(
                              widthFactor: 0.48,
                              child: GroupCard(
                                  groupData: doc.data(), groupDocId: doc.id),
                            ));
                          }

                          return Wrap(
                            runSpacing: 10,
                            spacing: 10,
                            children: groups,
                          );
                        }

                        return SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              if (searchText.isNotEmpty &&
                  _tabController != null &&
                  _tabController!.index == 2)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Expanded(
                    child: FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .where('full_name_lowercase',
                              isGreaterThanOrEqualTo: searchText.toLowerCase())
                          .where('full_name_lowercase',
                              isLessThan: searchText.toLowerCase() + 'z')
                          .get(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (userSnapshot.hasData &&
                            userSnapshot.data!.docs.isNotEmpty) {
                          print('userSnapshot:');
                          print(userSnapshot.data?.docs);

                          List<Widget> userWidgets = [];

                          for (final doc in userSnapshot.data!.docs) {
                            print(doc.data()['full_name']);

                            if (doc.data()['uid'] ==
                                Provider.of<ProfileModel>(context,
                                        listen: false)
                                    .userDetails['uid']) {
                              continue;
                            }

                            userWidgets.add(StreamBuilder<QuerySnapshot>(
                                stream: Provider.of<ConversationModel>(context,
                                        listen: false)
                                    .fetchDoc(doc.data()['uid'] ?? ''),
                                builder: (context, snapshot) {
                                  String? chatDocumentId;

                                  if (snapshot.hasData &&
                                      snapshot.data!.docs.isNotEmpty) {
                                    chatDocumentId =
                                        snapshot.data!.docs.first.id;
                                  }

                                  return FractionallySizedBox(
                                    widthFactor: 0.48,
                                    child: PersonCard(
                                      userName: doc.data()['full_name'] ?? '',
                                      onConnect: () async {
                                        final friendsModel =
                                            Provider.of<FriendsModel>(context,
                                                listen: false);
                                        final profileModel =
                                            Provider.of<ProfileModel>(context,
                                                listen: false);
                                        friendsModel
                                            .addFriend(doc.data()['uid'] ?? '')
                                            .then((_) {
                                          friendsModel.addFriendNofitication(
                                              profileModel.userDetails['uid'],
                                              profileModel
                                                  .userDetails['full_name'],
                                              doc.data()['uid'] ?? '');
                                        });
                                      },
                                      onTap: () {
                                        final friendsModel =
                                            Provider.of<FriendsModel>(context,
                                                listen: false);
                                        friendsModel.viewProfile(doc.data());
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                ProfileView(
                                                    // userData: friendsModel.friendSuggestions[index],
                                                    ),
                                          ),
                                        );
                                      },
                                      isRequestSent: ((doc.data()['requests'] ??
                                                  []) as List<dynamic>)
                                              .map((e) => e.toString())
                                              .toList()
                                              .contains(
                                                  Provider.of<ProfileModel>(
                                                          context,
                                                          listen: false)
                                                      .userDetails['uid']) ||
                                          Provider.of<FriendsModel>(context,
                                                  listen: false)
                                              .requestsList
                                              .contains(
                                                  doc.data()['uid'] ?? ''),
                                      isFriend: (Provider.of<ProfileModel>(
                                                      context,
                                                      listen: false)
                                                  .userDetails['friends']
                                              as List<dynamic>)
                                          .map((e) => e.toString())
                                          .toList()
                                          .contains(doc.data()['uid'] ?? ''),
                                      isRequesting: (Provider.of<ProfileModel>(
                                                      context,
                                                      listen: false)
                                                  .userDetails['requests']
                                              as List<dynamic>)
                                          .map((e) => e.toString())
                                          .toList()
                                          .contains(doc.data()['uid'] ?? ''),
                                      onAccept: () async {
                                        final friendsModel =
                                            Provider.of<FriendsModel>(context,
                                                listen: false);
                                        final profileModel =
                                            Provider.of<ProfileModel>(context,
                                                listen: false);
                                        friendsModel
                                            .confirmRequest(
                                                doc.data()['uid'] ?? '')
                                            .then((_) {
                                          friendsModel
                                              .confirmFriendNofitication(
                                                  profileModel
                                                      .userDetails['uid'],
                                                  profileModel
                                                      .userDetails['full_name'],
                                                  doc.data()['uid'] ?? '');
                                        });
                                      },
                                      onCancel: () async {
                                        final friendsModel =
                                            Provider.of<FriendsModel>(context,
                                                listen: false);

                                        friendsModel
                                            .cancelRequest(
                                                doc.data()['uid'] ?? '')
                                            .then((_) {
                                          friendsModel.removeNotification(
                                              doc.data()['uid'] ?? '');
                                        });
                                      },
                                      onMessage: () async {
                                        Provider.of<ConversationModel>(context,
                                                listen: false)
                                            .setChatDocId(chatDocumentId);

                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                Conversation(
                                              friendName:
                                                  doc.data()['full_name'] ?? '',
                                              friendProfilePic:
                                                  doc.data()['profile_pic'] ??
                                                      '',
                                              friendUid:
                                                  doc.data()['uid'] ?? '',
                                            ),
                                          ),
                                        );
                                      },
                                      profilePic:
                                          doc.data()['profile_pic'] ?? '',
                                    ),
                                  );
                                }));
                          }

                          return Wrap(
                            runSpacing: 10,
                            spacing: 10,
                            children: userWidgets,
                          );
                        }

                        return SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              if (searchText.isEmpty && _tabController != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(child: Text(initialDisplay)),
                ),
            ],
          ),
        )),
      );
    });
  }
}
