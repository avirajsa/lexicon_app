import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Choose colors based on theme to prevent invisibility
    final textColor = isDark 
        ? AppTheme.secondaryTextColor 
        : AppTheme.lightSecondaryText;
        
    final iconColor = isDark 
        ? AppTheme.accentColor.withAlpha(180) 
        : AppTheme.lightPrimaryText.withAlpha(180);

    return Padding(
      padding: const EdgeInsets.only(bottom: 60.0, top: 40.0),
      child: Column(
        children: [
          Text(
            'Follow me on',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: textColor.withAlpha(150),
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialLink(
                icon: FontAwesomeIcons.xTwitter,
                onTap: () => _launchUrl('https://x.com/avirajsa'),
                tooltip: 'X',
                color: iconColor,
              ),
              const SizedBox(width: 8),
              _SocialLink(
                icon: FontAwesomeIcons.linkedinIn,
                onTap: () => _launchUrl('https://linkedin.com/in/avirajsa'),
                tooltip: 'LinkedIn',
                color: iconColor,
              ),
              const SizedBox(width: 8),
              _SocialLink(
                icon: FontAwesomeIcons.github,
                onTap: () => _launchUrl('https://github.com/avirajsa'),
                tooltip: 'GitHub',
                color: iconColor,
              ),
              const SizedBox(width: 8),
              _SocialLink(
                icon: FontAwesomeIcons.instagram,
                onTap: () => _launchUrl('https://instagram.com/avirajsaha.ai'),
                tooltip: 'Instagram',
                color: iconColor,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            '© ${DateTime.now().year} Aviraj Saha',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: textColor.withAlpha(100),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'aviraj.saha@outlook.com',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontSize: 11,
                  color: textColor.withAlpha(80),
                ),
          ),
        ],
      ),
    );
  }
}

class _SocialLink extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final Color color;

  const _SocialLink({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: FaIcon(icon, size: 18, color: color),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      splashRadius: 20,
    );
  }
}
