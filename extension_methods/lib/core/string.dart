extension ExtensionString on String {
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
