// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PuzzleProgressTableTable extends PuzzleProgressTable
    with TableInfo<$PuzzleProgressTableTable, PuzzleProgressTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PuzzleProgressTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DifficultyLevel, String>
  difficulty =
      GeneratedColumn<String>(
        'difficulty',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DifficultyLevel>(
        $PuzzleProgressTableTable.$converterdifficulty,
      );
  static const VerificationMeta _isPlayedMeta = const VerificationMeta(
    'isPlayed',
  );
  @override
  late final GeneratedColumn<bool> isPlayed = GeneratedColumn<bool>(
    'is_played',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_played" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isWinMeta = const VerificationMeta('isWin');
  @override
  late final GeneratedColumn<bool> isWin = GeneratedColumn<bool>(
    'is_win',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_win" IN (0, 1))',
    ),
  );
  static const VerificationMeta _solvingTimeMeta = const VerificationMeta(
    'solvingTime',
  );
  @override
  late final GeneratedColumn<int> solvingTime = GeneratedColumn<int>(
    'solving_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<int> rate = GeneratedColumn<int>(
    'rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    difficulty,
    isPlayed,
    isWin,
    solvingTime,
    rate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'puzzle_progress_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PuzzleProgressTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('is_played')) {
      context.handle(
        _isPlayedMeta,
        isPlayed.isAcceptableOrUnknown(data['is_played']!, _isPlayedMeta),
      );
    }
    if (data.containsKey('is_win')) {
      context.handle(
        _isWinMeta,
        isWin.isAcceptableOrUnknown(data['is_win']!, _isWinMeta),
      );
    }
    if (data.containsKey('solving_time')) {
      context.handle(
        _solvingTimeMeta,
        solvingTime.isAcceptableOrUnknown(
          data['solving_time']!,
          _solvingTimeMeta,
        ),
      );
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PuzzleProgressTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PuzzleProgressTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      difficulty: $PuzzleProgressTableTable.$converterdifficulty.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}difficulty'],
        )!,
      ),
      isPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_played'],
      )!,
      isWin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_win'],
      ),
      solvingTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}solving_time'],
      ),
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rate'],
      ),
    );
  }

  @override
  $PuzzleProgressTableTable createAlias(String alias) {
    return $PuzzleProgressTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DifficultyLevel, String, String>
  $converterdifficulty = const EnumNameConverter<DifficultyLevel>(
    DifficultyLevel.values,
  );
}

class PuzzleProgressTableData extends DataClass
    implements Insertable<PuzzleProgressTableData> {
  final int id;
  final DifficultyLevel difficulty;
  final bool isPlayed;
  final bool? isWin;
  final int? solvingTime;
  final int? rate;
  const PuzzleProgressTableData({
    required this.id,
    required this.difficulty,
    required this.isPlayed,
    this.isWin,
    this.solvingTime,
    this.rate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['difficulty'] = Variable<String>(
        $PuzzleProgressTableTable.$converterdifficulty.toSql(difficulty),
      );
    }
    map['is_played'] = Variable<bool>(isPlayed);
    if (!nullToAbsent || isWin != null) {
      map['is_win'] = Variable<bool>(isWin);
    }
    if (!nullToAbsent || solvingTime != null) {
      map['solving_time'] = Variable<int>(solvingTime);
    }
    if (!nullToAbsent || rate != null) {
      map['rate'] = Variable<int>(rate);
    }
    return map;
  }

  PuzzleProgressTableCompanion toCompanion(bool nullToAbsent) {
    return PuzzleProgressTableCompanion(
      id: Value(id),
      difficulty: Value(difficulty),
      isPlayed: Value(isPlayed),
      isWin: isWin == null && nullToAbsent
          ? const Value.absent()
          : Value(isWin),
      solvingTime: solvingTime == null && nullToAbsent
          ? const Value.absent()
          : Value(solvingTime),
      rate: rate == null && nullToAbsent ? const Value.absent() : Value(rate),
    );
  }

  factory PuzzleProgressTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PuzzleProgressTableData(
      id: serializer.fromJson<int>(json['id']),
      difficulty: $PuzzleProgressTableTable.$converterdifficulty.fromJson(
        serializer.fromJson<String>(json['difficulty']),
      ),
      isPlayed: serializer.fromJson<bool>(json['isPlayed']),
      isWin: serializer.fromJson<bool?>(json['isWin']),
      solvingTime: serializer.fromJson<int?>(json['solvingTime']),
      rate: serializer.fromJson<int?>(json['rate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'difficulty': serializer.toJson<String>(
        $PuzzleProgressTableTable.$converterdifficulty.toJson(difficulty),
      ),
      'isPlayed': serializer.toJson<bool>(isPlayed),
      'isWin': serializer.toJson<bool?>(isWin),
      'solvingTime': serializer.toJson<int?>(solvingTime),
      'rate': serializer.toJson<int?>(rate),
    };
  }

  PuzzleProgressTableData copyWith({
    int? id,
    DifficultyLevel? difficulty,
    bool? isPlayed,
    Value<bool?> isWin = const Value.absent(),
    Value<int?> solvingTime = const Value.absent(),
    Value<int?> rate = const Value.absent(),
  }) => PuzzleProgressTableData(
    id: id ?? this.id,
    difficulty: difficulty ?? this.difficulty,
    isPlayed: isPlayed ?? this.isPlayed,
    isWin: isWin.present ? isWin.value : this.isWin,
    solvingTime: solvingTime.present ? solvingTime.value : this.solvingTime,
    rate: rate.present ? rate.value : this.rate,
  );
  PuzzleProgressTableData copyWithCompanion(PuzzleProgressTableCompanion data) {
    return PuzzleProgressTableData(
      id: data.id.present ? data.id.value : this.id,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      isPlayed: data.isPlayed.present ? data.isPlayed.value : this.isPlayed,
      isWin: data.isWin.present ? data.isWin.value : this.isWin,
      solvingTime: data.solvingTime.present
          ? data.solvingTime.value
          : this.solvingTime,
      rate: data.rate.present ? data.rate.value : this.rate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PuzzleProgressTableData(')
          ..write('id: $id, ')
          ..write('difficulty: $difficulty, ')
          ..write('isPlayed: $isPlayed, ')
          ..write('isWin: $isWin, ')
          ..write('solvingTime: $solvingTime, ')
          ..write('rate: $rate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, difficulty, isPlayed, isWin, solvingTime, rate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PuzzleProgressTableData &&
          other.id == this.id &&
          other.difficulty == this.difficulty &&
          other.isPlayed == this.isPlayed &&
          other.isWin == this.isWin &&
          other.solvingTime == this.solvingTime &&
          other.rate == this.rate);
}

class PuzzleProgressTableCompanion
    extends UpdateCompanion<PuzzleProgressTableData> {
  final Value<int> id;
  final Value<DifficultyLevel> difficulty;
  final Value<bool> isPlayed;
  final Value<bool?> isWin;
  final Value<int?> solvingTime;
  final Value<int?> rate;
  const PuzzleProgressTableCompanion({
    this.id = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.isPlayed = const Value.absent(),
    this.isWin = const Value.absent(),
    this.solvingTime = const Value.absent(),
    this.rate = const Value.absent(),
  });
  PuzzleProgressTableCompanion.insert({
    this.id = const Value.absent(),
    required DifficultyLevel difficulty,
    this.isPlayed = const Value.absent(),
    this.isWin = const Value.absent(),
    this.solvingTime = const Value.absent(),
    this.rate = const Value.absent(),
  }) : difficulty = Value(difficulty);
  static Insertable<PuzzleProgressTableData> custom({
    Expression<int>? id,
    Expression<String>? difficulty,
    Expression<bool>? isPlayed,
    Expression<bool>? isWin,
    Expression<int>? solvingTime,
    Expression<int>? rate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (difficulty != null) 'difficulty': difficulty,
      if (isPlayed != null) 'is_played': isPlayed,
      if (isWin != null) 'is_win': isWin,
      if (solvingTime != null) 'solving_time': solvingTime,
      if (rate != null) 'rate': rate,
    });
  }

  PuzzleProgressTableCompanion copyWith({
    Value<int>? id,
    Value<DifficultyLevel>? difficulty,
    Value<bool>? isPlayed,
    Value<bool?>? isWin,
    Value<int?>? solvingTime,
    Value<int?>? rate,
  }) {
    return PuzzleProgressTableCompanion(
      id: id ?? this.id,
      difficulty: difficulty ?? this.difficulty,
      isPlayed: isPlayed ?? this.isPlayed,
      isWin: isWin ?? this.isWin,
      solvingTime: solvingTime ?? this.solvingTime,
      rate: rate ?? this.rate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(
        $PuzzleProgressTableTable.$converterdifficulty.toSql(difficulty.value),
      );
    }
    if (isPlayed.present) {
      map['is_played'] = Variable<bool>(isPlayed.value);
    }
    if (isWin.present) {
      map['is_win'] = Variable<bool>(isWin.value);
    }
    if (solvingTime.present) {
      map['solving_time'] = Variable<int>(solvingTime.value);
    }
    if (rate.present) {
      map['rate'] = Variable<int>(rate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PuzzleProgressTableCompanion(')
          ..write('id: $id, ')
          ..write('difficulty: $difficulty, ')
          ..write('isPlayed: $isPlayed, ')
          ..write('isWin: $isWin, ')
          ..write('solvingTime: $solvingTime, ')
          ..write('rate: $rate')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PuzzleProgressTableTable puzzleProgressTable =
      $PuzzleProgressTableTable(this);
  late final Index idxDifficultyIsPlayed = Index(
    'idx_difficulty_is_played',
    'CREATE INDEX idx_difficulty_is_played ON puzzle_progress_table (difficulty, is_played)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    puzzleProgressTable,
    idxDifficultyIsPlayed,
  ];
}

typedef $$PuzzleProgressTableTableCreateCompanionBuilder =
    PuzzleProgressTableCompanion Function({
      Value<int> id,
      required DifficultyLevel difficulty,
      Value<bool> isPlayed,
      Value<bool?> isWin,
      Value<int?> solvingTime,
      Value<int?> rate,
    });
typedef $$PuzzleProgressTableTableUpdateCompanionBuilder =
    PuzzleProgressTableCompanion Function({
      Value<int> id,
      Value<DifficultyLevel> difficulty,
      Value<bool> isPlayed,
      Value<bool?> isWin,
      Value<int?> solvingTime,
      Value<int?> rate,
    });

class $$PuzzleProgressTableTableFilterComposer
    extends Composer<_$AppDatabase, $PuzzleProgressTableTable> {
  $$PuzzleProgressTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DifficultyLevel, DifficultyLevel, String>
  get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isPlayed => $composableBuilder(
    column: $table.isPlayed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWin => $composableBuilder(
    column: $table.isWin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get solvingTime => $composableBuilder(
    column: $table.solvingTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PuzzleProgressTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PuzzleProgressTableTable> {
  $$PuzzleProgressTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPlayed => $composableBuilder(
    column: $table.isPlayed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWin => $composableBuilder(
    column: $table.isWin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get solvingTime => $composableBuilder(
    column: $table.solvingTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PuzzleProgressTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PuzzleProgressTableTable> {
  $$PuzzleProgressTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DifficultyLevel, String> get difficulty =>
      $composableBuilder(
        column: $table.difficulty,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get isPlayed =>
      $composableBuilder(column: $table.isPlayed, builder: (column) => column);

  GeneratedColumn<bool> get isWin =>
      $composableBuilder(column: $table.isWin, builder: (column) => column);

  GeneratedColumn<int> get solvingTime => $composableBuilder(
    column: $table.solvingTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);
}

class $$PuzzleProgressTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PuzzleProgressTableTable,
          PuzzleProgressTableData,
          $$PuzzleProgressTableTableFilterComposer,
          $$PuzzleProgressTableTableOrderingComposer,
          $$PuzzleProgressTableTableAnnotationComposer,
          $$PuzzleProgressTableTableCreateCompanionBuilder,
          $$PuzzleProgressTableTableUpdateCompanionBuilder,
          (
            PuzzleProgressTableData,
            BaseReferences<
              _$AppDatabase,
              $PuzzleProgressTableTable,
              PuzzleProgressTableData
            >,
          ),
          PuzzleProgressTableData,
          PrefetchHooks Function()
        > {
  $$PuzzleProgressTableTableTableManager(
    _$AppDatabase db,
    $PuzzleProgressTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PuzzleProgressTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PuzzleProgressTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PuzzleProgressTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DifficultyLevel> difficulty = const Value.absent(),
                Value<bool> isPlayed = const Value.absent(),
                Value<bool?> isWin = const Value.absent(),
                Value<int?> solvingTime = const Value.absent(),
                Value<int?> rate = const Value.absent(),
              }) => PuzzleProgressTableCompanion(
                id: id,
                difficulty: difficulty,
                isPlayed: isPlayed,
                isWin: isWin,
                solvingTime: solvingTime,
                rate: rate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DifficultyLevel difficulty,
                Value<bool> isPlayed = const Value.absent(),
                Value<bool?> isWin = const Value.absent(),
                Value<int?> solvingTime = const Value.absent(),
                Value<int?> rate = const Value.absent(),
              }) => PuzzleProgressTableCompanion.insert(
                id: id,
                difficulty: difficulty,
                isPlayed: isPlayed,
                isWin: isWin,
                solvingTime: solvingTime,
                rate: rate,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PuzzleProgressTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PuzzleProgressTableTable,
      PuzzleProgressTableData,
      $$PuzzleProgressTableTableFilterComposer,
      $$PuzzleProgressTableTableOrderingComposer,
      $$PuzzleProgressTableTableAnnotationComposer,
      $$PuzzleProgressTableTableCreateCompanionBuilder,
      $$PuzzleProgressTableTableUpdateCompanionBuilder,
      (
        PuzzleProgressTableData,
        BaseReferences<
          _$AppDatabase,
          $PuzzleProgressTableTable,
          PuzzleProgressTableData
        >,
      ),
      PuzzleProgressTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PuzzleProgressTableTableTableManager get puzzleProgressTable =>
      $$PuzzleProgressTableTableTableManager(_db, _db.puzzleProgressTable);
}
