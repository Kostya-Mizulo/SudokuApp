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
    required this.elapsedTime,
  });

  final List<List<Cell>> cells;
  final String difficultyLabel;
  final bool isNotesActivated;
  final Map<int, bool> numberButtonsVisibility;
  final String elapsedTime;

  SudokuGameLoaded copyWith({
    List<List<Cell>>? cells,
    String? difficultyLabel,
    bool? isNotesActivated,
    Map<int, bool>? numberButtonsVisibility,
    String? elapsedTime,
  }) =>
      SudokuGameLoaded(
        cells: cells ?? this.cells,
        difficultyLabel: difficultyLabel ?? this.difficultyLabel,
        isNotesActivated: isNotesActivated ?? this.isNotesActivated,
        numberButtonsVisibility:
            numberButtonsVisibility ?? this.numberButtonsVisibility,
        elapsedTime: elapsedTime ?? this.elapsedTime,
      );
}

final class SudokuGameError extends SudokuGameState {
  SudokuGameError(this.message);

  final String message;
}

final class SudokuGameResolved extends SudokuGameState {
  SudokuGameResolved(this.elapsedTime);

  final String elapsedTime;
}
