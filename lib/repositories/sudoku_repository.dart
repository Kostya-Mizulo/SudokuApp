import 'dart:convert';

import '../sudoku_logic/cell.dart';
import '../sudoku_logic/difficulty_level.dart';
import 'puzzle_storage_service.dart';

class SudokuRepository {
  const SudokuRepository();

  Future<({int id, List<List<Cell>> cells})> getPuzzle(
      DifficultyLevel difficulty) async {
    final file = await PuzzleStorageService.getFile(difficulty);
    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final puzzles =
        (data['puzzles'] as List<dynamic>).cast<Map<String, dynamic>>();

    final puzzle =
        puzzles.where((p) => p['isResolved'] != true).firstOrNull;

    if (puzzle == null) {
      throw StateError(
          'Нет нерешённых головоломок для уровня ${difficulty.name}.');
    }

    final solvedGrid = (puzzle['solvedGrid'] as List<dynamic>)
        .map((row) => (row as List<dynamic>).cast<int>())
        .toList();
    final puzzleGrid = (puzzle['puzzleGrid'] as List<dynamic>)
        .map((row) => (row as List<dynamic>).cast<int>())
        .toList();

    return (
      id: puzzle['id'] as int,
      cells: _buildCells(solvedGrid, puzzleGrid),
    );
  }

  Future<void> savePuzzleResolved(
    int id,
    DifficultyLevel difficulty, {
    int? rating,
    int? timeSeconds,
  }) async {
    final file = await PuzzleStorageService.getFile(difficulty);
    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final puzzles =
        (data['puzzles'] as List<dynamic>).cast<Map<String, dynamic>>();

    for (final puzzle in puzzles) {
      if (puzzle['id'] == id) {
        puzzle['isResolved'] = true;
        if (rating != null) puzzle['rateWhileResolved'] = rating;
        if (timeSeconds != null) puzzle['timeSeconds'] = timeSeconds;
        break;
      }
    }

    final resolvedCount = (data['resolvedCount'] as int) + 1;
    data['resolvedCount'] = resolvedCount;
    if (resolvedCount >= (data['totalCount'] as int)) {
      data['isAllResolved'] = true;
    }

    file.writeAsStringSync(jsonEncode(data));
  }

  static List<List<Cell>> _buildCells(
      List<List<int>> solvedGrid, List<List<int>> puzzleGrid) {
    return [
      for (var row = 0; row < solvedGrid.length; row++)
        [
          for (var column = 0; column < solvedGrid[row].length; column++)
            Cell(row, column)
              ..setRealNumber(solvedGrid[row][column])
              ..setNumberByStart(puzzleGrid[row][column])
        ]
    ];
  }
}
