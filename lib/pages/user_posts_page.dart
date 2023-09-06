import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kolot/components/post_card.dart';
import 'package:kolot/models/post_model.dart';

class UserPostsPage extends StatefulWidget {
  // final String docId;
  final int page;
  final String uid;
  UserPostsPage({super.key, required this.page, required this.uid});

  @override
  State<UserPostsPage> createState() => _UserPostsPageState();
}

class _UserPostsPageState extends State<UserPostsPage>
    with AutomaticKeepAliveClientMixin {
  late PageController pageController;

  @override
  void initState() {
    super.initState();

    pageController = PageController(initialPage: widget.page);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Post"),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection("posts")
            .where("uid", isEqualTo: widget.uid)
            .orderBy("time", descending: true)
            .get(),
        builder: (context, snapshot) {
          Widget child = Center(child: Text("Error"));

          if (snapshot.connectionState == ConnectionState.waiting) {
            child = Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            final posts = snapshot.data!.docs;

            child = ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: posts.length,
              controller: pageController,
              itemBuilder: (context, index) {
                PostModel _post = PostModel.fromSnap(posts[index]);

                return PostCard(
                  post: _post,
                  docId: posts[index].id,
                );
              },
            );
          }

          return child;
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
