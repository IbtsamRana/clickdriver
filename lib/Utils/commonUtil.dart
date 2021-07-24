import 'package:shared_preferences/shared_preferences.dart';

class CommonUtils{
  static Future<String> fetchPrefs(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }
}