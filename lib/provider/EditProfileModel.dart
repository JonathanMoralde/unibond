import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditProfileModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  List<String> setSelectedInterests = [];

  List<String> get selectedInterests => setSelectedInterests;

  TextEditingController bioController = TextEditingController();

  void addInterest(String value) {
    if (setSelectedInterests.contains(value)) {
      setSelectedInterests.remove(value);
      return;
    }
    setSelectedInterests.add(value);
  }

  Future<void> saveProfilePicture(File _image, User user) async {
    try {
      // Upload the image to Firebase Storage
      // final User? user = FirebaseAuth.instance.currentUser;
      final storageRef =
          _firebaseStorage.ref().child('profile_pictures/${user.uid}.jpg');
      await storageRef.putFile(_image);

      // Get the download URL of the uploaded image
      final imageUrl = await storageRef.getDownloadURL();

      // Update the user's profile information in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'profile_pic': imageUrl}).then((_) {
        print('Profile pic was saved successfully');
      });
    } catch (e) {
      print(e);
      print('unable to save profile pic');
    }
  }

  Future<void> saveBio(String bio, User user) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'bio': bio}).then((_) {
        print('Bio was saved successfully');
      });
    } catch (e) {
      print(e);
      print('unable to save bio');
    }
  }

  Future<void> saveInterests(List<String> interests, User user) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'interests': interests}).then((_) {
        print('Interests was saved successfully');
      });
    } catch (e) {
      print(e);
      print('unable to save interests');
    }
  }
}
