import 'package:flutter/material.dart';

class HomeNavigationProvider extends ChangeNotifier {
  double _scrollOffset = 0;
  double get scrollOffset => this._scrollOffset;

  set scrollOffset(double value) {
    this._scrollOffset = value;
    notifyListeners();
  }
}
