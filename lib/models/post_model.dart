import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String userId;
  final String caption;
  final String mediaUrl;
  final List likes;
  final DateTime time;

  PostModel({
    required this.postId,
    required this.userId,
    required this.caption,
    required this.mediaUrl,
    required this.likes,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        "postId": postId,
        "uid": userId,
        "caption": caption,
        "mediaUrl": mediaUrl,
        "likes": likes,
        "time": time,
      };

  static PostModel fromSnap(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;

    return PostModel(
      postId: snap['postId'],
      userId: snap['uid'],
      caption: snap['caption'],
      mediaUrl: snap['mediaUrl'],
      likes: snap['likes'],
      time: snap['time'].toDate(),
    );
  }
}
