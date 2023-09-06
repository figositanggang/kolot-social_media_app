import 'dart:io';
import 'package:appinio_video_player/appinio_video_player.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_whisperer/image_whisperer.dart';
import 'package:kolot/components/text_button.dart';
import 'package:kolot/components/text_field.dart';
import 'package:kolot/pages/home_page.dart';
import 'package:kolot/resources/post_method.dart';
import 'package:kolot/utils/utils.dart';
import 'package:mime/mime.dart';

import "dart:html" as html;

class AddPostNavigation extends StatefulWidget {
  const AddPostNavigation({super.key});

  @override
  State<AddPostNavigation> createState() => _AddPostNavigationState();
}

class _AddPostNavigationState extends State<AddPostNavigation> {
  File? mobileFile;
  html.File? webfile;

  TextEditingController caption = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final currentUser = FirebaseAuth.instance.currentUser!;

  late VideoPlayerController controller;

  @override
  void dispose() {
    super.dispose();

    controller.dispose();
  }

  // Check File Type Mobile
  Future<Widget> checkFileTypeMobile(File file) async {
    Widget child = Center(child: Text("Error"));

    if (kIsWeb) {
      child = GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Material(
                color: Colors.black,
                child: InteractiveViewer(
                  child: Image.network(file.path),
                  maxScale: 5,
                ),
              ),
            ),
          );
        },
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Image.network(
              file.path,
              height: MediaQuery.of(context).size.height / 2,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else {
      String mime = lookupMimeType(file.path)!;
      String type = mime.split("/")[0];

      if (type == "image") {
        child = InteractiveViewer(
          child: Image.file(file),
          maxScale: 5,
        );
      } else if (type == "video") {
        controller = VideoPlayerController.file(file)
          ..initialize().then((value) {
            controller.play();
            controller.setLooping(false);
            setState(() {});
          });

        child = VideoPlayer(controller);
      }
    }

    return child;
  }

  // Check File Type Mobile
  Future<Widget> checkFileTypeWeb(html.File file) async {
    BlobImage blobImage = BlobImage(file, name: file.name);

    final url = blobImage.url!;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Material(
              color: Colors.black,
              child: InteractiveViewer(
                child: Image.network(url),
                maxScale: 5,
              ),
            ),
          ),
        );
      },
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Image.network(
            url,
            height: MediaQuery.of(context).size.height / 2,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // Pick Image
  pickImage() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Pilih Sumber Media"),
          children: [
            SimpleDialogOption(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text("Kamera"),
              onPressed: () async {
                mobileFile = await Utils.pickImage(ImageSource.camera);
                setState(() {});
                checkFileTypeMobile(mobileFile!);
              },
            ),
            SimpleDialogOption(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text("Gallery"),
              onPressed: () async {
                mobileFile = await Utils.pickImage(ImageSource.gallery);
                setState(() {});
                checkFileTypeMobile(mobileFile!);
              },
            ),
          ],
        );
      },
    );
  }

  // Posting
  Future<void> postingMobile(File file) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          child: LinearProgressIndicator(),
        );
      },
    );

    String res = await PostMethods.postMobile(
      postId: currentUser.uid,
      caption: caption.text,
      type: "image",
      media: file,
    );

    Navigator.pop(context);

    if (res == 'error') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal Posting"),
        ),
      );
    } else if (res == 'success') {
      mobileFile = null;
      caption.text = "";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Berhasil Posting"),
        ),
      );
    }
  }

  // Posting Web
  Future<void> postingWeb(html.File file) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          child: LinearProgressIndicator(),
        );
      },
    );

    String res = await PostMethods.postWeb(
      postId: currentUser.uid,
      caption: caption.text,
      type: "image",
      media: file,
    );

    Navigator.pop(context);

    if (res == 'error') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal Posting"),
        ),
      );
    } else if (res == 'success') {
      webfile = null;
      caption.text = "";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Berhasil Posting"),
        ),
      );

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Data Mobile
    if (mobileFile != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: FutureBuilder(
              future: checkFileTypeMobile(mobileFile!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  Widget post = snapshot.data!;
                  return Column(
                    children: [
                      // Post
                      post,

                      Container(
                        padding: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width / 1.25,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.1),
                        ),
                        child: Column(
                          children: [
                            // Caption
                            MyTextField(
                              controller: caption,
                              hintText: "Caption",
                              obscureText: false,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Caption masih kosong...";
                                }

                                return null;
                              },
                            ),

                            SizedBox(height: 5),

                            // Post Button
                            MyTextButton(
                              child: Center(child: Text("Post")),
                              padding: EdgeInsets.symmetric(vertical: 10),
                              onTap: () async {
                                if (formKey.currentState!.validate()) {
                                  await postingMobile(mobileFile!);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ),
      );
    }

    // Data Web
    else if (webfile != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: FutureBuilder(
              future: checkFileTypeWeb(webfile!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  Widget post = snapshot.data!;
                  return Column(
                    children: [
                      // Post
                      post,

                      Container(
                        padding: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width / 1.25,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.1),
                        ),
                        child: Column(
                          children: [
                            // Caption
                            MyTextField(
                              controller: caption,
                              hintText: "Caption",
                              obscureText: false,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Caption masih kosong...";
                                }

                                return null;
                              },
                            ),

                            SizedBox(height: 5),

                            // Post Button
                            MyTextButton(
                              child: Center(child: Text("Post")),
                              padding: EdgeInsets.symmetric(vertical: 10),
                              onTap: () async {
                                if (formKey.currentState!.validate()) {
                                  if (kIsWeb) {
                                    await postingWeb(webfile!);
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ElevatedButton(
          child: Text("Upload"),
          onPressed: () async {
            // Web
            if (kIsWeb) {
              webfile = await Utils.pickImage(ImageSource.camera);
              setState(() {});
            }

            // Non Web
            else {
              pickImage();
            }
          },
        ),
      ),
    );
  }
}
