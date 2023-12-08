import 'package:flutter/material.dart';

class FontSizeNotifier with ChangeNotifier {
  double _fontSize;

  FontSizeNotifier(this._fontSize);

  double get fontSize => _fontSize;

  set fontSize(double fontSize) {
    _fontSize = fontSize;
    notifyListeners();
  }
}
