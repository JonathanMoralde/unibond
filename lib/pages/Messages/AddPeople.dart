import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/provider/CreateGroupChatModel.dart';
import 'package:unibond/provider/ProfileModel.dart';
import 'package:unibond/widgets/styledTextFormField.dart';

class AddPeople extends StatefulWidget {
  final bool fromGroupDetails;
  final String? groupDocId;
  const AddPeople({super.key, required this.fromGroupDetails, this.groupDocId});

  @override
  State<AddPeople> createState() => _AddPeopleState();
}

class _AddPeopleState extends State<AddPeople> {
  final searchController = TextEditingController();
  String searchText = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.fromGroupDetails) {
      Provider.of<CreateGroupChatModel>(context, listen: false).resetSelected();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StyledTextFormField(
          height: 40,
          paddingBottom: 0,
          paddingTop: 0,
          paddingLeft: 16,
          paddingRight: 16,
          controller: searchController,
          hintText: 'Search people',
          obscureText: false,
          onChanged: (val) {
            setState(() {
              searchText = val;
            });
          },
        ),
        actions: [
          if (isLoading == true)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircularProgressIndicator(),
            ),
          if (widget.fromGroupDetails && isLoading == false)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    isLoading = true;
                  });
                  Provider.of<CreateGroupChatModel>(context, listen: false)
                      .addPeopleToGroup(
                          widget.groupDocId!,
                          Provider.of<ProfileModel>(context, listen: false)
                              .userDetails)
                      .then((_) {
                    Provider.of<CreateGroupChatModel>(context, listen: false)
                        .reset();
                    setState(() {
                      isLoading = false;
                    });
                  });
                },
                child: const Text(
                  "ADD",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
        ],
      ),
      body: widget.fromGroupDetails
          ? StreamBuilder<DocumentSnapshot>(
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

                final membersList = (groupData['members'] as List<dynamic>)
                    .map((e) => e.toString())
                    .toList();
                final friendsList =
                    (Provider.of<ProfileModel>(context, listen: false)
                            .userDetails['friends'] as List<dynamic>)
                        .map((e) => e.toString())
                        .toList();

                final newList = friendsList;

                for (final memberUid in membersList) {
                  newList.remove(memberUid);
                }

                return Consumer<CreateGroupChatModel>(
                    builder: (context, createGroupChatModel, child) {
                  return SafeArea(
                      child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          if (searchText.isEmpty)
                            for (final friendUid in newList)
                              FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(friendUid)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final friendData = snapshot.data!.data()
                                        as Map<String, dynamic>;

                                    final isSelected = createGroupChatModel
                                        .selectedUsers
                                        .contains(friendData['uid']);

                                    return Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xffE4ECEF),
                                        border: Border(
                                          top: BorderSide(
                                              color: Colors.grey.shade300),
                                          left: BorderSide(
                                              color: Colors.grey.shade300),
                                          right: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                      ),
                                      child: CheckboxListTile(
                                        value: isSelected,
                                        onChanged: (bool? selected) {
                                          if (selected == true) {
                                            createGroupChatModel
                                                .addUser(friendData['uid']);
                                          } else {
                                            createGroupChatModel
                                                .removeUser(friendData['uid']);
                                          }
                                        },
                                        title: Row(
                                          children: [
                                            friendData['profile_pic'] != null &&
                                                    (friendData['profile_pic']
                                                            as String)
                                                        .isNotEmpty
                                                ? CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(friendData[
                                                            'profile_pic']),
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
                                                friendData['full_name'],
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  return const SizedBox.shrink();
                                },
                              ),
                          if (searchText.isNotEmpty)
                            FutureBuilder(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .where('full_name',
                                      isGreaterThanOrEqualTo: searchText)
                                  .where('full_name',
                                      isLessThan: searchText + 'z')
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Column(
                                    children: [
                                      for (final doc in snapshot.data!.docs)
                                        if (!membersList
                                            .contains(doc.data()['uid']))
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: const Color(0xffE4ECEF),
                                              border: Border(
                                                top: BorderSide(
                                                    color:
                                                        Colors.grey.shade300),
                                                left: BorderSide(
                                                    color:
                                                        Colors.grey.shade300),
                                                right: BorderSide(
                                                    color:
                                                        Colors.grey.shade300),
                                              ),
                                            ),
                                            child: CheckboxListTile(
                                              value: createGroupChatModel
                                                  .selectedUsers
                                                  .contains(doc.data()['uid']),
                                              onChanged: (bool? selected) {
                                                if (selected == true) {
                                                  createGroupChatModel.addUser(
                                                      doc.data()['uid']);
                                                } else {
                                                  createGroupChatModel
                                                      .removeUser(
                                                          doc.data()['uid']);
                                                }
                                              },
                                              title: Row(
                                                children: [
                                                  doc.data()['profile_pic'] !=
                                                              null &&
                                                          (doc.data()['profile_pic']
                                                                  as String)
                                                              .isNotEmpty
                                                      ? CircleAvatar(
                                                          backgroundImage:
                                                              NetworkImage(doc
                                                                      .data()[
                                                                  'profile_pic']),
                                                          maxRadius: 20,
                                                        )
                                                      : const CircleAvatar(
                                                          backgroundImage:
                                                              AssetImage(
                                                                  'lib/assets/default_profile_pic.png'),
                                                          maxRadius: 20,
                                                        ),
                                                  const SizedBox(width: 5),
                                                  Expanded(
                                                    child: Text(
                                                      doc.data()['full_name'],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                    ],
                                  );
                                }

                                return const SizedBox.shrink();
                              },
                            ),

                          // DISPLAY USERS WHO ARE NOT FRIEND BUT SELECTED FROM THE SEARCH
                          if (searchText.isEmpty)
                            for (final selectedUid
                                in createGroupChatModel.selectedUsers)
                              FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(selectedUid)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final selectedData = snapshot.data!.data()
                                        as Map<String, dynamic>;

                                    final isSelected = createGroupChatModel
                                        .selectedUsers
                                        .contains(selectedData['uid']);
                                    if (!newList.contains(selectedUid)) {
                                      return Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xffE4ECEF),
                                          border: Border(
                                            top: BorderSide(
                                                color: Colors.grey.shade300),
                                            left: BorderSide(
                                                color: Colors.grey.shade300),
                                            right: BorderSide(
                                                color: Colors.grey.shade300),
                                          ),
                                        ),
                                        child: CheckboxListTile(
                                          value: isSelected,
                                          onChanged: (bool? selected) {
                                            if (selected == true) {
                                              createGroupChatModel
                                                  .addUser(selectedData['uid']);
                                            } else {
                                              createGroupChatModel.removeUser(
                                                  selectedData['uid']);
                                            }
                                          },
                                          title: Row(
                                            children: [
                                              selectedData['profile_pic'] !=
                                                          null &&
                                                      (selectedData[
                                                                  'profile_pic']
                                                              as String)
                                                          .isNotEmpty
                                                  ? CircleAvatar(
                                                      backgroundImage:
                                                          NetworkImage(
                                                              selectedData[
                                                                  'profile_pic']),
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
                                                  selectedData['full_name'],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    return const SizedBox.shrink();
                                  }

                                  return const SizedBox.shrink();
                                },
                              ),
                        ],
                      ),
                    ),
                  ));
                });
              })
          : Consumer<CreateGroupChatModel>(
              builder: (context, createGroupChatModel, child) {
              return SafeArea(
                  child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .where('full_name',
                                isGreaterThanOrEqualTo: searchText)
                            .where('full_name', isLessThan: searchText + 'z')
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Column(
                              children: [
                                for (final doc in snapshot.data!.docs)
                                  if (doc.data()['uid'] !=
                                      Provider.of<ProfileModel>(context,
                                              listen: false)
                                          .userDetails['uid'])
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xffE4ECEF),
                                        border: Border(
                                          top: BorderSide(
                                              color: Colors.grey.shade300),
                                          left: BorderSide(
                                              color: Colors.grey.shade300),
                                          right: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                      ),
                                      child: CheckboxListTile(
                                        value: createGroupChatModel
                                            .selectedUsers
                                            .contains(doc.data()['uid']),
                                        onChanged: (bool? selected) {
                                          if (selected == true) {
                                            createGroupChatModel
                                                .addUser(doc.data()['uid']);
                                          } else {
                                            createGroupChatModel
                                                .removeUser(doc.data()['uid']);
                                          }
                                        },
                                        title: Row(
                                          children: [
                                            doc.data()['profile_pic'] != null &&
                                                    (doc.data()['profile_pic']
                                                            as String)
                                                        .isNotEmpty
                                                ? CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(doc.data()[
                                                            'profile_pic']),
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
                                                doc.data()['full_name'],
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              ],
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ));
            }),
    );
  }
}
