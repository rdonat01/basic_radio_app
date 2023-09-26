import 'package:flutter/material.dart';

class Utils {
  static bool isColorLight(Color color) {
    return (color.red * 0.299 + color.green * 0.587 + color.blue * 0.114) > 186;
  }
}
