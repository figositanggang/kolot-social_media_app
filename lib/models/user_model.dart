import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String name;
  final String bio;
  final String photoUrl;
  final List followers;
  final List following;

  const UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.name,
    required this.bio,
    required this.photoUrl,
    required this.followers,
    required this.following,
  });

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "email": email,
        "username": username,
        "name": name,
        "bio": bio,
        "photoUrl": photoUrl,
        "followers": followers,
        "following": following,
      };

  static UserModel fromSnap(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;

    return UserModel(
      uid: snap['uid'],
      email: snap['email'],
      username: snap['username'],
      name: snap['name'],
      bio: snap['bio'],
      photoUrl: snap['photoUrl'],
      followers: snap['followers'],
      following: snap['following'],
    );
  }
}
