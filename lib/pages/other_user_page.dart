import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kolot/models/post_model.dart';
import 'package:kolot/models/user_model.dart';
import 'package:kolot/pages/followers_following_page.dart';
import 'package:kolot/pages/user_posts_page.dart';
import 'package:kolot/resources/auth_method.dart';
import 'package:kolot/resources/follow_method.dart';
import 'package:kolot/resources/post_method.dart';

class OtherUserPage extends StatefulWidget {
  final UserModel user;
  final String uid;

  const OtherUserPage({super.key, required this.user, required this.uid});

  @override
  State<OtherUserPage> createState() => _OtherUserPageState();
}

class _OtherUserPageState extends State<OtherUserPage> {
  int postsLength = 0;
  User currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();

    getPosts();
    getUserPosts();
  }

  // Get User Posts
  getUserPosts() async {
    var snap = await PostMethods.getUserPosts(widget.uid);
    setState(() {
      postsLength = snap.length;
    });
  }

  // Get Post
  Stream<QuerySnapshot<Map<String, dynamic>>> getPosts() {
    return FirebaseFirestore.instance
        .collection("posts")
        .where("uid", isEqualTo: widget.uid)
        .orderBy("time", descending: true)
        .snapshots();
  }

  // Show Profile Picture
  void _showProfilePic(UserModel data) {
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
              data.photoUrl,
              width: 250,
            ),
          ),
        ),
      ),
    );
  }

  // Follow
  Future<void> follow() async {
    String res = await FollowMethods.follow(widget.uid);
  }

  // Un-Follow
  Future<void> unFollow() async {
    String res = await FollowMethods.unFollow(widget.uid);
  }

  // Check Apakah Sudah di-Follow
  Future<bool> checkFollowed(String uid) async {
    bool res = await FollowMethods.isFollowed(uid);

    return res;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthMethods.getUserDetails(widget.uid),
      builder: (context, snapshot) {
        Widget child = Center();
        if (snapshot.connectionState == ConnectionState.waiting) {
          child = Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          // Current User
          final user = UserModel.fromSnap(snapshot.data);

          child = Scaffold(
            appBar: AppBar(
              title: Text(widget.user.username),
              actions: [
                FutureBuilder(
                  future: checkFollowed(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      bool isFollowed = snapshot.data!;

                      if (currentUser.uid == widget.uid) {
                        return SizedBox();
                      }

                      // Followed
                      else if (isFollowed) {
                        return TextButton(
                          child: Text("Mengikuti"),
                          onPressed: () {
                            unFollow();
                          },
                        );
                      }

                      // Not Followed
                      else {
                        return TextButton(
                          child: Text("Ikuti"),
                          onPressed: () {
                            follow();
                          },
                        );
                      }
                    }

                    return SizedBox();
                  },
                ),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Atas
                Container(
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
                                            uid: user.uid,
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
                                            uid: user.uid,
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

                          if (snapshot.hasData &&
                              snapshot.data!.docs.length != 0) {
                            final List<
                                    QueryDocumentSnapshot<Map<String, dynamic>>>
                                data = snapshot.data!.docs;

                            child = GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 3,
                                mainAxisSpacing: 3,
                              ),
                              itemCount: data.length,
                              itemBuilder: (BuildContext context, int index) {
                                final post = PostModel.fromSnap(data[index]);

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
                                                  builder: (context) =>
                                                      UserPostsPage(
                                                    page: index,
                                                    uid: widget.uid,
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
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            child = Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          // No Data
                          else if (!snapshot.hasData ||
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

        return child;
      },
    );
  }
}
