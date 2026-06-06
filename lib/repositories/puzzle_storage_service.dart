import 'dart:convert';
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
      try {
        await _copyIfAbsent(dir, difficulty);
      } catch (_) {
        // Атомарное копирование не удалось — пишем напрямую, если файл всё ещё отсутствует.
        final target = _fileIn(dir, difficulty);
        if (!await target.exists()) {
          final content =
              await rootBundle.loadString('$_assetsDir${_fileName(difficulty)}');
          await target.writeAsString(_enrichJson(content));
        }
      }
    }
  }

  /// Добавляет мутабельные поля прогресса к иммутабельному JSON из ассета.
  static String _enrichJson(String assetContent) {
    final data = jsonDecode(assetContent) as Map<String, dynamic>;
    data['resolvedCount'] = 0;
    data['isAllResolved'] = false;
    final puzzles = (data['puzzles'] as List).cast<Map<String, dynamic>>();
    for (final puzzle in puzzles) {
      puzzle['isResolved'] = false;
      puzzle['rateWhileResolved'] = null;
    }
    return jsonEncode(data);
  }

  static Future<File> getFile(DifficultyLevel difficulty) async {
    final dir = await _puzzlesDir();
    return _fileIn(dir, difficulty);
  }

  /// Копирует файл из ассетов в [dir], если он там ещё не существует.
  ///
  /// Использует временный файл и атомарное переименование, чтобы
  /// частично записанный файл не остался при внезапном завершении приложения.
  static Future<void> _copyIfAbsent(
      Directory dir, DifficultyLevel difficulty) async {
    final target = _fileIn(dir, difficulty);
    if (await target.exists()) return;

    final content =
        await rootBundle.loadString('$_assetsDir${_fileName(difficulty)}');

    final tmp = File('${target.path}.tmp');
    await tmp.writeAsString(_enrichJson(content));
    await tmp.rename(target.path);
  }

  static Future<Directory> _puzzlesDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/$_subDir');
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  static File _fileIn(Directory dir, DifficultyLevel difficulty) =>
      File('${dir.path}/${_fileName(difficulty)}');

  static String _fileName(DifficultyLevel difficulty) =>
      '${difficulty.name.toLowerCase()}.json';
}
