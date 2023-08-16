import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
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
  ScrollController _scrollController = ScrollController();
  bool _scrollDown = false;
  bool _showAppBar = true;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(
      () {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          _scrollDown = true;
          _showAppBar = false;
        } else {
          _scrollDown = false;
          _showAppBar = true;
        }
        Future.delayed(Duration(milliseconds: 500), () {
          setState(() {});
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _scrollController.removeListener(() {});
  }

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
          if (snapshot.data!.docs.length > 0) {
            final List<QueryDocumentSnapshot<Map<String, dynamic>>> data =
                snapshot.data!.docs;

            child = Column(
              children: [
                AnimatedContainer(
                  height: _showAppBar ? kToolbarHeight : 0,
                  duration: Duration(milliseconds: 100),
                  child: AppBar(
                    title: Text(
                      "Kolot",
                      style: TextStyle(
                        fontFamily: GoogleFonts.arvo().fontFamily,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final post = PostModel.fromSnap(data[index]);

                      return PostCard(
                        post: post,
                        postId: data[index].id,
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            child = Center(
              child: Text("Belum ada postingan"),
            );
          }
        }

        return child;
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
