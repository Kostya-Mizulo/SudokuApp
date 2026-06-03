import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudokuapp/sudoku_logic/sudoku_logic.dart';

import 'sudoku_game_event.dart';
import 'sudoku_game_state.dart';

class SudokuGameBloc extends Bloc<SudokuGameEvent, SudokuGameState> {
  SudokuGameBloc() : super(SudokuGameInitial()) {
    on<SudokuGameStarted>(_onGameStarted);
    on<SudokuGameNotesToggled>(_onNotesToggled);
    on<SudokuGameCellSelected>(_onCellSelected);
  }

  SudokuGame? _game;

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
      _game = await SudokuGame.fromDifficulty(event.difficulty);
      emit(_snapshot());
    } catch (e) {
      emit(SudokuGameError(e.toString()));
    }
  }
}
