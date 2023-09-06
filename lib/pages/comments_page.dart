import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kolot/models/comment_model.dart';
import 'package:kolot/models/post_model.dart';
import 'package:kolot/models/user_model.dart';
import 'package:kolot/resources/post_method.dart';

class CommentsPage extends StatefulWidget {
  final String postId;

  const CommentsPage({super.key, required this.postId});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage>
    with AutomaticKeepAliveClientMixin {
  TextEditingController controller = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();

    getComments();
  }

  Stream<DocumentSnapshot> getComments() {
    return FirebaseFirestore.instance
        .collection("posts")
        .doc(widget.postId)
        .snapshots();
  }

  Future<UserModel> getUser(String userId) async {
    DocumentSnapshot snap =
        await FirebaseFirestore.instance.collection("users").doc(userId).get();

    return UserModel.fromSnap(snap);
  }

  addComment() async {
    String res = "";

    res = await PostMethods.addComment(
      CommentModel(
        comment: controller.text,
        userId: currentUser.uid,
      ),
      postId: widget.postId,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Komen"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: getComments(),
              builder: (context, snapshot) {
                Widget child = Center(
                  child: Text("Belum ada komen"),
                );

                if (snapshot.connectionState == ConnectionState.waiting) {
                  child = Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasData &&
                    (snapshot.data!['comments'] as List).length > 0) {
                  final comments = PostModel.fromSnap(snapshot.data!).comments;

                  child = ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = CommentModel.fromSnap(comments[index]);

                      return FutureBuilder(
                        future: getUser(comment.userId),
                        builder: (context, snapshot) {
                          Widget child = ListTile();

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            child = ListTile(
                              leading: CircleAvatar(
                                child: CircularProgressIndicator(),
                              ),
                              title: Text(""),
                              subtitle: Text(""),
                            );
                          }
                          if (snapshot.hasData) {
                            final user = snapshot.data!;

                            child = ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    CachedNetworkImageProvider(user.photoUrl),
                              ),
                              title: Text(user.username),
                              subtitle: Container(
                                padding: EdgeInsets.all(8),
                                color: Colors.white.withOpacity(.05),
                                child: Text(
                                  comment.comment,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }

                          return child;
                        },
                      );
                    },
                  );
                }

                return child;
              },
            ),
          ),
          TextField(
            controller: controller,
            maxLines: null,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 2,
                  color: Colors.red,
                ),
              ),
              hintText: "Tambahkan komen...",
              suffix: controller.text.isNotEmpty
                  ? TextButton(
                      onPressed: () {
                        addComment();
                      },
                      child: Text("Kirim"),
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
