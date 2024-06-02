import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FriendsModel extends ChangeNotifier {
  String activeDisplay = 'suggestion';
  Map<String, dynamic> _selectedProfile = {};
  Map<String, dynamic> get selectedProfile => _selectedProfile;

  List<Map<String, dynamic>> setFriendSuggestions = [];
  List<Map<String, dynamic>> get friendSuggestions => setFriendSuggestions;

  List<Map<String, dynamic>> setFriendsList = [];
  List<Map<String, dynamic>> get friendsList => setFriendsList;

  List<String> _requestsList = [];
  List<String> get requestsList => _requestsList;

  List<Map<String, dynamic>> _requestsDataList = [];
  List<Map<String, dynamic>> get requestsDataList => _requestsDataList;

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

  void viewProfile(Map<String, dynamic> user) {
    _selectedProfile = user;
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
        List<dynamic> tempRequests = userDoc.data()?['requests'] ?? [];
        _requestsList = tempRequests.map((e) => e.toString()).toList();

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

  Future<void> addFriend(String friendUid) async {
    try {
      final userUid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(friendUid).set({
        'requests': FieldValue.arrayUnion([userUid])
      }, SetOptions(merge: true)).then((_) {
        // setFriendSuggestions
        //     .removeWhere((suggestions) => suggestions['uid'] == friendUid);
        _requestsList.add(friendUid);
        notifyListeners();

        Fluttertoast.showToast(
          msg: 'Friend request sent!',
          backgroundColor: Colors.green,
          textColor: Colors.black,
        );
      });
    } catch (e) {
      print('error adding friend: $e');
    }
  }

  Future<void> cancelRequest(String selectedUid) async {
    try {
      final userUid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(selectedUid)
          .update({
        'requests': FieldValue.arrayRemove([userUid])
      }).then((_) {
        _requestsList.remove(selectedUid);
        notifyListeners();
        Fluttertoast.showToast(
          msg: 'Friend request has been cancelled',
          backgroundColor: Colors.green,
          textColor: Colors.black,
        );
      });
    } catch (e) {
      print('an error occured while canceling request: $e');
    }
  }

  Future<void> fetchRequests() async {
    try {
      final userUid = FirebaseAuth.instance.currentUser!.uid;

      final DocumentSnapshot<Map<String, dynamic>> result =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userUid)
              .get();

      final List<dynamic> tempList = result.data()?['requests'] ?? [];
      _requestsList = tempList.map((e) => e.toString()).toList();
      print(_requestsList);
      print('execute fetch requests');

      notifyListeners();
    } catch (e) {
      print("error fetching friend requests: $e");
    }
  }

  Future<void> fetchRequestUserDetails() async {
    try {
      final userUid = FirebaseAuth.instance.currentUser!.uid;

      final DocumentSnapshot<Map<String, dynamic>> result =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userUid)
              .get();

      final List<dynamic> tempList = result.data()?['requests'] ?? [];

      tempList.forEach((e) async {
        final query =
            await FirebaseFirestore.instance.collection('users').doc(e).get();

        _requestsDataList.add(query.data() ?? {});
        notifyListeners();
      });
    } catch (e) {
      print('error fetching user details: $e');
    }
  }

  Future<void> confirmRequest(String friendUid) async {
    try {
      final String userUid = FirebaseAuth.instance.currentUser!.uid;

      // add to the current user's friend list and remove from requests
      await FirebaseFirestore.instance.collection('users').doc(userUid).set({
        'friends': FieldValue.arrayUnion([friendUid])
      }, SetOptions(merge: true)).then((_) async {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userUid)
            .update({
          'requests': FieldValue.arrayRemove([friendUid])
        });
      });

      // add the current user to the new friend's friend list
      await FirebaseFirestore.instance.collection('users').doc(friendUid).set({
        'friends': FieldValue.arrayUnion([userUid])
      }, SetOptions(merge: true));

      if (friendSuggestions.any((friend) => friend['uid'] == friendUid)) {
        setFriendSuggestions
            .removeWhere((friend) => friend['uid'] == friendUid);
        notifyListeners();
      }

      if (requestsDataList.any((friend) => friend['uid'] == friendUid)) {
        _requestsDataList.removeWhere((friend) => friend['uid'] == friendUid);
        notifyListeners();
      }
    } catch (e) {
      print('error confirming friend request: $e');
    }
  }

  Future<void> declineRequest(String selectedUid) async {
    try {
      final userUid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(userUid).update({
        'requests': FieldValue.arrayRemove([selectedUid])
      }).then((_) {
        if (requestsDataList.any((friend) => friend['uid'] == selectedUid)) {
          _requestsDataList
              .removeWhere((friend) => friend['uid'] == selectedUid);
          notifyListeners();
        }
      });
    } catch (e) {
      print('error declining request: $e');
    }
  }

  Future<void> removeFriend(String selectedUid) async {
    try {
      final userUid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(userUid).update({
        'friends': FieldValue.arrayRemove([selectedUid])
      }).then((_) async {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(selectedUid)
            .update({
          'friends': FieldValue.arrayRemove([userUid])
        });
      });
      friendsList.removeWhere((friend) => friend['uid'] == selectedUid);

      _selectedProfile['friends'].remove(userUid);
      notifyListeners();
    } catch (e) {
      print("error removing friend: $e");
    }
  }

  void resetState() {
    activeDisplay = 'suggestion';
    _selectedProfile = {};
    setFriendSuggestions = [];
    setFriendsList = [];
    _requestsDataList = [];
    _requestsList = [];
    _lastDocument = null;
    _isFetching = false;
    _hasMoreData = true;
    isInitialized = false;
    notifyListeners();
  }
}
