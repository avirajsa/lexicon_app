import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dictionary_api.dart';

class OfflineDictionaryService {
  static final OfflineDictionaryService instance = OfflineDictionaryService._();
  OfflineDictionaryService._();

  Database? _db;
  static const String _dbName = 'dictionary.db';
  static const String _githubUrl = 'https://raw.githubusercontent.com/avirajsa/lexicon_app/main/assets/offline_dictionary/dictionary.db';

  Future<bool> get isInstalled async {
    final path = await _getDbPath();
    return File(path).exists();
  }

  Future<String> _getDbPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return join(directory.path, _dbName);
  }

  Future<Database> _getDatabase() async {
    if (_db != null && _db!.isOpen) return _db!;
    final path = await _getDbPath();
    _db = await openDatabase(path);
    return _db!;
  }

  Future<void> downloadDictionary({Function(double)? onProgress}) async {
    final path = await _getDbPath();
    final response = await http.Client().send(http.Request('GET', Uri.parse(_githubUrl)));
    
    final total = response.contentLength ?? 0;
    var received = 0;
    final file = File(path);
    final sink = file.openWrite();

    await response.stream.map((chunk) {
      received += chunk.length;
      if (onProgress != null && total > 0) {
        onProgress(received / total);
      }
      return chunk;
    }).pipe(sink);

    await sink.close();
    // Re-open database after download
    await _getDatabase();
  }

  Future<void> deleteDictionary() async {
    await closeDatabase();
    final path = await _getDbPath();
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> closeDatabase() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }

  Future<DictionaryEntry?> lookup(String word) async {
    if (!await isInstalled) return null;

    try {
      final db = await _getDatabase();
      final List<Map<String, dynamic>> maps = await db.query(
        'words',
        where: 'LOWER(word) = LOWER(?)',
        whereArgs: [word],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        final row = maps.first;
        // SQLite stores meaning and synonyms as plain text/JSON strings usually
        // If they are JSON strings, we decode. If they are plain text, we wrap.
        // Based on requirements, they seem to be simple text fields or JSON.
        // Let's assume a healthy schema that we can map to DictionaryEntry.
        
        final meanings = [
          WordMeaning(
            partOfSpeech: 'word',
            definitions: [
              WordDefinition(definition: row['meaning'] as String? ?? 'No definition.')
            ],
            synonyms: (row['synonyms'] as String? ?? '')
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList(),
          )
        ];

        return DictionaryEntry(
          word: row['word'] as String? ?? word,
          meanings: meanings,
        );
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
