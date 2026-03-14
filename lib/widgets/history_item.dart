import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A dismissible (swipe-to-delete) row for a single search history entry.
///
/// Calls [onRemove] when the user confirms removal so the parent can update
/// its state and persist the deletion to storage.
class HistoryItem extends StatefulWidget {
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
  State<HistoryItem> createState() => _HistoryItemState();
}

class _HistoryItemState extends State<HistoryItem> {
  bool _showDelete = false;

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
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.word.toLowerCase(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
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
