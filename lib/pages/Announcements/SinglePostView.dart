import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:unibond/provider/ProfileModel.dart';
import 'package:unibond/widgets/Announcements/PostCard.dart';

class SinglePostView extends StatefulWidget {
  final String postId; // Ensure proper typing here
  const SinglePostView({super.key, required this.postId});

  @override
  State<SinglePostView> createState() => _SinglePostViewState();
}

class _SinglePostViewState extends State<SinglePostView> {
  Map<String, dynamic>? postDetail;
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    fetchPostDetail();
  }

  Future<void> fetchPostDetail() async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('announcements')
          .doc(widget.postId)
          .get();

      if (result.exists && result.data() != null) {
        final data = result.data() as Map<String, dynamic>;
        setState(() {
          postDetail = data;
          isLoading = false; // Data fetched successfully, stop loading
        });
      } else {
        setState(() {
          isLoading = false; // Stop loading even if no data
        });
        Fluttertoast.showToast(msg: "Announcement not found");
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false; // Stop loading on error
      });
      Fluttertoast.showToast(msg: "Error fetching announcement");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement'),
      ),
      body: Consumer<ProfileModel>(builder: (context, profileModel, child) {
        // Show loading indicator while fetching data
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // If postDetail is null, display a message
        if (postDetail == null) {
          return const Center(child: Text('No announcement found.'));
        }

        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: PostCard(
                fromLink: true,
                postDetails: postDetail!['post_details'] ??
                    '', // Ensure fallback if null
                postPic:
                    postDetail!['post_pic'] ?? '', // Default to empty string
                likes: (postDetail!['likes'] as List<dynamic>)
                    .map((e) => e.toString())
                    .toList(), // Handle null 'likes' with default 0
                postId: widget.postId,
                currentUserId: profileModel.userDetails['uid'] ?? '',
                profilePic: postDetail!['posted_by_profile_pic'] ?? '',
                fullName: postDetail!['posted_by'] ?? 'Unknown',
                datePosted: postDetail!['date_posted'] != null
                    ? (postDetail!['date_posted'] as Timestamp)
                    : Timestamp.now(), // Handle null date
              ),
            ),
          ),
        );
      }),
    );
  }
}
