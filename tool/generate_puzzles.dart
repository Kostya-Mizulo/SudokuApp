// dart run tool/generate_puzzles.dart
//
// Запускать из корня проекта. Скрипт переключает CWD в lib/, чтобы
// SudokuParser мог найти resources/puzzles/<difficulty>.json по
// относительному пути.

import 'dart:io';

import 'package:sudokuapp/sudoku_logic/difficulty_level.dart';
import 'package:sudokuapp/sudoku_logic/sudoku_creator.dart';
import 'package:sudokuapp/sudoku_logic/sudoku_size.dart';

void main() {
  Directory.current = Directory('lib');

  final tasks = [
    (DifficultyLevel.sixteen, SudokuSize.sixteen, 18),
  ];

  for (final (difficulty, size, count) in tasks) {
    stdout.writeln('=== ${difficulty.name.toUpperCase()}: generating $count puzzles... ===');
    final stopwatch = Stopwatch()..start();
    SudokuCreator.generate(size, difficulty, count, onProgress: (n) {
      stdout.write('\r  $n / $count');
    });
    stopwatch.stop();
    stdout.writeln('\n  Done in ${stopwatch.elapsed.inSeconds}s');
  }

  stdout.writeln('\nAll puzzles generated!');
}
