import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:unibond/provider/ProfileModel.dart';

class PostPage extends StatefulWidget {
  final String? documentId; // For editing an existing post
  final String? postDetails;
  final String? postPic;
  const PostPage({super.key, this.documentId, this.postDetails, this.postPic});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController _postController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Prepopulate fields if it's an edit operation
    if (widget.postDetails != null) {
      _postController.text = widget.postDetails!;
    }
    if (widget.postPic != null) {
      // Load image from postPic (optional)
    }
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  // Function to pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> createPost({
    required String postDetails,
    File? imageFile,
    required String fullName, // posted_by
    required String uid,
    required String profile_pic,
  }) async {
    setState(() {
      isLoading = true;
    });
    // Firestore and Storage instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseStorage storage = FirebaseStorage.instance;

    // Prepare post data
    String postId = firestore
        .collection('announcements')
        .doc()
        .id; // Create a unique post ID
    String? imageUrl;

    // Step 1: Upload image if available
    if (imageFile != null) {
      try {
        // Define the storage reference path
        Reference storageRef = storage.ref().child('announcements/$postId.jpg');

        // Upload the image file
        UploadTask uploadTask = storageRef.putFile(imageFile);

        // Get the download URL after the upload is complete
        TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
        imageUrl = await snapshot.ref.getDownloadURL();
      } catch (e) {
        print('Error uploading image: $e');
        return;
      }
    }

    // Step 2: Insert post details into Firestore
    try {
      await firestore.collection('announcements').doc(postId).set({
        'post_details': postDetails, // Post text content
        'post_pic': imageUrl ?? '', // Image URL (empty string if no image)
        'posted_by': fullName, // User ID who posted
        'posted_by_uid': uid,
        'posted_by_profile_pic': profile_pic,
        'date_posted': FieldValue.serverTimestamp(), // Server timestamp
        'likes': [], // Empty list of likes
        'views': [], // Empty list of views
      });

      print('Post created successfully!');
    } catch (e) {
      print('Error creating post: $e');
    }
  }

  Future<void> editPost({
    required String postDetails,
    File? imageFile,
    required String documentId,
  }) async {
    setState(() {
      isLoading = true;
    });

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseStorage storage = FirebaseStorage.instance;
    String? imageUrl = widget.postPic; // Use existing image if no new image

    // Step 1: Upload new image if available
    if (imageFile != null) {
      try {
        Reference storageRef =
            storage.ref().child('announcements/$documentId.jpg');
        UploadTask uploadTask = storageRef.putFile(imageFile);
        TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
        imageUrl = await snapshot.ref.getDownloadURL();
      } catch (e) {
        print('Error uploading image: $e');
        return;
      }
    }

    // Step 2: Update post details in Firestore
    try {
      await firestore.collection('announcements').doc(documentId).update({
        'post_details': postDetails,
        'post_pic': imageUrl ?? '',
      });
      print('Post edited successfully!');
      Navigator.pop(context);
    } catch (e) {
      print('Error editing post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.documentId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Post' : 'Create Post'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              child: isLoading
                  ? CircularProgressIndicator()
                  : Text(isEditMode ? 'SAVE' : 'POST'),
              onTap: () {
                final profileModel =
                    Provider.of<ProfileModel>(context, listen: false);
                // Handle post submission logic
                if (isEditMode) {
                  editPost(
                    postDetails: _postController.text,
                    imageFile: _imageFile,
                    documentId: widget.documentId!,
                  ).then((_) {
                    setState(() {
                      isLoading = false;
                      _postController.clear();
                      _imageFile = null;
                    });
                  });
                } else {
                  createPost(
                          postDetails: _postController.text,
                          fullName: profileModel.userDetails['full_name'],
                          uid: profileModel.userDetails['uid'],
                          imageFile: _imageFile,
                          profile_pic: profileModel.userDetails['profile_pic'])
                      .then((_) {
                    setState(() {
                      isLoading = false;
                      _postController.clear();
                      _imageFile = null;
                    });
                  });
                }
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // TextField for post content
              TextField(
                controller: _postController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Type something for your post",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Display selected image if exists
              _imageFile != null
                  ? Image.file(
                      _imageFile!,
                      height: 200,
                    )
                  : (widget.postPic != null)
                      ? Image.network(widget.postPic!)
                      : SizedBox.shrink(),
              SizedBox(height: 16),

              // Buttons for selecting image from camera or gallery
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  IconButton(
                    icon: Icon(Icons.image),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                  Text(isEditMode ? 'Change Image' : 'Add an image'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
