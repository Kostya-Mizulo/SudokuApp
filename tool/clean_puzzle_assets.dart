// dart run tool/clean_puzzle_assets.dart
//
// Удаляет из файлов ассетов поля, которые относятся к мутабельному
// прогрессу (isResolved, rateWhileResolved, resolvedCount, isAllResolved).
// Запускать из корня проекта.

import 'dart:convert';
import 'dart:io';

void main() {
  final files = ['easy', 'medium', 'hard', 'master', 'sixteen']
      .map((n) => File('lib/resources/puzzles/$n.json'))
      .toList();

  for (final file in files) {
    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

    data.remove('resolvedCount');
    data.remove('isAllResolved');

    final puzzles = (data['puzzles'] as List).cast<Map<String, dynamic>>();
    for (final puzzle in puzzles) {
      puzzle.remove('isResolved');
      puzzle.remove('rateWhileResolved');
    }

    final pretty = const JsonEncoder.withIndent('  ').convert(data);
    file.writeAsStringSync(_collapseIntArrays(pretty));
    stdout.writeln('Cleaned: ${file.path} (${puzzles.length} puzzles)');
  }

  stdout.writeln('\nDone.');
}

/// Схлопывает массивы, содержащие только целые числа, в одну строку.
/// Массивы массивов (solvedGrid / puzzleGrid) остаются многострочными.
String _collapseIntArrays(String json) {
  return json.replaceAllMapped(
    RegExp(r'\[\n\s+(?:\d+,\n\s+)*\d+\n\s+\]'),
    (match) {
      final numbers =
          RegExp(r'\d+').allMatches(match.group(0)!).map((m) => m.group(0)!);
      return '[${numbers.join(', ')}]';
    },
  );
}
