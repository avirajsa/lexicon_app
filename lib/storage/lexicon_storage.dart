import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LexiconEntry {
  final String word;
  final String definition;
  final DateTime dateAdded;

  const LexiconEntry({
    required this.word,
    required this.definition,
    required this.dateAdded,
  });

  Map<String, dynamic> toJson() => {
        'word': word,
        'definition': definition,
        'dateAdded': dateAdded.toIso8601String(),
      };

  factory LexiconEntry.fromJson(Map<String, dynamic> json) => LexiconEntry(
        word: json['word'] as String,
        definition: json['definition'] as String? ?? '',
        dateAdded: DateTime.tryParse(json['dateAdded'] as String? ?? '') ??
            DateTime.now(),
      );
}

class LexiconStorage {
  static const String _key = 'personal_lexicon';

  static Future<List<LexiconEntry>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((e) {
          try {
            return LexiconEntry.fromJson(
                json.decode(e) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<LexiconEntry>()
        .toList();
  }

  static Future<bool> contains(String word) async {
    final entries = await getAll();
    return entries.any(
        (e) => e.word.toLowerCase() == word.toLowerCase());
  }

  static Future<void> addWord(String word, String definition) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getAll();

    // Avoid duplicates
    entries.removeWhere(
        (e) => e.word.toLowerCase() == word.toLowerCase());

    // Insert at top — most recently added first
    entries.insert(
      0,
      LexiconEntry(
        word: word,
        definition: definition,
        dateAdded: DateTime.now(),
      ),
    );

    await prefs.setStringList(
      _key,
      entries.map((e) => json.encode(e.toJson())).toList(),
    );
  }

  static Future<void> removeWord(String word) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getAll();
    entries.removeWhere(
        (e) => e.word.toLowerCase() == word.toLowerCase());
    await prefs.setStringList(
      _key,
      entries.map((e) => json.encode(e.toJson())).toList(),
    );
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
