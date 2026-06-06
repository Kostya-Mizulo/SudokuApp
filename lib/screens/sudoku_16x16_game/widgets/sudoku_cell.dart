import 'package:flutter/material.dart';

const double _kBoxBorder = 1.5;
const double _kCellBorder = 0.5;

class SudokuCell extends StatelessWidget {
  const SudokuCell({
    super.key,
    required this.row,
    required this.col,
    required this.insertedNumber,
    required this.isGivenNumber,
    required this.isSelected,
    required this.isHighlighted,
    required this.isInsertedNumberCurrentlyHighlighted,
    required this.isCorrectNumberInserted,
    required this.onTap,
    this.predictedNumbersByUser,
  });

  final int row;
  final int col;
  final int insertedNumber;
  final bool isGivenNumber;
  final bool isSelected;
  final bool isHighlighted;
  final bool isInsertedNumberCurrentlyHighlighted;
  final bool? isCorrectNumberInserted;
  final VoidCallback onTap;
  final Set<int>? predictedNumbersByUser;

  BorderSide _rightBorder() {
    if (col == 15) return BorderSide.none;
    if (col % 4 == 3) return const BorderSide(color: Colors.black, width: _kBoxBorder);
    return const BorderSide(color: Colors.grey, width: _kCellBorder);
  }

  BorderSide _bottomBorder() {
    if (row == 15) return BorderSide.none;
    if (row % 4 == 3) return const BorderSide(color: Colors.black, width: _kBoxBorder);
    return const BorderSide(color: Colors.grey, width: _kCellBorder);
  }

  Widget _buildCandidates() {
    return Column(
      children: List.generate(4, (gridRow) {
        return Expanded(
          child: Row(
            children: List.generate(4, (gridCol) {
              final number = gridRow * 4 + gridCol + 1;
              final visible = predictedNumbersByUser!.contains(number);
              return Expanded(
                child: Center(
                  child: visible
                      ? FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            '$number',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final color = isSelected
        ? primary.withValues(alpha: 0.60)
        : isInsertedNumberCurrentlyHighlighted
            ? primary.withValues(alpha: 0.30)
            : isHighlighted
                ? primary.withValues(alpha: 0.10)
                : Theme.of(context).scaffoldBackgroundColor;

    final hasCandidates =
        predictedNumbersByUser != null && predictedNumbersByUser!.isNotEmpty;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            border: Border(
              right: _rightBorder(),
              bottom: _bottomBorder(),
            ),
          ),
          child: insertedNumber != 0
              ? FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    '$insertedNumber',
                    style: TextStyle(
                      color: isCorrectNumberInserted == false
                          ? Colors.red
                          : isSelected && isCorrectNumberInserted == true
                              ? Colors.indigo
                              : Colors.black,
                      fontSize: 64,
                    ),
                  ),
                )
              : hasCandidates
                  ? _buildCandidates()
                  : null,
        ),
      ),
    );
  }
}
