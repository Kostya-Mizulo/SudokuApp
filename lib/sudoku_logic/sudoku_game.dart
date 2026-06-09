import 'dart:math';

import 'cell.dart';
import 'difficulty_level.dart';

class SudokuGame {
  SudokuGame.fromPuzzle(int id, DifficultyLevel difficulty, List<List<Cell>> cells)
      : _sudokuGridId = id,
        _difficulty = difficulty,
        _sudokuSize = cells.length,
        _cells = cells,
        _isSudokuResolved = false,
        _numberButtonsVisibility = _buildInitialButtonVisibility(cells);

  SudokuGame.fromSession({
    required int id,
    required DifficultyLevel difficulty,
    required List<List<int>> resolvedGrid,
    required List<List<int>> initialGrid,
    required List<List<int>> currentGrid,
  })  : _sudokuGridId = id,
        _difficulty = difficulty, // ignore: prefer_initializing_formals
        _sudokuSize = resolvedGrid.length,
        _cells = _buildSessionCells(resolvedGrid, initialGrid, currentGrid),
        _isSudokuResolved = false,
        _numberButtonsVisibility =
            _buildSessionButtonVisibility(resolvedGrid, currentGrid);

  static Map<int, bool> _buildInitialButtonVisibility(List<List<Cell>> cells) {
    final size = cells.length;
    final visibility = {for (var i = 1; i <= size; i++) i: true};
    for (var n = 1; n <= size; n++) {
      var count = 0;
      for (var r = 0; r < size; r++) {
        for (var c = 0; c < size; c++) {
          if (cells[r][c].insertedNumber == n) count++;
        }
      }
      if (count == size) visibility[n] = false;
    }
    return visibility;
  }

  static List<List<Cell>> _buildSessionCells(
    List<List<int>> resolvedGrid,
    List<List<int>> initialGrid,
    List<List<int>> currentGrid,
  ) {
    final size = resolvedGrid.length;
    return [
      for (var r = 0; r < size; r++)
        [
          for (var c = 0; c < size; c++)
            () {
              final cell = Cell(r, c)
                ..setRealNumber(resolvedGrid[r][c])
                ..setNumberByStart(initialGrid[r][c]);
              final current = currentGrid[r][c];
              if (!cell.isInsertedByStart && current != 0) {
                cell.setInsertedNumber(current);
              }
              if (cell.insertedNumber != 0) {
                cell.isCorrectNumberInserted = cell.insertedNumber == resolvedGrid[r][c];
              }
              return cell;
            }(),
        ]
    ];
  }

  static Map<int, bool> _buildSessionButtonVisibility(
    List<List<int>> resolvedGrid,
    List<List<int>> currentGrid,
  ) {
    final size = resolvedGrid.length;
    final visibility = {for (var i = 1; i <= size; i++) i: true};
    for (var n = 1; n <= size; n++) {
      var count = 0;
      for (var r = 0; r < size; r++) {
        for (var c = 0; c < size; c++) {
          if (currentGrid[r][c] == n && resolvedGrid[r][c] == n) count++;
        }
      }
      if (count == size) visibility[n] = false;
    }
    return visibility;
  }

  final int _sudokuGridId;
  final DifficultyLevel _difficulty;
  final int _sudokuSize;
  final Map<int, bool> _numberButtonsVisibility;
  bool _isSudokuResolved = false;
  bool isNotesActivated = false;
  final List<List<Cell>> _cells;

  int get sudokuGridId => _sudokuGridId;
  DifficultyLevel get difficulty => _difficulty;
  String get difficultyLabel => switch (_difficulty) {
        DifficultyLevel.easy => 'Лёгкий',
        DifficultyLevel.medium => 'Средний',
        DifficultyLevel.hard => 'Тяжёлый',
        DifficultyLevel.master => 'Мастер',
        DifficultyLevel.sixteen => '16 × 16',
      };
  int get sudokuSize => _sudokuSize;
  Map<int, bool> get numberButtonsVisibility => _numberButtonsVisibility;
  bool get isSudokuResolved => _isSudokuResolved;
  List<List<Cell>> get cells => _cells;

  void markCellsViaUserCellSelection(int row, int column) {
    _clearAllHighlights();
    _cells[row][column].isSelected = true;

    for (var i = 0; i < _sudokuSize; i++) {
      if (i != column) _cells[row][i].isHighlighted = true;
    }

    for (var i = 0; i < _sudokuSize; i++) {
      if (i != row) _cells[i][column].isHighlighted = true;
    }

    final sizeOfField = sqrt(_sudokuSize).toInt();
    final minRow = (row ~/ sizeOfField) * sizeOfField;
    final maxRow = minRow + sizeOfField - 1;
    final minCol = (column ~/ sizeOfField) * sizeOfField;
    final maxCol = minCol + sizeOfField - 1;

    for (var i = minRow; i <= maxRow; i++) {
      for (var j = minCol; j <= maxCol; j++) {
        if (i == row && j == column) continue;
        _cells[i][j].isHighlighted = true;
      }
    }

    final selectedNumber = _cells[row][column].insertedNumber;
    if (selectedNumber != 0) {
      for (var i = 0; i < _sudokuSize; i++) {
        for (var j = 0; j < _sudokuSize; j++) {
          if (i == row && j == column) continue;
          if (_cells[i][j].insertedNumber == selectedNumber) {
            _cells[i][j].isInsertedNumberCurrentlyHighlighted = true;
          }
        }
      }
    }
  }

  void _clearAllHighlights() {
    for (var i = 0; i < _sudokuSize; i++) {
      for (var j = 0; j < _sudokuSize; j++) {
        _clearCellHighlight(_cells[i][j]);
      }
    }
  }

  void insertNumberInSelectedCell(int number) {
    for (var i = 0; i < _sudokuSize; i++) {
      for (var j = 0; j < _sudokuSize; j++) {
        final cell = _cells[i][j];
        if (!cell.isSelected) continue;

        cell.insertNumberByUser(number);

        if (cell.isCorrectNumberInserted == true) {
          for (var r = 0; r < _sudokuSize; r++) {
            for (var c = 0; c < _sudokuSize; c++) {
              if (r == i && c == j) continue;
              if (_cells[r][c].insertedNumber == number) {
                _cells[r][c].isInsertedNumberCurrentlyHighlighted = true;
              }
            }
          }
          _updateNumberButtonVisibility(number);
          _isSudokuResolved = _cells.every(
            (row) => row.every((c) => c.insertedNumber == c.realNumber),
          );
        }
        return;
      }
    }
  }

  void _clearCellHighlight(Cell cell) => cell.clearHighlight();

  void _updateNumberButtonVisibility(int number) {
    var count = 0;
    for (var i = 0; i < _sudokuSize; i++) {
      for (var j = 0; j < _sudokuSize; j++) {
        final cell = _cells[i][j];
        if (cell.insertedNumber == number && cell.realNumber == number) count++;
      }
    }
    if (count == _sudokuSize) _numberButtonsVisibility[number] = false;
  }

  void togglePredictedNumberByUser(int number) {
    for (var i = 0; i < _sudokuSize; i++) {
      for (var j = 0; j < _sudokuSize; j++) {
        final cell = _cells[i][j];
        if (!cell.isSelected) continue;
        if (cell.insertedNumber != 0) return;
        cell.predictedNumbersByUser ??= <int>{};
        if (!cell.predictedNumbersByUser!.add(number)) {
          cell.predictedNumbersByUser!.remove(number);
        }
        return;
      }
    }
  }

  void clearCellByClickClearButton() {
    for (var i = 0; i < _sudokuSize; i++) {
      for (var j = 0; j < _sudokuSize; j++) {
        final cell = _cells[i][j];
        if (!cell.isSelected) continue;

        if (cell.isCorrectNumberInserted == false) {
          cell.insertedNumber = 0;
          cell.isCorrectNumberInserted = null;
        } else if (cell.insertedNumber == 0 &&
            cell.predictedNumbersByUser != null &&
            cell.predictedNumbersByUser!.isNotEmpty) {
          cell.predictedNumbersByUser!.clear();
        }
        return;
      }
    }
  }

  void revealHintCell() {
    _clearAllHighlights();

    final emptyCells = <(int, int)>[];
    for (var r = 0; r < _sudokuSize; r++) {
      for (var c = 0; c < _sudokuSize; c++) {
        if (_cells[r][c].insertedNumber == 0) emptyCells.add((r, c));
      }
    }
    if (emptyCells.isEmpty) return;

    final idx = Random().nextInt(emptyCells.length);
    final (row, col) = emptyCells[idx];
    final cell = _cells[row][col];

    cell.setInsertedNumber(cell.realNumber);
    cell.isCorrectNumberInserted = true;
    cell.isSelected = true;

    _updateNumberButtonVisibility(cell.realNumber);
    _isSudokuResolved = _cells.every(
      (row) => row.every((c) => c.insertedNumber == c.realNumber),
    );
  }

  List<List<int>> getSolvedGrid() {
    return List.generate(
      sudokuSize,
      (r) => List.generate(
          sudokuSize, (c) => cells[r][c].getInsertedNumber(),
          growable: false),
      growable: false,
    );
  }
}
