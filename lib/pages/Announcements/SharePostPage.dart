import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/provider/ProfileModel.dart';

class SharePostPage extends StatefulWidget {
  final String postDetails;
  final String postPic;
  final String senderId;
  final String senderName;
  final String senderProfilePic;
  final String postDocId;

  const SharePostPage({
    Key? key,
    required this.postDetails,
    required this.postPic,
    required this.senderId,
    required this.senderName,
    required this.senderProfilePic,
    required this.postDocId,
  }) : super(key: key);

  @override
  _SharePostPageState createState() => _SharePostPageState();
}

class _SharePostPageState extends State<SharePostPage> {
  List<String> selectedGroups = [];
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Post to Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              if (selectedGroups.isNotEmpty) {
                await _shareToSelectedGroups();
                Navigator.pop(
                    context); // Return to the previous screen after sharing
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please select at least one group.')),
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<ProfileModel>(builder: (context, profileModel, child) {
        return Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search groups...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onChanged: (query) {
                  setState(() {
                    searchQuery = query;
                  });
                },
              ),
            ),

            // List of Groups with Checkboxes
            Expanded(
              child: StreamBuilder(
                stream: profileModel.userDetails['role'] == 'admin'
                    ? FirebaseFirestore.instance
                        .collection('groups')
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collection('groups')
                        .where('members',
                            arrayContains: profileModel.userDetails['uid'])
                        .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No groups available.'));
                  }

                  // Filter groups based on the search query
                  var groups = snapshot.data!.docs.where((doc) {
                    return doc['group_name']
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase());
                  }).toList();

                  return ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot group = groups[index];
                      String groupId = group.id;
                      String groupName = group['group_name'];
                      String groupPic = group['group_pic'];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: groupPic.isNotEmpty
                              ? NetworkImage(groupPic)
                              : const AssetImage(
                                      'lib/assets/default_group_pic.png')
                                  as ImageProvider,
                        ),
                        title: Text(groupName),
                        trailing: Checkbox(
                          value: selectedGroups.contains(groupId),
                          onChanged: (isSelected) {
                            setState(() {
                              if (isSelected!) {
                                selectedGroups.add(groupId);
                              } else {
                                selectedGroups.remove(groupId);
                              }
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _shareToSelectedGroups() async {
    // Insert the message into the `messages` subcollection of each selected group
    for (String groupId in selectedGroups) {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .add({
        'content': widget.postDetails,
        'is_read': false,
        'sender_id': widget.senderId,
        'sender_name': widget.senderName,
        'sender_profile_pic': widget.senderProfilePic,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'announcement',
        'post_pic': widget.postPic,
        'post_doc_id': widget.postDocId,
      });
    }
  }
}
