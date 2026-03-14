import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/lookup_screen.dart';
import 'screens/history_screen.dart';
import 'screens/lexicon_screen.dart';
import 'screens/tongue_twisters_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/theme_toggle.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LexiconApp());
}

class LexiconApp extends StatefulWidget {
  const LexiconApp({super.key});

  @override
  State<LexiconApp> createState() => _LexiconAppState();
}

class _LexiconAppState extends State<LexiconApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isLight = prefs.getBool('is_light_mode') ?? false;
    setState(() {
      _themeMode = isLight ? ThemeMode.light : ThemeMode.dark;
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      prefs.setBool('is_light_mode', _themeMode == ThemeMode.light);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lexicon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: MainScaffold(
        themeMode: _themeMode,
        onThemeToggle: _toggleTheme,
      ),
    );
  }
}

class MainScaffold extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onThemeToggle;

  const MainScaffold({
    super.key,
    required this.themeMode,
    required this.onThemeToggle,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  String? _selectedHistoryWord;
  DateTime? _lastBackPressed;

  // GlobalKeys let us call methods across screens without rebuilding
  final GlobalKey<HistoryScreenState> _historyKey = GlobalKey();
  final GlobalKey<LexiconScreenState> _lexiconKey = GlobalKey();

  // PageController for global swipe navigation
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 1.0,
      keepPage: true,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _switchTab(int index) async {
    if (index == _currentIndex) return;

    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      if (index != 0) _selectedHistoryWord = null;
    });

    // Refresh relevant tab data
    if (index == 1) _historyKey.currentState?.loadHistory();
    if (index == 2) _lexiconKey.currentState?.loadLexicon();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;

        final now = DateTime.now();
        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          _lastBackPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Press back again to exit',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? AppTheme.backgroundColor : AppTheme.lightBackgroundColor,
                    ),
              ),
              backgroundColor: isDark ? AppTheme.accentColor : AppTheme.lightPrimaryText,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.only(left: 100, right: 100, bottom: 100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        } else {
          // Grant exit
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // ── Tab content with PageView (Swipe Navigation) ────────────
            PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              children: [
                LookupScreen(
                  initialWord: _selectedHistoryWord,
                  themeToggle: ThemeToggle(
                    isDark: isDark,
                    onToggle: widget.onThemeToggle,
                  ),
                  onHistoryUpdated: () {
                    _historyKey.currentState?.loadHistory();
                  },
                  onLexiconUpdated: () {
                    _lexiconKey.currentState?.loadLexicon();
                  },
                ),
                HistoryScreen(
                  key: _historyKey,
                  onWordSelect: (word) {
                    setState(() {
                      _selectedHistoryWord = word;
                    });
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                    );
                  },
                ),
                LexiconScreen(
                  key: _lexiconKey,
                  onWordSelect: (word) {
                    setState(() {
                      _selectedHistoryWord = word;
                    });
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                    );
                  },
                ),
                const TongueTwistersScreen(),
              ],
            ),

          // ── Floating pill navigation ──────────────────────────────
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: Center(
              child: _FloatingNavPill(
                currentIndex: _currentIndex,
                onTap: _switchTab,
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

/// The minimal floating pill navigation bar.
/// Semi-transparent, blurred background, icon-only, no thick bar.
class _FloatingNavPill extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isDark;

  const _FloatingNavPill({
    required this.currentIndex,
    required this.onTap,
    required this.isDark,
  });

  static const _items = [
    (
      icon: Icons.search_rounded,
      altIcon: Icons.search_rounded,
      label: 'Lookup'
    ),
    (
      icon: Icons.history_rounded,
      altIcon: Icons.history_rounded,
      label: 'History'
    ),
    (
      icon: Icons.bookmark_border_rounded,
      altIcon: Icons.bookmark_rounded,
      label: 'Lexicon'
    ),
    (
      icon: Icons.auto_stories_outlined,
      altIcon: Icons.auto_stories_rounded,
      label: 'Twisters'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.surfaceColor.withAlpha(210)
                : AppTheme.lightSurfaceColor.withAlpha(210),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(10)
                  : Colors.black.withAlpha(10),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final isActive = i == currentIndex;
              return _NavIcon(
                icon: isActive ? item.altIcon : item.icon,
                label: item.label,
                isActive: isActive,
                isDark: isDark,
                onTap: () => onTap(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: isActive ? 56 : 48,
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? Colors.white.withAlpha(14) : Colors.black.withAlpha(14))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              icon,
              key: ValueKey(isActive),
              size: 22,
              color: isActive
                  ? (isDark ? AppTheme.accentColor : AppTheme.lightPrimaryText)
                  : (isDark ? AppTheme.iconColor : AppTheme.lightMutedColor),
            ),
          ),
        ),
      ),
    );
  }
}
