import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/dictionary_api.dart';
import '../storage/lexicon_storage.dart';
import '../theme/app_theme.dart';

class WordDisplay extends StatefulWidget {
  final DictionaryEntry entry;
  final void Function(String word)? onSynonymTap;

  const WordDisplay({super.key, required this.entry, this.onSynonymTap});

  @override
  State<WordDisplay> createState() => _WordDisplayState();
}

class _WordDisplayState extends State<WordDisplay>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isSaved = false;
  bool _isSaving = false;

  // Slide-up animation controller
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut);

    _slideCtrl.forward();
    _checkSaved();
  }

  @override
  void didUpdateWidget(WordDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.word != widget.entry.word) {
      // Re-animate when word changes
      _slideCtrl
        ..reset()
        ..forward();
      _checkSaved();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkSaved() async {
    final saved = await LexiconStorage.contains(widget.entry.word);
    if (mounted) setState(() => _isSaved = saved);
  }

  Future<void> _toggleLexicon() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    if (_isSaved) {
      await LexiconStorage.removeWord(widget.entry.word);
    } else {
      await LexiconStorage.addWord(
        widget.entry.word,
        widget.entry.primaryDefinition,
      );
    }
    if (mounted) {
      setState(() {
        _isSaved = !_isSaved;
        _isSaving = false;
      });
    }
  }

  Future<void> _playAudio() async {
    if (widget.entry.audioUrl == null || widget.entry.audioUrl!.isEmpty) return;
    try {
      setState(() => _isPlaying = true);
      await _audioPlayer.play(UrlSource(widget.entry.audioUrl!));
      _audioPlayer.onPlayerComplete.first.then((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
    } catch (_) {
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  Future<void> _launchGoogle(String word) async {
    final url = Uri.parse('https://www.google.com/search?q=$word+meaning');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Word + controls row ─────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    entry.word.toLowerCase(),
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                // Bookmark button
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: IconButton(
                    key: ValueKey(_isSaved),
                    icon: Icon(
                      _isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: _isSaved
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).disabledColor,
                      size: 24,
                    ),
                    onPressed: _toggleLexicon,
                    tooltip: _isSaved ? 'Remove from Lexicon' : 'Add to Lexicon',
                  ),
                ),
                // Audio button
                if (entry.audioUrl != null && entry.audioUrl!.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      _isPlaying
                          ? Icons.volume_up_rounded
                          : Icons.volume_up_outlined,
                      color: _isPlaying
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).disabledColor,
                      size: 26,
                    ),
                    onPressed: _playAudio,
                  ),
              ],
            ),

            // ── Pronunciation ───────────────────────────────────────
            if (entry.phonetic != null) ...[
              const SizedBox(height: 4),
              Text(
                entry.phonetic!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      color: AppTheme.secondaryTextColor,
                    ),
              ),
            ],

            // ── Meanings ────────────────────────────────────────────
            ...entry.meanings.map((m) => _buildMeaning(context, m)),

            // ── Origin ─────────────────────────────────────────────
            if (entry.origin != null) ...[
              const SizedBox(height: 32),
              Text(
                'Origin',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.mutedColor,
                      letterSpacing: 0.8,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.origin!,
                style:
                    Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
              ),
            ],

            // ── Synonyms ────────────────────────────────────────────
            if (entry.allSynonyms.isNotEmpty) ...[
              const SizedBox(height: 40),
              Text(
                'Synonyms',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.mutedColor,
                      letterSpacing: 0.8,
                    ),
              ),
              const SizedBox(height: 12),
              _buildSynonyms(context, entry.allSynonyms),
            ],

            // ── Google link ─────────────────────────────────────────
            const SizedBox(height: 48),
            _buildGoogleLink(context, entry.word),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMeaning(BuildContext context, WordMeaning meaning) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 36),
        Text(
          meaning.partOfSpeech,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.secondaryTextColor,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.4,
              ),
        ),
        const SizedBox(height: 16),
        ...meaning.definitions.asMap().entries.map((e) {
          final idx = e.key;
          final def = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (meaning.definitions.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      '${idx + 1}.',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: AppTheme.mutedColor),
                    ),
                  ),
                Text(def.definition,
                    style: Theme.of(context).textTheme.bodyLarge),
                if (def.example != null && def.example!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '"${def.example}"',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppTheme.secondaryTextColor.withAlpha(150),
                        ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSynonyms(BuildContext context, List<String> synonyms) {
    final display = synonyms.take(10).toList();
    return Wrap(
      spacing: 0,
      runSpacing: 8,
      children: display.asMap().entries.map((e) {
        final word = e.value;
        final isLast = e.key == display.length - 1;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => widget.onSynonymTap?.call(word),
              child: Text(
                word,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary.withAlpha(180),
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      decorationColor: Theme.of(context).colorScheme.primary.withAlpha(60),
                    ),
              ),
            ),
            if (!isLast)
              Text(
                '  •  ',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.mutedColor),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildGoogleLink(BuildContext context, String word) {
    return GestureDetector(
      onTap: () => _launchGoogle(word),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'See more on Google',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(120),
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.arrow_forward_rounded,
              size: 14, 
              color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(120)),
        ],
      ),
    );
  }
}
