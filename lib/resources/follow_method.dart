import 'package:cloud_firestore/cloud_firestore.dart';

class FollowMethods {
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<String> follow({
    required String followerId,
    required String followingId,
  }) async {
    String res = '';

    DocumentSnapshot followingSnap =
        await _firestore.collection("users").doc(followingId).get();
    DocumentSnapshot followerSnap =
        await _firestore.collection("users").doc(followerId).get();

    // Followers yang di-follow
    List followerFollowing = followingSnap['followers'];

    // Following follower
    List followingFollower = followerSnap['following'];

    // Belum di-follow
    if (!followerFollowing.contains(followerId)) {
      // Tambah Follower yang di-follow
      followerFollowing.add(followerId);
      await _firestore
          .collection("users")
          .doc(followingId)
          .update({"followers": followerFollowing});

      // Tambah Following follower
      followingFollower.add(followingId);
      await _firestore
          .collection("users")
          .doc(followerId)
          .update({"following": followingFollower});

      res = "success";
    }

    // Sudah di-follow
    else {
      followerFollowing.remove(followerId);
      await _firestore
          .collection("users")
          .doc(followingId)
          .update({"followers": followerFollowing});

      // Tambah Following follower
      followingFollower.remove(followingId);
      await _firestore
          .collection("users")
          .doc(followerId)
          .update({"following": followingFollower});
    }

    return res;
  }
}
