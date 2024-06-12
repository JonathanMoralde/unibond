import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:unibond/provider/GroupChatDetailsModel.dart';

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

  @override
  void initState() {
    super.initState();

    Provider.of<GroupChatDetailsModel>(context, listen: false).fetchMembersData(
        (widget.groupData['members'] as List<dynamic>)
            .map((e) => e.toString())
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (widget.isMember)
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
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
                          child: widget.groupData['group_pic'] != null &&
                                  (widget.groupData['group_pic'] as String)
                                      .isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      widget.groupData['group_pic']),
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
                          widget.groupData['group_name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        // GROUP DESCRIPTION
                        Text(
                          widget.groupData['group_description'],
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
                      "Members in ${widget.groupData['group_name']} (${(widget.groupData['members'] as List<dynamic>).map((e) => e.toString()).toList().length})",
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
                          if ((widget.groupData['admin'] as List<dynamic>)
                              .map((e) => e.toString())
                              .toList()
                              .contains(student['uid']))
                            const Text('(admin)'),
                        ],
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
