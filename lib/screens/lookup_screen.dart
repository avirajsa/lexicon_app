import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/dictionary_api.dart';
import '../storage/history_storage.dart';
import '../widgets/floating_search_bar.dart';
import '../widgets/word_display.dart';
import '../theme/app_theme.dart';

class LookupScreen extends StatefulWidget {
  final String? initialWord;
  final Widget? themeToggle;
  final VoidCallback? onHistoryUpdated;
  final VoidCallback? onLexiconUpdated;

  const LookupScreen({
    super.key,
    this.initialWord,
    this.themeToggle,
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
  final ScrollController _scrollController = ScrollController();
  bool _isSearchBarVisible = true;
  bool _isSearchFocused = false;
  double _lastScrollOffset = 0;

  DictionaryEntry? _entry;
  bool _isLoading = false;
  bool _noInternet = false;
  String? _errorWord = null;

  // Tracks content key so AnimatedSwitcher knows when to animate
  int _resultKey = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _searchFocus.addListener(_onFocusChange);
    if (widget.initialWord != null) {
      _searchController.text = widget.initialWord!;
      _handleSearch();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _searchFocus.removeListener(_onFocusChange);
    _scrollController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isSearchFocused = _searchFocus.hasFocus;
      // Ensure bar is visible when typing
      if (_isSearchFocused) _isSearchBarVisible = true;
    });
  }

  void _scrollListener() {
    // Word not found case: always keep search bar visible
    if (_errorWord != null) {
      if (!_isSearchBarVisible) {
        setState(() => _isSearchBarVisible = true);
      }
      return;
    }

    final currentOffset = _scrollController.offset;
    final scrollDelta = currentOffset - _lastScrollOffset;

    if (currentOffset <= 0) {
      // At the top
      if (!_isSearchBarVisible) {
        setState(() => _isSearchBarVisible = true);
      }
    } else if (scrollDelta > 10 && _isSearchBarVisible) {
      // Scrolling down
      setState(() => _isSearchBarVisible = false);
    } else if (scrollDelta < -10 && !_isSearchBarVisible) {
      // Scrolling up
      setState(() => _isSearchBarVisible = true);
    }

    _lastScrollOffset = currentOffset;
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
      _noInternet = false;
    });

    // Real-time: save to history immediately before API call
    await HistoryStorage.addWord(query);
    widget.onHistoryUpdated?.call();

    try {
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
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _noInternet = true;
          _resultKey++;
        });
      }
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
    return PopScope(
      canPop: !_isSearchFocused,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_isSearchFocused) {
          _searchFocus.unfocus();
        }
      },
      child: GestureDetector(
      onTap: () => _searchFocus.unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
          // ── Scrollable content ──────────────────────────────────────
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 100),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    opacity: _isSearchFocused ? 0.0 : 1.0,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: KeyedSubtree(
                        key: ValueKey('result_${_resultKey}_${_isLoading}_${_noInternet}_${_errorWord != null}'),
                        child: _buildResult(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 200),
                ],
              ),
            ),
          ),

          // ── Floating search bar ─────────────────────────────────────
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            left: 32,
            right: 32,
            bottom: _isSearchBarVisible 
                ? (_entry != null || _isLoading || _isSearchFocused ? 100 : MediaQuery.of(context).size.height * 0.4)
                : -100, // Slide down to hide
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              opacity: _isSearchBarVisible ? 1.0 : 0.0,
              child: FloatingSearchBar(
                controller: _searchController,
                focusNode: _searchFocus,
                onSearch: _handleSearch,
              ),
            ),
          ),

          // ── Theme Toggle ──────────────────────────────────────────
          if (widget.themeToggle != null)
            Positioned(
              top: 48,
              right: 24,
                child: widget.themeToggle!,
              ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildResult() {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary.withAlpha(50),
          ),
        ),
      );
    }

    if (_noInternet) {
      return Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/illustrations/no_internet.svg",
                height: 120,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onBackground.withAlpha(50),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "No internet connection",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "Check your connection and try again",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
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
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded,
                      size: 14, color: Theme.of(context).colorScheme.primary),
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
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your reading companion',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground.withAlpha(150),
                ),
          ),
        ],
      ),
    );
  }
}
