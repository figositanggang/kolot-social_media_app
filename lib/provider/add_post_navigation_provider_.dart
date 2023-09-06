import 'dart:io';

import 'package:flutter/material.dart';

class AddPostNavigationProvider extends ChangeNotifier {
  File? _file;
  File? get file => this._file;

  set file(File? value) {
    this._file = value;
    notifyListeners();
  }

  TextEditingController _caption = TextEditingController();
  TextEditingController get caption => this._caption;

  set caption(TextEditingController value) {
    this._caption = value;
    notifyListeners();
  }
}
