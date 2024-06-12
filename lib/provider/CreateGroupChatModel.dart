import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateGroupChatModel extends ChangeNotifier {
  List<String> _selectedUsers = [];
  List<String> get selectedUsers => _selectedUsers;
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  XFile? image;

  List<Map<String, dynamic>> _memberSuggestions = [];
  List<Map<String, dynamic>> get memberSuggestions => _memberSuggestions;

  DocumentSnapshot? _lastDocument;
  bool _isFetching = false;
  bool setHasMoreData = true;
  bool _hasMoreData = true;
  bool get hasMoreData => _hasMoreData;
  final int _limit = 10; // Number of documents to fetch per page
  bool isInitialized = false;

  Future<void> selectImage() async {
    final picker = ImagePicker();
    image = await picker.pickImage(source: ImageSource.gallery);
    notifyListeners();
  }

  Future<void> fetchMemberSuggestions({bool loadMore = false}) async {
    if (_isFetching || !_hasMoreData) {
      print('executed this one');
      return;
    }

    _isFetching = true;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      if (!loadMore) {
        print('executed this');
        _memberSuggestions = [];
        _lastDocument = null;
        _hasMoreData = true;
      }

      // final DocumentSnapshot<Map<String, dynamic>> userDoc =
      //     await FirebaseFirestore.instance.collection('users').doc().get();

      // if (userDoc.exists) {
      // List<dynamic> friendList = userDoc.data()?['friends'] ?? [];
      // print(friendList);

      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('users')
          .where('uid', isNotEqualTo: uid)
          .limit(_limit);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final QuerySnapshot<Map<String, dynamic>> result = await query.get();
      if (result.docs.isNotEmpty) {
        _lastDocument = result.docs.last;

        final newSuggestions = result.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        _memberSuggestions.addAll(newSuggestions); //setFriend suggestions

        if (newSuggestions.length < _limit) {
          _hasMoreData = false; // No more data to fetch
        }
      } else {
        _hasMoreData = false; // No more data to fetch
      }

      isInitialized = true;
      notifyListeners();
      print(_memberSuggestions);
      // }
    } catch (e) {
      print('Error querying documents: $e');
    } finally {
      _isFetching = false;
    }
  }

  void addUser(String userId) {
    if (!_selectedUsers.contains(userId)) {
      _selectedUsers.add(userId);
      notifyListeners();
    }
  }

  void removeUser(String userId) {
    if (_selectedUsers.contains(userId)) {
      _selectedUsers.remove(userId);
      notifyListeners();
    }
  }

  Future<void> createGroupChat(Map<String, dynamic> _userDetails) async {
    try {
      // Upload the image to Firebase Storage
      final userUid = _userDetails['uid'];

      // final DocumentSnapshot<Map<String, dynamic>> userDoc =
      //     await FirebaseFirestore.instance.collection('users').doc().get();

      if (image != null &&
          nameController.text.isNotEmpty &&
          descriptionController.text.isNotEmpty) {
        // if (userDoc.exists) {
        final String userName = _userDetails['full_name'];

        final storageRef = FirebaseStorage.instance.ref().child(
            'group_chat/${nameController.text}/group_pic/${DateTime.now().microsecondsSinceEpoch}.jpg');
        await storageRef.putFile(File(image!.path));

        // Get the download URL of the uploaded image
        final imageUrl = await storageRef.getDownloadURL();

        final timeSent = Timestamp.now();

        DocumentReference groupRef =
            await FirebaseFirestore.instance.collection('groups').add({
          'group_pic': imageUrl,
          'group_name': nameController.text,
          'group_description': descriptionController.text,
          'admin': [userUid],
          'members': [userUid, ...selectedUsers],
          'latest_chat_message': '$userName created the group',
          'latest_chat_user': userUid,
          'latest_timestamp': timeSent,
        });

        String groupDocId = groupRef.id;

        await FirebaseFirestore.instance
            .collection('groups')
            .doc(groupDocId)
            .collection('messages')
            .add({
          'is_read': false,
          'content': '$userName created the group',
          'sender_id': userUid,
          'timestamp': timeSent,
          'type': 'notify'
        });
        // }
      }
    } catch (e) {
      print('failed to create group chat: $e');
    } finally {
      nameController.clear();
      descriptionController.clear();
      image = null;
      _selectedUsers = [];
      notifyListeners();
    }
  }

  void reset() {
    _selectedUsers = [];
    nameController.clear();
    descriptionController.clear();
    image = null;
    _memberSuggestions = [];
    _lastDocument = null;
  }
}
