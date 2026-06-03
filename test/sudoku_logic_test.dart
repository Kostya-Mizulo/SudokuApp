import 'package:flutter_test/flutter_test.dart';
import 'package:sudokuapp/sudoku_logic/sudoku_logic.dart';

/// Проверяет, что сетка корректна: в каждой строке, столбце и поле числа 1..n
/// без повторов.
bool isValidSolved(List<List<int>> grid) {
  final n = grid.length;
  final boxSize = (n == 16) ? 4 : 3;

  for (var r = 0; r < n; r++) {
    final seen = <int>{};
    for (var c = 0; c < n; c++) {
      final v = grid[r][c];
      if (v < 1 || v > n || !seen.add(v)) return false;
    }
  }
  for (var c = 0; c < n; c++) {
    final seen = <int>{};
    for (var r = 0; r < n; r++) {
      final v = grid[r][c];
      if (v < 1 || v > n || !seen.add(v)) return false;
    }
  }
  for (var br = 0; br < boxSize; br++) {
    for (var bc = 0; bc < boxSize; bc++) {
      final seen = <int>{};
      for (var r = br * boxSize; r < (br + 1) * boxSize; r++) {
        for (var c = bc * boxSize; c < (bc + 1) * boxSize; c++) {
          final v = grid[r][c];
          if (v < 1 || v > n || !seen.add(v)) return false;
        }
      }
    }
  }
  return true;
}

void main() {
  test('generateSolvedGrid produces a valid 9x9 grid', () {
    final grid = SudokuCreator.generateSolvedGrid(SudokuSize.nine);
    expect(grid.length, 9);
    expect(isValidSolved(grid), isTrue);
  });

  test('solver solves a known 9x9 puzzle to its full solution', () {
    final puzzle = <List<int>>[
      [5, 3, 0, 0, 7, 0, 0, 0, 0],
      [6, 0, 0, 1, 9, 5, 0, 0, 0],
      [0, 9, 8, 0, 0, 0, 0, 6, 0],
      [8, 0, 0, 0, 6, 0, 0, 0, 3],
      [4, 0, 0, 8, 0, 3, 0, 0, 1],
      [7, 0, 0, 0, 2, 0, 0, 0, 6],
      [0, 6, 0, 0, 0, 0, 2, 8, 0],
      [0, 0, 0, 4, 1, 9, 0, 0, 5],
      [0, 0, 0, 0, 8, 0, 0, 7, 9],
    ];

    final sudoku = SudokuSolver(9);
    sudoku.initiateSudokuMap(puzzle);
    sudoku.solveSudoku();

    final solved = sudoku.getSolvedGrid();
    expect(isValidSolved(solved), isTrue);
    // Подставленные клетки должны совпадать с исходными подсказками.
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (puzzle[r][c] != 0) {
          expect(solved[r][c], puzzle[r][c]);
        }
      }
    }
  });

  test('a fully solved grid makes the solver get stuck (matches Java NPE)', () {
    // В оригинале решатель ищет следующий ход только среди ПУСТЫХ ячеек.
    // У полностью заполненной сетки таких нет, поэтому он «застревает» —
    // в Java это был NullPointerException, здесь это SudokuStuckException.
    final grid = SudokuCreator.generateSolvedGrid(SudokuSize.nine);
    final sudoku = SudokuSolver(9);
    sudoku.initiateSudokuMap(grid);
    expect(sudoku.solveSudoku, throwsA(isA<SudokuStuckException>()));
  });

  test('removeNumbers yields a puzzle the solver restores to its solution', () {
    final solved = SudokuCreator.generateSolvedGrid(SudokuSize.nine);
    final puzzle = SudokuCreator.removeNumbers(solved, DifficultyLevel.easy);
    expect(puzzle, isNotNull);

    final sudoku = SudokuSolver(9);
    sudoku.initiateSudokuMap(puzzle!);
    sudoku.solveSudoku();
    expect(sudoku.getSolvedGrid(), solved);
  });
}
