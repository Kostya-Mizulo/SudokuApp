import 'package:sudokuapp/sudoku_logic/sudoku_logic.dart';

sealed class SudokuGameState {}

final class SudokuGameInitial extends SudokuGameState {}

final class SudokuGameLoading extends SudokuGameState {}

final class SudokuGameLoaded extends SudokuGameState {
  SudokuGameLoaded({
    required this.cells,
    required this.difficultyLabel,
    required this.isNotesActivated,
    required this.numberButtonsVisibility,
  });

  final List<List<Cell>> cells;
  final String difficultyLabel;
  final bool isNotesActivated;
  final Map<int, bool> numberButtonsVisibility;
}

final class SudokuGameError extends SudokuGameState {
  SudokuGameError(this.message);

  final String message;
}
