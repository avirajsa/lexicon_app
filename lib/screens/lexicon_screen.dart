import 'package:flutter/material.dart';
import '../storage/lexicon_storage.dart';
import '../theme/app_theme.dart';
import '../widgets/lexicon_item.dart';
import '../widgets/app_footer.dart';

class LexiconScreen extends StatefulWidget {
  final Function(String) onWordSelect;

  const LexiconScreen({super.key, required this.onWordSelect});

  @override
  State<LexiconScreen> createState() => LexiconScreenState();
}

// Public so MainScaffold can call loadLexicon() via GlobalKey
class LexiconScreenState extends State<LexiconScreen> {
  List<LexiconEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    loadLexicon();
  }

  Future<void> loadLexicon() async {
    final entries = await LexiconStorage.getAll();
    if (mounted) {
      setState(() => _entries = entries);
    }
  }

  Future<void> _removeEntry(String word) async {
    await LexiconStorage.removeWord(word);
    loadLexicon();
  }

  Future<void> _clearAll() async {
    await LexiconStorage.clearAll();
    loadLexicon();
  }

  String get _milestoneLabel {
    final n = _entries.length;
    if (n >= 100) return '100 word milestone reached';
    if (n >= 50) return '50 word milestone reached';
    if (n >= 25) return '25 word milestone reached';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ─────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(32, 100, 32, 24),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lexicon',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your saved words',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  if (_entries.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: Theme.of(context).disabledColor,
                      ),
                      onPressed: _clearAll,
                    ),
                ],
              ),
            ),
          ),

          // ── Word count stat ─────────────────────────────────────────
          if (_entries.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Count display
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        '${_entries.length} ${_entries.length == 1 ? 'word' : 'words'}',
                        key: ValueKey(_entries.length),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).hintColor,
                              letterSpacing: 0.6,
                            ),
                      ),
                    ),
                    // Milestone label — appears only when milestone hit
                    if (_milestoneLabel.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _milestoneLabel,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(120),
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // ── Entry list ──────────────────────────────────────────────
          if (_entries.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Opacity(
                  opacity: 0.3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bookmark_border_rounded, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'No saved words yet',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entry = _entries[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: LexiconItem(
                        entry: entry,
                        onTap: () => widget.onWordSelect(entry.word),
                        onRemove: () => _removeEntry(entry.word),
                      ),
                    );
                  },
                  childCount: _entries.length,
                ),
              ),
            ),

          // ── Footer ─────────────────────────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 60)),
          const SliverToBoxAdapter(child: AppFooter()),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
