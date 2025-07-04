import 'package:shared_preferences/shared_preferences.dart';

/// OfflineManager: Local storage and sync logic.
class OfflineManager {
  Future<void> saveGameState(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> loadGameState(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> clearGameState(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
