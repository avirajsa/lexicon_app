import 'package:flutter/material.dart';
import '../storage/lexicon_storage.dart';
import '../theme/app_theme.dart';

/// A dismissible (swipe-to-delete) row for a single saved lexicon entry.
///
/// Shows the word, a short definition, and a human-readable date.
/// Calls [onTap] to re-open the word and [onRemove] to delete it.
class LexiconItem extends StatefulWidget {
  final LexiconEntry entry;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const LexiconItem({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onRemove,
  });

  @override
  State<LexiconItem> createState() => _LexiconItemState();
}

class _LexiconItemState extends State<LexiconItem> {
  bool _showDelete = false;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime dt) {
    return '${_months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onLongPress: () {
        setState(() {
          _showDelete = true;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.entry.word.toLowerCase(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                  if (widget.entry.definition.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.entry.definition,
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
                    _formatDate(widget.entry.dateAdded),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontSize: 11,
                          color: AppTheme.mutedColor,
                        ),
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _showDelete ? 1.0 : 0.0,
                child: _showDelete
                    ? IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 18,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                        onPressed: widget.onRemove,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        visualDensity: VisualDensity.compact,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
