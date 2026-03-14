import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../services/settings_provider.dart';
import '../theme/app_theme.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceColor : AppTheme.lightBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                  children: [
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 32),

                    _buildSectionHeader(context, 'Appearance'),
                    _SettingsRow(
                      icon: Icons.brightness_6_rounded,
                      title: 'Appearance',
                      subtitle: isDark ? 'Dark Mode' : 'Light Mode',
                      trailing: Switch(
                        value: isDark,
                        onChanged: (_) => settings.toggleTheme(),
                        activeColor: colorScheme.primary,
                      ),
                      onTap: () => settings.toggleTheme(),
                    ),
                    _buildFontSizeSelector(context, settings),

                    const SizedBox(height: 32),
                    _buildSectionHeader(context, 'Reading'),
                    _SettingsRow(
                      icon: Icons.short_text_rounded,
                      title: 'Minimal Mode',
                      subtitle: 'Primary meaning only',
                      trailing: Switch(
                        value: settings.minimalMode,
                        onChanged: (v) => settings.setMinimalMode(v),
                        activeColor: colorScheme.primary,
                      ),
                    ),

                    const SizedBox(height: 32),
                    _buildSectionHeader(context, 'Accessibility'),
                    _SettingsRow(
                      icon: Icons.accessibility_new_rounded,
                      title: 'Dyslexia Mode',
                      subtitle: 'Friendly font and spacing',
                      trailing: Switch(
                        value: settings.dyslexiaMode,
                        onChanged: (v) => settings.setDyslexiaMode(v),
                        activeColor: colorScheme.primary,
                      ),
                    ),
                    _SettingsRow(
                      icon: Icons.palette_rounded,
                      title: 'Colorblind Mode',
                      subtitle: 'Safe accent colors',
                      trailing: Switch(
                        value: settings.colorblindMode,
                        onChanged: (v) => settings.setColorblindMode(v),
                        activeColor: colorScheme.primary,
                      ),
                    ),

                    const SizedBox(height: 32),
                    _buildSectionHeader(context, 'Advanced'),
                    _SettingsRow(
                      icon: Icons.search_rounded,
                      title: 'System-wide Lookup',
                      subtitle: 'Search selected text',
                      trailing: Switch(
                        value: settings.systemLookup,
                        onChanged: (v) => settings.setSystemLookup(v),
                        activeColor: colorScheme.primary,
                      ),
                    ),
                    _SettingsRow(
                      icon: Icons.copy_rounded,
                      title: 'Floating Bubble',
                      subtitle: 'Lookup copied words',
                      trailing: Switch(
                        value: settings.floatingBubble,
                        onChanged: (v) => settings.setFloatingBubble(v),
                        activeColor: colorScheme.primary,
                      ),
                    ),

                    const SizedBox(height: 32),
                    _buildSectionHeader(context, 'Offline Library'),
                    if (settings.isDownloading)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SettingsRow(
                            icon: Icons.cloud_download_rounded,
                            title: 'Downloading Library...',
                            subtitle: 'This may take a moment',
                            trailing: SizedBox.shrink(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: settings.downloadProgress,
                                backgroundColor: isDark ? Colors.white12 : Colors.black12,
                                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              '${(settings.downloadProgress * 100).toInt()}%',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppTheme.mutedColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      )
                    else
                      _SettingsRow(
                        icon: Icons.storage_rounded,
                        title: 'Offline Dictionary',
                        subtitle: settings.offlineDownloaded ? 'Ready for offline search' : 'Download for offline use',
                        trailing: TextButton(
                          onPressed: () async {
                            if (settings.offlineDownloaded) {
                              final confirm = await _showDeleteDialog(context);
                              if (confirm == true) {
                                settings.uninstallOfflineLibrary();
                              }
                            } else {
                              settings.installOfflineLibrary();
                            }
                          },
                          child: Text(
                            settings.offlineDownloaded ? 'Remove' : 'Install',
                            style: TextStyle(
                              color: settings.offlineDownloaded ? Colors.redAccent : colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),
                    _buildSectionHeader(context, 'About'),
                    _SettingsRow(
                      icon: Icons.share_rounded,
                      title: 'Share Lexicon',
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.mutedColor),
                      onTap: () {
                        Share.share('Check out Lexicon — a minimal dictionary for readers! https://example.com/lexicon');
                      },
                    ),
                    _SettingsRow(
                      icon: Icons.mail_outline_rounded,
                      title: 'Send Feedback',
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.mutedColor),
                      onTap: () async {
                        final url = Uri.parse('mailto:aviraj@example.com?subject=Lexicon%20Feedback');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? AppTheme.surfaceColor 
          : AppTheme.lightBackgroundColor,
        title: const Text('Remove Library?'),
        content: const Text('This will delete the offline dictionary from your device. You can download it again anytime.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.mutedColor,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
      ),
    );
  }

  Widget _buildFontSizeSelector(BuildContext context, SettingsProvider settings) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.text_fields_rounded, size: 22, color: AppTheme.mutedColor),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              'Font Size',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
            ),
          ),
          Row(
            children: LexiconFontSize.values.map((size) {
              final isSelected = settings.fontSize == size;
              return GestureDetector(
                onTap: () => settings.setFontSize(size),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.primary.withAlpha(20) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? colorScheme.primary.withAlpha(40) : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    size.name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: isSelected ? colorScheme.primary : AppTheme.mutedColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppTheme.mutedColor),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.mutedColor,
                            fontSize: 13,
                          ),
                    ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
