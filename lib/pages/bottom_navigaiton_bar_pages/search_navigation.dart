import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kolot/models/user_model.dart';
import 'package:kolot/pages/other_user_page.dart';
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
    QuerySnapshot snap;

    snap = await FirebaseFirestore.instance
        .collection("users")
        .where(
          "username".toLowerCase(),
          isGreaterThanOrEqualTo: text.toLowerCase(),
        )
        .get();

    List temp = [];
    snap.docs.forEach((element) {
      var user = UserModel.fromSnap(element);
      String name = user.name.toLowerCase();
      String username = user.username.toLowerCase();
      String search = text.toLowerCase();

      if (username.contains(search) ||
          username.compareTo(search) == 0 ||
          name.contains(search) ||
          name.compareTo(search) == 0) {
        temp.add(element);
      }
    });

    users = temp.toSet().toList();
    temp.clear();

    setState(() {});
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
        body: SingleChildScrollView(
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
                      setState(() {});
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
              users.length != 0 && searchBarProvider.controller.text.isNotEmpty
                  ? Column(
                      children: List.generate(
                        users.length,
                        (index) {
                          final user = UserModel.fromSnap(users[index]);

                          return ListTile(
                            contentPadding: EdgeInsets.all(10),
                            leading: CircleAvatar(
                              backgroundImage:
                                  CachedNetworkImageProvider(user.photoUrl),
                            ),
                            title: Text(user.username),
                            subtitle: Text(
                              user.name,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(.5)),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OtherUserPage(
                                    uid: user.uid,
                                    user: user,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    )
                  : Center(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
