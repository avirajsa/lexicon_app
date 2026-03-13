import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HistoryList extends StatelessWidget {
  final List<String> history;
  final Function(String) onSelect;

  const HistoryList({
    super.key,
    required this.history,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            "Recent Searches",
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.mutedColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...history.map((word) => InkWell(
          onTap: () => onSelect(word),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
            child: Text(
              word.toLowerCase(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryTextColor.withAlpha(200),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        )),
      ],
    );
  }
}
