import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupModel extends ChangeNotifier {
  List<Map<String, dynamic>> _groupList = [];
  List<Map<String, dynamic>> get groupList => _groupList;

  DocumentSnapshot? _lastMemberDocument;
  DocumentSnapshot? _lastNonMemberDocument;
  bool _isFetching = false;
  bool _hasMoreData = true;
  bool get hasMoreData => _hasMoreData;
  final int _limit = 10; // Number of documents to fetch per page
  bool isInitialized = false;

  Future<void> fetchGroups({bool loadMore = false}) async {
    if (_isFetching || !_hasMoreData) {
      print('Already fetching or no more data.');
      return;
    }

    _isFetching = true;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      if (!loadMore) {
        _groupList = [];
        _lastMemberDocument = null;
        _lastNonMemberDocument = null;
        _hasMoreData = true;
      }

      // First, fetch groups where the user is a member
      Query<Map<String, dynamic>> memberQuery = FirebaseFirestore.instance
          .collection('groups')
          .where('members', arrayContains: uid)
          .limit(_limit);

      if (_lastMemberDocument != null) {
        memberQuery = memberQuery.startAfterDocument(_lastMemberDocument!);
      }

      final QuerySnapshot<Map<String, dynamic>> memberResult =
          await memberQuery.get();
      if (memberResult.docs.isNotEmpty) {
        _lastMemberDocument = memberResult.docs.last;

        final memberGroups = memberResult.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        _groupList.addAll(memberGroups);

        if (memberGroups.length < _limit) {
          print('line 55');
          // Fetch non-member groups if member groups are less than limit
          int remainingLimit = _limit - memberGroups.length;

          Query<Map<String, dynamic>> nonMemberQuery = FirebaseFirestore
              .instance
              .collection('groups')
              .where(uid, whereNotIn: [uid]).limit(remainingLimit);

          if (_lastNonMemberDocument != null) {
            nonMemberQuery =
                nonMemberQuery.startAfterDocument(_lastNonMemberDocument!);
          }

          final QuerySnapshot<Map<String, dynamic>> nonMemberResult =
              await nonMemberQuery.get();
          if (nonMemberResult.docs.isNotEmpty) {
            print('line 72');
            _lastNonMemberDocument = nonMemberResult.docs.last;

            final nonMemberGroups = nonMemberResult.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();

            // nonMemberGroups.removeWhere((group) => _groupList.contains(group));

            _groupList.addAll(nonMemberGroups);

            if (nonMemberGroups.length < remainingLimit) {
              _hasMoreData = false; // No more data to fetch
            }
          } else {
            _hasMoreData = false; // No more data to fetch
          }
        }
      } else {
        // If no member groups found, directly fetch non-member groups
        Query<Map<String, dynamic>> nonMemberQuery =
            FirebaseFirestore.instance.collection('groups').limit(_limit);

        if (_lastNonMemberDocument != null) {
          nonMemberQuery =
              nonMemberQuery.startAfterDocument(_lastNonMemberDocument!);
        }

        final QuerySnapshot<Map<String, dynamic>> nonMemberResult =
            await nonMemberQuery.get();
        if (nonMemberResult.docs.isNotEmpty) {
          _lastNonMemberDocument = nonMemberResult.docs.last;

          final nonMemberGroups = nonMemberResult.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          _groupList.addAll(nonMemberGroups);

          if (nonMemberGroups.length < _limit) {
            _hasMoreData = false; // No more data to fetch
          }
        } else {
          _hasMoreData = false; // No more data to fetch
        }
      }

      isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error querying documents: $e');
    } finally {
      _isFetching = false;
    }
  }

  void resetState() {
    _groupList = [];
    _lastMemberDocument = null;
    _lastNonMemberDocument = null;
    _hasMoreData = true;
    _isFetching = false;
    notifyListeners();
  }
}
