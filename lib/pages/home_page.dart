import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kolot/components/text_button.dart';
import 'package:kolot/pages/bottom_navigaiton_bar_pages/add_post_navigation.dart';
import 'package:kolot/pages/bottom_navigaiton_bar_pages/home_navigation.dart';
import 'package:kolot/pages/bottom_navigaiton_bar_pages/profile_navigation.dart';
import 'package:kolot/pages/bottom_navigaiton_bar_pages/search_navigation.dart';
import 'package:kolot/provider/add_post_navigation_provider_.dart';
import 'package:kolot/provider/bottom_navigation_provider.dart';

import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Current User
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    final bottomNavigationProvider =
        Provider.of<BottomNavigationProvider>(context);
    final addPostNavigationProvider =
        Provider.of<AddPostNavigationProvider>(context);

    final List<Widget> body = [
      HomeNavigation(
        key: PageStorageKey("home_navigation"),
      ),
      SearchNavigation(
        key: PageStorageKey("search_navigation"),
      ),
      AddPostNavigation(
        key: PageStorageKey("add_post_navigation"),
      ),
      ProfileNavigation(
        key: PageStorageKey("profile_navigation"),
      ),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,

      body: IndexedStack(
        children: body,
        index: bottomNavigationProvider.currentIndex,
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        currentIndex: bottomNavigationProvider.currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (value) {
          bottomNavigationProvider.currentIndex = value;
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(LineIcons.home),
            label: "home",
            tooltip: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(LineIcons.search),
            label: "search",
            tooltip: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.add),
            label: "post",
            tooltip: "Post",
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.person),
            label: "profile",
            tooltip: "Profile",
          ),
        ],
      ),
      // body: body[bottomNavigationProvider.currentIndex],
    );
  }
}
