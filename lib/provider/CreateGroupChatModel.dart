import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
        // ? Check first if existing group name exist
        final query = await FirebaseFirestore.instance
            .collection('groups')
            .where('group_name', isEqualTo: nameController.text)
            .get();

        if (query.docs.isNotEmpty) {
          Fluttertoast.showToast(
              msg: 'Group name is already taken!', backgroundColor: Colors.red);
          return;
        }

        // if (userDoc.exists) {
        final String userName = _userDetails['full_name'];
        final String userProfPic = _userDetails['profile_pic'];

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
          'type': 'notify',
          'sender_name': userName,
          'sender_profile_pic': userProfPic,
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

  Future<void> editGroup(
      Map<String, dynamic> _userDetails, String groupDocId) async {
    try {
      // fetch the group uid
      final groupRef =
          FirebaseFirestore.instance.collection('groups').doc(groupDocId);

      // Upload the image to Firebase Storage
      final userUid = _userDetails['uid'];

      final String userName = _userDetails['full_name'];
      final String userProfPic = _userDetails['profile_pic'];

      if (image != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
            'group_chat/${nameController.text}/group_pic/${DateTime.now().microsecondsSinceEpoch}.jpg');
        await storageRef.putFile(File(image!.path));

        // Get the download URL of the uploaded image
        final imageUrl = await storageRef.getDownloadURL();

        await groupRef.update({
          'group_pic': imageUrl,
          'latest_chat_message': '$userName changed the group photo',
          'latest_chat_user': userUid,
          'latest_timestamp': Timestamp.now(),
        });

        await groupRef.collection('messages').add({
          'is_read': false,
          'content': '$userName changed the group photo',
          'sender_id': userUid,
          'timestamp': Timestamp.now(),
          'type': 'notify',
          'sender_name': userName,
          'sender_profile_pic': userProfPic,
        });

        final query = await FirebaseFirestore.instance
            .collection('notification')
            .where('is_group', isEqualTo: true)
            .where('chat_doc_id', isEqualTo: groupDocId)
            .get();

        if (query.docs.isNotEmpty) {
          for (final doc in query.docs) {
            await FirebaseFirestore.instance
                .collection('notification')
                .doc(doc.id)
                .update({'group_pic': imageUrl});
          }
        }
      }

      if (nameController.text.isNotEmpty) {
        // ? Check first if existing group name exist
        final groupNameQuery = await FirebaseFirestore.instance
            .collection('groups')
            .where('group_name', isEqualTo: nameController.text)
            .get();

        if (groupNameQuery.docs.isNotEmpty) {
          Fluttertoast.showToast(
              msg: 'Group name is already taken!', backgroundColor: Colors.red);
          return;
        }

        await groupRef.update({
          'group_name': nameController.text,
          'latest_chat_message':
              '$userName changed the group name to ${nameController.text}',
          'latest_chat_user': userUid,
          'latest_timestamp': Timestamp.now(),
        });

        await groupRef.collection('messages').add({
          'is_read': false,
          'content':
              '$userName changed the group name to ${nameController.text}',
          'sender_id': userUid,
          'timestamp': Timestamp.now(),
          'type': 'notify',
          'sender_name': userName,
          'sender_profile_pic': userProfPic,
        });

        final query = await FirebaseFirestore.instance
            .collection('notification')
            // .where('is_group', isEqualTo: true)
            .where('chat_doc_id', isEqualTo: groupDocId)
            .get();

        if (query.docs.isNotEmpty) {
          for (final doc in query.docs) {
            await FirebaseFirestore.instance
                .collection('notification')
                .doc(doc.id)
                .update({'group_name': nameController.text});
          }
        }

        final groupData = await groupRef.get();
        final groupDataMap = groupData.data() as Map<String, dynamic>;

        final query2 = await FirebaseFirestore.instance
            .collection('notification')
            .where('group_name', isEqualTo: groupDataMap['group_name'])
            .get();

        if (query2.docs.isNotEmpty) {
          for (final doc in query2.docs) {
            await FirebaseFirestore.instance
                .collection('notification')
                .doc(doc.id)
                .update({'group_name': nameController.text});
          }
        }
      }

      if (descriptionController.text.isNotEmpty) {
        await groupRef.update({
          'group_description': descriptionController.text,
          'latest_chat_message': '$userName changed the group description',
          'latest_chat_user': userUid,
          'latest_timestamp': Timestamp.now(),
        });

        await groupRef.collection('messages').add({
          'is_read': false,
          'content': '$userName changed the group description',
          'sender_id': userUid,
          'timestamp': Timestamp.now(),
          'type': 'notify',
          'sender_name': userName,
          'sender_profile_pic': userProfPic,
        });
      }
    } catch (e) {
      print('failed to edit group chat: $e');
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

  // For AddPeople.dart
  Future<void> addPeopleToGroup(
      String groupDocId, Map<String, dynamic> currentUser) async {
    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupDocId)
          .update({'members': FieldValue.arrayUnion(selectedUsers)}).then(
              ((_) async {
        for (final uid in selectedUsers) {
          final data = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();
          final dataMap = data.data() as Map<String, dynamic>;

          await FirebaseFirestore.instance
              .collection('groups')
              .doc(groupDocId)
              .update({
            'latest_chat_message':
                '${currentUser['full_name']} added ${dataMap['full_name']} to the group',
            'latest_chat_user': currentUser['uid'],
            'latest_timestamp': Timestamp.now(),
          });

          await FirebaseFirestore.instance
              .collection('groups')
              .doc(groupDocId)
              .collection('messages')
              .add({
            'is_read': false,
            'content':
                '${currentUser['full_name']} added ${dataMap['full_name']} to the group',
            'sender_id': currentUser['uid'],
            'timestamp': Timestamp.now(),
            'type': 'notify',
            'sender_name': currentUser['full_name'],
            'sender_profile_pic': currentUser['profile_pic'],
          });
        }
      }));
    } catch (e) {
      print("an error occured while adding people: $e");
    }
  }

  void resetSelected() {
    _selectedUsers = [];
  }
}
