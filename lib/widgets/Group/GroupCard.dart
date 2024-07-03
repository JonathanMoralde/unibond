import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/Messages/GroupChatDetails.dart';
import 'package:unibond/pages/Messages/GroupConversation.dart';
import 'package:unibond/provider/GroupChatDetailsModel.dart';
import 'package:unibond/provider/ProfileModel.dart';

class GroupCard extends StatefulWidget {
  final Map<String, dynamic> groupData;
  final String groupDocId;
  const GroupCard(
      {super.key, required this.groupData, required this.groupDocId});

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
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
                groupDocId: widget.groupDocId,
              ),
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => GroupChatDetails(
                groupDocId: widget.groupDocId,
                isMember: false,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        decoration: BoxDecoration(
            color: const Color(0xffD9D9D9),
            borderRadius: BorderRadius.circular(16)),
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
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(widget.groupDocId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                if (snapshot.hasError) {
                  print('Error: ${snapshot.error}');
                  return const SizedBox.shrink();
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const SizedBox.shrink();
                }

                final groupData = snapshot.data!.data() as Map<String, dynamic>;

                final members = (groupData['members'] as List<dynamic>)
                    .map((e) => e.toString())
                    .toList();

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future:
                      Provider.of<GroupChatDetailsModel>(context, listen: false)
                          .fetchMembers(members),
                  builder: (context, futureSnapshot) {
                    if (futureSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }
                    if (futureSnapshot.hasError) {
                      print('Error: ${futureSnapshot.error}');
                      return const SizedBox.shrink();
                    }
                    if (!futureSnapshot.hasData ||
                        futureSnapshot.data!.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (final member in futureSnapshot.data!.take(5))
                          member['profile_pic'] != null &&
                                  (member['profile_pic'] as String).isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(member['profile_pic']!),
                                  maxRadius: 10,
                                )
                              : const CircleAvatar(
                                  backgroundImage: AssetImage(
                                      'lib/assets/default_profile_pic.png'),
                                  maxRadius: 10,
                                ),
                        if (futureSnapshot.data!.length > 5) SizedBox(width: 5),
                        if (futureSnapshot.data!.length > 5)
                          Text(
                            '${(futureSnapshot.data!.length - 5).toString()}+',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                      ],
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
