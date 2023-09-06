import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kolot/models/post_model.dart';
import 'package:kolot/models/user_model.dart';
import 'package:kolot/pages/comments_page.dart';
import 'package:kolot/pages/home_page.dart';
import 'package:kolot/pages/other_user_page.dart';
import 'package:kolot/provider/bottom_navigation_provider.dart';
import 'package:kolot/resources/post_method.dart';
import 'package:line_icons/line_icons.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final String docId;

  PostCard({
    super.key,
    required this.post,
    required this.docId,
  });

  @override
  State<PostCard> createState() => PostCardState();
}

class PostCardState extends State<PostCard> {
  final _currentUser = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  double _opacity = 0;

  late PostModel post;

  // late CustomVideoPlayerController customeController;
  // late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();

    post = widget.post;

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();

    // customeController.dispose();
  }

  // Get User
  Future<UserModel> _getUser() async {
    DocumentSnapshot snap =
        await firebaseFirestore.collection("users").doc(post.userId).get();

    return UserModel.fromSnap(snap);
  }

  // Delete Post
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
    String res = await PostMethods.deletePost(post, widget.docId);

    if (res == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Postingan berhasil dihapus")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Postingan gagal dihapus")),
      );
    }

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
        (route) => false);
  }

  // Check Like

  // Check File Type
  Widget checkFileType(BuildContext context, PostModel post) {
    String type = post.type;

    // if (type == "image") {
    // }
    return CachedNetworkImage(
      width: MediaQuery.of(context).size.width,
      imageUrl: post.mediaUrl,
      fadeInCurve: Curves.fastOutSlowIn,
      fadeInDuration: Duration(milliseconds: 100),
      fit: BoxFit.cover,
      // placeholder: (context, url) => Center(
      //   child: Icon(
      //     LineIcons.circleAlt,
      //     size: 200,
      //     opticalSize: 1,
      //   ),
      // ),
    );

    // else {
    //   controller = VideoPlayerController.networkUrl(Uri.parse(post.mediaUrl))
    //     ..initialize().then((value) {
    //       setState(() {});
    //     });
    //   customeController = CustomVideoPlayerController(
    //     context: context,
    //     videoPlayerController: controller,
    //   );
    //   return Stack(
    //     children: [
    //       AspectRatio(
    //         aspectRatio: controller.value.aspectRatio,
    //         child: CustomVideoPlayer(
    //             customVideoPlayerController: customeController),
    //       ),
    //       Positioned.fill(
    //         child: GestureDetector(
    //           onTap: () {},
    //         ),
    //       ),
    //     ],
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
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
                            uid: user.uid,
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

            // Content
            FutureBuilder(
              future:
                  firebaseFirestore.collection("posts").doc(widget.docId).get(),
              builder: (context, snapshot) {
                Widget child = Center(child: Text("Error"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  child = SizedBox(
                    height: 300,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                        child: Text("Loading..."),
                      ),
                    ),
                  );
                }

                if (snapshot.hasData) {
                  final post = PostModel.fromSnap(snapshot.data!);

                  child = GestureDetector(
                    onDoubleTap: () async {
                      setState(() {
                        _opacity = 1;
                      });
                      Future.delayed(Duration(seconds: 1), () {
                        setState(() {
                          _opacity = 0;
                        });
                      });
                      if (!post.likes.contains(_currentUser.uid)) {
                        await PostMethods.giveRemoveLike(
                          postId: widget.docId,
                          userId: _currentUser.uid,
                        );
                      }
                    },
                    onTap: () {
                      if (post.type == "image") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PhotoView(
                              imageProvider:
                                  CachedNetworkImageProvider(post.mediaUrl),
                            ),
                          ),
                        );
                      }
                    },
                    child: Stack(
                      children: [
                        // Post Media
                        checkFileType(context, post),

                        // Like Effect
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: AnimatedOpacity(
                              duration: Duration(milliseconds: 500),
                              opacity: _opacity,
                              child: Icon(
                                Icons.favorite,
                                size: 125,
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
                  );
                }
                return child;
              },
            ),

            SizedBox(height: 5),
            // Likes & Comments
            Row(
              children: [
                // Likes
                IconButton(
                  tooltip: "Suka",
                  icon: FutureBuilder(
                    future: firebaseFirestore
                        .collection("posts")
                        .doc(widget.docId)
                        .get(),
                    builder: (context, snapshot) {
                      Widget child = Row(
                        children: [
                          Icon(Icons.favorite_border),
                          SizedBox(width: 5),
                          Text("0"),
                        ],
                      );

                      if (snapshot.hasData) {
                        PostModel _post = PostModel.fromSnap(snapshot.data!);
                        child = Row(
                          children: [
                            _post.likes.contains(_currentUser.uid)
                                ? Icon(Icons.favorite)
                                : Icon(Icons.favorite_border),
                            SizedBox(width: 5),
                            Text("${_post.likes.length}"),
                          ],
                        );
                      }

                      return child;
                    },
                  ),
                  onPressed: () async {
                    await PostMethods.giveRemoveLike(
                      postId: widget.docId,
                      userId: _currentUser.uid,
                    );

                    setState(() {});
                  },
                ),

                // Comments
                IconButton(
                  tooltip: "Komen",
                  icon: Row(
                    children: [
                      Icon(LineIcons.comment),
                      SizedBox(width: 5),
                      Text("${widget.post.comments.length}"),
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentsPage(
                          key: PageStorageKey("post-card-key"),
                          postId: widget.docId,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            Container(
              padding: EdgeInsets.only(left: 10),
              width: MediaQuery.of(context).size.width,
              child: Text(post.caption),
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
