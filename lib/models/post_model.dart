import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String userId;
  final String caption;
  final String mediaUrl;
  final String mediaName;
  final String type;
  final List likes;
  final List comments;
  final DateTime time;

  PostModel({
    required this.postId,
    required this.userId,
    required this.caption,
    required this.mediaUrl,
    required this.mediaName,
    required this.type,
    required this.likes,
    required this.comments,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        "postId": postId,
        "uid": userId,
        "caption": caption,
        "mediaUrl": mediaUrl,
        "mediaName": mediaName,
        "type": type,
        "likes": likes,
        "comments": comments,
        "time": time,
      };

  static PostModel fromSnap(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;

    return PostModel(
      postId: snap['postId'],
      userId: snap['uid'],
      caption: snap['caption'],
      mediaUrl: snap['mediaUrl'],
      mediaName: snap['mediaName'],
      type: snap['type'],
      likes: snap['likes'],
      comments: snap['comments'],
      time: snap['time'].toDate(),
    );
  }
}
