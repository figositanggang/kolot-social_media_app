import 'package:flutter/material.dart';
import 'package:kolot/components/post_card.dart';
import 'package:kolot/models/post_model.dart';

class UserPostsPage extends StatefulWidget {
  final PostModel post;
  final String postId;
  const UserPostsPage({super.key, required this.post, required this.postId});

  @override
  State<UserPostsPage> createState() => _UserPostsPageState();
}

class _UserPostsPageState extends State<UserPostsPage> {
  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(
        title: Text("Post"),
      ),
      body: SingleChildScrollView(
        child: PostCard(
          post: post,
          postId: widget.postId,
        ),
      ),
    );
  }
}
