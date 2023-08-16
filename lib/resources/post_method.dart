import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kolot/models/comment_model.dart';

import 'package:kolot/models/post_model.dart';
import 'package:kolot/resources/storage_method.dart';

class PostMethods {
  static final FirebaseFirestore _firebaseFirestore =
      FirebaseFirestore.instance;

  // Post Details
  static Stream<QuerySnapshot<Map<String, dynamic>>> getPostDetails() {
    Stream<QuerySnapshot<Map<String, dynamic>>> snap = _firebaseFirestore
        .collection("posts")
        .orderBy(
          "time",
          descending: true,
        )
        .snapshots();

    return snap;
  }

  // Users' Posts
  static Future<List<QueryDocumentSnapshot>> getUserPosts(String userId) async {
    QuerySnapshot snap = await _firebaseFirestore
        .collection("posts")
        .where("uid", isEqualTo: userId)
        .get();

    return snap.docs;
  }

  // Posting
  static Future<String> post({
    required String postId,
    required String caption,
    required Uint8List media,
  }) async {
    String res = "Coba";

    try {
      // Upload Media
      String mediaUrl = await StorageMethods.uploadMedia(
        childName: "postMedia",
        file: media,
        isPost: false,
      );

      // post
      final post = PostModel(
        postId: postId,
        userId: postId,
        caption: caption,
        mediaUrl: mediaUrl,
        likes: [],
        comments: [],
        time: DateTime.now(),
      );

      // Add Post to Firebase
      await _firebaseFirestore.collection("posts").doc().set(
            post.toJson(),
          );

      res = "Success";
    } on FirebaseAuthException catch (e) {
      res = e.toString();
    }

    return res;
  }

  // Give or Remove Like
  static Future giveRemoveLike({
    required String postId,
    required String userId,
  }) async {
    DocumentSnapshot snap =
        await _firebaseFirestore.collection("posts").doc(postId).get();

    List likes = snap['likes'];

    if (!likes.contains(userId)) {
      likes.add(userId);
      await _firebaseFirestore
          .collection("posts")
          .doc(postId)
          .update({"likes": likes});
    } else {
      likes.remove(userId);
      await _firebaseFirestore
          .collection("posts")
          .doc(postId)
          .update({"likes": likes});
    }
  }

  // Add Comment
  static Future<String> addComment(CommentModel comment,
      {required String postId}) async {
    String res = "";

    DocumentSnapshot snap =
        await _firebaseFirestore.collection("posts").doc(postId).get();

    List comments = snap['comments'];

    comments.add(comment.toJson());

    res = await _firebaseFirestore
        .collection("posts")
        .doc(postId)
        .update({"comments": comments})
        .then((value) => "success")
        .onError((error, stackTrace) => "error");

    return res;
  }

  // Delete Post
  static Future<String> deletePost(String postId) async {
    String res = "";
    await _firebaseFirestore
        .collection("posts")
        .doc(postId)
        .delete()
        .then((value) => res = "success")
        .onError((error, stackTrace) => res = "error");

    return res;
  }
}
