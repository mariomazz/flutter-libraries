library fc_configurations;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FcService {
  static Future<Map<String, String>> getEnvironment(
      FirebaseFirestore firestoreInstance,
      {String? env}) async {
    try {
      env ??= const String.fromEnvironment('ENVIRONMENT', defaultValue: "dev")
          .toLowerCase();

      return (await firestoreInstance
              .collection('app_env')
              .where("env_name", isEqualTo: env.toLowerCase())
              .get())
          .docs
          .first
          .data()
          .map((key, value) => MapEntry(key.toLowerCase(), value.toString()));
    } catch (e) {
      if (kDebugMode) {
        print("Exception getAppEnvironment => $e");
      }
      return {};
    }
  }
}
