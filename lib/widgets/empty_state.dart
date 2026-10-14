import 'package:flutter/material.dart';
import '../core/constants.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  const EmptyState({
    super.key,
    this.title = 'No expenses yet',
    this.subtitle = 'Tap the + button to add your first expense.',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: kTeal.withValues(alpha: 0.1)),
              child: const Icon(Icons.receipt_long_outlined,
                  size: 44, color: kTeal),
            ),
            const SizedBox(height: 18),
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: kGrey)),
          ],
        ),
      ),
    );
  }
}
