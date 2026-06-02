import 'dart:math';

import 'difficulty_level.dart';
import 'sudoku_solver.dart';
import 'sudoku_parser.dart';
import 'sudoku_size.dart';

/// Генератор судоку.
///
/// Порт `sudoku_grid/SudokuCreator.java`. Отладочный вывод прогресса убран;
/// перенаправление `System.out` для подавления вывода решателя больше не нужно,
/// так как решатель не печатает в консоль во время решения.
class SudokuCreator {
  SudokuCreator._();

  static final Random _random = Random();

  static void generate(SudokuSize size, DifficultyLevel difficulty, int count) {
    var generated = 0;
    while (generated < count) {
      final solvedGrid = generateSolvedGrid(size);
      final puzzle = removeNumbers(solvedGrid, difficulty);
      if (puzzle != null) {
        SudokuParser.savePuzzle(solvedGrid, puzzle, difficulty);
        generated++;
      }
    }
  }

  static List<List<int>> generateSolvedGrid(SudokuSize size) {
    final n = size.size;
    final grid = List.generate(n, (_) => List<int>.filled(n, 0), growable: false);
    _fillGrid(grid, n);
    return grid;
  }

  /// Принимает заполненный судоку и уровень сложности. Возвращает головоломку
  /// или null, если не удалось достичь minEmptyCells.
  static List<List<int>>? removeNumbers(
      List<List<int>> solvedGrid, DifficultyLevel difficulty) {
    final n = solvedGrid.length;
    final boxSize = sqrt(n).toInt();
    final min = difficulty.minEmptyCells;
    final max = difficulty.maxEmptyCells;
    final target = min + _random.nextInt(max - min + 1);

    final puzzle = _copyGrid(solvedGrid, n);
    var removed = 0;

    while (removed < target) {
      if (!_tryRemoveOneCell(puzzle, n, boxSize)) break;
      removed++;
    }

    return removed >= min ? puzzle : null;
  }

  /// Случайно перебирает заполненные клетки и пробует удалить одну так, чтобы
  /// судоку оставался с единственным решением. true — успех, false — нельзя
  /// удалить ни одну клетку.
  static bool _tryRemoveOneCell(List<List<int>> grid, int n, int boxSize) {
    final filled = <List<int>>[];
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        if (grid[r][c] != 0) filled.add([r, c]);
      }
    }

    filled.shuffle(_random);

    for (final cell in filled) {
      final r = cell[0];
      final c = cell[1];
      final saved = grid[r][c];
      grid[r][c] = 0;
      if (_isSolvable(grid, n) && _hasUniqueSolution(grid, n, boxSize)) {
        return true;
      }
      grid[r][c] = saved;
    }
    return false;
  }

  /// Создаёт [SudokuSolver] и запускает [SudokuSolver.solveSudoku]. Нормальное завершение —
  /// судоку решается логически; [SudokuStuckException] — решатель застрял
  /// (в Java эту роль играл NullPointerException).
  static bool _isSolvable(List<List<int>> grid, int n) {
    try {
      final sudoku = SudokuSolver(n);
      sudoku.initiateSudokuMap(grid);
      sudoku.solveSudoku();
      return true;
    } on SudokuStuckException {
      return false;
    }
  }

  static bool _hasUniqueSolution(List<List<int>> grid, int n, int boxSize) {
    if (n == SudokuSize.sixteen.size) {
      final rowMask = List<int>.filled(n, 0);
      final colMask = List<int>.filled(n, 0);
      final boxMask = List<int>.filled(n, 0);
      for (var r = 0; r < n; r++) {
        for (var c = 0; c < n; c++) {
          final v = grid[r][c];
          if (v != 0) {
            final bit = 1 << (v - 1);
            final box = (r ~/ boxSize) * boxSize + (c ~/ boxSize);
            rowMask[r] |= bit;
            colMask[c] |= bit;
            boxMask[box] |= bit;
          }
        }
      }
      final fullMask = (1 << n) - 1;
      return _countSolutionsFast(
              grid, n, boxSize, 2, rowMask, colMask, boxMask, fullMask) ==
          1;
    }
    return _countSolutions(grid, n, boxSize, 2) == 1;
  }

  /// Для 9x9: считает решения прямым backtracking, останавливаясь на limit.
  static int _countSolutions(List<List<int>> grid, int n, int boxSize, int limit) {
    for (var row = 0; row < n; row++) {
      for (var col = 0; col < n; col++) {
        if (grid[row][col] != 0) continue;
        var count = 0;
        for (var number = 1; number <= n && count < limit; number++) {
          if (_isValidPlacement(grid, row, col, number, n, boxSize)) {
            grid[row][col] = number;
            count += _countSolutions(grid, n, boxSize, limit - count);
            grid[row][col] = 0;
          }
        }
        return count;
      }
    }
    return 1;
  }

  /// Для 16x16: MRV — выбираем клетку с минимумом кандидатов; битовые маски
  /// дают O(1) вычисление кандидатов.
  static int _countSolutionsFast(List<List<int>> grid, int n, int boxSize,
      int limit, List<int> rowMask, List<int> colMask, List<int> boxMask,
      int fullMask) {
    var bestRow = -1;
    var bestCol = -1;
    var bestAvailable = 0;
    var bestCount = n + 1;

    outer:
    for (var row = 0; row < n; row++) {
      for (var col = 0; col < n; col++) {
        if (grid[row][col] != 0) continue;
        final box = (row ~/ boxSize) * boxSize + (col ~/ boxSize);
        final available = ~(rowMask[row] | colMask[col] | boxMask[box]) & fullMask;
        if (available == 0) return 0;
        final count = _bitCount(available);
        if (count < bestCount) {
          bestCount = count;
          bestRow = row;
          bestCol = col;
          bestAvailable = available;
          if (bestCount == 1) break outer;
        }
      }
    }

    if (bestRow == -1) return 1;

    var solutions = 0;
    final box = (bestRow ~/ boxSize) * boxSize + (bestCol ~/ boxSize);
    var available = bestAvailable;
    while (available != 0 && solutions < limit) {
      final bit = available & -available;
      available &= available - 1;
      grid[bestRow][bestCol] = _numberOfTrailingZeros(bit) + 1;
      rowMask[bestRow] |= bit;
      colMask[bestCol] |= bit;
      boxMask[box] |= bit;

      solutions += _countSolutionsFast(
          grid, n, boxSize, limit - solutions, rowMask, colMask, boxMask,
          fullMask);

      grid[bestRow][bestCol] = 0;
      rowMask[bestRow] ^= bit;
      colMask[bestCol] ^= bit;
      boxMask[box] ^= bit;
    }
    return solutions;
  }

  static bool _fillGrid(List<List<int>> grid, int n) {
    final boxSize = sqrt(n).toInt();
    for (var row = 0; row < n; row++) {
      for (var col = 0; col < n; col++) {
        if (grid[row][col] != 0) continue;
        final candidates = <int>[for (var number = 1; number <= n; number++) number];
        candidates.shuffle(_random);
        for (final number in candidates) {
          if (_isValidPlacement(grid, row, col, number, n, boxSize)) {
            grid[row][col] = number;
            if (_fillGrid(grid, n)) return true;
            grid[row][col] = 0;
          }
        }
        return false;
      }
    }
    return true;
  }

  static bool _isValidPlacement(
      List<List<int>> grid, int row, int col, int number, int n, int boxSize) {
    for (var i = 0; i < n; i++) {
      if (grid[row][i] == number || grid[i][col] == number) return false;
    }
    final boxRow = (row ~/ boxSize) * boxSize;
    final boxCol = (col ~/ boxSize) * boxSize;
    for (var r = boxRow; r < boxRow + boxSize; r++) {
      for (var c = boxCol; c < boxCol + boxSize; c++) {
        if (grid[r][c] == number) return false;
      }
    }
    return true;
  }

  static List<List<int>> _copyGrid(List<List<int>> grid, int n) =>
      List.generate(n, (r) => List<int>.from(grid[r]), growable: false);

  /// Количество установленных битов (аналог `Integer.bitCount`).
  static int _bitCount(int x) {
    var count = 0;
    var v = x;
    while (v != 0) {
      count += v & 1;
      v >>= 1;
    }
    return count;
  }

  /// Число завершающих нулей для значения с единственным установленным битом
  /// (аналог `Integer.numberOfTrailingZeros` для степени двойки).
  static int _numberOfTrailingZeros(int bit) => bit.bitLength - 1;
}
