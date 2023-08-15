import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class AddPostNavigationProvider extends ChangeNotifier {
  Uint8List? _image;
  Uint8List? get image => this._image;

  set image(Uint8List? value) {
    this._image = value;
    notifyListeners();
  }

  File? _video;
  File? get video => this._video;

  set video(File? value) {
    this._video = value;
    notifyListeners();
  }

  bool _isImage = false;
  bool get isImage => this._isImage;

  set isImage(bool value) {
    this._isImage = value;
    notifyListeners();
  }

  TextEditingController _caption = TextEditingController();
  TextEditingController get caption => this._caption;

  set caption(TextEditingController value) {
    this._caption = value;
    notifyListeners();
  }
}
