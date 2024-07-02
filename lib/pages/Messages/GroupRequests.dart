import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupRequests extends StatefulWidget {
  final String groupName;
  const GroupRequests({super.key, required this.groupName});

  @override
  State<GroupRequests> createState() => _GroupRequestsState();
}

class _GroupRequestsState extends State<GroupRequests> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Join Requests"),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('groups')
                    .where('group_name', isEqualTo: widget.groupName)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final result = snapshot.data!.docs.first.data()
                        as Map<String, dynamic>;

                    final requestsList =
                        ((result['requests'] ?? []) as List<dynamic>)
                            .map((e) => e.toString())
                            .toList();
                    if (requestsList.isEmpty) {
                      return Center(
                        child: Text("There are no requests"),
                      );
                    }

                    return Column(
                      children: requestsList.map((uid) {
                        return FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .where('uid', isEqualTo: uid)
                              .get(),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (userSnapshot.hasData) {
                              final userResult = userSnapshot.data!.docs.first
                                  .data() as Map<String, dynamic>;

                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xffE4ECEF),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  children: [
                                    userResult['profile_pic'] != null &&
                                            (userResult['profile_pic']
                                                    as String)
                                                .isNotEmpty
                                        ? CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                userResult['profile_pic']),
                                            maxRadius: 20,
                                          )
                                        : const CircleAvatar(
                                            backgroundImage: AssetImage(
                                                'lib/assets/default_profile_pic.png'),
                                            maxRadius: 20,
                                          ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: Text(
                                        userResult['full_name'],
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.check),
                                      onPressed: () async {
                                        // Handle accept  request
                                        final result = await FirebaseFirestore
                                            .instance
                                            .collection('groups')
                                            .where('group_name',
                                                isEqualTo: widget.groupName)
                                            .get();

                                        if (result.docs.isNotEmpty) {
                                          await FirebaseFirestore.instance
                                              .collection('groups')
                                              .doc(result.docs.first.id)
                                              .update({
                                            'requests': FieldValue.arrayRemove(
                                                [userResult['uid']]),
                                            'members': FieldValue.arrayUnion(
                                                [userResult['uid']])
                                          });

                                          await FirebaseFirestore.instance
                                              .collection('groups')
                                              .doc(result.docs.first.id)
                                              .update({
                                            'latest_chat_message':
                                                '${userResult['full_name']} joined the group',
                                            'latest_chat_user':
                                                userResult['uid'],
                                            'latest_timestamp': Timestamp.now(),
                                          });

                                          await FirebaseFirestore.instance
                                              .collection('groups')
                                              .doc(result.docs.first.id)
                                              .collection('messages')
                                              .add({
                                            'is_read': false,
                                            'content':
                                                '${userResult['full_name']} joined the group',
                                            'sender_id': userResult['uid'],
                                            'timestamp': Timestamp.now(),
                                            'type': 'notify',
                                            'sender_name':
                                                userResult['full_name'],
                                            'sender_profile_pic':
                                                userResult['profile_pic'],
                                          });
                                        }
                                      },
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.close),
                                      onPressed: () async {
                                        // Handle decline request
                                        final result = await FirebaseFirestore
                                            .instance
                                            .collection('groups')
                                            .where('group_name',
                                                isEqualTo: widget.groupName)
                                            .get();

                                        if (result.docs.isNotEmpty) {
                                          await FirebaseFirestore.instance
                                              .collection('groups')
                                              .doc(result.docs.first.id)
                                              .update({
                                            'requests': FieldValue.arrayRemove(
                                                [userResult['uid']])
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }

                            return SizedBox.shrink();
                          },
                        );
                      }).toList(),
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              )
            ],
          ),
        ),
      )),
    );
  }
}
