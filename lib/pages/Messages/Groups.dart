import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/Messages/CreateGroupChat.dart';
import 'package:unibond/provider/GroupModel.dart';
import 'package:unibond/widgets/Group/GroupCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Groups extends StatefulWidget {
  const Groups({super.key});

  @override
  State<Groups> createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupModel = Provider.of<GroupModel>(context, listen: false);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.sizeOf(context).height * 1,
            child: Image.asset(
              'lib/assets/announcementbg.png',
              alignment: AlignmentDirectional.bottomEnd,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: groupModel.getGroupsStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Wrap(
                            children: [
                              FractionallySizedBox(
                                widthFactor: 0.47,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            const CreateGroupChat(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 32),
                                    decoration: BoxDecoration(
                                      color: Color(0xffD9D9D9),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: Icon(
                                            Icons.add_rounded,
                                            size: 50,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        const Text(
                                          'Create New',
                                          style: TextStyle(fontSize: 15),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 27),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        final groups = snapshot.data!.docs;

                        return GridView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.73,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: groups.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              // CREATE GROUP CARD
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const CreateGroupChat(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 32),
                                  decoration: BoxDecoration(
                                    color: Color(0xffD9D9D9),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: Icon(
                                          Icons.add_rounded,
                                          size: 50,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'Create New',
                                        style: TextStyle(fontSize: 15),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 27),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              final groupData = groups[index - 1].data();
                              final groupDocId = groups[index - 1].id;
                              return GroupCard(
                                groupDocId: groupDocId,
                                groupData: groupData,
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
