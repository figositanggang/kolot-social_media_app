import 'dart:io';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';

class Utils {
  static Future pickImage(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();

    XFile? file;
    html.File? webFile;

    // Web
    if (kIsWeb) {
      webFile = await ImagePickerWeb.getImageAsFile();
    }

    // Mobile
    else {
      if (source == ImageSource.gallery) {
        file = await imagePicker.pickMedia();
      } else if (source == ImageSource.camera) {
        file = await imagePicker.pickImage(source: source);
      }
    }

    if (file != null || webFile != null) {
      // Web
      if (kIsWeb) {
        return webFile;
      }

      // Mobile
      return File(file!.path);
    }

    return null;
  }
}
