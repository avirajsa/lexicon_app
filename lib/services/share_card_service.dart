import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareCardService {
  static Future<void> shareWordText({
    required String? word,
    required String? definition,
  }) async {
    if (word == null || word.isEmpty) return;
    
    final capitalizedWord = '${word[0].toUpperCase()}${word.substring(1)}';
    final text = 'Word: $capitalizedWord\n\n'
                 'Meaning:\n'
                 '${definition ?? "No definition found."}\n\n'
                 'Discover more beautiful words with Lexicon:\n'
                 'https://avirajsa.github.io/lexicon_app/';
    
    await Share.share(text);
  }

  static Future<void> shareWord({
    required BuildContext context,
    required GlobalKey boundaryKey,
    required String word,
  }) async {
    try {
      final RenderRepaintBoundary boundary =
          boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      // We can use a higher pixel ratio to get better quality
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/$word.png').create();
      await imagePath.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: 'Look up "$word" on Lexicon',
      );
    } catch (e) {
      debugPrint('Error sharing word: $e');
    }
  }
}

class ShareCard extends StatelessWidget {
  final String word;
  final String definition;
  final String? example;
  final bool isDark;

  const ShareCard({
    super.key,
    required this.word,
    required this.definition,
    this.example,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Square 1080x1080 design (scaled for display)
    return Container(
      width: 400, // scaled down for internal rendering if needed, but we use pixelRatio for HQ
      height: 400,
      padding: const EdgeInsets.all(48),
      color: isDark ? const Color(0xFF0F0F10) : const Color(0xFFF4E9D8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            word.toLowerCase(),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            definition,
            style: TextStyle(
              fontSize: 20,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.5,
            ),
          ),
          if (example != null && example!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '"$example"',
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
          ],
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Lexicon',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
