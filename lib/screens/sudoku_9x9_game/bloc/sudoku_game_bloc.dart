import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudokuapp/repositories/active_session_repository.dart';
import 'package:sudokuapp/repositories/sudoku_repository.dart';
import 'package:sudokuapp/sudoku_logic/sudoku_logic.dart';

import 'sudoku_game_event.dart';
import 'sudoku_game_state.dart';

class SudokuGameBloc extends Bloc<SudokuGameEvent, SudokuGameState> {
  SudokuGameBloc({
    SudokuRepository? sudokuRepository,
    ActiveSessionRepository? activeSessionRepository,
  })  : _repository = sudokuRepository ?? const SudokuRepository(),
        _activeSessionRepository =
            activeSessionRepository ?? const ActiveSessionRepository(),
        super(SudokuGameInitial()) {
    on<SudokuGameStarted>(_onGameStarted);
    on<SudokuGameResumed>(_onGameResumed);
    on<SudokuGameNotesToggled>(_onNotesToggled);
    on<SudokuGameCellSelected>(_onCellSelected);
    on<SudokuGameNumberInserted>(_onNumberInserted);
    on<SudokuGameCellCleared>(_onCellCleared);
    on<SudokuGameSessionSaveRequested>(_onSessionSaveRequested);
    on<SudokuGameTimerTicked>(_onTimerTicked);
  }

  final SudokuRepository _repository;
  final ActiveSessionRepository _activeSessionRepository;
  SudokuGame? _game;
  int _elapsedSeconds = 0;

  // Prevents double-save when the event fires and close() is called in sequence.
  bool _sessionSaved = false;

  static String _formatElapsed(int totalSeconds) {
    final mm = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final ss = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  Future<void> _trySaveIfResolved() async {
    if (_game == null || !_game!.isSudokuResolved) return;
    await _repository.savePuzzleResolved(
      _game!.sudokuGridId,
      _game!.difficulty,
      timeSeconds: _elapsedSeconds,
    );
    await _activeSessionRepository.clearSession();
  }

  Future<void> _saveActiveSession() async {
    if (_game == null || _game!.isSudokuResolved || _sessionSaved) return;
    _sessionSaved = true;
    await _activeSessionRepository.saveSession(
      id: _game!.sudokuGridId,
      difficulty: _game!.difficulty,
      cells: _game!.cells,
      elapsedSeconds: _elapsedSeconds,
    );
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
      elapsedTime: _formatElapsed(_elapsedSeconds),
    );
  }

  void _onTimerTicked(
    SudokuGameTimerTicked event,
    Emitter<SudokuGameState> emit,
  ) {
    final current = state;
    if (current is! SudokuGameLoaded || _game == null) return;
    _elapsedSeconds++;
    emit(current.copyWith(elapsedTime: _formatElapsed(_elapsedSeconds)));
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
    if (_game!.isSudokuResolved) emit(SudokuGameResolved(_formatElapsed(_elapsedSeconds)));
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

  Future<void> _onGameResumed(
    SudokuGameResumed event,
    Emitter<SudokuGameState> emit,
  ) async {
    emit(SudokuGameLoading());
    try {
      final session = await _activeSessionRepository.loadSession();
      _elapsedSeconds = session.elapsedSeconds;
      _game = SudokuGame.fromSession(
        id: session.id,
        difficulty: session.difficulty,
        resolvedGrid: session.resolvedGrid,
        initialGrid: session.initialGrid,
        currentGrid: session.currentGrid,
      );
      emit(_snapshot());
    } catch (e) {
      emit(SudokuGameError(e.toString()));
    }
  }

  Future<void> _onGameStarted(
    SudokuGameStarted event,
    Emitter<SudokuGameState> emit,
  ) async {
    emit(SudokuGameLoading());
    try {
      final puzzle = await _repository.getPuzzle(event.difficulty);
      _elapsedSeconds = 0;
      _game = SudokuGame.fromPuzzle(puzzle.id, event.difficulty, puzzle.cells);
      emit(_snapshot());
    } catch (e) {
      emit(SudokuGameError(e.toString()));
    }
  }

  Future<void> saveSession() => _saveActiveSession();

  Future<void> _onSessionSaveRequested(
    SudokuGameSessionSaveRequested event,
    Emitter<SudokuGameState> emit,
  ) async {
    await _saveActiveSession();
  }

  /// Fallback: saves the session when the BLoC is closed by BlocProvider
  /// (e.g. programmatic navigation) without the event being fired first.
  @override
  Future<void> close() async {
    await _saveActiveSession();
    return super.close();
  }
}
