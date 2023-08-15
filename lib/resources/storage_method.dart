import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageMethods {
  static final FirebaseStorage storage = FirebaseStorage.instance;
  static final currentUser = FirebaseAuth.instance.currentUser!;

  // add image
  static Future<String> uploadMedia({
    required String childName,
    required Uint8List file,
    required bool isPost,
  }) async {
    Reference ref = storage.ref().child(childName).child(currentUser.uid);

    UploadTask uploadTask = ref.putData(file);

    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();

    return downloadUrl;
  }
}
