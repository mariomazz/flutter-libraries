import 'package:extension_methods/core/string.dart';

extension ExtMap<A, B> on Map<A, B> {
  String createQueryParameters({
    required Map<A, B> elements,
    bool questionMarker = true,
  }) {
    String stringValue = questionMarker ? "?" : "";
    elements.forEach((key, value) {
      stringValue += "$key=${value.toString()}&";
    });

    return stringValue.removeLast(test: (e) => e.endsWith("&"));
  }
}
