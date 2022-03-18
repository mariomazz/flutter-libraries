library extended_methods_list;

import 'dart:math';

/// A Calculator.
class ExtendedMethodsList {
  static T getRandomElement<T>(List<T> list) {
    final random = Random();
    var i = random.nextInt(list.length);
    return list[i];
  }
}
