import '../sudoku_logic/cell.dart';
import '../sudoku_logic/difficulty_level.dart';
import '../sudoku_logic/sudoku_parser.dart';

class SudokuRepository {
  const SudokuRepository([this._parser = const SudokuParser()]);

  final SudokuParser _parser;

  Future<({int id, List<List<Cell>> cells})> getPuzzle(
      DifficultyLevel difficulty) {
    return _parser.getSudokuPuzzle(difficulty);
  }

  void savePuzzleResolved(
    int id,
    DifficultyLevel difficulty, {
    int? rating,
  }) {
    _parser.markPuzzleResolved(id, difficulty, rating: rating);
  }
}
