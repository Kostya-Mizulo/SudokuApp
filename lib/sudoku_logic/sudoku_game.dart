import 'dart:math';

import 'cell.dart';
import 'difficulty_level.dart';

class SudokuGame {
  SudokuGame.fromPuzzle(int id, DifficultyLevel difficulty, List<List<Cell>> cells)
      : _sudokuGridId = id,
        _difficulty = difficulty,
        _sudokuSize = cells.length,
        _cells = cells,
        _stopwatchSolving = Stopwatch(),
        _numberButtonsVisibility = {
          for (var i = 1; i <= cells.length; i++) i: true,
        };

  final int _sudokuGridId;
  DifficultyLevel _difficulty;
  int _sudokuSize;
  Stopwatch _stopwatchSolving;
  Map<int, bool> _numberButtonsVisibility;
  bool _isSudokuResolved = false;
  bool _isNotesActivated = false;
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
  Stopwatch get stopwatchSolving => _stopwatchSolving;
  Map<int, bool> get numberButtonsVisibility => _numberButtonsVisibility;
  bool get isSudokuResolved => _isSudokuResolved;
  bool get isNotesActivated => _isNotesActivated;
  List<List<Cell>> get cells => _cells;

  set difficulty(DifficultyLevel value) => _difficulty = value;
  set sudokuSize(int value) => _sudokuSize = value;
  set stopwatchSolving(Stopwatch value) => _stopwatchSolving = value;
  set numberButtonsVisibility(Map<int, bool> value) => _numberButtonsVisibility = value;
  set isSudokuResolved(bool value) => _isSudokuResolved = value;
  set isNotesActivated(bool value) => _isNotesActivated = value;

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
