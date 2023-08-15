import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kolot/components/like_button.dart';

class UserPost extends StatefulWidget {
  final String email;
  final String bacot;
  final String postId;
  final List<String> likes;

  UserPost({
    super.key,
    required this.email,
    required this.bacot,
    required this.postId,
    required this.likes,
  });

  @override
  State<UserPost> createState() => _UserPostState();
}

class _UserPostState extends State<UserPost> {
  // Current User
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();

    isLiked = widget.likes.contains(currentUser.email);
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    DocumentReference postRef =
        FirebaseFirestore.instance.collection("User Posts").doc(widget.postId);

    if (isLiked) {
      postRef.update({
        "Likes": FieldValue.arrayUnion([currentUser.email]),
      });
    } else {
      postRef.update({
        "Likes": FieldValue.arrayRemove([currentUser.email]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .scaffoldBackgroundColor
            .withBlue(50)
            .withRed(25)
            .withOpacity(.25),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(.25)),
          bottom: BorderSide(color: Colors.white.withOpacity(.25)),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture
              CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://i.pinimg.com/564x/47/aa/84/47aa8442327df1894927e610b1697ded.jpg"),
                radius: 20,
              ),

              SizedBox(width: 20),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.email,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      width: double.infinity,
                      color: Colors.blue.withOpacity(.1),
                      child: Text(widget.bacot),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 10),

          // Actions
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              children: [
                LikeButton(
                  isLiked: isLiked,
                  onTap: toggleLike,
                ),
                GestureDetector(
                  child: Text(
                    widget.likes.length == 0 ? "" : "${widget.likes.length}",
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
