import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import '../sudoku_logic/difficulty_level.dart';

/// Управляет рабочими копиями файлов головоломок в локальном хранилище.
///
/// При первом запуске копирует ассеты из `lib/resources/puzzles/` в директорию
/// приложения. Последующие запуски используют уже созданные копии, которые
/// можно изменять (отмечать решёнными и т.п.).
class PuzzleStorageService {
  static const String _assetsDir = 'lib/resources/puzzles/';
  static const String _subDir = 'puzzles';

  static Future<void> initialize() async {
    final dir = await _puzzlesDir();
    for (final difficulty in DifficultyLevel.values) {
      final file = _fileIn(dir, difficulty);
      if (!file.existsSync()) {
        final content =
            await rootBundle.loadString('$_assetsDir${_fileName(difficulty)}');
        file.writeAsStringSync(content);
      }
    }
  }

  static Future<File> getFile(DifficultyLevel difficulty) async {
    final dir = await _puzzlesDir();
    return _fileIn(dir, difficulty);
  }

  static Future<Directory> _puzzlesDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/$_subDir');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  static File _fileIn(Directory dir, DifficultyLevel difficulty) =>
      File('${dir.path}/${_fileName(difficulty)}');

  static String _fileName(DifficultyLevel difficulty) =>
      '${difficulty.name.toLowerCase()}.json';
}
