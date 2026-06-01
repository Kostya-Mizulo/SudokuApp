import 'package:flutter/material.dart';

import 'sudoku_cell.dart';

const double _kMapBorder = 1.5;

class SudokuMap extends StatelessWidget {
  const SudokuMap({
    super.key,
    required this.selectedRow,
    required this.selectedCol,
    required this.onCellTap,
  });

  final int? selectedRow;
  final int? selectedCol;
  final void Function(int row, int col) onCellTap;

  @override
  Widget build(BuildContext context) {
    final mapSize = MediaQuery.of(context).size.width * 0.98;

    return Container(
      width: mapSize,
      height: mapSize,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: _kMapBorder),
      ),
      child: Column(
        children: List.generate(
          9,
          (row) => Expanded(
            child: Row(
              children: List.generate(
                9,
                (col) => SudokuCell(
                  row: row,
                  col: col,
                  isSelected: selectedRow == row && selectedCol == col,
                  isHighlighted: selectedRow != null &&
                      selectedCol != null &&
                      !(selectedRow == row && selectedCol == col) &&
                      (selectedRow == row || selectedCol == col),
                  onTap: () => onCellTap(row, col),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
