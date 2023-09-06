import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:ionicons/ionicons.dart';
import 'package:kolot/models/post_model.dart';
import 'package:kolot/models/user_model.dart';
import 'package:kolot/pages/add_post_navigation.dart';
import 'package:kolot/pages/followers_following_page.dart';
import 'package:kolot/pages/user_posts_page.dart';

import 'package:kolot/provider/bottom_navigation_provider.dart';
import 'package:kolot/resources/auth_method.dart';
import 'package:kolot/resources/post_method.dart';
import 'package:provider/provider.dart';

class ProfileNavigation extends StatefulWidget {
  const ProfileNavigation({super.key});

  @override
  State<ProfileNavigation> createState() => _ProfileNavigationState();
}

class _ProfileNavigationState extends State<ProfileNavigation>
    with AutomaticKeepAliveClientMixin {
  final currentUser = FirebaseAuth.instance.currentUser!;
  int postsLength = 0;

  @override
  void initState() {
    super.initState();

    getPosts();
    getUserPosts();
  }

  getUserPosts() async {
    var snap = await PostMethods.getUserPosts(currentUser.uid);
    setState(() {
      postsLength = snap.length;
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPosts() {
    return FirebaseFirestore.instance
        .collection("posts")
        .where("uid", isEqualTo: currentUser.uid)
        .orderBy("time", descending: true)
        .snapshots();
  }

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
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final bottomNavigationProvider =
        Provider.of<BottomNavigationProvider>(context);

    return StreamBuilder(
      stream: AuthMethods.getUserDetails(currentUser.uid),
      builder: (context, snapshot) {
        Widget child = Center();
        if (snapshot.connectionState == ConnectionState.waiting) {
          child = Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          // Current User
          final user = UserModel.fromSnap(snapshot.data);

          // print("FOLLOWERS GUA: ${user.followers}");

          child = Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: Text(
                user.username,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddPostNavigation(),
                      ),
                    );
                  },
                  tooltip: "Posting",
                  icon: Icon(Ionicons.add),
                ),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      enableDrag: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      context: context,
                      builder: (context) => BottomSheet(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        enableDrag: false,
                        backgroundColor: Colors.transparent,
                        onClosing: () {},
                        builder: (context) => Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  width: 100,
                                  height: 7,
                                  margin: EdgeInsets.only(top: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(.25),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              _textButton(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      content: Text("Ingin Keluar?"),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            await AuthMethods.signOut(context);
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                            bottomNavigationProvider
                                                .currentIndex = 0;
                                          },
                                          child: Text("Ya"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Text(
                                  "Keluar",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  icon: Icon(Ionicons.menu),
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
                                                    uid: currentUser.uid,
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

  @override
  bool get wantKeepAlive => true;
}

Widget _textButton({
  required void Function()? onTap,
  required Widget child,
}) {
  return Column(
    children: [
      ListTile(
        title: child,
        onTap: onTap,
      ),
      Divider(height: 0),
    ],
  );
}
