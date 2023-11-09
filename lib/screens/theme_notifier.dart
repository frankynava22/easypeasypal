import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _themeData;

  ThemeNotifier(this._themeData);

  getTheme() => _themeData;

  setTheme(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }
  
}


// font size 
class FontSizeNotifier with ChangeNotifier {
 
  double _fontSize = 16.0;
  double _primaryTextSize = 22.0; 

  double get fontSize => _fontSize;
  double get primaryTextSize => _primaryTextSize; 

  void setFontSize(double newSize) {
    //update both 
    _fontSize = newSize;
    _primaryTextSize = 1.2 * newSize; // this will be bigger text 

    // notify 
    notifyListeners(); 
  }

  
}

// bold text 
class BoldTextNotifier with ChangeNotifier {
  bool _isBold = false;

  bool get isBold => _isBold;

  void setBold(bool isBold) {
    _isBold = isBold;
    notifyListeners(); 

  }
}