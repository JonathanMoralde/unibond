import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/Messages/GroupChatDetails.dart';
import 'package:unibond/pages/Messages/GroupConversation.dart';
import 'package:unibond/provider/GroupChatDetailsModel.dart';
import 'package:unibond/provider/GroupConversationModel.dart';
import 'package:unibond/provider/ProfileModel.dart';

class GroupCard extends StatefulWidget {
  final Map<String, dynamic> groupData;
  const GroupCard({super.key, required this.groupData});

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  List<Map<String, dynamic>> membersList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    await Provider.of<GroupChatDetailsModel>(context, listen: false)
        .fetchMembers((widget.groupData['members'] as List<dynamic>)
            .map((e) => e.toString())
            .toList())
        .then((list) {
      membersList.addAll(list);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final profileModel = Provider.of<ProfileModel>(context, listen: false);

        final members = (widget.groupData['members'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();

        if (members.contains(profileModel.userDetails['uid'])) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => GroupConversation(
                groupData: widget.groupData,
              ),
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => GroupChatDetails(
                isMember: false,
                groupData: widget.groupData,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        decoration: BoxDecoration(
            color: Color(0xffD9D9D9), borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            widget.groupData['group_pic'] != null &&
                    (widget.groupData['group_pic'] as String).isNotEmpty
                ? CircleAvatar(
                    backgroundImage:
                        NetworkImage(widget.groupData['group_pic']!),
                    maxRadius: 45,
                  )
                : const CircleAvatar(
                    backgroundImage:
                        AssetImage('lib/assets/default_profile_pic.png'),
                    maxRadius: 45,
                  ),
            const SizedBox(
              height: 14,
            ),
            Text(
              widget.groupData['group_name'],
              style: const TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final member in membersList.take(5).toList())
                  member['profile_pic'] != null &&
                          (member['profile_pic'] as String).isNotEmpty
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(member['profile_pic']!),
                          maxRadius: 10,
                        )
                      : const CircleAvatar(
                          backgroundImage:
                              AssetImage('lib/assets/default_profile_pic.png'),
                          maxRadius: 10,
                        ),
                // const CircleAvatar(
                //   backgroundImage:
                //       AssetImage('lib/assets/default_profile_pic.png'),
                //   maxRadius: 10,
                // ),
                // const CircleAvatar(
                //   backgroundImage:
                //       AssetImage('lib/assets/default_profile_pic.png'),
                //   maxRadius: 10,
                // ),
                // const CircleAvatar(
                //   backgroundImage:
                //       AssetImage('lib/assets/default_profile_pic.png'),
                //   maxRadius: 10,
                // ),
                // const CircleAvatar(
                //   backgroundImage:
                //       AssetImage('lib/assets/default_profile_pic.png'),
                //   maxRadius: 10,
                // ),
                SizedBox(
                  width: 5,
                ),
                if (membersList.length > 5)
                  Text(
                    '${(membersList.length - 5).toString()}+',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
              ],
            )
          ],
        ),
      ),
    );
  }
}
