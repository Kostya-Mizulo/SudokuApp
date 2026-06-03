import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudokuapp/sudoku_logic/sudoku_logic.dart';

import '../bloc/bloc.dart';
import '../widgets/widgets.dart';

class Sudoku9x9GameScreen extends StatelessWidget {
  const Sudoku9x9GameScreen({super.key, required this.difficulty});

  final DifficultyLevel difficulty;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SudokuGameBloc()..add(SudokuGameStarted(difficulty)),
      child: const _Sudoku9x9GameView(),
    );
  }
}

class _Sudoku9x9GameView extends StatelessWidget {
  const _Sudoku9x9GameView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SudokuGameBloc, SudokuGameState>(
      builder: (context, state) {
        if (state is! SudokuGameLoaded) return const Scaffold();

        final screenSize = MediaQuery.of(context).size;
        final screenWidth = screenSize.width;
        final screenHeight = screenSize.height;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(
                Icons.chevron_left,
                size: screenWidth * 0.096,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DifficultyLabel(),
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
        );
      },
    );
  }
}
