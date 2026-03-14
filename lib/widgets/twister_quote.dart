import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TwisterQuote extends StatelessWidget {
  final String text;

  const TwisterQuote({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 20,
              letterSpacing: 0.2,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            width: 40,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(50),
          ),
        ],
      ),
    );
  }
}
