import 'package:flutter/material.dart';
import 'package:sudokuapp/sudoku_logic/sudoku_logic.dart';

const _levels = [
  ('Лёгкий', DifficultyLevel.easy),
  ('Средний', DifficultyLevel.medium),
  ('Тяжёлый', DifficultyLevel.hard),
  ('Мастер', DifficultyLevel.master),
  ('16 × 16', null),
];

class DifficultyPopup extends StatelessWidget {
  const DifficultyPopup({super.key});

  static Future<DifficultyLevel?> show(BuildContext context) {
    return showDialog<DifficultyLevel?>(
      context: context,
      builder: (_) => const DifficultyPopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    final size = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size.width * 0.064),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: size.height * 0.035),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Новая игра',
              style: TextStyle(
                fontSize: size.width * 0.048,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: primary,
              ),
            ),
            SizedBox(height: size.height * 0.03),
            for (int i = 0; i < _levels.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  indent: size.width * 0.064,
                  endIndent: size.width * 0.064,
                  color: primary.withValues(alpha: 0.15),
                ),
              _LevelItem(
                label: _levels[i].$1,
                difficulty: _levels[i].$2,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LevelItem extends StatelessWidget {
  const _LevelItem({required this.label, required this.difficulty});

  final String label;
  final DifficultyLevel? difficulty;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    final size = MediaQuery.of(context).size;

    return InkWell(
      onTap: difficulty == null
          ? null
          : () => Navigator.of(context).pop(difficulty),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: size.height * 0.018,
          horizontal: size.width * 0.075,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: size.width * 0.043,
              fontWeight: FontWeight.w500,
              color: difficulty == null
                  ? primary.withValues(alpha: 0.4)
                  : primary,
            ),
          ),
        ),
      ),
    );
  }
}
