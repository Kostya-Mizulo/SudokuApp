import 'package:sudokuapp/sudoku_logic/sudoku_logic.dart';

sealed class SudokuGameEvent {}

final class SudokuGameStarted extends SudokuGameEvent {
  SudokuGameStarted(this.difficulty);

  final DifficultyLevel difficulty;
}

final class SudokuGameNotesToggled extends SudokuGameEvent {}

final class SudokuGameCellSelected extends SudokuGameEvent {
  SudokuGameCellSelected(this.row, this.column);

  final int row;
  final int column;
}

final class SudokuGameNumberInserted extends SudokuGameEvent {
  SudokuGameNumberInserted(this.number);

  final int number;
}
