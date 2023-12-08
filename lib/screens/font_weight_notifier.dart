import 'package:flutter/material.dart';

class FontWeightNotifier with ChangeNotifier {
  FontWeight _fontWeight = FontWeight.normal;

  FontWeight get fontWeight => _fontWeight;

  set fontWeight(FontWeight newWeight) {
    _fontWeight = newWeight;
    notifyListeners();
  }
}
