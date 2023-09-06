import 'dart:io';
import 'dart:html' as html;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class StorageMethods {
  static final FirebaseStorage storage = FirebaseStorage.instance;
  static final currentUser = FirebaseAuth.instance.currentUser!;

  // Storage Media from Mobile
  static Future<String> uploadMediaMobile({
    required String childName,
    required File file,
  }) async {
    try {
      Reference ref = storage
          .ref()
          .child(childName)
          .child("${currentUser.uid}-${basename(file.path)}");

      UploadTask uploadTask = ref.putFile(file);

      TaskSnapshot taskSnapshot = await uploadTask;

      if (taskSnapshot.state == TaskState.success) {
        return await uploadTask.snapshot.ref.getDownloadURL();
      } else {
        return 'error';
      }
    } catch (e) {
      return 'error';
    }
  }

  // Storage Media from Web
  static Future<String> uploadMediaWeb({
    required String childName,
    required html.File file,
  }) async {
    try {
      Reference ref = storage
          .ref()
          .child(childName)
          .child("${currentUser.uid}-${file.name}");

      UploadTask uploadTask = ref.putBlob(file);

      TaskSnapshot taskSnapshot = await uploadTask;

      if (taskSnapshot.state == TaskState.success) {
        return await uploadTask.snapshot.ref.getDownloadURL();
      } else {
        return 'error';
      }
    } catch (e) {
      return 'error';
    }
  }

  // Delete Media
  static Future<String> deleteMedia(String url) async {
    String res = 'error';
    Reference ref = storage.ref().child("postMedia/${url}");

    try {
      await ref.delete();
      print("Berhasil dihapus");
      res = "success";
    } on FirebaseException catch (e) {
      print("ERROR: ${e.message}");
      print("Gagal dihapus");

      res = e.code;
    }

    return res;
  }
}
