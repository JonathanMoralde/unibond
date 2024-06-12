import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/Messages/GroupChatDetails.dart';
import 'package:unibond/provider/GroupConversationModel.dart';
import 'package:unibond/widgets/styledTextFormField.dart';

class GroupConversation extends StatefulWidget {
  final Map<String, dynamic> groupData;
  const GroupConversation({super.key, required this.groupData});

  @override
  State<GroupConversation> createState() => _GroupConversationState();
}

class _GroupConversationState extends State<GroupConversation> {
  final chatController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            widget.groupData['group_pic'] != null &&
                    (widget.groupData['group_pic'] as String).isNotEmpty
                ? CircleAvatar(
                    backgroundImage:
                        NetworkImage(widget.groupData['group_pic']!),
                    maxRadius: 15,
                  )
                : const CircleAvatar(
                    backgroundImage:
                        AssetImage('lib/assets/default_profile_pic.png'),
                    maxRadius: 15,
                  ),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              child: Text(
                widget.groupData['group_name'],
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.videocam,
              color: Colors.black,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.call,
              color: Colors.black,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => GroupChatDetails(
                    isMember: true,
                    groupData: widget.groupData,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.info,
              color: Colors.black,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
                reverse: true,
                shrinkWrap: true,
                itemCount: 10,
                itemBuilder: (BuildContext context, int index) {
                  return Text('test $index');
                }),
          ),

          // INPUTS
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    XFile? image =
                        await picker.pickImage(source: ImageSource.camera);

                    if (image != null) {
                      // conversationModel.sendImage(
                      //     File(image.path), widget.friendUid);
                    }
                  },
                  icon: const Icon(Icons.camera_alt),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final List<XFile> images =
                        await picker.pickMultiImage(imageQuality: 70);
                    if (images.isNotEmpty) {
                      for (final image in images) {
                        // conversationModel.sendImage(
                        //     File(image.path), widget.friendUid);
                      }
                    }
                  },
                  icon: const Icon(Icons.image),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Expanded(
                  child: StyledTextFormField(
                    controller: chatController,
                    hintText: 'Type something',
                    obscureText: false,
                    maxLines: 6,
                    paddingLeft: 16,
                    paddingRight: 16,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // conversationModel.sendMessage(
                    //     chatController.text, widget.friendUid);
                    // chatController.clear();
                  },
                  icon: const Icon(Icons.send),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              ],
            ),
          ),
        ],
      )),
    );
  }
}
