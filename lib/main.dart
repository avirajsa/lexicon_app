import 'dart:ui';
import 'package:flutter/material.dart';
import 'screens/lookup_screen.dart';
import 'screens/history_screen.dart';
import 'screens/lexicon_screen.dart';
import 'screens/tongue_twisters_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const LexiconApp());
}

class LexiconApp extends StatelessWidget {
  const LexiconApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lexicon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  String? _selectedHistoryWord;

  // GlobalKeys let us call methods across screens without rebuilding
  final GlobalKey<HistoryScreenState> _historyKey = GlobalKey();
  final GlobalKey<LexiconScreenState> _lexiconKey = GlobalKey();

  // Fade animation for tab switching
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _switchTab(int index) async {
    if (index == _currentIndex) return;

    // Quick fade out → switch → fade in
    await _fadeCtrl.reverse();
    setState(() {
      _currentIndex = index;
      if (index != 0) _selectedHistoryWord = null;
    });
    await _fadeCtrl.forward();

    // Refresh relevant tab data
    if (index == 1) _historyKey.currentState?.loadHistory();
    if (index == 2) _lexiconKey.currentState?.loadLexicon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Tab content with fade transition ─────────────────────
          FadeTransition(
            opacity: _fadeAnim,
            child: IndexedStack(
              index: _currentIndex,
              children: [
                LookupScreen(
                  initialWord: _selectedHistoryWord,
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
                      _currentIndex = 0;
                    });
                    _fadeCtrl
                      ..reset()
                      ..forward();
                  },
                ),
                LexiconScreen(
                  key: _lexiconKey,
                  onWordSelect: (word) {
                    setState(() {
                      _selectedHistoryWord = word;
                      _currentIndex = 0;
                    });
                    _fadeCtrl
                      ..reset()
                      ..forward();
                  },
                ),
                const TongueTwistersScreen(),
              ],
            ),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The minimal floating pill navigation bar.
/// Semi-transparent, blurred background, icon-only, no thick bar.
class _FloatingNavPill extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingNavPill({
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (icon: Icons.search_rounded, altIcon: Icons.search_rounded, label: 'Lookup'),
    (icon: Icons.history_rounded, altIcon: Icons.history_rounded, label: 'History'),
    (icon: Icons.bookmark_border_rounded, altIcon: Icons.bookmark_rounded, label: 'Lexicon'),
    (icon: Icons.auto_stories_outlined, altIcon: Icons.auto_stories_rounded, label: 'Twisters'),
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
            // Very dark frosted glass feel
            color: AppTheme.surfaceColor.withAlpha(210),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: Colors.white.withAlpha(10),
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
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.isActive,
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
              ? Colors.white.withAlpha(14)
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
                  ? AppTheme.accentColor
                  : AppTheme.iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
