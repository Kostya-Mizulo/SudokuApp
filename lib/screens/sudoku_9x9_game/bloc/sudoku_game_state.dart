import 'package:sudokuapp/sudoku_logic/sudoku_logic.dart';

sealed class SudokuGameState {}

final class SudokuGameInitial extends SudokuGameState {}

final class SudokuGameLoading extends SudokuGameState {}

final class SudokuGameLoaded extends SudokuGameState {
  SudokuGameLoaded(this.game);

  final SudokuGame game;
}

final class SudokuGameError extends SudokuGameState {
  SudokuGameError(this.message);

  final String message;
}
