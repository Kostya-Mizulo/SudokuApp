import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudokuapp/repositories/sudoku_repository.dart';
import 'package:sudokuapp/sudoku_logic/sudoku_logic.dart';

import 'sudoku_game_event.dart';
import 'sudoku_game_state.dart';

class SudokuGameBloc extends Bloc<SudokuGameEvent, SudokuGameState> {
  SudokuGameBloc([this._repository = const SudokuRepository()]) : super(SudokuGameInitial()) {
    on<SudokuGameStarted>(_onGameStarted);
    on<SudokuGameNotesToggled>(_onNotesToggled);
    on<SudokuGameCellSelected>(_onCellSelected);
    on<SudokuGameNumberInserted>(_onNumberInserted);
    on<SudokuGameCellCleared>(_onCellCleared);
  }

  final SudokuRepository _repository;
  SudokuGame? _game;

  Future<void> _trySaveIfResolved() async {
    if (_game == null || !_game!.isSudokuResolved) return;
    await _repository.savePuzzleResolved(_game!.sudokuGridId, _game!.difficulty);
  }

  SudokuGameLoaded _snapshot() {
    final game = _game!;
    return SudokuGameLoaded(
      cells: List.generate(
        game.sudokuSize,
        (r) => List.generate(game.sudokuSize, (c) => game.cells[r][c].copySnapshot()),
      ),
      difficultyLabel: game.difficultyLabel,
      isNotesActivated: game.isNotesActivated,
      numberButtonsVisibility: Map.from(game.numberButtonsVisibility),
    );
  }

  void _onCellSelected(
    SudokuGameCellSelected event,
    Emitter<SudokuGameState> emit,
  ) {
    if (_game == null) return;
    _game!.markCellsViaUserCellSelection(event.row, event.column);
    emit(_snapshot());
  }

  Future<void> _onNumberInserted(
    SudokuGameNumberInserted event,
    Emitter<SudokuGameState> emit,
  ) async {
    if (_game == null) return;
    if (_game!.isNotesActivated) return;
    _game!.insertNumberInSelectedCell(event.number);
    emit(_snapshot());
    await _trySaveIfResolved();
  }

  void _onCellCleared(
    SudokuGameCellCleared event,
    Emitter<SudokuGameState> emit,
  ) {
    if (_game == null) return;
    _game!.clearCellByClickClearButton();
    emit(_snapshot());
  }

  void _onNotesToggled(
    SudokuGameNotesToggled event,
    Emitter<SudokuGameState> emit,
  ) {
    if (_game == null) return;
    _game!.isNotesActivated = !_game!.isNotesActivated;
    emit(_snapshot());
  }

  Future<void> _onGameStarted(
    SudokuGameStarted event,
    Emitter<SudokuGameState> emit,
  ) async {
    emit(SudokuGameLoading());
    try {
      final puzzle = await _repository.getPuzzle(event.difficulty);
      _game = SudokuGame.fromPuzzle(puzzle.id, event.difficulty, puzzle.cells);
      emit(_snapshot());
    } catch (e) {
      emit(SudokuGameError(e.toString()));
    }
  }
}
