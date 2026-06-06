import 'dart:io';

import 'difficulty_level.dart';

/// Сохраняет сгенерированные головоломки в JSON-файлы `resources/puzzles/<difficulty>.json`.
///
/// Порт `sudoku_grid/SudokuParser.java`. Использует `dart:io`, поэтому работает
/// на desktop/mobile, но не во Flutter Web. Это инструмент времени генерации,
/// а не рантайма приложения (в приложении головоломки читаются из рабочих копий
/// через SudokuRepository + PuzzleStorageService).
class SudokuParser {
  const SudokuParser();

  static const String _puzzlesDir = 'resources/puzzles/';

  static const String _version = '01';
  static final RegExp _idPattern = RegExp(r'"id":\s*(\d+)');

  static void savePuzzle(List<List<int>> solvedGrid, List<List<int>> puzzleGrid,
      DifficultyLevel difficulty) {
    final file = File('$_puzzlesDir${difficulty.name.toLowerCase()}.json');
    final content = file.readAsStringSync().trim();

    if (content == '[]' || content.isEmpty) {
      _initializeFile(file, solvedGrid.length, difficulty);
    }

    final nextId = _calculateNextId(file, difficulty);
    final newEntry = _buildEntry(solvedGrid, puzzleGrid, difficulty, nextId);
    _appendToFile(file, newEntry);
  }

  static void _initializeFile(File file, int size, DifficultyLevel difficulty) {
    final initial = '{\n'
        '  "sudokuSize": $size,\n'
        '  "difficulty": "${difficulty.name.toUpperCase()}",\n'
        '  "totalCount": 0,\n'
        '  "puzzles": []\n'
        '}';
    file.writeAsStringSync(initial);
  }

  static int _calculateNextId(File file, DifficultyLevel difficulty) {
    final content = file.readAsStringSync();
    final firstId =
        int.parse('${_getDifficultyDigit(difficulty)}${_version}0001');

    var lastId = 0;
    for (final match in _idPattern.allMatches(content)) {
      lastId = int.parse(match.group(1)!);
    }

    return lastId == 0 ? firstId : lastId + 1;
  }

  static String _buildEntry(List<List<int>> solvedGrid,
      List<List<int>> puzzleGrid, DifficultyLevel difficulty, int id) {
    const fi = '      '; // field indent
    return '    {\n'
        '$fi"id": $id,\n'
        '$fi"difficulty": "${difficulty.name.toUpperCase()}",\n'
        '$fi"solvedGrid": ${_gridToJson(solvedGrid)},\n'
        '$fi"puzzleGrid": ${_gridToJson(puzzleGrid)}\n'
        '    }';
  }

  static String _gridToJson(List<List<int>> grid) {
    final sb = StringBuffer('[');
    for (var i = 0; i < grid.length; i++) {
      sb.write('\n        [');
      for (var j = 0; j < grid[i].length; j++) {
        sb.write(grid[i][j]);
        if (j < grid[i].length - 1) sb.write(', ');
      }
      sb.write(']');
      if (i < grid.length - 1) sb.write(',');
    }
    sb.write('\n      ]');
    return sb.toString();
  }

  static void _appendToFile(File file, String newEntry) {
    final content = file.readAsStringSync();
    final puzzlesEnd = content.lastIndexOf(']');
    final beforeClose = content.substring(0, puzzlesEnd).trimRight();
    final afterClose = content.substring(puzzlesEnd + 1);

    final isEmpty = !beforeClose.contains('"id":');

    String updated;
    if (isEmpty) {
      updated = '$beforeClose\n$newEntry\n  ]$afterClose';
    } else {
      updated = '$beforeClose,\n$newEntry\n  ]$afterClose';
    }

    final newCount = _countOccurrences(updated, '"id":');
    updated = updated.replaceFirst(
        RegExp(r'"totalCount":\s*\d+'), '"totalCount": $newCount');

    file.writeAsStringSync(updated);
  }

  static int _countOccurrences(String text, String pattern) {
    var count = 0;
    var idx = 0;
    while ((idx = text.indexOf(pattern, idx)) != -1) {
      count++;
      idx += pattern.length;
    }
    return count;
  }

  static String _getDifficultyDigit(DifficultyLevel difficulty) {
    return switch (difficulty) {
      DifficultyLevel.easy => '1',
      DifficultyLevel.medium => '2',
      DifficultyLevel.hard => '3',
      DifficultyLevel.master => '4',
      DifficultyLevel.sixteen => '5',
    };
  }
}
