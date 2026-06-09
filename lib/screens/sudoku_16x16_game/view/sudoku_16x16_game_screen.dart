import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudokuapp/repositories/sudoku_repository.dart';
import 'package:sudokuapp/sudoku_logic/sudoku_logic.dart';

import '../../shared/screen_frame.dart';
import '../../win_screen/view/view.dart';
import '../bloc/bloc.dart';
import '../widgets/widgets.dart';

class Sudoku16x16GameScreen extends StatelessWidget {
  const Sudoku16x16GameScreen({super.key, required this.difficulty})
      : _resume = false;

  const Sudoku16x16GameScreen.resume({super.key})
      : difficulty = null,
        _resume = true;

  final DifficultyLevel? difficulty;
  final bool _resume;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = SudokuGameBloc(
          sudokuRepository: context.read<SudokuRepository>(),
        );
        return _resume
            ? (bloc..add(SudokuGameResumed()))
            : (bloc..add(SudokuGameStarted(difficulty!)));
      },
      child: const _Sudoku16x16GameView(),
    );
  }
}

class _Sudoku16x16GameView extends StatefulWidget {
  const _Sudoku16x16GameView();

  @override
  State<_Sudoku16x16GameView> createState() => _Sudoku16x16GameViewState();
}

class _Sudoku16x16GameViewState extends State<_Sudoku16x16GameView>
    with WidgetsBindingObserver {
  late final SudokuGameBloc _bloc;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<SudokuGameBloc>();
    WidgetsBinding.instance.addObserver(this);
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _bloc.add(SudokuGameTimerTicked()),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _bloc.add(SudokuGameSessionSaveRequested());
    }
  }

  void _onPopInvoked(bool didPop, dynamic result) {
    if (didPop) _bloc.saveSession();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(child: BlocListener<SudokuGameBloc, SudokuGameState>(
      listener: (context, state) {
        if (state is SudokuGameResolved) {
          _ticker?.cancel();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => WinScreen(elapsedTime: state.elapsedTime),
            ),
          );
        }
      },
      child: BlocBuilder<SudokuGameBloc, SudokuGameState>(
        builder: (context, state) {
          if (state is! SudokuGameLoaded) return const Scaffold();

          final screenSize = MediaQuery.of(context).size;
          final screenWidth = screenSize.width;
          final screenHeight = screenSize.height;

          return PopScope(
            onPopInvokedWithResult: _onPopInvoked,
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: Icon(
                    Icons.chevron_left,
                    size: screenWidth * 0.096,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    await _bloc.saveSession();
                    if (mounted) navigator.pop();
                  },
                ),
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.15),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DifficultyLabel(),
                        StopwatchDisplay(),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Center(
                    child: SizedBox(
                      width: screenWidth * 0.98,
                      height: screenWidth * 0.98,
                      child: InteractiveViewer(
                        minScale: 1.0,
                        maxScale: 16 / 5,
                        boundaryMargin: EdgeInsets.zero,
                        child: const SudokuMap(),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.045),
                  const GameActionButtons(),
                  SizedBox(height: screenHeight * 0.03),
                  NumberInputRow(
                    onNumberTap: (number) => context
                        .read<SudokuGameBloc>()
                        .add(SudokuGameNumberInserted(number)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ));
  }
}
