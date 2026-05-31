# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter Sudoku app (`sudokuapp`). Dart SDK `^3.12.0`. Targets: Android, iOS.

## Commands

```bash
# Run the app
flutter run

# Run on a specific device
flutter run -d <device-id>   # e.g. windows, chrome, emulator-5554

# List available devices
flutter devices

# Hot reload (while app is running)
r

# Build
flutter build apk             # Android
flutter build ios             # iOS

# Analyze
flutter analyze


## Code Structure

```
lib/
  main.dart          # Entry point — wires MaterialApp to the start screen
  screens/           # UI, one folder per screen (see "Screen architecture" below)
    main_menu/
      view/
        main_menu_screen.dart  # MainMenuScreen widget
        view.dart              # barrel: export 'main_menu_screen.dart'
      widgets/
        counter_display.dart   # a widget used only by this screen
        widgets.dart           # barrel: export 'counter_display.dart'
  sudoku_logic/      # Pure-Dart game logic (no Flutter deps); barrel: sudoku_logic.dart
    cell.dart            # Single cell: value + candidate ("predicted") numbers
    sudoku_size.dart     # enum: nine(9) / sixteen(16)
    difficulty_level.dart# enum: easy/medium/hard/master/sixteen + empty-cell ranges
    sudoku.dart          # Logical solver (naked/hidden pairs & triplets, X-Wing, ...)
    sudoku_creator.dart  # Generates solved grids + digs unique-solution puzzles
    sudoku_parser.dart   # Serializes puzzles to puzzles/<difficulty>.json (uses dart:io)
  puzzles/
    easy.json        # 9x9, 100 puzzles
    medium.json      # 9x9, 100 puzzles
    hard.json        # 9x9, 100 puzzles
    master.json      # 9x9, 100 puzzles
    sixteen.json     # 16x16, 10 puzzles
test/
  widget_test.dart
  sudoku_logic_test.dart
```

`lib/main.dart` only bootstraps `MaterialApp`; every screen lives under `lib/screens/`.

### Screen architecture — ОБЯЗАТЕЛЬНО / MANDATORY

**Этому правилу нужно следовать ВСЕГДА при создании новых файлов с экранами и виджетами.**

Каждый экран — это отдельная подпапка внутри `lib/screens/`:

```
lib/screens/<screen_name>/
  view/
    <screen_name>_screen.dart   # сам класс экрана (один экран = один файл)
    view.dart                   # barrel: только export'ы файлов экрана
  widgets/
    <widget>.dart               # по одному файлу на каждый виджет этого экрана
    widgets.dart                # barrel: только export'ы виджетов
```

Правила:

- **Имя подпапки экрана** (`<screen_name>`) задаёт пользователь. Если имя не указано — **спросить** перед созработкой, не выдумывать.
- В `view/` лежит файл с самим экраном плюс `view.dart`, который реэкспортит его (`export '<screen_name>_screen.dart';`).
- В `widgets/` — по одному файлу на каждый виджет экрана плюс `widgets.dart`, который реэкспортит их.
- **Импорты идут только через barrel-файлы** `view.dart` и `widgets.dart`, а не напрямую через файлы экрана/виджета. Экран подключает свои виджеты как `import '../widgets/widgets.dart';`; внешний код подключает экран как `import 'screens/<screen_name>/view/view.dart';`.
- Виджеты, общие для нескольких экранов, в эту структуру не входят (для них при необходимости заведём отдельную папку).

### `sudoku_logic` package

A faithful Dart port of the Java `sudoku_grid` package (the original source lives outside this repo). Key points:

- **Pure Dart** — no Flutter imports, so it is unit-testable in isolation. Import via `package:sudokuapp/sudoku_logic/sudoku_logic.dart`.
- The solver works only on grids **with empty cells**. A fully-solved grid makes `solveSudoku()` throw `SudokuStuckException` (this mirrors the original Java `NullPointerException` used as a "solver stuck" signal, which `SudokuCreator` catches).
- `Cell` keeps Java-style `getX`/`setX` accessors and an `addPredictedNumber` (the Java `setPredictedNumbers(int)` overload) for 1:1 traceability to the original.
- `sudoku_parser.dart` uses `dart:io` (no Flutter Web); it is a generation-time tool — the app reads bundled puzzles from assets instead.

### Puzzle JSON format

Each file in `lib/puzzles/` shares this schema:

```json
{
  "sudokuSize": 9,
  "difficulty": "MEDIUM",
  "totalCount": 100,
  "resolvedCount": 0,
  "isAllResolved": false,
  "puzzles": [
    {
      "id": 2010001,
      "difficulty": "MEDIUM",
      "isResolved": false,
      "rateWhileResolved": null,
      "solvedGrid": [[2,4,5,...], ...],
      "puzzleGrid":  [[0,0,0,...], ...]
    }
  ]
}
```

- `sudokuSize` — 9 или 16 (размер сетки)
- `solvedGrid` — полностью решённая сетка N×N
- `puzzleGrid` — начальная сетка, `0` = пустая клетка
- `rateWhileResolved` — оценка пользователя после решения, изначально `null`

Загрузка: `rootBundle.loadString('lib/puzzles/easy.json')` (зарегистрированы в `pubspec.yaml`).

## Dependencies

- `flutter` + `cupertino_icons` — only runtime deps currently
- `flutter_lints` — lint rules via `analysis_options.yaml` (`package:flutter_lints/flutter.yaml`)

Add new packages with `flutter pub add <package>` and commit both `pubspec.yaml` and `pubspec.lock`.


## Правила:
 - **Архитектура экранов** (`lib/screens/<screen>/view` + `widgets` с barrel-файлами) — ОБЯЗАТЕЛЬНА при создании любых новых экранов/виджетов. См. раздел «Screen architecture — ОБЯЗАТЕЛЬНО / MANDATORY».