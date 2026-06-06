// dart run tool/verify_puzzle_assets.dart
import 'dart:convert';
import 'dart:io';

void main() {
  final levels = {
    'easy': (sudokuSize: 9, expectedCount: 250, idPrefix: '101'),
    'medium': (sudokuSize: 9, expectedCount: 250, idPrefix: '201'),
    'hard': (sudokuSize: 9, expectedCount: 250, idPrefix: '301'),
    'master': (sudokuSize: 9, expectedCount: 250, idPrefix: '401'),
    'sixteen': (sudokuSize: 16, expectedCount: 50, idPrefix: '501'),
  };

  var totalErrors = 0;

  for (final entry in levels.entries) {
    final name = entry.key;
    final expected = entry.value;
    final file = File('lib/resources/puzzles/$name.json');
    var errors = 0;

    void err(String msg) {
      stdout.writeln('  [ERR] $msg');
      errors++;
    }

    stdout.writeln('=== $name.json ===');

    // 1. Валидный JSON
    Map<String, dynamic> data;
    try {
      data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    } catch (e) {
      stdout.writeln('  [ERR] Invalid JSON: $e');
      totalErrors++;
      continue;
    }

    // 2. Верхнеуровневые поля
    final topKeys = data.keys.toSet();
    final requiredTop = {'sudokuSize', 'difficulty', 'totalCount', 'puzzles'};
    final forbiddenTop = {'resolvedCount', 'isAllResolved'};
    for (final k in requiredTop) {
      if (!topKeys.contains(k)) err('missing top-level field: "$k"');
    }
    for (final k in forbiddenTop) {
      if (topKeys.contains(k)) err('forbidden top-level field present: "$k"');
    }

    // 3. sudokuSize
    if (data['sudokuSize'] != expected.sudokuSize) {
      err('sudokuSize=${data['sudokuSize']} expected ${expected.sudokuSize}');
    }

    // 4. difficulty
    if (data['difficulty'] != name.toUpperCase()) {
      err('difficulty="${data['difficulty']}" expected "${name.toUpperCase()}"');
    }

    // 5. puzzles — количество и totalCount
    final puzzles = (data['puzzles'] as List).cast<Map<String, dynamic>>();
    if (puzzles.length != expected.expectedCount) {
      err('puzzles.length=${puzzles.length} expected ${expected.expectedCount}');
    }
    if (data['totalCount'] != puzzles.length) {
      err('totalCount=${data['totalCount']} != puzzles.length=${puzzles.length}');
    }

    // 6. Каждый паззл
    final n = expected.sudokuSize;
    final seenIds = <int>{};
    final requiredPuzzleKeys = {'id', 'difficulty', 'solvedGrid', 'puzzleGrid'};
    final forbiddenPuzzleKeys = {'isResolved', 'rateWhileResolved'};

    for (var i = 0; i < puzzles.length; i++) {
      final p = puzzles[i];
      final label = 'puzzle[$i]';

      for (final k in requiredPuzzleKeys) {
        if (!p.containsKey(k)) err('$label missing field: "$k"');
      }
      for (final k in forbiddenPuzzleKeys) {
        if (p.containsKey(k)) err('$label forbidden field present: "$k"');
      }

      // ID формат
      final id = p['id'] as int?;
      if (id == null) {
        err('$label id is null');
      } else {
        if (!id.toString().startsWith(expected.idPrefix)) {
          err('$label id=$id does not start with ${expected.idPrefix}');
        }
        if (!seenIds.add(id)) err('$label duplicate id=$id');
      }

      // difficulty
      if (p['difficulty'] != name.toUpperCase()) {
        err('$label difficulty="${p['difficulty']}" expected "${name.toUpperCase()}"');
      }

      // solvedGrid размер и значения
      final solved = p['solvedGrid'];
      if (solved is! List || solved.length != n) {
        err('$label solvedGrid wrong row count: ${solved is List ? solved.length : 'not a list'}');
      } else {
        for (var r = 0; r < n; r++) {
          final row = solved[r];
          if (row is! List || row.length != n) {
            err('$label solvedGrid[$r] wrong length');
            continue;
          }
          for (var c = 0; c < n; c++) {
            final v = row[c] as int?;
            if (v == null || v < 1 || v > n) {
              err('$label solvedGrid[$r][$c]=$v out of range [1..$n]');
            }
          }
        }
      }

      // puzzleGrid размер и значения (0 = пустая клетка)
      final puzzle = p['puzzleGrid'];
      if (puzzle is! List || puzzle.length != n) {
        err('$label puzzleGrid wrong row count');
      } else {
        for (var r = 0; r < n; r++) {
          final row = puzzle[r];
          if (row is! List || row.length != n) {
            err('$label puzzleGrid[$r] wrong length');
            continue;
          }
          for (var c = 0; c < n; c++) {
            final v = row[c] as int?;
            if (v == null || v < 0 || v > n) {
              err('$label puzzleGrid[$r][$c]=$v out of range [0..$n]');
            }
          }
        }
      }
    }

    if (errors == 0) {
      stdout.writeln('  OK — ${puzzles.length} puzzles, size ${n}x$n');
    } else {
      stdout.writeln('  $errors error(s) found');
      totalErrors += errors;
    }
  }

  stdout.writeln('');
  if (totalErrors == 0) {
    stdout.writeln('All files OK.');
  } else {
    stdout.writeln('Total errors: $totalErrors');
    exit(1);
  }
}
