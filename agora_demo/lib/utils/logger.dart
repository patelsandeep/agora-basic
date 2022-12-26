import 'package:flutter/foundation.dart';

class Logger {
  //Prints logs only in debug mode
  static log(title) {
    if (kDebugMode) {
      print(title);
    }
  }
}
