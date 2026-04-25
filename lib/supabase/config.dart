import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class Config {
  static const bool isProduction =
      String.fromEnvironment('FLUTTER_APP_FLAVOR') == 'prod';

  static String get(String key) {
    final value = dotenv.env[key];
    if (value == null) {
      throw Exception('Missing required configuration key [$key]');
    }
    return value;
  }

  static Future<void> load() async {
    const suffix = isProduction ? '.prod' : '.dev';
    await dotenv.load(fileName: '.env$suffix');
  }
}
