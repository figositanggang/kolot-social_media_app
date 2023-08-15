import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kolot/components/text_button.dart';
import 'package:kolot/models/post_model.dart';
import 'package:kolot/models/user_model.dart';
import 'package:kolot/pages/followers_following_page.dart';
import 'package:kolot/pages/user_posts_page.dart';
import 'package:kolot/resources/follow_method.dart';
import 'package:kolot/resources/post_method.dart';

class OtherUserPage extends StatefulWidget {
  final String userId;
  final UserModel user;
  const OtherUserPage({super.key, required this.userId, required this.user});

  @override
  State<OtherUserPage> createState() => _OtherUserPageState();
}

class _OtherUserPageState extends State<OtherUserPage> {
  int postsLength = 0;
  final _currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();

    getPosts();
    getUserPosts();
    isFollowed();
  }

  getUserPosts() async {
    var snap = await PostMethods.getUserPosts(widget.userId);
    setState(() {
      postsLength = snap.length;
    });
  }

  Future<UserModel> getUserDetails() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userId)
        .get();

    return UserModel.fromSnap(snap);
  }

  Future<bool> isFollowed() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userId)
        .get();

    UserModel user = UserModel.fromSnap(snap);

    return user.followers.contains(_currentUser.uid);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPosts() {
    return FirebaseFirestore.instance
        .collection("posts")
        .where("uid", isEqualTo: widget.userId)
        .orderBy("time", descending: true)
        .snapshots();
  }

  void _showProfilePic(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                user.photoUrl,
                width: 250,
              ),
            )),
      ),
    );
  }

  _follow() async {
    await FollowMethods.follow(
      followerId: _currentUser.uid,
      followingId: widget.userId,
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          widget.user.username,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Follow Button
          FutureBuilder(
            future: isFollowed(),
            builder: (context, snapshot) {
              Widget child = Center();

              // Following
              if (snapshot.hasData) {
                if (snapshot.data == true) {
                  child = TextButton(
                    child: Text(
                      "Mengikuti",
                      style: TextStyle(fontSize: 18),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Berhenti follow?"),
                          actions: [
                            MyTextButton(
                              child: Text("Ya"),
                              onTap: _follow,
                            ),
                            MyTextButton(
                              child: Text("Tidak"),
                              onTap: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ButtonStyle(
                      padding: MaterialStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      ),
                    ),
                  );
                } else {
                  child = TextButton(
                    child: Text(
                      "Ikuti",
                      style: TextStyle(fontSize: 18),
                    ),
                    onPressed: _follow,
                    style: ButtonStyle(
                      padding: MaterialStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      ),
                    ),
                  );
                }
              } else {
                child = Text("...");
              }

              return child;
            },
          ),

          SizedBox(width: 10),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Atas
          FutureBuilder(
            future: getUserDetails(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final user = snapshot.data!;

                return Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Foto Profil
                          GestureDetector(
                            onTap: () {
                              _showProfilePic(user);
                            },
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(user.photoUrl),
                              radius: 50,
                            ),
                          ),

                          // Followers Following
                          Expanded(
                            child: Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  // Posts
                                  StreamBuilder(
                                      stream: getPosts(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          final data = snapshot.data!.docs;

                                          return Column(
                                            children: [
                                              Text("Posts"),
                                              Text(data.length.toString()),
                                            ],
                                          );
                                        } else {
                                          return Text("0");
                                        }
                                      }),

                                  // Followers
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FollowersFollowingPage(
                                            isFollower: true,
                                            uid: widget.userId,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        Text("Followers"),
                                        Text(user.followers.length.toString()),
                                      ],
                                    ),
                                  ),

                                  // Following
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FollowersFollowingPage(
                                            isFollower: false,
                                            uid: widget.userId,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        Text("Following"),
                                        Text(user.following.length.toString()),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 10),

                      // Nama
                      Text(
                        user.name,
                        style: TextStyle(
                          letterSpacing: 2,
                          fontSize: 18,
                        ),
                      ),

                      // Bio
                      Text(
                        user.bio,
                        style: TextStyle(color: Colors.white.withOpacity(.5)),
                      ),
                    ],
                  ),
                );
              } else {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Foto Profil
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 50,
                          ),

                          // Followers Following
                          Expanded(
                            child: Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  // Posts
                                  Column(
                                    children: [
                                      Text("Posts"),
                                      Text("0"),
                                    ],
                                  ),

                                  // Followers
                                  Column(
                                    children: [
                                      Text("Followers"),
                                      Text("0"),
                                    ],
                                  ),

                                  // Following
                                  Column(
                                    children: [
                                      Text("Following"),
                                      Text("0"),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 10),

                      // Nama
                      Text(
                        "username",
                        style: TextStyle(
                          letterSpacing: 2,
                          fontSize: 18,
                        ),
                      ),

                      // Bio
                      Text(
                        "bio",
                        style: TextStyle(color: Colors.white.withOpacity(.5)),
                      ),
                    ],
                  ),
                );
              }
            },
          ),

          // Bawah (Posts)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(.5)),
                ),
              ),
              child: SingleChildScrollView(
                child: StreamBuilder(
                  stream: getPosts(),
                  builder: (context, snapshot) {
                    Widget child = Center();

                    if (snapshot.hasData && snapshot.data!.docs.length != 0) {
                      final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                          posts = snapshot.data!.docs;

                      child = GridView.builder(
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 3,
                          mainAxisSpacing: 3,
                        ),
                        itemCount: posts.length,
                        itemBuilder: (BuildContext context, int index) {
                          final post = PostModel.fromSnap(posts[index]);

                          return SizedBox(
                            height: 100,
                            width: 100,
                            child: Stack(
                              children: [
                                SizedBox(
                                  height: double.infinity,
                                  width: double.infinity,
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: post.mediaUrl,
                                    placeholder: (context, url) =>
                                        Icon(Icons.photo),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Material(
                                    elevation: 0,
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => UserPostsPage(
                                              post: post,
                                              postId: post.postId,
                                            ),
                                          ),
                                        );
                                      },
                                      splashColor:
                                          Colors.black.withOpacity(.25),
                                      highlightColor:
                                          Colors.black.withOpacity(.25),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      );
                    }

                    // Loading
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      child = Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    // No Data
                    else if (!snapshot.hasData &&
                        snapshot.data!.docs.length == 0) {
                      child = Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Icon(
                                    Ionicons.image_outline,
                                    size: 100,
                                    color: Colors.white,
                                  ),
                                  Positioned(
                                    top: 25,
                                    left: 10,
                                    child: Icon(
                                      Ionicons.alert_outline,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Text("Tidak ada postingan"),
                            ],
                          ),
                        ),
                      );
                    }

                    return child;
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
