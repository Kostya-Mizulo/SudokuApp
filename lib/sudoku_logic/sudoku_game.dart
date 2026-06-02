import 'dart:math';

import 'cell.dart';
import 'difficulty_level.dart';
import 'sudoku_parser.dart';
import 'sudoku_solver.dart' show SudokuStuckException;

class SudokuGame {
  SudokuGame._(this._sudokuGridId, this._difficulty, List<List<Cell>> cells)
      : _sudokuSize = cells.length,
        _cells = cells,
        _stopwatchSolving = Stopwatch(),
        _numberButtonsVisibility = {
          for (var i = 1; i <= cells.length; i++) i: true,
        };

  static Future<SudokuGame> fromDifficulty(DifficultyLevel difficulty) async {
    final result = await SudokuParser.getSudokuPuzzle(difficulty);
    return SudokuGame._(result.id, difficulty, result.cells);
  }

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
  }

  void _clearAllHighlights() {
    for (var i = 0; i < _sudokuSize; i++) {
      for (var j = 0; j < _sudokuSize; j++) {
        _clearCellHighlight(_cells[i][j]);
      }
    }
  }

  void _clearCellHighlight(Cell cell) => cell.clearHighlight();

  void printInitialSudoku() {
    final buffer = StringBuffer();
    for (var i = 0; i < sudokuSize; i++) {
      for (var j = 0; j < sudokuSize; j++) {
        buffer.write('${cells[i][j].getNumberByStart()}  ');
      }
      buffer.writeln();
    }
    // ignore: avoid_print
    print('Начальный судоку\n$buffer');
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

  void printCompletedSudoku() {
    final buffer = StringBuffer();
    for (var i = 0; i < sudokuSize; i++) {
      for (var j = 0; j < sudokuSize; j++) {
        buffer.write('${cells[i][j].getInsertedNumber()}  ');
      }
      buffer.writeln();
    }
    // ignore: avoid_print
    print('Решенный судоку\n$buffer');
  }

  // ┌──────────────────────────────────────────────────────────────────────┐
  // │                                                                      │
  // │                                                                      │
  // │                                                                      │
  // │            Ниже — только код решения судоку программой              │
  // │                                                                      │
  // │                                                                      │
  // │                                                                      │
  // │                                                                      │
  // └──────────────────────────────────────────────────────────────────────┘

  /// Полностью решает судоку, который задан в качестве задания.
  void _solveSudoku() {
    _pickupAllPossibleNumbersForEachSell();

    while (!isSudokuResolved) {
      final numberAndPosition = _findNextNumberInSudoku();

      // Блок выполняет методы поиска «шпиона» поочерёдно, пока какой-нибудь
      // не отработает. Шпион — предсказанное число для ячейки, которого там
      // быть не может, при этом напрямую подставить число некуда.
      if (numberAndPosition == null) {
        final isSmthDeleted =
            _callAllMethodsToFindAndDeleteAnyPossiblePredictedNumber();
        if (isSmthDeleted) continue;
      }

      // В оригинале здесь происходил NullPointerException, если
      // numberAndPosition == null. SudokuCreator трактует это как
      // «решатель застрял».
      if (numberAndPosition == null) {
        throw SudokuStuckException();
      }

      cells[numberAndPosition[0]][numberAndPosition[1]]
          .setInsertedNumber(numberAndPosition[2]);

      _deletePredictedNumberFromStringAndColumnAndField(
        numberAndPosition[2],
        numberAndPosition[0],
        numberAndPosition[1],
      );

      _checkIfSudokuResolved();
    }
  }

  /// Для каждой пустой ячейки подбирает все возможные числа.
  void _pickupAllPossibleNumbersForEachSell() {
    for (var string = 0; string < sudokuSize; string++) {
      for (var column = 0; column < sudokuSize; column++) {
        if (cells[string][column].getInsertedNumber() != 0) {
          cells[string][column].addPredictedNumber(0);
          continue;
        }
        cells[string][column].setPredictedNumbers(
            _pickupAllPossibleNumbersForCurrentCell(string, column));
      }
    }
  }

  /// Подбирает все возможные на данный момент числа для конкретной пустой ячейки.
  Set<int> _pickupAllPossibleNumbersForCurrentCell(int string, int column) {
    final possibleNumbers = <int>{};
    final impossibleNumbers = _findInappropriateNumbers(string, column);

    for (var number = 1; number <= sudokuSize; number++) {
      if (impossibleNumbers.contains(number)) continue;
      possibleNumbers.add(number);
    }

    return possibleNumbers;
  }

  /// Подбирает все невозможные для ячейки числа.
  Set<int> _findInappropriateNumbers(int string, int column) {
    final inappropriateNumbers = <int>{};
    inappropriateNumbers.addAll(_findInappropriateNumbersViaString(string, column));
    inappropriateNumbers.addAll(_findInappropriateNumbersViaColumn(string, column));
    inappropriateNumbers.addAll(_findInappropriateNumbersViaField(string, column));
    return inappropriateNumbers;
  }

  Set<int> _findInappropriateNumbersViaString(int string, int column) {
    final inappropriateNumbers = <int>{};
    for (var i = 0; i < sudokuSize; i++) {
      if (i == column) continue;
      if (cells[string][i].getInsertedNumber() == 0) continue;
      inappropriateNumbers.add(cells[string][i].getInsertedNumber());
    }
    return inappropriateNumbers;
  }

  Set<int> _findInappropriateNumbersViaColumn(int string, int column) {
    final inappropriateNumbers = <int>{};
    for (var i = 0; i < sudokuSize; i++) {
      if (i == string) continue;
      if (cells[i][column].getInsertedNumber() == 0) continue;
      inappropriateNumbers.add(cells[i][column].getInsertedNumber());
    }
    return inappropriateNumbers;
  }

  Set<int> _findInappropriateNumbersViaField(int string, int column) {
    final inappropriateNumbers = <int>{};

    final sizeOfField = sqrt(sudokuSize).toInt();
    final fieldPositionByString = string ~/ sizeOfField;
    final fieldPositionByColumn = column ~/ sizeOfField;

    final minStringInField = fieldPositionByString * sizeOfField;
    final maxStringInField = minStringInField + sizeOfField - 1;

    final minColumnInField = fieldPositionByColumn * sizeOfField;
    final maxColumnInField = minColumnInField + sizeOfField - 1;

    for (var i = minStringInField; i <= maxStringInField; i++) {
      for (var j = minColumnInField; j <= maxColumnInField; j++) {
        if (i == string && j == column) continue;
        if (cells[i][j].getInsertedNumber() == 0) continue;
        inappropriateNumbers.add(cells[i][j].getInsertedNumber());
      }
    }

    return inappropriateNumbers;
  }

  /// Ищет, какое следующее число и в какую ячейку можно подставить.
  List<int>? _findNextNumberInSudoku() {
    var number = 0;
    for (var string = 0; string < sudokuSize; string++) {
      for (var column = 0; column < sudokuSize; column++) {
        if (cells[string][column].getInsertedNumber() != 0) continue;

        number = _insertNumberInCellIfOnlyTheOnePossible(string, column);
        if (number != 0) return [string, column, number];

        number =
            _checkIfAnyPossibleNumberFromCellCanBeOnlyHereInString(string, column);
        if (number != 0) return [string, column, number];

        number =
            _checkIfAnyPossibleNumberFromCellCanBeOnlyHereInColumn(string, column);
        if (number != 0) return [string, column, number];

        number =
            _checkIfAnyPossibleNumberFromCellCanBeOnlyHereInField(string, column);
        if (number != 0) return [string, column, number];
      }
    }
    return null;
  }

  /// Если в ячейке предсказано только одно число — подставляет его.
  /// Если предсказано более одного числа, возвращает 0.
  int _insertNumberInCellIfOnlyTheOnePossible(int string, int column) {
    if (cells[string][column].getPredictedNumbers()!.length == 1) {
      final number = cells[string][column].getPredictedNumbers()!.first;
      cells[string][column].setInsertedNumber(number);
      return number;
    }
    return 0;
  }

  /// Ищет число, встречающееся среди кандидатов только в этой ячейке по строке.
  int _checkIfAnyPossibleNumberFromCellCanBeOnlyHereInString(int string, int column) {
    final predictedNumbersAndCounting = <int, int>{};
    var numberToFill = 0;
    for (final number in cells[string][column].getPredictedNumbers()!) {
      predictedNumbersAndCounting[number] = 1;
    }

    for (var i = 0; i < sudokuSize; i++) {
      if (i == column) continue;
      for (final number in predictedNumbersAndCounting.keys.toList()) {
        if (cells[string][i].getPredictedNumbers()!.contains(number)) {
          predictedNumbersAndCounting[number] =
              predictedNumbersAndCounting[number]! + 1;
        }
      }
    }

    for (final entry in predictedNumbersAndCounting.entries) {
      if (entry.value == 1) {
        numberToFill = entry.key;
        break;
      }
    }

    return numberToFill;
  }

  /// Ищет число, встречающееся среди кандидатов только в этой ячейке по столбцу.
  int _checkIfAnyPossibleNumberFromCellCanBeOnlyHereInColumn(int string, int column) {
    final predictedNumbersAndCounting = <int, int>{};
    var numberToFill = 0;
    for (final number in cells[string][column].getPredictedNumbers()!) {
      predictedNumbersAndCounting[number] = 1;
    }

    for (var i = 0; i < sudokuSize; i++) {
      if (i == string) continue;
      for (final number in predictedNumbersAndCounting.keys.toList()) {
        if (cells[i][column].getPredictedNumbers()!.contains(number)) {
          predictedNumbersAndCounting[number] =
              predictedNumbersAndCounting[number]! + 1;
        }
      }
    }

    for (final entry in predictedNumbersAndCounting.entries) {
      if (entry.value == 1) {
        numberToFill = entry.key;
        break;
      }
    }

    return numberToFill;
  }

  /// Ищет число, встречающееся среди кандидатов только в этой ячейке по полю.
  int _checkIfAnyPossibleNumberFromCellCanBeOnlyHereInField(int string, int column) {
    final predictedNumbersAndCounting = <int, int>{};
    var numberToFill = 0;
    final sizeOfField = sqrt(sudokuSize).toInt();
    final fieldPositionByString = string ~/ sizeOfField;
    final fieldPositionByColumn = column ~/ sizeOfField;

    final minStringInField = fieldPositionByString * sizeOfField;
    final maxStringInField = minStringInField + sizeOfField - 1;

    final minColumnInField = fieldPositionByColumn * sizeOfField;
    final maxColumnInField = minColumnInField + sizeOfField - 1;

    for (final number in cells[string][column].getPredictedNumbers()!) {
      predictedNumbersAndCounting[number] = 1;
    }

    for (var i = minStringInField; i <= maxStringInField; i++) {
      for (var j = minColumnInField; j <= maxColumnInField; j++) {
        if (i == string && j == column) continue;
        for (final number in predictedNumbersAndCounting.keys.toList()) {
          if (cells[i][j].getPredictedNumbers()!.contains(number)) {
            predictedNumbersAndCounting[number] =
                predictedNumbersAndCounting[number]! + 1;
          }
        }
      }
    }

    for (final entry in predictedNumbersAndCounting.entries) {
      if (entry.value == 1) {
        numberToFill = entry.key;
        break;
      }
    }

    return numberToFill;
  }

  /// Проходит по всем методам решения, которые находят и удаляют возможное
  /// число из пустой ячейки.
  bool _callAllMethodsToFindAndDeleteAnyPossiblePredictedNumber() {
    var isSmthFoundedAndDeleted = false;

    isSmthFoundedAndDeleted =
        _checkIfPredictedNumberCanBeOnlyInOneStringOrColumnInFieldAndDeleteFromOtherFields();
    if (isSmthFoundedAndDeleted) return true;

    isSmthFoundedAndDeleted = _findAndDeleteNakedPairsInString();
    if (isSmthFoundedAndDeleted) return true;

    isSmthFoundedAndDeleted = _findAndDeleteNakedPairsInColumn();
    if (isSmthFoundedAndDeleted) return true;

    isSmthFoundedAndDeleted = _findAndDeleteNakedPairsInField();
    if (isSmthFoundedAndDeleted) return true;

    isSmthFoundedAndDeleted = _findAndDeleteNakedTripletInString();
    if (isSmthFoundedAndDeleted) return true;

    isSmthFoundedAndDeleted = _findAndDeleteNakedTripletInColumn();
    if (isSmthFoundedAndDeleted) return true;

    isSmthFoundedAndDeleted = _findAndDeleteNakedTripletInField();
    if (isSmthFoundedAndDeleted) return true;

    isSmthFoundedAndDeleted = _findAndDeleteHiddenPairsInString();
    if (isSmthFoundedAndDeleted) return true;

    isSmthFoundedAndDeleted = _findAndDeleteHiddenPairsInColumn();
    if (isSmthFoundedAndDeleted) return true;

    isSmthFoundedAndDeleted = _findAndDeleteHiddenPairsInField();
    if (isSmthFoundedAndDeleted) return true;

    isSmthFoundedAndDeleted = _findAndDeleteHiddenTripletInString();
    if (isSmthFoundedAndDeleted) return true;

    isSmthFoundedAndDeleted = _findAndDeleteHiddenTripletInColumn();
    if (isSmthFoundedAndDeleted) return true;

    isSmthFoundedAndDeleted = _findAndDeleteHiddenTripletInField();
    if (isSmthFoundedAndDeleted) return true;

    isSmthFoundedAndDeleted = _applyXWingRows();
    if (isSmthFoundedAndDeleted) return true;

    isSmthFoundedAndDeleted = _applyXWingColumns();
    if (isSmthFoundedAndDeleted) return true;

    return isSmthFoundedAndDeleted;
  }

  /// Если кандидат в поле возможен только в одной строке (или столбце) —
  /// удаляет его из этой строки (столбца) за пределами поля.
  bool _checkIfPredictedNumberCanBeOnlyInOneStringOrColumnInFieldAndDeleteFromOtherFields() {
    var ifBrake = false;

    for (var string = 0; string < sudokuSize; string++) {
      for (var column = 0; column < sudokuSize; column++) {
        if (cells[string][column].getInsertedNumber() != 0) continue;

        final sizeOfField = sqrt(sudokuSize).toInt();
        final fieldPositionByString = string ~/ sizeOfField;
        final fieldPositionByColumn = column ~/ sizeOfField;

        final minStringInField = fieldPositionByString * sizeOfField;
        final maxStringInField = minStringInField + sizeOfField - 1;

        final minColumnInField = fieldPositionByColumn * sizeOfField;
        final maxColumnInField = minColumnInField + sizeOfField - 1;

        for (final number
            in cells[string][column].getPredictedNumbers()!.toList()) {
          final wherePredictedNumberExistsInField = List.generate(
              sizeOfField, (_) => List<int>.filled(sizeOfField, 0),
              growable: false);

          for (var i = 0; i < sizeOfField; i++) {
            for (var j = 0; j < sizeOfField; j++) {
              if (cells[minStringInField + i][minColumnInField + j]
                  .getPredictedNumbers()!
                  .contains(number)) {
                wherePredictedNumberExistsInField[i][j] = 1;
              } else {
                wherePredictedNumberExistsInField[i][j] = 0;
              }
            }
          }

          for (var i = 0; i < sizeOfField; i++) {
            for (var j = 0; j < sizeOfField; j++) {
              if (wherePredictedNumberExistsInField[i][j] == 0) continue;

              // Проверяем, что число есть только в 1 строке.
              var isOnlyInOneString = true;
              for (var k = 0; k < sizeOfField; k++) {
                if (k == i) continue;
                for (var l = 0; l < sizeOfField; l++) {
                  if (wherePredictedNumberExistsInField[k][l] == 1) {
                    isOnlyInOneString = false;
                  }
                  if (!isOnlyInOneString) break;
                }
                if (!isOnlyInOneString) break;
              }

              if (isOnlyInOneString) {
                ifBrake = _deletePredictedNumberFromStringWithoutOneField(
                    number, string, minColumnInField, maxColumnInField);
              }

              if (ifBrake) break;

              // Проверяем, что число есть только в 1 столбце.
              var isOnlyInOneColumn = true;
              for (var k = 0; k < sizeOfField; k++) {
                for (var l = 0; l < sizeOfField; l++) {
                  if (l == j) continue;
                  if (wherePredictedNumberExistsInField[k][l] == 1) {
                    isOnlyInOneColumn = false;
                  }
                  if (!isOnlyInOneColumn) break;
                }
                if (!isOnlyInOneColumn) break;
              }

              if (isOnlyInOneColumn) {
                ifBrake = _deletePredictedNumberFromColumnWithoutOneField(
                    number, column, minStringInField, maxStringInField);
              }
              if (ifBrake) break;
            }

            if (ifBrake) break;
          }

          if (ifBrake) break;
        }
        if (ifBrake) break;
      }
      if (ifBrake) break;
    }
    return ifBrake;
  }

  /// Удаляет предсказанное число из всей строки, кроме одного поля.
  bool _deletePredictedNumberFromStringWithoutOneField(
    int number,
    int string,
    int firstColumnOfFieldWithNoDelete,
    int lastColumnOfFieldWithNoDelete,
  ) {
    var ifSomethingRemoved = false;
    for (var i = 0; i < sudokuSize; i++) {
      if (i >= firstColumnOfFieldWithNoDelete &&
          i <= lastColumnOfFieldWithNoDelete) {
        continue;
      }
      ifSomethingRemoved = cells[string][i].removePredictedNumber(number);
    }
    return ifSomethingRemoved;
  }

  /// Удаляет предсказанное число из всего столбца, кроме одного поля.
  bool _deletePredictedNumberFromColumnWithoutOneField(
    int number,
    int column,
    int firstStringOfFieldWithNoDelete,
    int lastStringOfFieldWithNoDelete,
  ) {
    var ifSomethingRemoved = false;
    for (var i = 0; i < sudokuSize; i++) {
      if (i >= firstStringOfFieldWithNoDelete &&
          i <= lastStringOfFieldWithNoDelete) {
        continue;
      }
      ifSomethingRemoved = cells[i][column].removePredictedNumber(number);
    }
    return ifSomethingRemoved;
  }

  bool _findAndDeleteNakedPairsInString() {
    var isSmthDeleted = false;

    for (var string = 0; string < sudokuSize; string++) {
      for (var col1 = 0; col1 < sudokuSize - 1; col1++) {
        if (cells[string][col1].getPredictedNumbers()!.length != 2) continue;

        for (var col2 = col1 + 1; col2 < sudokuSize; col2++) {
          if (!_sgSetEquals(cells[string][col1].getPredictedNumbers()!,
              cells[string][col2].getPredictedNumbers()!)) {
            continue;
          }

          final pair = cells[string][col1].getPredictedNumbers()!;
          final number1 = pair.first;
          final number2 = pair.elementAt(1);

          for (var column = 0; column < sudokuSize; column++) {
            if (column == col1 || column == col2) continue;
            isSmthDeleted =
                cells[string][column].removePredictedNumber(number1) ||
                    isSmthDeleted;
            isSmthDeleted =
                cells[string][column].removePredictedNumber(number2) ||
                    isSmthDeleted;
          }
        }
      }
    }

    return isSmthDeleted;
  }

  bool _findAndDeleteNakedPairsInColumn() {
    var isSmthDeleted = false;

    for (var column = 0; column < sudokuSize; column++) {
      for (var str1 = 0; str1 < sudokuSize - 1; str1++) {
        if (cells[str1][column].getPredictedNumbers()!.length != 2) continue;

        for (var str2 = str1 + 1; str2 < sudokuSize; str2++) {
          if (!_sgSetEquals(cells[str1][column].getPredictedNumbers()!,
              cells[str2][column].getPredictedNumbers()!)) {
            continue;
          }

          final pair = cells[str1][column].getPredictedNumbers()!;
          final number1 = pair.first;
          final number2 = pair.elementAt(1);

          for (var string = 0; string < sudokuSize; string++) {
            if (string == str1 || string == str2) continue;
            isSmthDeleted =
                cells[string][column].removePredictedNumber(number1) ||
                    isSmthDeleted;
            isSmthDeleted =
                cells[string][column].removePredictedNumber(number2) ||
                    isSmthDeleted;
          }
        }
      }
    }

    return isSmthDeleted;
  }

  bool _findAndDeleteNakedPairsInField() {
    var isSmthDeleted = false;
    final sizeOfField = sqrt(sudokuSize).toInt();

    for (var fieldRow = 0; fieldRow < sizeOfField; fieldRow++) {
      for (var fieldCol = 0; fieldCol < sizeOfField; fieldCol++) {
        final minString = fieldRow * sizeOfField;
        final maxString = minString + sizeOfField - 1;
        final minColumn = fieldCol * sizeOfField;
        final maxColumn = minColumn + sizeOfField - 1;

        final cellsInField = <List<int>>[];
        for (var i = minString; i <= maxString; i++) {
          for (var j = minColumn; j <= maxColumn; j++) {
            cellsInField.add([i, j]);
          }
        }

        for (var i = 0; i < cellsInField.length - 1; i++) {
          final cell1 = cellsInField[i];
          if (cells[cell1[0]][cell1[1]].getPredictedNumbers()!.length != 2) {
            continue;
          }

          for (var j = i + 1; j < cellsInField.length; j++) {
            final cell2 = cellsInField[j];
            if (!_sgSetEquals(cells[cell1[0]][cell1[1]].getPredictedNumbers()!,
                cells[cell2[0]][cell2[1]].getPredictedNumbers()!)) {
              continue;
            }

            final pair = cells[cell1[0]][cell1[1]].getPredictedNumbers()!;
            final number1 = pair.first;
            final number2 = pair.elementAt(1);

            for (final cell in cellsInField) {
              if (_sgCellEquals(cell, cell1) || _sgCellEquals(cell, cell2)) continue;
              isSmthDeleted =
                  cells[cell[0]][cell[1]].removePredictedNumber(number1) ||
                      isSmthDeleted;
              isSmthDeleted =
                  cells[cell[0]][cell[1]].removePredictedNumber(number2) ||
                      isSmthDeleted;
            }
          }
        }
      }
    }

    return isSmthDeleted;
  }

  bool _findAndDeleteNakedTripletInString() {
    var isSmthDeleted = false;

    for (var string = 0; string < sudokuSize; string++) {
      for (var col1 = 0; col1 < sudokuSize - 2; col1++) {
        final size1 = cells[string][col1].getPredictedNumbers()!.length;
        if (size1 < 2 || size1 > 3) continue;

        for (var col2 = col1 + 1; col2 < sudokuSize - 1; col2++) {
          final size2 = cells[string][col2].getPredictedNumbers()!.length;
          if (size2 < 2 || size2 > 3) continue;

          for (var col3 = col2 + 1; col3 < sudokuSize; col3++) {
            final size3 = cells[string][col3].getPredictedNumbers()!.length;
            if (size3 < 2 || size3 > 3) continue;

            final union = <int>{};
            union.addAll(cells[string][col1].getPredictedNumbers()!);
            union.addAll(cells[string][col2].getPredictedNumbers()!);
            union.addAll(cells[string][col3].getPredictedNumbers()!);

            if (union.length != 3) continue;

            // Голая тройка найдена — удаляем её числа из остальных ячеек строки.
            for (var column = 0; column < sudokuSize; column++) {
              if (column == col1 || column == col2 || column == col3) continue;
              for (final value in union) {
                isSmthDeleted =
                    cells[string][column].removePredictedNumber(value) ||
                        isSmthDeleted;
              }
            }
          }
        }
      }
    }

    return isSmthDeleted;
  }

  bool _findAndDeleteNakedTripletInColumn() {
    var isSmthDeleted = false;

    for (var column = 0; column < sudokuSize; column++) {
      for (var string1 = 0; string1 < sudokuSize - 2; string1++) {
        final size1 = cells[string1][column].getPredictedNumbers()!.length;
        if (size1 < 2 || size1 > 3) continue;

        for (var string2 = string1 + 1; string2 < sudokuSize - 1; string2++) {
          final size2 = cells[string2][column].getPredictedNumbers()!.length;
          if (size2 < 2 || size2 > 3) continue;

          for (var string3 = string2 + 1; string3 < sudokuSize; string3++) {
            final size3 = cells[string3][column].getPredictedNumbers()!.length;
            if (size3 < 2 || size3 > 3) continue;

            final union = <int>{};
            union.addAll(cells[string1][column].getPredictedNumbers()!);
            union.addAll(cells[string2][column].getPredictedNumbers()!);
            union.addAll(cells[string3][column].getPredictedNumbers()!);

            if (union.length != 3) continue;

            // Голая тройка найдена — удаляем её числа из остальных ячеек столбца.
            for (var string = 0; string < sudokuSize; string++) {
              if (string == string1 || string == string2 || string == string3) {
                continue;
              }
              for (final value in union) {
                isSmthDeleted =
                    cells[string][column].removePredictedNumber(value) ||
                        isSmthDeleted;
              }
            }
          }
        }
      }
    }

    return isSmthDeleted;
  }

  bool _findAndDeleteNakedTripletInField() {
    var isSmthDeleted = false;
    final sizeOfField = sqrt(sudokuSize).toInt();

    for (var fieldRow = 0; fieldRow < sizeOfField; fieldRow++) {
      for (var fieldCol = 0; fieldCol < sizeOfField; fieldCol++) {
        final minString = fieldRow * sizeOfField;
        final maxString = minString + sizeOfField - 1;
        final minColumn = fieldCol * sizeOfField;
        final maxColumn = minColumn + sizeOfField - 1;

        final cellsInField = <List<int>>[];
        for (var i = minString; i <= maxString; i++) {
          for (var j = minColumn; j <= maxColumn; j++) {
            cellsInField.add([i, j]);
          }
        }

        for (var i = 0; i < cellsInField.length - 2; i++) {
          final cell1 = cellsInField[i];
          final size1 = cells[cell1[0]][cell1[1]].getPredictedNumbers()!.length;
          if (size1 < 2 || size1 > 3) continue;

          for (var j = i + 1; j < cellsInField.length - 1; j++) {
            final cell2 = cellsInField[j];
            final size2 = cells[cell2[0]][cell2[1]].getPredictedNumbers()!.length;
            if (size2 < 2 || size2 > 3) continue;

            for (var k = j + 1; k < cellsInField.length; k++) {
              final cell3 = cellsInField[k];
              final size3 =
                  cells[cell3[0]][cell3[1]].getPredictedNumbers()!.length;
              if (size3 < 2 || size3 > 3) continue;

              final union = <int>{};
              union.addAll(cells[cell1[0]][cell1[1]].getPredictedNumbers()!);
              union.addAll(cells[cell2[0]][cell2[1]].getPredictedNumbers()!);
              union.addAll(cells[cell3[0]][cell3[1]].getPredictedNumbers()!);

              if (union.length != 3) continue;

              // Голая тройка найдена — удаляем её числа из остальных ячеек поля.
              for (final cellInField in cellsInField) {
                if (_sgCellEquals(cellInField, cell1) ||
                    _sgCellEquals(cellInField, cell2) ||
                    _sgCellEquals(cellInField, cell3)) {
                  continue;
                }
                for (final value in union) {
                  isSmthDeleted = cells[cellInField[0]][cellInField[1]]
                          .removePredictedNumber(value) ||
                      isSmthDeleted;
                }
              }
            }
          }
        }
      }
    }

    return isSmthDeleted;
  }

  bool _findAndDeleteHiddenPairsInString() {
    var isSmthDeleted = false;

    for (var string = 0; string < sudokuSize; string++) {
      // число -> список столбцов, где оно встречается как кандидат
      final numberToColumns = <int, List<int>>{};
      for (var col = 0; col < sudokuSize; col++) {
        final predicted = cells[string][col].getPredictedNumbers();
        if (predicted == null || predicted.isEmpty) continue;
        for (final value in predicted) {
          numberToColumns.putIfAbsent(value, () => <int>[]).add(col);
        }
      }

      // числа, встречающиеся ровно в 2 ячейках строки
      final numbersInTwoCells = <int>[];
      for (final entry in numberToColumns.entries) {
        if (entry.value.length == 2) numbersInTwoCells.add(entry.key);
      }

      // ищем 2 числа, встречающиеся ровно в одних и тех же 2 ячейках
      for (var i = 0; i < numbersInTwoCells.length - 1; i++) {
        for (var j = i + 1; j < numbersInTwoCells.length; j++) {
          final num1 = numbersInTwoCells[i];
          final num2 = numbersInTwoCells[j];

          final cols1 = numberToColumns[num1]!;
          final cols2 = numberToColumns[num2]!;

          if (!_sgListEquals(cols1, cols2)) continue;

          // Скрытая пара: num1 и num2 могут стоять только здесь — удаляем
          // из этих ячеек все остальные кандидаты.
          final col1 = cols1[0];
          final col2 = cols1[1];

          final toRemoveFromCell1 =
              Set<int>.from(cells[string][col1].getPredictedNumbers()!);
          toRemoveFromCell1.remove(num1);
          toRemoveFromCell1.remove(num2);
          for (final value in toRemoveFromCell1) {
            isSmthDeleted =
                cells[string][col1].removePredictedNumber(value) || isSmthDeleted;
          }

          final toRemoveFromCell2 =
              Set<int>.from(cells[string][col2].getPredictedNumbers()!);
          toRemoveFromCell2.remove(num1);
          toRemoveFromCell2.remove(num2);
          for (final value in toRemoveFromCell2) {
            isSmthDeleted =
                cells[string][col2].removePredictedNumber(value) || isSmthDeleted;
          }
        }
      }
    }

    return isSmthDeleted;
  }

  bool _findAndDeleteHiddenPairsInColumn() {
    var isSmthDeleted = false;

    for (var col = 0; col < sudokuSize; col++) {
      // число -> список строк, где оно встречается как кандидат
      final numberToStrings = <int, List<int>>{};
      for (var string = 0; string < sudokuSize; string++) {
        final predicted = cells[string][col].getPredictedNumbers();
        if (predicted == null || predicted.isEmpty) continue;
        for (final value in predicted) {
          numberToStrings.putIfAbsent(value, () => <int>[]).add(string);
        }
      }

      final numbersInTwoCells = <int>[];
      for (final entry in numberToStrings.entries) {
        if (entry.value.length == 2) numbersInTwoCells.add(entry.key);
      }

      for (var i = 0; i < numbersInTwoCells.length - 1; i++) {
        for (var j = i + 1; j < numbersInTwoCells.length; j++) {
          final num1 = numbersInTwoCells[i];
          final num2 = numbersInTwoCells[j];

          final strings1 = numberToStrings[num1]!;
          final strings2 = numberToStrings[num2]!;

          if (!_sgListEquals(strings1, strings2)) continue;

          final string1 = strings1[0];
          final string2 = strings1[1];

          final toRemoveFromCell1 =
              Set<int>.from(cells[string1][col].getPredictedNumbers()!);
          toRemoveFromCell1.remove(num1);
          toRemoveFromCell1.remove(num2);
          for (final value in toRemoveFromCell1) {
            isSmthDeleted =
                cells[string1][col].removePredictedNumber(value) || isSmthDeleted;
          }

          final toRemoveFromCell2 =
              Set<int>.from(cells[string2][col].getPredictedNumbers()!);
          toRemoveFromCell2.remove(num1);
          toRemoveFromCell2.remove(num2);
          for (final value in toRemoveFromCell2) {
            isSmthDeleted =
                cells[string2][col].removePredictedNumber(value) || isSmthDeleted;
          }
        }
      }
    }

    return isSmthDeleted;
  }

  bool _findAndDeleteHiddenPairsInField() {
    var isSmthDeleted = false;
    final sizeOfField = sqrt(sudokuSize).toInt();

    for (var fieldRow = 0; fieldRow < sizeOfField; fieldRow++) {
      for (var fieldCol = 0; fieldCol < sizeOfField; fieldCol++) {
        final minString = fieldRow * sizeOfField;
        final maxString = minString + sizeOfField - 1;
        final minColumn = fieldCol * sizeOfField;
        final maxColumn = minColumn + sizeOfField - 1;

        // число -> список ячеек [строка, столбец], где оно встречается
        final numberToCells = <int, List<List<int>>>{};
        for (var string = minString; string <= maxString; string++) {
          for (var col = minColumn; col <= maxColumn; col++) {
            final predicted = cells[string][col].getPredictedNumbers();
            if (predicted == null || predicted.isEmpty) continue;
            for (final value in predicted) {
              numberToCells.putIfAbsent(value, () => <List<int>>[]).add(
                  [string, col]);
            }
          }
        }

        final numbersInTwoCells = <int>[];
        for (final entry in numberToCells.entries) {
          if (entry.value.length == 2) numbersInTwoCells.add(entry.key);
        }

        for (var i = 0; i < numbersInTwoCells.length - 1; i++) {
          for (var j = i + 1; j < numbersInTwoCells.length; j++) {
            final num1 = numbersInTwoCells[i];
            final num2 = numbersInTwoCells[j];

            final cells1 = numberToCells[num1]!;
            final cells2 = numberToCells[num2]!;

            if (!_sgCellEquals(cells1[0], cells2[0]) ||
                !_sgCellEquals(cells1[1], cells2[1])) {
              continue;
            }

            final cell1 = cells1[0];
            final cell2 = cells1[1];

            final toRemoveFromCell1 =
                Set<int>.from(cells[cell1[0]][cell1[1]].getPredictedNumbers()!);
            toRemoveFromCell1.remove(num1);
            toRemoveFromCell1.remove(num2);
            for (final value in toRemoveFromCell1) {
              isSmthDeleted =
                  cells[cell1[0]][cell1[1]].removePredictedNumber(value) ||
                      isSmthDeleted;
            }

            final toRemoveFromCell2 =
                Set<int>.from(cells[cell2[0]][cell2[1]].getPredictedNumbers()!);
            toRemoveFromCell2.remove(num1);
            toRemoveFromCell2.remove(num2);
            for (final value in toRemoveFromCell2) {
              isSmthDeleted =
                  cells[cell2[0]][cell2[1]].removePredictedNumber(value) ||
                      isSmthDeleted;
            }
          }
        }
      }
    }

    return isSmthDeleted;
  }

  bool _findAndDeleteHiddenTripletInString() {
    var isSmthDeleted = false;

    for (var string = 0; string < sudokuSize; string++) {
      final numberToColumns = <int, List<int>>{};
      for (var col = 0; col < sudokuSize; col++) {
        final predicted = cells[string][col].getPredictedNumbers();
        if (predicted == null || predicted.isEmpty) continue;
        for (final value in predicted) {
          numberToColumns.putIfAbsent(value, () => <int>[]).add(col);
        }
      }

      // числа, встречающиеся не более чем в 3 ячейках
      final candidates = <int>[];
      for (final entry in numberToColumns.entries) {
        if (entry.value.length <= 3) candidates.add(entry.key);
      }

      for (var i = 0; i < candidates.length - 2; i++) {
        for (var j = i + 1; j < candidates.length - 1; j++) {
          for (var k = j + 1; k < candidates.length; k++) {
            final num1 = candidates[i];
            final num2 = candidates[j];
            final num3 = candidates[k];

            final unionCols = <int>{};
            unionCols.addAll(numberToColumns[num1]!);
            unionCols.addAll(numberToColumns[num2]!);
            unionCols.addAll(numberToColumns[num3]!);

            if (unionCols.length != 3) continue;

            // Скрытая тройка — оставляем только num1/num2/num3 в этих ячейках.
            final toKeep = <int>{num1, num2, num3};
            for (final col in unionCols) {
              final toRemove =
                  Set<int>.from(cells[string][col].getPredictedNumbers()!);
              toRemove.removeAll(toKeep);
              for (final value in toRemove) {
                isSmthDeleted =
                    cells[string][col].removePredictedNumber(value) ||
                        isSmthDeleted;
              }
            }
          }
        }
      }
    }

    return isSmthDeleted;
  }

  bool _findAndDeleteHiddenTripletInColumn() {
    var isSmthDeleted = false;

    for (var col = 0; col < sudokuSize; col++) {
      final numberToStrings = <int, List<int>>{};
      for (var string = 0; string < sudokuSize; string++) {
        final predicted = cells[string][col].getPredictedNumbers();
        if (predicted == null || predicted.isEmpty) continue;
        for (final value in predicted) {
          numberToStrings.putIfAbsent(value, () => <int>[]).add(string);
        }
      }

      final candidates = <int>[];
      for (final entry in numberToStrings.entries) {
        if (entry.value.length <= 3) candidates.add(entry.key);
      }

      for (var i = 0; i < candidates.length - 2; i++) {
        for (var j = i + 1; j < candidates.length - 1; j++) {
          for (var k = j + 1; k < candidates.length; k++) {
            final num1 = candidates[i];
            final num2 = candidates[j];
            final num3 = candidates[k];

            final unionStrings = <int>{};
            unionStrings.addAll(numberToStrings[num1]!);
            unionStrings.addAll(numberToStrings[num2]!);
            unionStrings.addAll(numberToStrings[num3]!);

            if (unionStrings.length != 3) continue;

            final toKeep = <int>{num1, num2, num3};
            for (final string in unionStrings) {
              final toRemove =
                  Set<int>.from(cells[string][col].getPredictedNumbers()!);
              toRemove.removeAll(toKeep);
              for (final value in toRemove) {
                isSmthDeleted =
                    cells[string][col].removePredictedNumber(value) ||
                        isSmthDeleted;
              }
            }
          }
        }
      }
    }

    return isSmthDeleted;
  }

  bool _findAndDeleteHiddenTripletInField() {
    var isSmthDeleted = false;
    final sizeOfField = sqrt(sudokuSize).toInt();

    for (var fieldRow = 0; fieldRow < sizeOfField; fieldRow++) {
      for (var fieldCol = 0; fieldCol < sizeOfField; fieldCol++) {
        final minString = fieldRow * sizeOfField;
        final maxString = minString + sizeOfField - 1;
        final minColumn = fieldCol * sizeOfField;
        final maxColumn = minColumn + sizeOfField - 1;

        // число -> список ячеек (кодируем как string*sudokuSize+col)
        final numberToCells = <int, List<int>>{};
        for (var string = minString; string <= maxString; string++) {
          for (var col = minColumn; col <= maxColumn; col++) {
            final predicted = cells[string][col].getPredictedNumbers();
            if (predicted == null || predicted.isEmpty) continue;
            for (final value in predicted) {
              numberToCells
                  .putIfAbsent(value, () => <int>[])
                  .add(string * sudokuSize + col);
            }
          }
        }

        final candidates = <int>[];
        for (final entry in numberToCells.entries) {
          if (entry.value.length <= 3) candidates.add(entry.key);
        }

        for (var i = 0; i < candidates.length - 2; i++) {
          for (var j = i + 1; j < candidates.length - 1; j++) {
            for (var k = j + 1; k < candidates.length; k++) {
              final num1 = candidates[i];
              final num2 = candidates[j];
              final num3 = candidates[k];

              final unionCells = <int>{};
              unionCells.addAll(numberToCells[num1]!);
              unionCells.addAll(numberToCells[num2]!);
              unionCells.addAll(numberToCells[num3]!);

              if (unionCells.length != 3) continue;

              final toKeep = <int>{num1, num2, num3};
              for (final encoded in unionCells) {
                final string = encoded ~/ sudokuSize;
                final col = encoded % sudokuSize;
                final toRemove =
                    Set<int>.from(cells[string][col].getPredictedNumbers()!);
                toRemove.removeAll(toKeep);
                for (final value in toRemove) {
                  isSmthDeleted =
                      cells[string][col].removePredictedNumber(value) ||
                          isSmthDeleted;
                }
              }
            }
          }
        }
      }
    }

    return isSmthDeleted;
  }

  bool _applyXWingRows() {
    var removed = false;

    for (var number = 1; number <= sudokuSize; number++) {
      // Находим строки, где цифра может быть только в двух столбцах.
      for (var string1 = 0; string1 < sudokuSize - 1; string1++) {
        final columns1 = _findColumnsInStringWhereNumberContained(string1, number);
        if (columns1.length != 2) continue;

        for (var string2 = string1 + 1; string2 < sudokuSize; string2++) {
          final columns2 =
              _findColumnsInStringWhereNumberContained(string2, number);
          if (columns2.length != 2) continue;

          if (_sgListEquals(columns1, columns2)) {
            final column1 = columns1[0];
            final column2 = columns1[1];

            if (_removeCandidateFromColumns(
                column1, column2, string1, string2, number)) {
              removed = true;
            }
          }
        }
      }
    }
    return removed;
  }

  List<int> _findColumnsInStringWhereNumberContained(int string, int number) {
    final columns = <int>[];
    for (var column = 0; column < sudokuSize; column++) {
      if (cells[string][column].getPredictedNumbers()!.contains(number)) {
        columns.add(column);
      }
    }
    return columns;
  }

  bool _removeCandidateFromColumns(
      int column1, int column2, int string1, int string2, int number) {
    var ifSomethingRemoved1 = false;
    var ifSomethingRemoved2 = false;
    for (var string = 0; string < sudokuSize; string++) {
      if (string == string1 || string == string2) continue;

      ifSomethingRemoved1 = cells[string][column1].removePredictedNumber(number);
      if (ifSomethingRemoved1) ifSomethingRemoved2 = ifSomethingRemoved1;
      ifSomethingRemoved1 = cells[string][column2].removePredictedNumber(number);
      if (ifSomethingRemoved1) ifSomethingRemoved2 = ifSomethingRemoved1;
    }
    return ifSomethingRemoved2;
  }

  bool _applyXWingColumns() {
    var removed = false;

    for (var number = 1; number <= sudokuSize; number++) {
      // Находим столбцы, где цифра может быть только в двух строках.
      for (var column1 = 0; column1 < sudokuSize - 1; column1++) {
        final strings1 = _findStringsInColumnWhereNumberContained(column1, number);
        if (strings1.length != 2) continue;

        for (var column2 = column1 + 1; column2 < sudokuSize; column2++) {
          final strings2 =
              _findStringsInColumnWhereNumberContained(column2, number);
          if (strings2.length != 2) continue;

          if (_sgListEquals(strings1, strings2)) {
            final string1 = strings1[0];
            final string2 = strings1[1];

            if (_removeCandidateFromStrings(
                column1, column2, string1, string2, number)) {
              removed = true;
            }
          }
        }
      }
    }
    return removed;
  }

  // NB: в оригинале (Java) здесь добавляется `column`, а не `string` —
  // поведение сохранено дословно.
  List<int> _findStringsInColumnWhereNumberContained(int column, int number) {
    final strings = <int>[];
    for (var string = 0; string < sudokuSize; string++) {
      if (cells[string][column].getPredictedNumbers()!.contains(number)) {
        strings.add(column);
      }
    }
    return strings;
  }

  bool _removeCandidateFromStrings(
      int column1, int column2, int string1, int string2, int number) {
    var ifSomethingRemoved1 = false;
    var ifSomethingRemoved2 = false;
    for (var column = 0; column < sudokuSize; column++) {
      if (column == column1 || column == column2) continue;

      ifSomethingRemoved1 = cells[string1][column].removePredictedNumber(number);
      if (ifSomethingRemoved1) ifSomethingRemoved2 = ifSomethingRemoved1;
      ifSomethingRemoved1 = cells[string2][column].removePredictedNumber(number);
      if (ifSomethingRemoved1) ifSomethingRemoved2 = ifSomethingRemoved1;
    }
    return ifSomethingRemoved2;
  }

  /// Удаляет число из всей строки, столбца и поля исходной ячейки —
  /// число точно стоит в этой ячейке, поэтому в остальных его быть не может.
  void _deletePredictedNumberFromStringAndColumnAndField(
      int number, int string, int column) {
    // Очищаем все предсказания для ячейки и записываем в неё только это число.
    cells[string][column].clearPredictedNumbers();
    cells[string][column].addPredictedNumber(number);

    // Удаляем число из всей строки, кроме самой ячейки.
    for (var i = 0; i < sudokuSize; i++) {
      if (i == column) continue;
      cells[string][i].removePredictedNumber(number);
    }

    // Удаляем число из всего столбца, кроме самой ячейки.
    for (var i = 0; i < sudokuSize; i++) {
      if (i == string) continue;
      cells[i][column].removePredictedNumber(number);
    }

    // Удаляем число из всех ячеек поля, кроме исходной.
    final sizeOfField = sqrt(sudokuSize).toInt();
    final fieldPositionByString = string ~/ sizeOfField;
    final fieldPositionByColumn = column ~/ sizeOfField;

    final minStringInField = fieldPositionByString * sizeOfField;
    final maxStringInField = minStringInField + sizeOfField - 1;

    final minColumnInField = fieldPositionByColumn * sizeOfField;
    final maxColumnInField = minColumnInField + sizeOfField - 1;

    for (var i = minStringInField; i <= maxStringInField; i++) {
      for (var j = minColumnInField; j <= maxColumnInField; j++) {
        if (i == string && j == column) continue;
        cells[i][j].removePredictedNumber(number);
      }
    }
  }

  bool _checkIfSudokuResolved() {
    var isResolved = true;
    for (var string = 0; string < sudokuSize; string++) {
      for (var column = 0; column < sudokuSize; column++) {
        if (cells[string][column].getInsertedNumber() == 0) {
          isResolved = false;
          break;
        }
      }
      if (isResolved == false) break;
    }
    isSudokuResolved = isResolved;
    return isResolved;
  }
}

bool _sgSetEquals(Set<int> a, Set<int> b) =>
    a.length == b.length && a.containsAll(b);

bool _sgListEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _sgCellEquals(List<int> a, List<int> b) => a[0] == b[0] && a[1] == b[1];
