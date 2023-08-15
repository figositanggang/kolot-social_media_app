import 'package:flutter/material.dart';

class TextFieldProvider extends ChangeNotifier {
  bool _obscure = true;
  bool get obscure => _obscure;
  set obscure(value) {
    _obscure = value;
    notifyListeners();
  }
}
