import 'package:flutter/material.dart';

class BottomNavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => this._currentIndex;

  set currentIndex(int value) {
    this._currentIndex = value;
    notifyListeners();
  }
}
