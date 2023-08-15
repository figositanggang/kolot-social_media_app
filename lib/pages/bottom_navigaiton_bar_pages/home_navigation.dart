import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kolot/components/post_card.dart';
import 'package:kolot/models/post_model.dart';

import 'package:kolot/resources/post_method.dart';

class HomeNavigation extends StatefulWidget {
  const HomeNavigation({super.key});

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder(
      stream: PostMethods.getPostDetails(),
      builder: (context, snapshot) {
        Widget child = Center();

        if (snapshot.connectionState == ConnectionState.waiting) {
          child = Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasData) {
          final List<QueryDocumentSnapshot<Map<String, dynamic>>> data =
              snapshot.data!.docs;

          child = ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final post = PostModel.fromSnap(data[index]);

              return PostCard(
                post: post,
                postId: data[index].id,
              );
            },
          );
        }

        return child;
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
