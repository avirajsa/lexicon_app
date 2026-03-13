import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/dictionary_api.dart';

class DefinitionCard extends StatelessWidget {
  final DictionaryEntry entry;

  const DefinitionCard({super.key, required this.entry});

  Future<void> _launchGoogle(String word) async {
    final url = Uri.parse('https://www.google.com/search?q=$word+meaning');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.word.toLowerCase(),
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        if (entry.partOfSpeech != null) ...[
          const SizedBox(height: 8),
          Text(
            entry.partOfSpeech!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: Colors.white54,
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          entry.definition,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 40),
        Center(
          child: TextButton(
            onPressed: () => _launchGoogle(entry.word),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.white24),
              ),
            ),
            child: Text(
              "Read More on Google",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
