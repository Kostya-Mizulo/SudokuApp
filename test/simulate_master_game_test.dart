// Симуляция реального сценария: пользователь нажал «Начать игру» с уровнем
// сложности MASTER. Тест проходит весь путь приложения:
//   1) загрузка головоломки ИЗ ФАЙЛА  lib/puzzles/master.json через
//      SudokuParser.getSudokuPuzzle (реальный rootBundle, как в рантайме);
//   2) проверка, что объекты Cell корректно созданы и заполнены
//      (realNumber ← solvedGrid, numberByStart ← puzzleGrid);
//   3) создание объекта SudokuSolver и заполнение его стартовой сеткой;
//   4) запуск логического решателя SudokuSolver.solveSudoku();
//   5) проверка, что судоку валидно решён и совпал с эталоном из файла.
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

String renderGrid(List<List<int>> grid) {
  final sb = StringBuffer();
  for (var r = 0; r < grid.length; r++) {
    if (r % 3 == 0 && r != 0) sb.writeln('------+-------+------');
    for (var c = 0; c < grid[r].length; c++) {
      if (c % 3 == 0 && c != 0) sb.write('| ');
      final v = grid[r][c];
      sb.write(v == 0 ? '. ' : '$v ');
    }
    sb.writeln();
  }
  return sb.toString();
}

void main() {
  // rootBundle.loadString требует инициализированного биндинга и читает
  // ассеты, объявленные в pubspec.yaml (lib/puzzles/master.json).
  TestWidgetsFlutterBinding.ensureInitialized();

  test('СИМУЛЯЦИЯ: старт игры MASTER → загрузка из файла → решение решателем',
      () async {
    // ───────────── Шаг 1. Пользователь нажал «Начать игру» (MASTER) ─────────
    // Приложение запрашивает головоломку у парсера — тот читает её из ассета.
    final cells = await SudokuParser.getSudokuPuzzle(DifficultyLevel.master);

    // Сетка 9x9 из объектов Cell.
    expect(cells.length, 9, reason: 'MASTER — это 9x9');
    for (final row in cells) {
      expect(row.length, 9);
      for (final cell in row) {
        expect(cell, isA<Cell>());
      }
    }

    // Восстанавливаем стартовую сетку (что показано игроку) и эталон (ответ),
    // ИЗ САМИХ ОБЪЕКТОВ Cell — так проверяем, что они заполнены корректно.
    final puzzleGrid = [
      for (final row in cells) [for (final cell in row) cell.getNumberByStart()]
    ];
    final solvedFromFile = [
      for (final row in cells) [for (final cell in row) cell.getRealNumber()]
    ];

    // Стартовая сетка обязана иметь пустые клетки (0), иначе решатель «застрянет».
    final emptyCount = puzzleGrid
        .expand((r) => r)
        .where((v) => v == 0)
        .length;
    expect(emptyCount, greaterThan(0));
    // Для MASTER диапазон пустых клеток объявлен в enum как 55..64.
    expect(
      emptyCount,
      inInclusiveRange(
          DifficultyLevel.master.minEmptyCells,
          DifficultyLevel.master.maxEmptyCells),
      reason: 'число пустых клеток должно попадать в диапазон MASTER',
    );

    // Эталонное решение из файла само по себе обязано быть валидным судоку.
    expect(isValidSolved(solvedFromFile), isTrue,
        reason: 'solvedGrid из файла должен быть корректным судоку');

    // Каждая подсказка в стартовой сетке должна совпадать с эталоном.
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (puzzleGrid[r][c] != 0) {
          expect(puzzleGrid[r][c], solvedFromFile[r][c],
              reason: 'подсказка ($r,$c) расходится с solvedGrid');
        }
      }
    }

    // ignore: avoid_print
    print('\n=== Шаг 1. Головоломка MASTER загружена из lib/puzzles/master.json ===');
    // ignore: avoid_print
    print('Пустых клеток (0): $emptyCount  (диапазон MASTER: '
        '${DifficultyLevel.master.minEmptyCells}..${DifficultyLevel.master.maxEmptyCells})');
    // ignore: avoid_print
    print('Стартовая сетка (puzzleGrid), показанная игроку:\n${renderGrid(puzzleGrid)}');

    // ───────────── Шаг 2. Создаём объект SudokuSolver и заполняем его ─────────────
    final sudoku = SudokuSolver(9);
    sudoku.initiateSudokuMap(puzzleGrid);

    // После initiate каждая стартовая клетка должна стоять как insertedNumber.
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        expect(sudoku.cells[r][c].getInsertedNumber(), puzzleGrid[r][c]);
      }
    }

    // ───────────── Шаг 3. Запускаем логический решатель ─────────────────────
    sudoku.solveSudoku();
    expect(sudoku.isSudokuResolved, isTrue,
        reason: 'решатель должен полностью решить судоку');

    final solvedByEngine = sudoku.getSolvedGrid();

    // ───────────── Шаг 4. Проверки результата ───────────────────────────────
    // 4.1 — решение валидно по правилам судоку.
    expect(isValidSolved(solvedByEngine), isTrue,
        reason: 'решение решателя должно быть корректным судоку');

    // 4.2 — решатель не тронул подсказки.
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (puzzleGrid[r][c] != 0) {
          expect(solvedByEngine[r][c], puzzleGrid[r][c]);
        }
      }
    }

    // 4.3 — решение совпало с эталоном из файла (единственность решения).
    expect(solvedByEngine, solvedFromFile,
        reason: 'решение решателя должно совпасть с solvedGrid из файла');

    // ignore: avoid_print
    print('=== Шаг 2-3. Решатель SudokuSolver.solveSudoku() отработал ===');
    // ignore: avoid_print
    print('Решение решателя:\n${renderGrid(solvedByEngine)}');
    // ignore: avoid_print
    print('=== РЕЗУЛЬТАТ: судоку валидно загружено и решено, '
        'совпало с эталоном из файла ===\n');
  });
}
