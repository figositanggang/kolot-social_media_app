import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kolot/models/user_model.dart';
import 'package:kolot/provider/search_bar_provider.dart';
import 'package:provider/provider.dart';

class SearchNavigation extends StatefulWidget {
  const SearchNavigation({super.key});

  @override
  State<SearchNavigation> createState() => _SearchNavigationState();
}

class _SearchNavigationState extends State<SearchNavigation>
    with AutomaticKeepAliveClientMixin {
  List users = [];

  // carii
  search(String text) async {
    QuerySnapshot get1;
    QuerySnapshot get2;
    get1 = await FirebaseFirestore.instance
        .collection("users")
        .where(
          "username".toLowerCase(),
          isGreaterThan: text.toLowerCase(),
        )
        .get();

    // get2 = await FirebaseFirestore.instance
    //     .collection("users")
    //     .where(
    //       "username".toLowerCase(),
    //       isLessThanOrEqualTo: text.toLowerCase(),
    //     )
    //     .get();

    setState(() {
      users = get1.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final searchBarProvider = Provider.of<SearchBarProvider>(context);

    return GestureDetector(
      onTap: () {
        SystemChannels.textInput.invokeListMethod("TextInput.hide");
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: searchBarProvider.controller,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    hintText: "cari...",
                    suffixIcon: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        searchBarProvider.controller.text = "";
                      },
                      icon: Icon(Ionicons.close),
                      color: Colors.blue,
                    ),
                  ),
                  onEditingComplete: () {
                    search(searchBarProvider.controller.text);
                  },
                  onChanged: (value) {
                    search(searchBarProvider.controller.text);
                  },
                  style: TextStyle(color: Colors.blue),
                ),

                // Body
                users.length != 0
                    ? Column(
                        children: List.generate(
                          users.length,
                          (index) {
                            final user = UserModel.fromSnap(users[index]);

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    CachedNetworkImageProvider(user.photoUrl),
                              ),
                              title: Text(user.username),
                              onTap: () {},
                            );
                          },
                        ),
                      )
                    : Center(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
