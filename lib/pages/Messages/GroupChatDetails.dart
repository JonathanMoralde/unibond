import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/MainLayout.dart';
import 'package:unibond/pages/Messages/CreateGroupChat.dart';
import 'package:unibond/pages/Messages/GroupRequests.dart';
import 'package:unibond/provider/GroupChatDetailsModel.dart';
import 'package:unibond/provider/GroupModel.dart';
import 'package:unibond/provider/ProfileModel.dart';

class GroupChatDetails extends StatefulWidget {
  final bool isMember;
  final Map<String, dynamic> groupData;
  const GroupChatDetails(
      {super.key, required this.isMember, required this.groupData});

  @override
  State<GroupChatDetails> createState() => _GroupChatDetailsState();
}

class _GroupChatDetailsState extends State<GroupChatDetails> {
  XFile? image;

  Map<String, dynamic>? groupDataState;

  @override
  void initState() {
    super.initState();
    setState(() {
      groupDataState = widget.groupData;
    });

    Provider.of<GroupChatDetailsModel>(context, listen: false).fetchMembersData(
        (groupDataState!['members'] as List<dynamic>)
            .map((e) => e.toString())
            .toList());
  }

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
                          groupData: groupDataState,
                        ),
                      ),
                    );
                    break;
                  case 'joinrequests':
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => GroupRequests(
                          groupName: groupDataState!['group_name'],
                        ),
                      ),
                    );
                    break;
                  case 'leavegroup':
                    if ((groupDataState!['admin'] as List<dynamic>).contains(
                            Provider.of<ProfileModel>(context, listen: false)
                                .userDetails['uid']) &&
                        (groupDataState!['admin'] as List<dynamic>).length ==
                            1) {
                      Fluttertoast.showToast(
                          msg: 'Set a new admin first before leaving group',
                          gravity: ToastGravity.CENTER);
                    } else {
                      Provider.of<GroupChatDetailsModel>(context, listen: false)
                          .leaveGroup(groupDataState!['group_name'])
                          .then((_) {
                        Provider.of<GroupModel>(context, listen: false)
                            .resetState();

                        Future.delayed(Duration(seconds: 2), () {
                          Provider.of<GroupModel>(context, listen: false)
                              .fetchGroups()
                              .then((_) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      MainLayout()),
                              (route) => false,
                            );
                          });
                        });
                      });
                    }
                    break;
                }
              },
            ),
          if (!widget.isMember)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: () {},
                child: Text("JOIN"),
              ),
            ),
        ],
      ),
      body: Consumer<GroupChatDetailsModel>(
          builder: (context, groupChatDetailsModel, child) {
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
                          width:
                              80, // double the maxRadius to cover the entire CircleAvatar
                          height:
                              80, // double the maxRadius to cover the entire CircleAvatar
                          decoration: BoxDecoration(
                            color: Colors.white,
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
                          child: groupDataState?['group_pic'] != null &&
                                  (groupDataState?['group_pic'] as String)
                                      .isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      groupDataState!['group_pic']),
                                  maxRadius: 40,
                                )
                              : const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 35,
                                  color: Colors.grey,
                                ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),

                        // GROUP NAME
                        Text(
                          groupDataState?['group_name'] ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        // GROUP DESCRIPTION
                        Text(
                          groupDataState?['group_description'] ?? '',
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
                            vertical: BorderSide(color: Colors.grey.shade300))),
                    child: Text(
                      "Members in ${groupDataState!['group_name']} (${(groupDataState!['members'] as List<dynamic>).map((e) => e.toString()).toList().length})",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  for (final student in groupChatDetailsModel.membersList)
                    Container(
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
                      child: Row(
                        children: [
                          student['profile_pic'] != null &&
                                  (student['profile_pic'] as String).isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(student['profile_pic']),
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
                              student['full_name'],
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                          if ((groupDataState!['admin'] as List<dynamic>)
                              .map((e) => e.toString())
                              .toList()
                              .contains(student['uid']))
                            const Text('(admin)'),

                          // IF CURRENT USER IS ADMIN
                          if ((groupDataState!['admin'] as List<dynamic>)
                              .map((e) => e.toString())
                              .toList()
                              .contains(Provider.of<ProfileModel>(context,
                                      listen: false)
                                  .userDetails['uid']))
                            PopupMenuButton<String>(
                              icon: const Icon(
                                  Icons.more_vert), // Icon for the button
                              itemBuilder: (BuildContext context) {
                                List<PopupMenuEntry<String>> items = [];

                                // Remove
                                if (((groupDataState!['admin'] as List<dynamic>)
                                        .map((e) => e.toString())
                                        .toList()
                                        .contains(student['uid'])) &&
                                    (groupDataState!['admin'] as List<dynamic>)
                                            .length >
                                        1) {
                                  items.add(
                                    const PopupMenuItem<String>(
                                      value: 'removeadmin',
                                      child: Text('Remove Admin'),
                                    ),
                                  );
                                }

                                // Make
                                if (!((groupDataState!['admin']
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

                                // remove member
                                if (student['uid'] !=
                                    Provider.of<ProfileModel>(context,
                                            listen: false)
                                        .userDetails['uid'])
                                  items.add(
                                    const PopupMenuItem<String>(
                                      value: 'removemember',
                                      child: Text('Remove Member'),
                                    ),
                                  );

                                return items;
                              },
                              onSelected: (String value) {
                                switch (value) {
                                  // Handle additional cases if needed
                                  case 'removeadmin':
                                    groupChatDetailsModel.removeAdmin(
                                        student['uid'],
                                        groupDataState!['group_name']);
                                    setState(() {
                                      (groupDataState!['admin']
                                              as List<dynamic>)
                                          .remove(student['uid']);
                                    });
                                    break;
                                  case 'makeadmin':
                                    groupChatDetailsModel.makeAdmin(
                                        student['uid'],
                                        groupDataState!['group_name']);
                                    setState(() {
                                      (groupDataState!['admin']
                                              as List<dynamic>)
                                          .add(student['uid']);
                                    });
                                    break;
                                  case 'removemember':
                                    groupChatDetailsModel.removeMember(
                                        student['uid'],
                                        groupDataState!['group_name']);
                                    groupChatDetailsModel
                                        .removeMemberinList(student['uid']);
                                    break;
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  InkWell(
                    onTap: () {},
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
                                fontSize: 16, fontWeight: FontWeight.w600),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(color: Colors.grey.shade300))),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
