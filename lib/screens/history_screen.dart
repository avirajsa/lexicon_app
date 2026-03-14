import 'package:flutter/material.dart';
import '../storage/history_storage.dart';
import '../theme/app_theme.dart';
import '../widgets/history_item.dart';
import '../widgets/app_footer.dart';

class HistoryScreen extends StatefulWidget {
  final Function(String) onWordSelect;

  const HistoryScreen({super.key, required this.onWordSelect});

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

// Public state so MainScaffold can call loadHistory() via GlobalKey.
class HistoryScreenState extends State<HistoryScreen> {
  List<String> _history = [];
  final GlobalKey<SliverAnimatedListState> _listKey = GlobalKey<SliverAnimatedListState>();

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final history = await HistoryStorage.getHistory();
    if (mounted) {
      setState(() => _history = history);
    }
  }

  Future<void> _removeItem(String word, int index) async {
    final removedItem = _history[index];

    // Remove from the list first to animate
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: HistoryItem(
              word: removedItem,
              onTap: () {},
              onRemove: () {},
            ),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 300),
    );

    // Then update the state data
    setState(() {
      _history.removeAt(index);
    });
    await HistoryStorage.removeWord(word);
  }

  Future<void> _clearHistory() async {
    await HistoryStorage.clearHistory();
    loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(32, 100, 32, 24),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'History',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Recent look-ups',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Long-press a word to remove it',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                  if (_history.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: Theme.of(context).disabledColor,
                      ),
                      onPressed: _clearHistory,
                    ),
                ],
              ),
            ),
          ),
          if (_history.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Opacity(
                  opacity: 0.3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history_rounded, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'No history yet',
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
              sliver: SliverAnimatedList(
                key: _listKey,
                initialItemCount: _history.length,
                itemBuilder: (context, index, animation) {
                  final word = _history[index];
                  return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: HistoryItem(
                          word: word,
                          onTap: () => widget.onWordSelect(word),
                          onRemove: () => _removeItem(word, index),
                        ),
                      ),
                    ),
                  );
                },
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
