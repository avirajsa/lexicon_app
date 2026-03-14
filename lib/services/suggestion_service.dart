import 'package:edit_distance/edit_distance.dart';

class SuggestionService {
  // A small local dictionary for common words to suggest against.
  // In a real app, this could be a more comprehensive list or based on user history.
  static const List<String> _commonWords = [
    'environment', 'envelopment', 'environmental',
    'dictionary', 'vocabulary', 'lexicon',
    'minimal', 'premium', 'animation',
    'reader', 'spacing', 'typography',
    'reading', 'writing', 'speaking',
    'listening', 'understand', 'knowledge',
    'meaning', 'definition', 'synonym',
  ];

  static List<String> getSuggestions(String query) {
    if (query.isEmpty) return [];

    final Levenshtein levenshtein = Levenshtein();
    final suggestions = _commonWords.map((word) {
      return {
        'word': word,
        'distance': levenshtein.distance(query.toLowerCase(), word.toLowerCase()),
      };
    }).toList();

    // Sort by distance and take top 3
    suggestions.sort((a, b) => (a['distance'] as num).compareTo(b['distance'] as num));
    
    return suggestions
        .where((s) => (s['distance'] as num) <= 3) // Only reasonably close matches
        .take(3)
        .map((s) => s['word'] as String)
        .toList();
  }
}
