import 'package:flutter/material.dart';

class SearchBarProvider extends ChangeNotifier {
  TextEditingController _controller = TextEditingController();
  TextEditingController get controller => this._controller;

  set controller(TextEditingController value) {
    this._controller = value;
    notifyListeners();
  }

  bool _isSuffix = false;
  bool get isSuffix => this._isSuffix;

  set isSuffix(bool value) {
    this._isSuffix = value;
    notifyListeners();
  }
}
