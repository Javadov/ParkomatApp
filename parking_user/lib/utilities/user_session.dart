import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();

  String? email;
  int? userId; // Added userId
  List<Map<String, dynamic>> vehicles = [];

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email');
    userId = prefs.getInt('userId'); // Load userId from shared preferences
  }

  Future<void> saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (email != null && userId != null) {
      prefs.setString('email', email!);
      prefs.setInt('userId', userId!); // Save userId to shared preferences
      prefs.setBool('isLoggedIn', true);
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
    prefs.remove('userId'); // Remove userId from shared preferences
    prefs.setBool('isLoggedIn', false);
    email = null;
    userId = null; // Clear userId
    vehicles.clear();
  }
}