library fc_configurations;

import 'package:flutter/foundation.dart';

class FcService {
  static Future<Map<String, dynamic>> getAppEnvironment(
      dynamic firestoreInstance,
      {String? env}) async {
    try {
      const defaultEnv = "dev";

      env ??=
          const String.fromEnvironment('ENVIRONMENT', defaultValue: defaultEnv)
              .toLowerCase();

      final envRef = await firestoreInstance
          .collection('app_env')
          .where("env_name", isEqualTo: env.toLowerCase())
          .get();

      final envConfig = envRef.docs.first.data();

      return envConfig ?? {};
    } catch (e) {
      if (kDebugMode) {
        print("Exception getAppEnvironment => $e");
      }
      return {};
    }
  }
}
