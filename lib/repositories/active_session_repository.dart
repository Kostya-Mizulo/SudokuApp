import 'dart:convert';

import '../sudoku_logic/cell.dart';
import '../sudoku_logic/difficulty_level.dart';
import 'active_session_storage_service.dart';

/// Сохраняет и загружает активную (незавершённую) игровую сессию.
///
/// Формат JSON:
/// ```json
/// {
///   "id": 2010001,
///   "difficulty": "MEDIUM",
///   "rating": null,
///   "elapsedSeconds": null,
///   "resolvedGrid": [[2,4,5,...], ...],
///   "initialGrid":  [[0,4,0,...], ...],
///   "currentGrid":  [[0,4,5,...], ...]
/// }
/// ```
/// - `resolvedGrid` — правильные ответы (`realNumber` каждой ячейки).
/// - `initialGrid`  — оригинальный пазл (`numberByStart`); ненулевые ячейки — заблокированы.
/// - `currentGrid`  — текущее состояние поля (`insertedNumber` каждой ячейки).
class ActiveSessionRepository {
  const ActiveSessionRepository();

  Future<void> saveSession({
    required int id,
    required DifficultyLevel difficulty,
    required List<List<Cell>> cells,
    required int elapsedSeconds,
  }) async {
    final resolvedGrid = [
      for (final row in cells) [for (final cell in row) cell.realNumber],
    ];
    final initialGrid = [
      for (final row in cells) [for (final cell in row) cell.numberByStart],
    ];
    final currentGrid = [
      for (final row in cells) [for (final cell in row) cell.insertedNumber],
    ];

    final data = {
      'id': id,
      'difficulty': difficulty.name.toUpperCase(),
      'rating': null,
      'elapsedSeconds': elapsedSeconds,
      'resolvedGrid': resolvedGrid,
      'initialGrid': initialGrid,
      'currentGrid': currentGrid,
    };

    final file = await ActiveSessionStorageService.getFile();
    file.writeAsStringSync(jsonEncode(data));
  }

  Future<bool> hasSession() async {
    final file = await ActiveSessionStorageService.getFile();
    return file.existsSync() && file.lengthSync() > 0;
  }

  Future<
      ({
        int id,
        DifficultyLevel difficulty,
        List<List<int>> resolvedGrid,
        List<List<int>> initialGrid,
        List<List<int>> currentGrid,
        int elapsedSeconds,
      })> loadSession() async {
    final file = await ActiveSessionStorageService.getFile();
    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

    final id = data['id'] as int;
    final difficulty = DifficultyLevel.values.firstWhere(
      (d) => d.name.toUpperCase() == (data['difficulty'] as String),
    );
    final resolvedGrid = (data['resolvedGrid'] as List)
        .map((row) => (row as List).cast<int>())
        .toList();
    final initialGrid = (data['initialGrid'] as List)
        .map((row) => (row as List).cast<int>())
        .toList();
    final currentGrid = (data['currentGrid'] as List)
        .map((row) => (row as List).cast<int>())
        .toList();
    final elapsedSeconds = (data['elapsedSeconds'] as int?) ?? 0;

    return (
      id: id,
      difficulty: difficulty,
      resolvedGrid: resolvedGrid,
      initialGrid: initialGrid,
      currentGrid: currentGrid,
      elapsedSeconds: elapsedSeconds,
    );
  }

  Future<void> clearSession() async {
    final file = await ActiveSessionStorageService.getFile();
    if (file.existsSync()) file.deleteSync();
  }
}
