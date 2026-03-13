import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A dismissible (swipe-to-delete) row for a single search history entry.
///
/// Calls [onRemove] when the user confirms removal so the parent can update
/// its state and persist the deletion to storage.
class HistoryItem extends StatelessWidget {
  final String word;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const HistoryItem({
    super.key,
    required this.word,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(word),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      // Subtle red reveal on swipe
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
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            word.toLowerCase(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
          ),
        ),
      ),
    );
  }
}
