import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:kolot/components/post_card.dart';
import 'package:kolot/models/post_model.dart';
import 'package:kolot/provider/home_navigation_provider.dart';

import 'package:kolot/resources/post_method.dart';
import 'package:provider/provider.dart';

class HomeNavigation extends StatefulWidget {
  const HomeNavigation({super.key});

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation>
    with AutomaticKeepAliveClientMixin {
  bool scrollDown = false;
  bool showAppBar = true;

  late ScrollController scrollController;
  late HomeNavigationProvider homeNavigationProv;

  List<PostModel> posts = [];

  @override
  void initState() {
    super.initState();

    homeNavigationProv =
        Provider.of<HomeNavigationProvider>(context, listen: false);
    scrollController =
        ScrollController(initialScrollOffset: homeNavigationProv.scrollOffset);

    setState(() {});

    scrollController.addListener(
      () {
        homeNavigationProv.scrollOffset = scrollController.position.pixels;
        // print(scrollController.position.pixels);
        if (scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          scrollDown = true;
          showAppBar = false;
        } else {
          scrollDown = false;
          showAppBar = true;
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
    scrollController.dispose();
    scrollController.removeListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        Positioned.fill(
          top: 0,
          left: 0,
          child: StreamBuilder(
            stream: PostMethods.getAllPosts(),
            builder: (context, snapshot) {
              Widget child = Center();

              // Waiting
              if (snapshot.connectionState == ConnectionState.waiting) {
                child = Center(
                  child: CircularProgressIndicator(),
                );
              }

              // Ada Data
              if (snapshot.hasData) {
                final posts = snapshot.data!.docs;

                child = ListView.builder(
                  padding: EdgeInsets.only(top: kToolbarHeight),
                  controller: scrollController,
                  itemCount: posts.length,
                  // shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final post = PostModel.fromSnap(posts[index]);

                    return PostCard(
                      post: post,
                      docId: posts[index].id,
                    );
                  },
                );
              } else {
                child = Center(
                  child: CircularProgressIndicator(),
                );
              }

              return child;
            },
          ),
        ),

        // App Bar
        Positioned(
          top: 0,
          left: 0,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 100),
            curve: Curves.easeInOutCubic,
            height: showAppBar ? kToolbarHeight : 0,
            width: MediaQuery.of(context).size.width,
            child: AppBar(
              foregroundColor: showAppBar ? Colors.white : Colors.transparent,
              title: Text(
                "Kolot",
                style: TextStyle(
                  fontFamily: GoogleFonts.arvo().fontFamily,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
