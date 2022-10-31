extension ExtensionString on String {
  static final _startValues = Expando<String>();
  String get value => _startValues[this] ?? "";
  set value(String x) => _startValues[this] = x;

  String removeLast({bool Function(String)? test}) {
    if (test?.call(this) ?? _fn(this)) {
      List<String> c = split("");
      c.removeLast();
      return c.join();
    }
    return this;
  }

  void removeLastAndSet({bool Function(String)? test}) {
    if (test?.call(this) ?? _fn(this)) {
      List<String> c = split("");
      c.removeLast();
      value = c.join();
    }
    return;
  }

  bool equals(String other) {
    return this == other;
  }

  bool notEquals(String other) {
    return this != other;
  }

  bool equalsAny(List<String> other) {
    for (var value in other) {
      if (equals(value)) {
        return true;
      }
    }

    return false;
  }
}

bool _fn(String v) => true;
