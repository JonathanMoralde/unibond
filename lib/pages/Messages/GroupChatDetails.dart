import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/Messages/AddPeople.dart';
import 'package:unibond/pages/Messages/CreateGroupChat.dart';
import 'package:unibond/pages/Messages/GroupRequests.dart';
import 'package:unibond/provider/GroupChatDetailsModel.dart';
import 'package:unibond/provider/ProfileModel.dart';

class GroupChatDetails extends StatefulWidget {
  final bool isMember;
  final String groupDocId;
  const GroupChatDetails(
      {super.key, required this.isMember, required this.groupDocId});

  @override
  State<GroupChatDetails> createState() => _GroupChatDetailsState();
}

class _GroupChatDetailsState extends State<GroupChatDetails> {
  XFile? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (widget.isMember)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert), // Icon for the button
              itemBuilder: (BuildContext context) {
                List<PopupMenuEntry<String>> items = [];

                // change group pic
                items.add(
                  const PopupMenuItem<String>(
                    value: 'editgroup',
                    child: Text('Edit Group'),
                  ),
                );

                // join request
                items.add(
                  const PopupMenuItem<String>(
                    value: 'joinrequests',
                    child: Text('Join requests'),
                  ),
                );

                // leave group
                items.add(
                  const PopupMenuItem<String>(
                    value: 'leavegroup',
                    child: Text('Leave group chat'),
                  ),
                );

                return items;
              },
              onSelected: (String value) {
                switch (value) {
                  // Handle additional cases if needed
                  case 'editgroup':
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => CreateGroupChat(
                          isEdit: true,
                          groupDocId: widget.groupDocId,
                        ),
                      ),
                    );
                    break;
                  case 'joinrequests':
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => GroupRequests(
                          groupDocId: widget.groupDocId,
                        ),
                      ),
                    );
                    break;
                  case 'leavegroup':
                    Provider.of<GroupChatDetailsModel>(context, listen: false)
                        .leaveGroup(widget.groupDocId);

                    break;
                }
              },
            ),
          if (!widget.isMember)
            StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('groups')
                    .doc(widget.groupDocId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return SizedBox.shrink();
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox.shrink();
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return SizedBox.shrink();
                  }

                  final groupData =
                      snapshot.data!.data() as Map<String, dynamic>;

                  final requestsList = (groupData['requests'] as List<dynamic>)
                      .map((e) => e.toString());

                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: GestureDetector(
                      onTap: requestsList.contains(
                              Provider.of<ProfileModel>(context, listen: false)
                                  .userDetails['uid'])
                          ? null
                          : () {
                              Provider.of<GroupChatDetailsModel>(context,
                                      listen: false)
                                  .joinGroupChat(widget.groupDocId);
                            },
                      child: requestsList.contains(
                              Provider.of<ProfileModel>(context, listen: false)
                                  .userDetails['uid'])
                          ? Text("REQUESTED")
                          : Text("JOIN"),
                    ),
                  );
                }),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupDocId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Group data not found'));
          }

          final groupData = snapshot.data!.data() as Map<String, dynamic>;
          final adminList = (groupData['admin'] as List<dynamic>)
              .map((e) => e.toString())
              .toList();

          // Fetch members data when group data changes
          Provider.of<GroupChatDetailsModel>(context, listen: false)
              .fetchMembersData(
            (groupData['members'] as List<dynamic>)
                .map((e) => e.toString())
                .toList(),
          );

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: const Color(0xffCAE5F1),
                          border: Border.all(color: Colors.grey.shade300)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // GROUP PIC
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.20),
                                  spreadRadius: 0,
                                  blurRadius: 3,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xff00B0FF),
                                width: 2.0,
                              ),
                            ),
                            child: groupData['group_pic'] != null &&
                                    (groupData['group_pic'] as String)
                                        .isNotEmpty
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(groupData['group_pic']),
                                    maxRadius: 40,
                                  )
                                : const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 35,
                                    color: Colors.grey,
                                  ),
                          ),
                          const SizedBox(height: 10),
                          // GROUP NAME
                          Text(
                            groupData['group_name'] ?? '',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          // GROUP DESCRIPTION
                          Text(
                            groupData['group_description'] ?? '',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          border: Border.symmetric(
                              vertical:
                                  BorderSide(color: Colors.grey.shade300))),
                      child: Text(
                        "Members in ${groupData['group_name']} (${(groupData['members'] as List<dynamic>).map((e) => e.toString()).toList().length})",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Consumer<GroupChatDetailsModel>(
                      builder: (context, groupChatDetailsModel, child) {
                        return Column(children: [
                          ...groupChatDetailsModel.membersList.map((student) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xffE4ECEF),
                                border: Border(
                                  top: BorderSide(color: Colors.grey.shade300),
                                  left: BorderSide(color: Colors.grey.shade300),
                                  right:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              child: Row(
                                children: [
                                  student['profile_pic'] != null &&
                                          (student['profile_pic'] as String)
                                              .isNotEmpty
                                      ? CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              student['profile_pic']),
                                          maxRadius: 20,
                                        )
                                      : const CircleAvatar(
                                          backgroundImage: AssetImage(
                                              'lib/assets/default_profile_pic.png'),
                                          maxRadius: 20,
                                        ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      student['full_name'],
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  if ((groupData['admin'] as List<dynamic>)
                                      .map((e) => e.toString())
                                      .toList()
                                      .contains(student['uid']))
                                    const Text('(admin)'),
                                  if ((groupData['admin'] as List<dynamic>)
                                      .map((e) => e.toString())
                                      .toList()
                                      .contains(Provider.of<ProfileModel>(
                                              context,
                                              listen: false)
                                          .userDetails['uid']))
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert),
                                      itemBuilder: (BuildContext context) {
                                        List<PopupMenuEntry<String>> items = [];

                                        // Remove Admin
                                        if (((groupData['admin']
                                                    as List<dynamic>)
                                                .map((e) => e.toString())
                                                .toList()
                                                .contains(student['uid'])) &&
                                            (groupData['admin']
                                                        as List<dynamic>)
                                                    .length >
                                                1) {
                                          items.add(
                                            const PopupMenuItem<String>(
                                              value: 'removeadmin',
                                              child: Text('Remove Admin'),
                                            ),
                                          );
                                        }

                                        // Make Admin
                                        if (!((groupData['admin']
                                                as List<dynamic>)
                                            .map((e) => e.toString())
                                            .toList()
                                            .contains(student['uid']))) {
                                          items.add(
                                            const PopupMenuItem<String>(
                                              value: 'makeadmin',
                                              child: Text('Make Admin'),
                                            ),
                                          );
                                        }

                                        if (student['uid'] !=
                                            Provider.of<ProfileModel>(context,
                                                    listen: false)
                                                .userDetails['uid']) {
                                          // Remove Member
                                          items.add(
                                            const PopupMenuItem<String>(
                                              value: 'remove',
                                              child: Text('Remove from group'),
                                            ),
                                          );
                                        }

                                        return items;
                                      },
                                      onSelected: (String value) {
                                        switch (value) {
                                          case 'remove':
                                            Provider.of<GroupChatDetailsModel>(
                                                    context,
                                                    listen: false)
                                                .removeMember(
                                                    student['uid'],
                                                    student['full_name'],
                                                    groupData['group_name'],
                                                    Provider.of<ProfileModel>(
                                                            context,
                                                            listen: false)
                                                        .userDetails);
                                            break;
                                          case 'makeadmin':
                                            Provider.of<GroupChatDetailsModel>(
                                                    context,
                                                    listen: false)
                                                .makeAdmin(student['uid'],
                                                    groupData['group_name']);
                                            break;
                                          case 'removeadmin':
                                            Provider.of<GroupChatDetailsModel>(
                                                    context,
                                                    listen: false)
                                                .removeAdmin(student['uid'],
                                                    groupData['group_name']);
                                            break;
                                        }
                                      },
                                    ),
                                ],
                              ),
                            );
                          }).toList(),

                          // ADD PEOPLE
                          if (widget.isMember &&
                              adminList.contains(Provider.of<ProfileModel>(
                                      context,
                                      listen: false)
                                  .userDetails['uid']))
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        AddPeople(
                                      fromGroupDetails: true,
                                      groupDocId: widget.groupDocId,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xffE4ECEF),
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                    left: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                    right: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.person_add),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "Add people",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(
                                        color: Colors.grey.shade300))),
                          ),
                        ]);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
