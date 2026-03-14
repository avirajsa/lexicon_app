import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'settings_sheet.dart';

class TopBar extends StatefulWidget {
  final String title;
  final Widget? rightAction;

  const TopBar({
    super.key,
    required this.title,
    this.rightAction,
  });

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> with SingleTickerProviderStateMixin {
  late final AnimationController _gearCtrl;

  @override
  void initState() {
    super.initState();
    _gearCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _gearCtrl.dispose();
    super.dispose();
  }

  void _openSettings() {
    _gearCtrl.forward(from: 0);
    SettingsSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 24,
        right: 24,
        bottom: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Settings Gear
          GestureDetector(
            onTap: _openSettings,
            child: RotationTransition(
              turns: Tween(begin: 0.0, end: 120 / 360).animate(
                CurvedAnimation(parent: _gearCtrl, curve: Curves.easeOutCubic),
              ),
              child: Icon(
                Icons.settings_outlined,
                color: isDark ? AppTheme.iconColor : AppTheme.lightMutedColor,
                size: 24,
              ),
            ),
          ),

          // Center: Title
          Text(
            widget.title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: isDark ? AppTheme.secondaryTextColor : AppTheme.lightSecondaryText,
                ),
          ),

          // Right: Action (Theme toggle)
          widget.rightAction ?? const SizedBox(width: 24),
        ],
      ),
    );
  }
}
