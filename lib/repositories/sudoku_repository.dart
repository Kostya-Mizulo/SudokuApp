import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../database/app_database.dart';
import '../sudoku_logic/cell.dart';
import '../sudoku_logic/difficulty_level.dart';

class SudokuRepository {
  const SudokuRepository(this._db);

  final AppDatabase _db;

  static const _assetsDir = 'lib/resources/puzzles/';

  Future<({int id, List<List<Cell>> cells})> getPuzzle(
      DifficultyLevel difficulty) async {
    final row = await (_db.select(_db.puzzleProgressTable)
          ..where(
            (t) =>
                t.difficulty.equalsValue(difficulty) &
                t.isPlayed.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.random()])
          ..limit(1))
        .getSingleOrNull();

    if (row == null) {
      throw StateError(
          'Нет нерешённых головоломок для уровня ${difficulty.name}.');
    }

    final content =
        await rootBundle.loadString('$_assetsDir${difficulty.name}.json');
    final puzzles = (jsonDecode(content)['puzzles'] as List)
        .cast<Map<String, dynamic>>();
    final puzzle = puzzles.firstWhere((p) => p['id'] == row.id);

    final solvedGrid = (puzzle['solvedGrid'] as List)
        .map((r) => (r as List).cast<int>())
        .toList();
    final puzzleGrid = (puzzle['puzzleGrid'] as List)
        .map((r) => (r as List).cast<int>())
        .toList();

    if (kDebugMode) {
      final before = await _rowById(row.id);
      debugPrint('[SudokuRepository.getPuzzle] before: ${_fmt(before)}');
    }
    await (_db.update(_db.puzzleProgressTable)
          ..where((t) => t.id.equals(row.id)))
        .write(const PuzzleProgressTableCompanion(isPlayed: Value(true)));
    if (kDebugMode) {
      final after = await _rowById(row.id);
      debugPrint('[SudokuRepository.getPuzzle]  after: ${_fmt(after)}');
    }

    return (id: row.id, cells: _buildCells(solvedGrid, puzzleGrid));
  }

  Future<void> markPuzzleAbandoned(int id) async {
    if (kDebugMode) {
      final before = await _rowById(id);
      debugPrint('[SudokuRepository.markPuzzleAbandoned] before: ${_fmt(before)}');
    }
    await (_db.update(_db.puzzleProgressTable)
          ..where((t) => t.id.equals(id)))
        .write(const PuzzleProgressTableCompanion(isWin: Value(false)));
    if (kDebugMode) {
      final after = await _rowById(id);
      debugPrint('[SudokuRepository.markPuzzleAbandoned]  after: ${_fmt(after)}');
    }
  }

  Future<void> savePuzzleResolved(
    int id, {
    int? rating,
    int? timeSeconds,
  }) async {
    if (kDebugMode) {
      final before = await _rowById(id);
      debugPrint('[SudokuRepository.savePuzzleResolved] before: ${_fmt(before)}');
    }
    await (_db.update(_db.puzzleProgressTable)
          ..where((t) => t.id.equals(id)))
        .write(PuzzleProgressTableCompanion(
          isWin: const Value(true),
          solvingTime: Value(timeSeconds),
          rate: Value(rating),
        ));
    if (kDebugMode) {
      final after = await _rowById(id);
      debugPrint('[SudokuRepository.savePuzzleResolved]  after: ${_fmt(after)}');
    }
  }

  Future<PuzzleProgressTableData?> _rowById(int id) =>
      (_db.select(_db.puzzleProgressTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  static String _fmt(PuzzleProgressTableData? row) {
    if (row == null) return 'not found';
    return 'id=${row.id} | difficulty=${row.difficulty.name} | '
        'isPlayed=${row.isPlayed} | isWin=${row.isWin} | '
        'solvingTime=${row.solvingTime}s | rate=${row.rate}';
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
