import 'dart:js_interop';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kolot/models/user_model.dart';
import 'package:kolot/resources/storage_method.dart';

class AuthMethods {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  // Get Current User Details
  static Stream getUserDetails() {
    User currentUser = auth.currentUser!;

    return firebaseFirestore
        .collection("users")
        .doc(currentUser.uid)
        .snapshots();
  }

  // Sign In
  static Future<void> signIn(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    try {
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Berhasil Masuk"),
        duration: Duration(milliseconds: 1000),
      ));
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-email") {
        _showError(context, "Email tidak valid");
      } else if (e.code == "wrong-password") {
        _showError(context, "Password salah");
      } else if (e.code == "user-not-found") {
        _showError(context, "User tidak ditemukan");
      } else {
        _showError(context, e.message);
      }

      print(e.code);
    }
  }

  // Sign Up
  static Future<String> signUp(
    BuildContext context, {
    required String email,
    required String password,
    required String username,
    required String name,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "Some error occurred";

    try {
      // register user
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!userCredential.isNull) {
        String photoUrl = await StorageMethods.uploadMedia(
          childName: "profilePics",
          file: file,
          isPost: false,
        );

        print("image ada");

        UserModel user = UserModel(
          uid: userCredential.user!.uid,
          email: email,
          username: username,
          name: name,
          bio: bio,
          photoUrl: photoUrl,
          followers: [],
          following: [],
        );

        // add user to database
        await firebaseFirestore
            .collection("users")
            .doc(userCredential.user!.uid)
            .set(
              user.toJson(),
            );
        res = "Success";
      }
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  // Sign Out
  static Future<void> signOut(BuildContext context) async {
    await auth.signOut();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Berhasil Keluar"),
      duration: Duration(milliseconds: 1000),
    ));
  }
}

_showError(BuildContext context, error) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(error),
    duration: Duration(milliseconds: 2000),
  ));
}
