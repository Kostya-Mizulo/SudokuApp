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

  void _onCellSelected(
    SudokuGameCellSelected event,
    Emitter<SudokuGameState> emit,
  ) {
    final current = state;
    if (current is! SudokuGameLoaded) return;
    current.game.markCellsViaUserCellSelection(event.row, event.column);
    emit(SudokuGameLoaded(current.game));
  }

  void _onNotesToggled(
    SudokuGameNotesToggled event,
    Emitter<SudokuGameState> emit,
  ) {
    final current = state;
    if (current is! SudokuGameLoaded) return;
    current.game.isNotesActivated = !current.game.isNotesActivated;
    emit(SudokuGameLoaded(current.game));
  }

  Future<void> _onGameStarted(
    SudokuGameStarted event,
    Emitter<SudokuGameState> emit,
  ) async {
    emit(SudokuGameLoading());
    try {
      final game = await SudokuGame.fromDifficulty(event.difficulty);
      emit(SudokuGameLoaded(game));
    } catch (e) {
      emit(SudokuGameError(e.toString()));
    }
  }
}
