import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/Announcements/PostPage.dart';
import 'package:unibond/pages/Announcements/SharePostPage.dart';
import 'package:unibond/provider/ProfileModel.dart';

class PostCard extends StatefulWidget {
  final String postDetails;
  final String postPic;
  final List<String> likes;
  final String postId;
  final String currentUserId;
  final String profilePic;
  final String fullName;
  final Timestamp datePosted;
  final bool fromLink;

  const PostCard(
      {super.key,
      required this.postDetails,
      required this.postPic,
      required this.likes,
      required this.postId,
      required this.currentUserId,
      required this.profilePic,
      required this.fullName,
      required this.datePosted,
      required this.fromLink});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(widget.currentUserId);
    postViews();
  }

  // Function to handle like/unlike
  void toggleLike() async {
    setState(() {
      isLiked = !isLiked;
    });

    if (isLiked) {
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(widget.postId)
          .update({
        'likes': FieldValue.arrayUnion([widget.currentUserId])
      });
    } else {
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(widget.postId)
          .update({
        'likes': FieldValue.arrayRemove([widget.currentUserId])
      });
    }
  }

  Future<void> postViews() async {
    try {
      final profileModel = Provider.of<ProfileModel>(context, listen: false);
      if (profileModel.userDetails['role'] != 'admin' && !widget.fromLink) {
        await FirebaseFirestore.instance
            .collection('announcements')
            .doc(widget.postId)
            .update({
          'views': FieldValue.arrayUnion([profileModel.userDetails['uid']])
        });
      }
    } catch (e) {
      print(e);
    }
  }

  // Function to share post (you can expand this)
  void sharePost() {
    final profileModel = Provider.of<ProfileModel>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SharePostPage(
          postDocId: widget.postId,
          postDetails: widget.postDetails,
          postPic: widget.postPic,
          senderId: widget.currentUserId,
          senderName: profileModel.userDetails[
              'full_name'], // Pass the sender's name (you can fetch this from the user model)
          senderProfilePic: profileModel.userDetails[
              'profile_pic'], // Pass the sender's profile picture URL
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileModel>(builder: (context, profileModel, child) {
      return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.black,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                      width:
                          40, // double the maxRadius to cover the entire CircleAvatar
                      height:
                          40, // double the maxRadius to cover the entire CircleAvatar
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.20), // Shadow color with opacity
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
                      child: widget.profilePic.isNotEmpty
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(widget.profilePic),
                              maxRadius: 20,
                            )
                          : const CircleAvatar(
                              backgroundImage: AssetImage(
                                  'lib/assets/default_profile_pic.png'),
                              maxRadius: 20,
                            )),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.fullName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            formatDateTime(widget.datePosted),
                            style: TextStyle(
                                color:
                                    const Color.fromARGB(255, 120, 120, 120)),
                          )
                        ],
                      ),
                    ),
                  ),
                  if (profileModel.userDetails['role'] == 'admin')
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert), // Icon for the button
                      itemBuilder: (BuildContext context) {
                        List<PopupMenuEntry<String>> items = [];

                        // change group pic
                        items.add(
                          const PopupMenuItem<String>(
                            value: 'editpost',
                            child: Text('Edit'),
                          ),
                        );

                        // leave group
                        items.add(
                          const PopupMenuItem<String>(
                            value: 'deletepost',
                            child: Text('Delete'),
                          ),
                        );

                        return items;
                      },
                      onSelected: (String value) {
                        switch (value) {
                          // Handle additional cases if needed
                          case 'editpost':
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) => PostPage(
                                      documentId: widget.postId,
                                      postDetails: widget.postDetails,
                                      postPic: widget.postPic,
                                    )));
                            break;
                          case 'deletepost':
                            _showDeleteConfirmationDialog(context);
                            break;
                        }
                      },
                    )
                ],
              ),
              // Post content
              Text(
                widget.postDetails,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),

              // Display image if available
              if (widget.postPic.isNotEmpty)
                Image.network(
                  widget.postPic,
                  // height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 10),

              // Like and Share buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Like button with heart icon
                  IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.grey,
                    ),
                    onPressed: toggleLike,
                  ),
                  // Share button
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: sharePost,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deletePost(); // Proceed with deleting the post
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePost() async {
    try {
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(widget.postId)
          .delete();

      Fluttertoast.showToast(msg: "Post deleted successfully");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting post: $e')),
      );
    }
  }

  String formatDateTime(Timestamp latestTimestamp) {
    DateTime lastChatDateTime = latestTimestamp.toDate();
    DateTime now = DateTime.now();

    Duration difference = now.difference(lastChatDateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}hr ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays <= 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('d MMM').format(lastChatDateTime);
    }
  }
}
