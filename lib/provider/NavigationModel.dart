import 'package:flutter/material.dart';

class NavigationModel extends ChangeNotifier {
  int currentIndex = 4;

  void changeIndex(int newIndex) {
    currentIndex = newIndex;
    notifyListeners();
  }
}
