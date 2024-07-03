import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/MainLayout.dart';
import 'package:unibond/provider/CreateGroupChatModel.dart';
import 'package:unibond/provider/GroupModel.dart';
import 'package:unibond/provider/ProfileModel.dart';
import 'package:unibond/widgets/styledButton.dart';
import 'package:unibond/widgets/styledTextFormField.dart';

class CreateGroupChat extends StatefulWidget {
  final bool? isEdit;
  final String? groupDocId;
  const CreateGroupChat({super.key, this.isEdit, this.groupDocId});

  @override
  State<CreateGroupChat> createState() => _CreateGroupChatState();
}

class _CreateGroupChatState extends State<CreateGroupChat> {
  final scrollController = ScrollController();

  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<CreateGroupChatModel>(context, listen: false)
        .fetchMemberSuggestions();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        // Fetch more data when the user scrolls to the bottom
        Provider.of<CreateGroupChatModel>(context, listen: false)
            .fetchMemberSuggestions(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (!isLoading && widget.isEdit == null)
            GestureDetector(
              onTap: () {
                setState(() {
                  isLoading = true;
                });
                Provider.of<CreateGroupChatModel>(context, listen: false)
                    .createGroupChat(
                        Provider.of<ProfileModel>(context, listen: false)
                            .userDetails)
                    .then((_) {
                  // Provider.of<GroupModel>(context, listen: false).resetState();

                  // Future.delayed(Duration(seconds: 2), () {
                  //   Provider.of<GroupModel>(context, listen: false)
                  //       .fetchGroups();
                  // });

                  setState(() {
                    isLoading = false;
                  });
                });
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Text(
                  'CREATE',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: CircularProgressIndicator(),
            ),
          if (widget.isEdit != null && widget.isEdit == true && !isLoading)
            GestureDetector(
              onTap: () {
                setState(() {
                  isLoading = true;
                });
                Provider.of<CreateGroupChatModel>(context, listen: false)
                    .editGroup(
                        Provider.of<ProfileModel>(context, listen: false)
                            .userDetails,
                        widget.groupDocId!)
                    .then((_) {
                  setState(() {
                    isLoading = false;
                  });

                  Navigator.pop(context);
                });
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Text(
                  'SAVE',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: Consumer<CreateGroupChatModel>(builder: (context, value, child) {
        return SafeArea(
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
                        child: value.image != null &&
                                (value.image?.path as String).isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  value.selectImage();
                                },
                                child: CircleAvatar(
                                  backgroundImage:
                                      FileImage(File(value.image!.path)),
                                  maxRadius: 40,
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  value.selectImage();
                                },
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 35,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),

                      // GROUP NAME
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.7,
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          // style: TextStyle(fontSize: 12),
                          controller: value.nameController,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText:
                                'Enter ${widget.isEdit != null && widget.isEdit == true ? 'new' : 'a'} group name',
                            // hintStyle: TextStyle(fontSize: 12),
                            focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff00B0FF)),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16))),
                            border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16))),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter group name';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      // GROUP DESCRIPTION
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.7,
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          // style: TextStyle(fontSize: 12),
                          controller: value.descriptionController,
                          minLines: 1,
                          maxLines: 4,
                          maxLength: 111,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText:
                                'Add ${widget.isEdit != null && widget.isEdit == true ? 'new' : 'a'}a brief description',
                            // hintStyle: TextStyle(fontSize: 12),
                            focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff00B0FF)),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16))),
                            border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16))),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter description';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.isEdit == null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        border: Border.symmetric(
                            vertical: BorderSide(color: Colors.grey.shade300))),
                    child: const Text(
                      "Add member to the group",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                if (widget.isEdit == null)
                  StyledButton(
                    btnText: 'Search by name',
                    onClick: () {},
                    isBorder: true,
                    borderColor: Colors.grey.shade300,
                    noShadow: true,
                    borderRadius: BorderRadius.circular(0),
                    btnColor: const Color(0xffE4ECEF),
                    textColor: Colors.grey,
                    btnWidth: double.infinity,
                    btnIcon: const Icon(Icons.search),
                  ),
                if (widget.isEdit == null)
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: value.memberSuggestions.length +
                          (value.hasMoreData ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < value.memberSuggestions.length) {
                          final user = value.memberSuggestions[index];
                          final isSelected =
                              value.selectedUsers.contains(user['uid']);
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xffE4ECEF),
                              border: Border(
                                left: BorderSide(color: Colors.grey.shade300),
                                right: BorderSide(color: Colors.grey.shade300),
                                bottom: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: CheckboxListTile(
                              title: Row(
                                children: [
                                  user['profile_pic'] != null &&
                                          (user['profile_pic'] as String)
                                              .isNotEmpty
                                      ? CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(user['profile_pic']),
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
                                    user['full_name'],
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  )),
                                ],
                              ),
                              value: isSelected,
                              onChanged: (bool? selected) {
                                if (selected == true) {
                                  value.addUser(user['uid']);
                                } else {
                                  value.removeUser(user['uid']);
                                }
                              },
                            ),
                          );
                        } else if (value.hasMoreData) {
                          // Show a loading indicator if there is more data to fetch
                          return Center(child: CircularProgressIndicator());
                        } else {
                          // No more data to fetch
                          return SizedBox.shrink();
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
