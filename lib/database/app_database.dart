import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../sudoku_logic/difficulty_level.dart';

part 'app_database.g.dart';

@TableIndex(name: 'idx_difficulty_is_played', columns: {#difficulty, #isPlayed})
class PuzzleProgressTable extends Table {
  IntColumn get id => integer()();
  TextColumn get difficulty => textEnum<DifficultyLevel>()();
  BoolColumn get isPlayed => boolean().withDefault(const Constant(false))();
  BoolColumn get isWin => boolean().nullable()();
  IntColumn get solvingTime => integer().nullable()();
  IntColumn get rate => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [PuzzleProgressTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // При добавлении колонки в версии N:
          //   if (from < N) await m.addColumn(table, table.newColumn);
          // Никогда не удаляй и не переименовывай колонки — данные пользователя потеряются.
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sudoku.db'));
    return NativeDatabase.createInBackground(file);
  });
}
