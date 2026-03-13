import 'dart:convert';
import 'package:http/http.dart' as http;

/// A single definition within a meaning group.
class WordDefinition {
  final String definition;
  final String? example;

  const WordDefinition({required this.definition, this.example});
}

/// A meaning group: one part-of-speech with its definitions and synonyms.
class WordMeaning {
  final String partOfSpeech;
  final List<WordDefinition> definitions;
  final List<String> synonyms;

  const WordMeaning({
    required this.partOfSpeech,
    required this.definitions,
    required this.synonyms,
  });

  factory WordMeaning.fromJson(Map<String, dynamic> json) {
    final rawDefs = (json['definitions'] as List<dynamic>?) ?? [];
    final definitions = rawDefs.map((d) {
      return WordDefinition(
        definition: d['definition'] as String? ?? '',
        example: d['example'] as String?,
      );
    }).where((d) => d.definition.isNotEmpty).toList();

    // Collect synonyms from both meaning-level and definition-level
    final meaningLevelSynonyms = (json['synonyms'] as List<dynamic>?)
            ?.map((s) => s as String)
            .toList() ??
        [];
    final defLevelSynonyms = rawDefs
        .expand<String>((d) =>
            ((d['synonyms'] as List<dynamic>?) ?? []).map((s) => s as String))
        .toList();

    final allSynonyms = {...meaningLevelSynonyms, ...defLevelSynonyms}.toList();

    return WordMeaning(
      partOfSpeech: json['partOfSpeech'] as String? ?? '',
      definitions: definitions,
      synonyms: allSynonyms,
    );
  }
}

/// Full dictionary entry for a word.
class DictionaryEntry {
  final String word;
  final String? phonetic;
  final String? audioUrl;
  final String? origin;
  final List<WordMeaning> meanings;

  const DictionaryEntry({
    required this.word,
    required this.meanings,
    this.phonetic,
    this.audioUrl,
    this.origin,
  });

  /// All unique synonyms across every meaning group.
  List<String> get allSynonyms {
    final seen = <String>{};
    return meanings
        .expand((m) => m.synonyms)
        .where((s) => seen.add(s.toLowerCase()))
        .toList();
  }

  /// The primary definition for quick display.
  String get primaryDefinition =>
      meanings.isNotEmpty && meanings.first.definitions.isNotEmpty
          ? meanings.first.definitions.first.definition
          : 'No definition found.';

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    final word = json['word'] as String;
    final phonetics = json['phonetics'] as List<dynamic>?;

    String? phonetic;
    String? audioUrl;

    if (phonetics != null && phonetics.isNotEmpty) {
      // Prefer an entry that has both text and audio
      final best = phonetics.firstWhere(
        (p) =>
            p['text'] != null &&
            p['audio'] != null &&
            (p['audio'] as String).isNotEmpty,
        orElse: () => phonetics.firstWhere(
          (p) => p['text'] != null,
          orElse: () => phonetics[0],
        ),
      );
      phonetic = best['text'] as String?;
      audioUrl = best['audio'] as String?;

      // Fall back to any audio entry if best had none
      if (audioUrl == null || audioUrl.isEmpty) {
        for (final p in phonetics) {
          if (p['audio'] != null && (p['audio'] as String).isNotEmpty) {
            audioUrl = p['audio'] as String;
            break;
          }
        }
      }
    }

    final rawMeanings = (json['meanings'] as List<dynamic>?) ?? [];
    final meanings =
        rawMeanings.map((m) => WordMeaning.fromJson(m as Map<String, dynamic>)).toList();

    return DictionaryEntry(
      word: word,
      phonetic: phonetic,
      audioUrl: audioUrl,
      origin: json['origin'] as String?,
      meanings: meanings,
    );
  }
}

class DictionaryApiService {
  static const String _baseUrl =
      'https://api.dictionaryapi.dev/api/v2/entries/en/';

  Future<DictionaryEntry?> fetchDefinition(String word) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl$word'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return DictionaryEntry.fromJson(data[0] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
