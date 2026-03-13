import 'package:shared_preferences/shared_preferences.dart';

class HistoryStorage {
  static const String _key = 'search_history';
  static const int _maxHistory = 10;

  static Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> addWord(String word) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentHistory = prefs.getStringList(_key) ?? [];
    
    // Remove if already exists to move it to the top
    currentHistory.removeWhere((item) => item.toLowerCase() == word.toLowerCase());
    
    // Insert at top
    currentHistory.insert(0, word);
    
    // Keep only the last 10
    if (currentHistory.length > _maxHistory) {
      currentHistory.removeRange(_maxHistory, currentHistory.length);
    }
    
    await prefs.setStringList(_key, currentHistory);
  }

  static Future<void> removeWord(String word) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> current = prefs.getStringList(_key) ?? [];
    current.removeWhere((item) => item.toLowerCase() == word.toLowerCase());
    await prefs.setStringList(_key, current);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
