import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';

class MyGlobalStorage {
  static List<LocaleName> speechLocaleNames = [];
  static Future<SharedPreferences> sharedPreferences =
      SharedPreferences.getInstance();
}
