library extended_methods_list;

import 'dart:math';

/// A Calculator.
class ExtendedMethodsList {
  static T getRandomElement<T>(List<T> list) =>
      list[Random().nextInt(list.length)];
}
