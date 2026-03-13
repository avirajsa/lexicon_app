import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/dictionary_api.dart';
import '../storage/history_storage.dart';
import '../widgets/floating_search_bar.dart';
import '../widgets/word_display.dart';
import '../theme/app_theme.dart';

class LookupScreen extends StatefulWidget {
  final String? initialWord;
  final VoidCallback? onHistoryUpdated;
  final VoidCallback? onLexiconUpdated;

  const LookupScreen({
    super.key,
    this.initialWord,
    this.onHistoryUpdated,
    this.onLexiconUpdated,
  });

  @override
  State<LookupScreen> createState() => _LookupScreenState();
}

class _LookupScreenState extends State<LookupScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final DictionaryApiService _apiService = DictionaryApiService();

  DictionaryEntry? _entry;
  bool _isLoading = false;
  String? _errorWord;

  // Tracks content key so AnimatedSwitcher knows when to animate
  int _resultKey = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (widget.initialWord != null) {
      _searchController.text = widget.initialWord!;
      _handleSearch();
    }
  }

  @override
  void didUpdateWidget(LookupScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialWord != null &&
        widget.initialWord != oldWidget.initialWord) {
      _searchController.text = widget.initialWord!;
      _handleSearch();
    }
  }

  Future<void> _handleSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    _searchFocus.unfocus();

    setState(() {
      _isLoading = true;
      _errorWord = null;
      _entry = null;
    });

    // Real-time: save to history immediately before API call
    await HistoryStorage.addWord(query);
    widget.onHistoryUpdated?.call();

    final result = await _apiService.fetchDefinition(query);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _resultKey++; // Trigger AnimatedSwitcher
        if (result != null) {
          _entry = result;
        } else {
          _errorWord = query;
        }
      });
    }
  }

  void _handleSynonymTap(String word) {
    _searchController.text = word;
    _handleSearch();
  }

  Future<void> _launchGoogle(String word) async {
    final url = Uri.parse('https://www.google.com/search?q=$word+meaning');
    await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Stack(
        children: [
          // ── Scrollable content ──────────────────────────────────────
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 100),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(_resultKey),
                      child: _buildResult(),
                    ),
                  ),
                  const SizedBox(height: 200),
                ],
              ),
            ),
          ),

          // ── Floating search bar ─────────────────────────────────────
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(
                top: _entry != null || _isLoading
                    ? MediaQuery.of(context).size.height * 0.4
                    : 0,
                left: 32,
                right: 32,
              ),
              child: FloatingSearchBar(
                controller: _searchController,
                focusNode: _searchFocus,
                onSearch: _handleSearch,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 40.0),
        child: Center(child: CircularProgressIndicator(color: Colors.white10)),
      );
    }

    if (_errorWord != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No dictionary result found.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => _launchGoogle(_errorWord!),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See more on Google',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.accentColor.withAlpha(100),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded,
                      size: 14, color: AppTheme.accentColor.withAlpha(100)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_entry != null) {
      return WordDisplay(
        entry: _entry!,
        onSynonymTap: _handleSynonymTap,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lexicon',
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Your reading companion',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
