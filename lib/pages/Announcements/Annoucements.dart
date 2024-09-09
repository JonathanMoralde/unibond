import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/Announcements/PostPage.dart';
import 'package:unibond/provider/ProfileModel.dart';
import 'package:unibond/widgets/Announcements/PostCard.dart';
import 'package:unibond/widgets/styledButton.dart';
import 'package:unibond/widgets/styledTextFormField.dart';

class Announcements extends StatefulWidget {
  const Announcements({super.key});

  @override
  State<Announcements> createState() => _AnnouncementsState();
}

class _AnnouncementsState extends State<Announcements> {
  final postController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProfileModel>(builder: (context, profileModel, child) {
        return SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (profileModel.userDetails['role'] == 'admin')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width:
                            50, // double the maxRadius to cover the entire CircleAvatar
                        height:
                            50, // double the maxRadius to cover the entire CircleAvatar
                        decoration: BoxDecoration(
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
                        child: profileModel.userDetails['profile_pic'] != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(
                                    profileModel.userDetails['profile_pic']),
                                maxRadius: 25,
                              )
                            : const CircleAvatar(
                                backgroundImage: AssetImage(
                                    'lib/assets/default_profile_pic.png'),
                                maxRadius: 25,
                              )),
                    StyledButton(
                      btnWidth: MediaQuery.sizeOf(context).width * 0.75,
                      noShadow: true,
                      isBorder: true,
                      borderColor: Colors.black,
                      btnColor: Colors.white,
                      textColor: Colors.grey,
                      btnText: 'Post something...        ',
                      iconOnRight: true,
                      btnIcon: Icon(Icons.post_add),
                      onClick: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) => PostPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              // Text('announcements'),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('announcements')
                    .orderBy('date_posted', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading posts'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No announcements available'));
                  }

                  // Display the list of posts
                  return ListView.builder(
                    padding: EdgeInsets.only(top: 8),
                    physics:
                        const NeverScrollableScrollPhysics(), // For proper scrolling in Column
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot post = snapshot.data!.docs[index];
                      return PostCard(
                        fromLink: false,
                        datePosted: post['date_posted'],
                        fullName: post['posted_by'],
                        profilePic: post['posted_by_profile_pic'],
                        postDetails: post['post_details'],
                        postPic: post['post_pic'],
                        likes: List<String>.from(post['likes']),
                        postId: post.id,
                        currentUserId: profileModel.userDetails[
                            'uid'], // Assume user UID is stored here
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ));
      }),
    );
  }
}
