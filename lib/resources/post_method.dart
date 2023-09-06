import 'dart:io';
import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kolot/models/comment_model.dart';
import 'package:kolot/models/post_model.dart';
import 'package:kolot/resources/storage_method.dart';

class PostMethods {
  static final FirebaseFirestore _firebaseFirestore =
      FirebaseFirestore.instance;

  // Get All Posts
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllPosts() {
    Stream<QuerySnapshot<Map<String, dynamic>>> snap = _firebaseFirestore
        .collection("posts")
        .orderBy(
          "time",
          descending: true,
        )
        .snapshots();

    return snap;
  }

  // for (var i = 0; i < await snap.length; i++) {
  //   await Future.delayed(Duration(milliseconds: 500));
  //   yield snap;
  // }

  // Users' Posts
  static Future<List<QueryDocumentSnapshot>> getUserPosts(String userId) async {
    QuerySnapshot snap = await _firebaseFirestore
        .collection("posts")
        .where("uid", isEqualTo: userId)
        .get();

    return snap.docs;
  }

  // Posting from Mobile
  static Future<String> postMobile({
    required String postId,
    required String caption,
    required String type,
    required File media,
  }) async {
    String res = "error";

    try {
      // Upload Media
      String mediaUrl = await StorageMethods.uploadMediaMobile(
        childName: "postMedia",
        file: media,
      );

      String mediaName = Uri.parse(mediaUrl).pathSegments.last.substring(10);

      // post
      final post = PostModel(
        postId: postId,
        userId: postId,
        caption: caption,
        mediaUrl: mediaUrl,
        mediaName: mediaName,
        type: type,
        likes: [],
        comments: [],
        time: DateTime.now(),
      );

      // Add Post to Firebase
      await _firebaseFirestore.collection("posts").doc("aw").set(
            post.toJson(),
          );

      res = "success";
    } on FirebaseAuthException catch (e) {
      res = e.toString();
    }

    return res;
  }

  // Posting from Web
  static Future<String> postWeb({
    required String postId,
    required String caption,
    required String type,
    required html.File media,
  }) async {
    String res = "error";

    try {
      // Upload Media
      String mediaUrl = await StorageMethods.uploadMediaWeb(
        childName: "postMedia",
        file: media,
      );
      String mediaName = Uri.parse(mediaUrl).pathSegments.last.substring(10);

      // Tidak Error Upload Media
      if (mediaUrl != "error") {
        // post
        final post = PostModel(
          postId: postId,
          userId: postId,
          caption: caption,
          mediaUrl: mediaUrl,
          mediaName: mediaName,
          type: type,
          likes: [],
          comments: [],
          time: DateTime.now(),
        );

        // Add Post to Firebase
        await _firebaseFirestore.collection("posts").doc().set(
              post.toJson(),
            );

        res = "success";
      }

      // Error Upload Media
      else {
        res = "error";
      }
    } on FirebaseAuthException catch (e) {
      res = e.toString();
    }

    return res;
  }

  // Give or Remove Like
  static Future<bool> giveRemoveLike({
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
      return true;
    } else {
      likes.remove(userId);
      await _firebaseFirestore
          .collection("posts")
          .doc(postId)
          .update({"likes": likes});
      return false;
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
  static Future<String> deletePost(PostModel post, String docId) async {
    String res = "error";

    try {
      String delete = await StorageMethods.deleteMedia(post.mediaName);
      if (delete == "success") {
        await _firebaseFirestore.collection("posts").doc(docId).delete();
      }
      res = "success";
    } catch (e) {
      res = "error";
    }

    return res;
  }
}
