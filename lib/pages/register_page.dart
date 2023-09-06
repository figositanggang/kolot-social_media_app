import 'dart:io';
import 'dart:html' as html;

import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_whisperer/image_whisperer.dart';
import 'package:kolot/components/text_button.dart';
import 'package:kolot/components/text_field.dart';
import 'package:kolot/pages/home_page.dart';
import 'package:kolot/provider/auth_provider.dart';
import 'package:kolot/resources/auth_method.dart';
import 'package:kolot/utils/utils.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final key = GlobalKey<FormState>();
  File? image;
  html.File? webImage;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController bio = TextEditingController();

// Select Image
  void selectImage() async {
    // Select From Web
    if (kIsWeb) {
      webImage = await Utils.pickImage(ImageSource.gallery);

      print("Image: $webImage");
    }

    // Select From Mobile
    else {
      image = await Utils.pickImage(ImageSource.gallery);
    }

    if (image != null || webImage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gambar berhasil dipuload")));
    }
    setState(() {});
  }

  // Check Platform
  Widget checkPlatform({
    File? image,
    html.File? webImage,
  }) {
    // Web
    if (kIsWeb) {
      // Image Ada
      if (webImage != null) {
        BlobImage blobImage = BlobImage(webImage, name: webImage.name);
        final url = blobImage.url!;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Container(
                  child: SafeArea(
                    child: Container(
                      color: Colors.black,
                      child: InteractiveViewer(
                        child: Image.network(url),
                        maxScale: 5,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          child: CircleAvatar(
            backgroundImage: NetworkImage(url),
            radius: 75,
          ),
        );
      }

      // Image Tidak Ada
      else {
        return CircleAvatar(
          backgroundImage: NetworkImage(
              "https://res.cloudinary.com/unlinked/image/upload/v1690390451/1200px-Default_pfp.svg_vxmzyk.png"),
          radius: 75,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        );
      }
    }

    // Mobile
    else {
      // Image Ada
      if (image != null) return mobileImage(image);

      // Image Kosong
      return CircleAvatar(
        backgroundImage: NetworkImage(
            "https://res.cloudinary.com/unlinked/image/upload/v1690390451/1200px-Default_pfp.svg_vxmzyk.png"),
        radius: 75,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      );
    }
  }

  Widget mobileImage(File image) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Container(
              child: SafeArea(
                child: PhotoView(
                  imageProvider: FileImage(image),
                ),
              ),
            ),
          ),
        );
      },
      child: CircleAvatar(
        backgroundImage: FileImage(image),
        radius: 75,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return GestureDetector(
      onTap: () {
        SystemChannels.textInput.invokeListMethod("TextInput.hide");
      },
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Form(
              key: key,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Stack(
                      children: [
                        checkPlatform(image: image, webImage: webImage),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: IconButton(
                            onPressed: () {
                              selectImage();
                            },
                            icon: Icon(Icons.add_a_photo),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),

                    // Email & Password
                    Column(
                      children: [
                        MyTextField(
                          controller: email,
                          hintText: "Email",
                          obscureText: false,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => EmailValidator.validate(value!)
                              ? null
                              : "Email tidak valid",
                        ),
                        SizedBox(height: 10),
                        MyTextField(
                          controller: username,
                          keyboardType: TextInputType.emailAddress,
                          hintText: "Username",
                          obscureText: false,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-z]|\d|\S')),
                          ],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Tidak boleh kosong";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        MyTextField(
                          controller: name,
                          hintText: "Nama Lengkap",
                          obscureText: false,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Tidak boleh kosong";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        MyTextField(
                          controller: bio,
                          hintText: "Bio",
                          obscureText: false,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Tidak boleh kosong";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        MyTextField(
                          controller: password,
                          hintText: "Password",
                          obscureText: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'\w|\S')),
                          ],
                          validator: (value) {
                            RegExp regex = RegExp(
                                r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[-_.]).{8,}$');
                            if (value!.isEmpty) {
                              return 'Tidak boleh kosong';
                            } else {
                              if (!regex.hasMatch(value) ||
                                  value.contains(" ")) {
                                return 'Password tidak valid, harus mengandung huruf besar dan kecil, angka dan simbol';
                              } else {
                                return null;
                              }
                            }
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 10),

                    // Button
                    MyTextButton(
                      child: Center(child: Text("Daftar")),
                      onTap: () async {
                        if (key.currentState!.validate()) {
                          // Gambar Belum Ada
                          if (image == null && webImage == null) {
                            return showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                title: Text("Peringatan!!"),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("OK"))
                                ],
                                content: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Gambar belum diupload"),
                                ),
                              ),
                            );
                          }

                          // Gambar Sudah Ada
                          authProvider.isLoading = true;
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Mencoba mendaftar..."),
                                  LinearProgressIndicator(),
                                ],
                              ),
                            ),
                            barrierDismissible: false,
                          );
                          await AuthMethods.signUp(
                            context,
                            email: email.text,
                            username: username.text,
                            name: name.text,
                            bio: bio.text,
                            password: password.text,
                            file: image == null ? webImage : image,
                          );
                          authProvider.isLoading = false;

                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                              (route) => false);
                        }
                      },
                      padding: EdgeInsets.all(18),
                    ),

                    SizedBox(height: 10),

                    // New Member
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Sudah Punya Akun?"),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            " Masuk Sekarang",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
