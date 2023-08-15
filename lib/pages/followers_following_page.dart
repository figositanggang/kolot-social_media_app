import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kolot/models/user_model.dart';
import 'package:kolot/pages/other_user_page.dart';

class FollowersFollowingPage extends StatefulWidget {
  // Follower / Following ?
  final bool isFollower;
  final String uid;
  const FollowersFollowingPage(
      {super.key, required this.isFollower, required this.uid});

  @override
  State<FollowersFollowingPage> createState() => _FollowersFollowingPageState();
}

class _FollowersFollowingPageState extends State<FollowersFollowingPage>
    with AutomaticKeepAliveClientMixin {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();

    if (widget.isFollower) {
      getFollowers();
    } else {
      getFollowing();
    }
  }

  Future<List<UserModel>> getFollowers() async {
    DocumentSnapshot snap =
        await firestore.collection("users").doc(widget.uid).get();

    final followers = UserModel.fromSnap(snap).followers;

    List<UserModel> users = [];

    for (var i = 0; i < followers.length; i++) {
      final data = followers[i];
      final snap = await firestore.collection("users").doc(data).get();

      users.add(UserModel.fromSnap(snap));
    }

    return users;
  }

  Future<List<UserModel>> getFollowing() async {
    DocumentSnapshot snap =
        await firestore.collection("users").doc(widget.uid).get();

    final following = UserModel.fromSnap(snap).following;

    List<UserModel> users = [];

    for (var i = 0; i < following.length; i++) {
      final data = following[i];
      final snap = await firestore.collection("users").doc(data).get();

      users.add(UserModel.fromSnap(snap));
    }

    return users;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: widget.isFollower ? Text("Followers") : Text("Following"),
      ),
      body: FutureBuilder(
        future: widget.isFollower ? getFollowers() : getFollowing(),
        builder: (context, snapshot) {
          Widget child = Center();

          if (snapshot.hasData) {
            final data = snapshot.data!;

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final user = data[index];

                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            CachedNetworkImageProvider(user.photoUrl),
                        backgroundColor: Colors.grey,
                      ),
                      title: Text(user.username),
                      subtitle: Text(
                        user.name,
                        style: TextStyle(color: Colors.white.withOpacity(.5)),
                      ),
                      trailing: user.followers.contains(currentUser.uid)
                          ? Text("Mengikuti")
                          : null,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OtherUserPage(
                              userId: user.uid,
                              user: user,
                            ),
                          ),
                        );
                      },
                    ),
                    Divider(
                      height: 0,
                      color: Colors.white.withOpacity(.25),
                    ),
                  ],
                );
              },
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            child = Center(
              child: CircularProgressIndicator(),
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
