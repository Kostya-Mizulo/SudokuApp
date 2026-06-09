import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../database/app_database.dart';
import '../sudoku_logic/difficulty_level.dart';

class PuzzleStorageService {
  static const _assetsDir = 'lib/resources/puzzles/';

  /// Заполняет таблицу SQLite данными из ассетов при первом запуске.
  ///
  /// Проверяет наличие хотя бы одной строки — если таблица непустая,
  /// инициализация пропускается. При сбое отдельной записи продолжает
  /// со следующего паззла; в debug-режиме выводит подробности в консоль.
  static Future<void> initialize(AppDatabase db) async {
    final existingRow =
        await (db.select(db.puzzleProgressTable)..limit(1)).getSingleOrNull();
    if (existingRow != null) return;

    for (final difficulty in DifficultyLevel.values) {
      final content =
          await rootBundle.loadString('$_assetsDir${difficulty.name}.json');
      final puzzles =
          (jsonDecode(content)['puzzles'] as List)
              .cast<Map<String, dynamic>>();

      for (final puzzle in puzzles) {
        try {
          await db.into(db.puzzleProgressTable).insert(
            PuzzleProgressTableCompanion(
              id: Value(puzzle['id'] as int),
              difficulty: Value(difficulty),
              isPlayed: const Value(false),
            ),
          );
        } catch (e, st) {
          if (kDebugMode) {
            debugPrint(
              '[PuzzleStorageService] Не удалось записать паззл '
              'id=${puzzle['id']}, difficulty=${difficulty.name}: $e\n$st',
            );
          }
        }
      }
    }
  }
}
