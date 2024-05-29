import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendsModel extends ChangeNotifier {
  String activeDisplay = 'suggestion';

  List<Map<String, dynamic>> setFriendSuggestions = [];
  List<Map<String, dynamic>> get friendSuggestions => setFriendSuggestions;

  List<Map<String, dynamic>> setFriendsList = [];
  List<Map<String, dynamic>> get friendsList => setFriendsList;

  DocumentSnapshot? _lastDocument;
  bool _isFetching = false;
  bool setHasMoreData = true;
  bool _hasMoreData = true;
  bool get hasMoreData => _hasMoreData;
  final int _limit = 10; // Number of documents to fetch per page
  bool isInitialized = false;

  FriendsModel() {
    fetchFriendSuggestions();
  }

  void changeDisplay(String newDisplay) {
    activeDisplay = newDisplay;
    notifyListeners();
  }

  Future<void> fetchFriendSuggestions({bool loadMore = false}) async {
    if (_isFetching || !_hasMoreData) {
      print('executed this one');
      return;
    }

    _isFetching = true;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      if (!loadMore) {
        print('executed this');
        setFriendSuggestions = [];
        _lastDocument = null;
        _hasMoreData = true;
      }

      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        List<dynamic> friendList = userDoc.data()?['friends'] ?? [];
        print(friendList);

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
              .where((doc) => !friendList.contains(doc['uid']))
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          setFriendSuggestions.addAll(newSuggestions); //setFriend suggestions

          if (newSuggestions.length < _limit) {
            _hasMoreData = false; // No more data to fetch
          }
        } else {
          _hasMoreData = false; // No more data to fetch
        }

        isInitialized = true;
        notifyListeners();
      }
    } catch (e) {
      print('Error querying documents: $e');
    } finally {
      _isFetching = false;
    }
  }

  Future<void> fetchFriendsList() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        List<dynamic> friendList = userDoc.data()?['friends'] ?? [];

        // Clear previous friends list
        setFriendsList = [];

        print(friendList);

        for (var friendUid in friendList) {
          final DocumentSnapshot<Map<String, dynamic>> friendData =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(friendUid)
                  .get();

          setFriendsList.add(friendData.data() ?? {});
        }

        isInitialized = true;
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  void resetState() {
    setFriendSuggestions = [];
    setFriendsList = [];
    _lastDocument = null;
    _isFetching = false;
    _hasMoreData = true;
    isInitialized = false;
    notifyListeners();
  }
}
