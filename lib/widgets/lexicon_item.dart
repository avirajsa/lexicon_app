import 'package:flutter/material.dart';
import '../storage/lexicon_storage.dart';
import '../theme/app_theme.dart';

/// A dismissible (swipe-to-delete) row for a single saved lexicon entry.
///
/// Shows the word, a short definition, and a human-readable date.
/// Calls [onTap] to re-open the word and [onRemove] to delete it.
class LexiconItem extends StatelessWidget {
  final LexiconEntry entry;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const LexiconItem({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onRemove,
  });

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime dt) {
    return '${_months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(entry.word),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(
          Icons.remove_circle_outline_rounded,
          color: Colors.red.withAlpha(160),
          size: 20,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.word.toLowerCase(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
              ),
              if (entry.definition.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  entry.definition,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        color: AppTheme.secondaryTextColor.withAlpha(180),
                      ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                _formatDate(entry.dateAdded),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontSize: 11,
                      color: AppTheme.mutedColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
