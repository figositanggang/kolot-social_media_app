import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kolot/components/text_button.dart';
import 'package:kolot/provider/add_post_navigation_provider_.dart';
import 'package:kolot/resources/post_method.dart';
import 'package:kolot/utils/utils.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class AddPostNavigation extends StatefulWidget {
  const AddPostNavigation({super.key});

  @override
  State<AddPostNavigation> createState() => _AddPostNavigationState();
}

class _AddPostNavigationState extends State<AddPostNavigation>
    with AutomaticKeepAliveClientMixin {
  bool isLoading = false;

  // Pick Image
  void _showDialog(AddPostNavigationProvider addPostNavigationProvider) async {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Pilih Sumber Media"),
          children: [
            SimpleDialogOption(
              child: Text("Kamera"),
              onPressed: () async {
                await pickImage(ImageSource.camera,
                    provider: addPostNavigationProvider);

                Navigator.pop(context);
              },
            ),
            SimpleDialogOption(
              child: Text("Galeri"),
              onPressed: () async {
                await pickImage(ImageSource.gallery,
                    provider: addPostNavigationProvider);

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Post
  void _post(AddPostNavigationProvider provider) async {
    setState(() {
      isLoading = true;
    });

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        content: LinearProgressIndicator(),
      ),
    );
    String res = await PostMethods.post(
      postId: currentUser.uid,
      caption: provider.caption.text,
      media: provider.image!,
    );

    setState(() {
      isLoading = false;
    });

    if (res == "Success") {
      try {
        provider.image = null;
        provider.caption.text = "";
      } catch (e) {}

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Berhasil di-post"),
        backgroundColor: Colors.green[800],
      ));

      Navigator.pop(context);
    }
  }

  final key = GlobalKey<FormState>();
  final currentUser = FirebaseAuth.instance.currentUser!;
  late VideoPlayerController controller;
  bool isPlay = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final addPostNavigationProvider =
        Provider.of<AddPostNavigationProvider>(context);

    Widget checkMedia() {
      if (addPostNavigationProvider.isImage) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoView(
                  imageProvider: MemoryImage(addPostNavigationProvider.image!)),
            ),
          ),
          child: Image.memory(addPostNavigationProvider.image!),
        );
      } else {
        setState(() {
          controller =
              VideoPlayerController.file(addPostNavigationProvider.video!);
        });

        controller.initialize().then((value) async {
          await controller.play();
          setState(() {
            isPlay = true;
          });
        });

        return GestureDetector(
          onTap: () async {
            if (isPlay) {
              await controller.pause();
              setState(() {
                isPlay = false;
              });
            } else {
              await controller.pause();
              setState(() {
                isPlay = true;
              });
            }
          },
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
        );
      }
    }

    if (addPostNavigationProvider.image == null) {
      return Center(
        child: ElevatedButton(
          onPressed: () {
            _showDialog(addPostNavigationProvider);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Upload"),
              Icon(Icons.upload),
            ],
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(side: BorderSide(color: Colors.white)),
          ),
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Form(
          key: key,
          child: Column(
            children: [
              AppBar(
                title: Text("Post"),
                actions: [
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Hapus Post"),
                          content: Text("Anda Yakin?"),
                          actions: [
                            MyTextButton(
                              child: Text("Ya"),
                              onTap: () {
                                try {
                                  addPostNavigationProvider.image = null;
                                  addPostNavigationProvider.caption.text = "";
                                } catch (e) {}

                                Navigator.pop(context);
                              },
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                            TextButton(
                              child: Text("Tidak"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhotoView(
                        imageProvider:
                            MemoryImage(addPostNavigationProvider.image!)),
                  ),
                ),
                child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: PhotoView(
                    disableGestures: true,
                    imageProvider:
                        MemoryImage(addPostNavigationProvider.image!),
                  ),
                ),
              ),
              TextFormField(
                controller: addPostNavigationProvider.caption,
                maxLines: null,
                decoration: InputDecoration(hintText: "caption..."),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Caption masih kosong";
                  }
                  return null;
                },
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () {
                    if (key.currentState!.validate()) {
                      _post(addPostNavigationProvider);
                    }
                  },
                  child: Text("Post"),
                  style: ElevatedButton.styleFrom(
                    shape: LinearBorder(),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();

    () async {
      await controller.dispose();
    };
  }

  @override
  bool get wantKeepAlive => true;
}
