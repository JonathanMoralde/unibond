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
  final scrollController = ScrollController();
  final searchController = TextEditingController();
  String searchText = '';
  bool isLoading = false;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _groupsNotJoined = [];

  late TabController? _tabController;

  String initialDisplay = 'Search Unibond';

  @override
  void initState() {
    super.initState();
    // Initialize the TabController with the initial length and vsync
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.initialIndex);

    _tabController?.addListener(_handleTabSelection);
    fetchGroupsNotJoined();
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
        setState(() {
          initialDisplay = 'Search People';
        });

        break;
    }
  }

  Future<void> fetchGroupsNotJoined() async {
    try {
      final result =
          await FirebaseFirestore.instance.collection('groups').get();

      final data = result.docs;

      final groupsNotJoined = data.where((doc) {
        return !(doc.data()['members'] as List<dynamic>)
            .contains(FirebaseAuth.instance.currentUser!.uid);
      }).toList();

      setState(() {
        _groupsNotJoined = groupsNotJoined;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final aspectRatio = screenWidth / (screenHeight / 1.4); // Adjust as needed

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
                  Tab(text: 'People'),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            if (_tabController != null && _tabController!.index != 0)
              Container(
                height: MediaQuery.sizeOf(context).height * 1,
                child: Image.asset(
                  'lib/assets/announcementbg.png',
                  alignment: AlignmentDirectional.bottomEnd,
                ),
              ),
            StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, currentUserSnapshot) {
                  if (currentUserSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (currentUserSnapshot.hasError) {
                    return Center(
                        child: Text('Error: ${currentUserSnapshot.error}'));
                  }

                  if (!currentUserSnapshot.hasData &&
                      currentUserSnapshot.data != null) {
                    return const Center(child: Text('No user data'));
                  }

                  final currentUserData =
                      currentUserSnapshot.data!.data() as Map<String, dynamic>;
                  final currentUserUid = currentUserData['uid'];
                  final currentUserFullName = currentUserData['full_name'];
                  final currentUserRequestList =
                      (currentUserData['requests'] as List<dynamic>)
                          .map((e) => e.toString())
                          .toList();
                  final currentUserFriendList =
                      (currentUserData['friends'] as List<dynamic>)
                          .map((e) => e.toString())
                          .toList();

                  return SafeArea(
                      child: Column(
                    children: [
                      if (searchText.isNotEmpty &&
                          _tabController != null &&
                          _tabController!.index == 0)
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .where('full_name_lowercase',
                                        isGreaterThanOrEqualTo:
                                            searchText.toLowerCase())
                                    .where('full_name_lowercase',
                                        isLessThan:
                                            searchText.toLowerCase() + 'z')
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }

                                  if (snapshot.hasData &&
                                      snapshot.data!.docs.isNotEmpty) {
                                    print(snapshot.data!.docs);
                                    print(snapshot.data!.docs.first
                                        .data()['uid']);

                                    List<Widget> userWidgets = [];
                                    for (final doc in snapshot.data!.docs) {
                                      userWidgets.add(
                                        FutureBuilder(
                                          future: FirebaseFirestore.instance
                                              .collection('chats')
                                              .where('composite_id',
                                                  isEqualTo: Provider.of<
                                                              ConversationModel>(
                                                          context,
                                                          listen: false)
                                                      .generateConversationId(
                                                          doc.data()['uid'],
                                                          currentUserUid))
                                              .get(),
                                          builder: (context, chatSnapshot) {
                                            if (chatSnapshot.hasData &&
                                                chatSnapshot
                                                    .data!.docs.isNotEmpty) {
                                              print('chat snapshot');
                                              print(chatSnapshot.data!.docs);

                                              List<Widget> chatWidgets = [];
                                              for (final chatDoc
                                                  in chatSnapshot.data!.docs) {
                                                chatWidgets.add(
                                                  MessageCard(
                                                    isRead: chatDoc[
                                                        'latest_chat_read'],
                                                    onTap: () async {
                                                      Provider.of<ConversationModel>(
                                                              context,
                                                              listen: false)
                                                          .setChatDocId(
                                                              chatDoc.id);

                                                      try {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection('chats')
                                                            .doc(chatDoc.id)
                                                            .update({
                                                          'latest_chat_read':
                                                              true
                                                        });
                                                      } catch (e) {
                                                        print(e);
                                                      }

                                                      Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              Conversation(
                                                            friendName: doc
                                                                    .data()[
                                                                'full_name'],
                                                            friendUid: doc
                                                                .data()['uid'],
                                                            friendProfilePic: doc
                                                                    .data()[
                                                                'profile_pic'],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    userName:
                                                        doc.data()['full_name'],
                                                    latestMessage: chatDoc[
                                                        'latest_chat_message'],
                                                    latestUser: chatDoc[
                                                        'latest_chat_user'],
                                                    latestTimestamp: chatDoc[
                                                        'latest_timestamp'],
                                                    profilePic: doc
                                                        .data()['profile_pic'],
                                                    friendId: doc.data()['uid'],
                                                  ),
                                                );
                                              }
                                              return Column(
                                                  children: chatWidgets);
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
                            ],
                          ),
                        ),
                      if (searchText.isNotEmpty &&
                          _tabController != null &&
                          _tabController!.index == 1)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FutureBuilder(
                              future: FirebaseFirestore.instance
                                  .collection('groups')
                                  .where('group_name_lowercase',
                                      isGreaterThanOrEqualTo:
                                          searchText.toLowerCase())
                                  .where('group_name_lowercase',
                                      isLessThan:
                                          searchText.toLowerCase() + 'z')
                                  .get(),
                              builder: (context, groupSnapshot) {
                                if (groupSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }
                                if (groupSnapshot.hasData &&
                                    groupSnapshot.data!.docs.isNotEmpty) {
                                  List<Widget> groups = [];
                                  for (final doc in groupSnapshot.data!.docs) {
                                    groups.add(GroupCard(
                                        groupData: doc.data(),
                                        groupDocId: doc.id));
                                  }

                                  return GridView.builder(
                                    controller: scrollController,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: aspectRatio,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                                    itemCount: groups.length,
                                    itemBuilder: (context, index) {
                                      return groups[index];
                                    },
                                  );

                                  // return Wrap(
                                  //   runSpacing: 10,
                                  //   spacing: 10,
                                  //   children: groups,
                                  // );
                                }

                                return SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                      if (searchText.isNotEmpty &&
                          _tabController != null &&
                          _tabController!.index == 2)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FutureBuilder(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .where('full_name_lowercase',
                                      isGreaterThanOrEqualTo:
                                          searchText.toLowerCase())
                                  .where('full_name_lowercase',
                                      isLessThan:
                                          searchText.toLowerCase() + 'z')
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

                                    userWidgets.add(StreamBuilder<
                                            QuerySnapshot>(
                                        stream: Provider.of<ConversationModel>(
                                                context,
                                                listen: false)
                                            .fetchDoc(doc.data()['uid'] ?? ''),
                                        builder: (context, snapshot) {
                                          String? chatDocumentId;

                                          if (snapshot.hasData &&
                                              snapshot.data!.docs.isNotEmpty) {
                                            chatDocumentId =
                                                snapshot.data!.docs.first.id;
                                          }

                                          return PersonCard(
                                            currentUserRequestsList:
                                                currentUserRequestList,
                                            currentUserUid: currentUserUid,
                                            currentUserFullName:
                                                currentUserFullName,
                                            uid: doc.data()['uid'] ?? '',
                                            onTap: () {
                                              final friendsModel =
                                                  Provider.of<FriendsModel>(
                                                      context,
                                                      listen: false);
                                              friendsModel
                                                  .viewProfile(doc.data());
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          ProfileView(
                                                    uid:
                                                        doc.data()['uid'] ?? '',
                                                    currentUserUid:
                                                        currentUserUid,
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }));
                                  }

                                  return GridView.builder(
                                    controller: scrollController,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: aspectRatio,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                                    itemCount: userWidgets.length,
                                    itemBuilder: (context, index) {
                                      return userWidgets[index];
                                    },
                                  );

                                  // return Wrap(
                                  //   runSpacing: 10,
                                  //   spacing: 10,
                                  //   children: userWidgets,
                                  // );
                                }

                                return SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                      if (searchText.isEmpty &&
                          _tabController != null &&
                          _tabController!.index != 1)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(child: Text(initialDisplay)),
                        ),
                      if (searchText.isEmpty &&
                          _tabController != null &&
                          _tabController!.index == 1)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: GridView.builder(
                              controller: scrollController,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: aspectRatio,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: _groupsNotJoined.length,
                              itemBuilder: (context, index) {
                                return GroupCard(
                                    groupData: _groupsNotJoined[index].data(),
                                    groupDocId: _groupsNotJoined[index].id);
                              },
                            ),
                          ),
                        )
                    ],
                  ));
                }),
          ],
        ),
      );
    });
  }
}
