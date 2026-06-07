import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudokuapp/sudoku_logic/sudoku_logic.dart';

import '../../shared/screen_frame.dart';
import '../../win_screen/view/view.dart';
import '../bloc/bloc.dart';
import '../widgets/widgets.dart';

class Sudoku9x9GameScreen extends StatelessWidget {
  const Sudoku9x9GameScreen({super.key, required this.difficulty})
      : _resume = false;

  const Sudoku9x9GameScreen.resume({super.key})
      : difficulty = null,
        _resume = true;

  final DifficultyLevel? difficulty;
  final bool _resume;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = SudokuGameBloc();
        return _resume
            ? (bloc..add(SudokuGameResumed()))
            : (bloc..add(SudokuGameStarted(difficulty!)));
      },
      child: const _Sudoku9x9GameView(),
    );
  }
}

class _Sudoku9x9GameView extends StatefulWidget {
  const _Sudoku9x9GameView();

  @override
  State<_Sudoku9x9GameView> createState() => _Sudoku9x9GameViewState();
}

class _Sudoku9x9GameViewState extends State<_Sudoku9x9GameView>
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
                  SizedBox(height: screenHeight * 0.025),
                  const Center(child: SudokuMap()),
                  SizedBox(height: screenHeight * 0.05),
                  const GameActionButtons(),
                  SizedBox(height: screenHeight * 0.04),
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
