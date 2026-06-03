import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc.dart';
import 'sudoku_cell.dart';

const double _kMapBorder = 1.5;

class SudokuMap extends StatelessWidget {
  const SudokuMap({super.key});

  @override
  Widget build(BuildContext context) {
    final mapSize = MediaQuery.of(context).size.width * 0.98;

    return Container(
      width: mapSize,
      height: mapSize,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: _kMapBorder),
      ),
      child: BlocBuilder<SudokuGameBloc, SudokuGameState>(
        buildWhen: (_, curr) => curr is SudokuGameLoaded,
        builder: (context, state) {
          final cells = state is SudokuGameLoaded ? state.cells : null;
          return Column(
            children: List.generate(
              9,
              (row) => Expanded(
                child: Row(
                  children: List.generate(
                    9,
                    (col) => SudokuCell(
                      row: row,
                      col: col,
                      insertedNumber: cells?[row][col].getInsertedNumber() ?? 0,
                      isGivenNumber: cells?[row][col].isInsertedByStart ?? false,
                      isSelected: cells?[row][col].isSelected ?? false,
                      isHighlighted: cells?[row][col].isHighlighted ?? false,
                      isInsertedNumberCurrentlyHighlighted:
                          cells?[row][col].isInsertedNumberCurrentlyHighlighted ?? false,
                      isCorrectNumberInserted:
                          cells?[row][col].isCorrectNumberInserted,
                      onTap: () => context
                          .read<SudokuGameBloc>()
                          .add(SudokuGameCellSelected(row, col)),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
