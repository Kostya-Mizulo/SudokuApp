import 'package:flutter/material.dart';

const _levels = [
  'Лёгкий',
  'Средний',
  'Тяжёлый',
  'Мастер',
  '16 × 16',
];

class DifficultyPopup extends StatelessWidget {
  const DifficultyPopup({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const DifficultyPopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Новая игра',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: primary,
              ),
            ),
            const SizedBox(height: 24),
            for (int i = 0; i < _levels.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  indent: 24,
                  endIndent: 24,
                  color: primary.withValues(alpha: 0.15),
                ),
              _LevelItem(label: _levels[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _LevelItem extends StatelessWidget {
  const _LevelItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: primary,
            ),
          ),
        ),
      ),
    );
  }
}
