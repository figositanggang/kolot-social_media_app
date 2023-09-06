import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kolot/models/user_model.dart';

class FollowMethods {
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static User _currentUser = FirebaseAuth.instance.currentUser!;

  // Follow
  static Future<String> follow(String ouid) async {
    String res = 'error';

    // Current User Snap
    DocumentSnapshot currentUserSnap =
        await _firestore.collection("users").doc(_currentUser.uid).get();
    // Other User Snap
    DocumentSnapshot otherUserSnap =
        await _firestore.collection("users").doc(ouid).get();

    // Following Current User
    List followingCurrentUser = currentUserSnap['following'];
    // Follower Other User
    List followerOtherUser = otherUserSnap['followers'];

    // Tambah Following Current User
    followingCurrentUser.add(ouid);
    await _firestore
        .collection("users")
        .doc(_currentUser.uid)
        .update({"following": followingCurrentUser});

    // Tambah Follower Other User
    followerOtherUser.add(_currentUser.uid);
    await _firestore
        .collection("users")
        .doc(ouid)
        .update({"followers": followerOtherUser});

    return res;
  }

  static Future<String> unFollow(String ouid) async {
    String res = "error";

    // Current User Snap
    DocumentSnapshot currentUserSnap =
        await _firestore.collection("users").doc(_currentUser.uid).get();
    // Other User Snap
    DocumentSnapshot otherUserSnap =
        await _firestore.collection("users").doc(ouid).get();

    // Following Current User
    List followingCurrentUser = currentUserSnap['following'];
    // Follower Other User
    List followerOtherUser = otherUserSnap['followers'];

    // Hapus Following Current User
    followingCurrentUser.remove(ouid);
    await _firestore
        .collection("users")
        .doc(_currentUser.uid)
        .update({"following": followingCurrentUser});

    // Hapus Follower Other User
    followerOtherUser.remove(_currentUser.uid);
    await _firestore
        .collection("users")
        .doc(ouid)
        .update({"followers": followerOtherUser});

    return res;
  }

  // Check Following
  static Future<bool> isFollowed(String ouid) async {
    DocumentSnapshot<Map<String, dynamic>> snap =
        await _firestore.collection("users").doc(ouid).get();

    UserModel user = UserModel.fromSnap(snap);

    // Followed
    if (user.followers.contains(_currentUser.uid)) {
      return true;
    }

    return false;
  }
}
