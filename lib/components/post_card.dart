import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kolot/models/post_model.dart';
import 'package:kolot/models/user_model.dart';
import 'package:kolot/pages/other_user_page.dart';
import 'package:kolot/provider/bottom_navigation_provider.dart';
import 'package:kolot/resources/post_method.dart';
import 'package:line_icons/line_icons.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final String postId;
  PostCard({
    super.key,
    required this.post,
    required this.postId,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final _currentUser = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  double _opacity = 0;

  checkLike() {
    if (widget.post.likes.contains(_currentUser.uid)) {
      return Icon(
        Icons.favorite,
        color: Colors.blue,
      );
    } else {
      return Icon(
        Icons.favorite_border,
        color: Colors.blue,
      );
    }
  }

  Future<UserModel> _getUser() async {
    DocumentSnapshot snap = await firebaseFirestore
        .collection("users")
        .doc(widget.post.userId)
        .get();

    return UserModel.fromSnap(snap);
  }

  _deletePost() async {
    // Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: LinearProgressIndicator(),
      ),
    );

    // hapus post
    String res = await PostMethods.deletePost(widget.postId);

    if (res == "success") {
      print("Berhasil hapus");
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Postingan berhasil dihapus")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Postingan gagal dihapus")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final bottomNavigationProvider =
        Provider.of<BottomNavigationProvider>(context);

    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User
            FutureBuilder(
              future: _getUser(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final user = snapshot.data!;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OtherUserPage(
                            user: user,
                            userId: user.uid,
                            key: PageStorageKey("other_user_page"),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding:
                          const EdgeInsets.only(top: 15, bottom: 15, left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(user.photoUrl),
                                  radius: 15,
                                ),
                                SizedBox(width: 15),
                                Text(user.username),
                              ],
                            ),
                          ),

                          // More Icon
                          post.userId == _currentUser.uid &&
                                  bottomNavigationProvider.currentIndex != 0
                              ? IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => SimpleDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        children: [
                                          SimpleDialogOption(
                                            child: Text(
                                              "Hapus",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 20),
                                            onPressed: () {
                                              _deletePost();
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.more_vert),
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, right: 15, left: 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          child: Icon(Ionicons.person),
                        ),
                        SizedBox(width: 15),
                        Text("username..."),
                      ],
                    ),
                  );
                }
              },
            ),

            // Image
            GestureDetector(
              onDoubleTap: () {
                if (!widget.post.likes.contains(_currentUser.uid)) {
                  PostMethods.giveRemoveLike(
                    postId: widget.postId,
                    userId: _currentUser.uid,
                  );
                }

                setState(() {
                  _opacity = 1;
                });
                Future.delayed(Duration(seconds: 1), () {
                  setState(() {
                    _opacity = 0;
                  });
                });
              },
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoView(
                          imageProvider:
                              CachedNetworkImageProvider(post.mediaUrl)),
                    ));
              },
              child: Stack(
                children: [
                  // Post Media
                  CachedNetworkImage(
                    width: MediaQuery.of(context).size.width,
                    imageUrl: post.mediaUrl,
                    fadeInCurve: Curves.fastOutSlowIn,
                    fadeInDuration: Duration(milliseconds: 100),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: Icon(
                        LineIcons.circleAlt,
                        size: 200,
                        opticalSize: 1,
                      ),
                    ),
                  ),

                  // Like Effect
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 500),
                        opacity: _opacity,
                        child: Icon(
                          Icons.favorite,
                          color: Colors.blue,
                          size: 200,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(.5),
                              blurRadius: 20,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 5),
            // Likes
            IconButton(
              icon: checkLike(),
              onPressed: () {
                PostMethods.giveRemoveLike(
                  postId: widget.postId,
                  userId: _currentUser.uid,
                );
              },
            ),

            // Likes & Caption
            Container(
              padding: EdgeInsets.only(left: 10),
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${post.likes.length} suka"),

                  SizedBox(height: 5),
                  // Caption
                  Text(post.caption),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
