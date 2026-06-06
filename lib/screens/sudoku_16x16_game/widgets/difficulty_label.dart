import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc.dart';

class DifficultyLabel extends StatelessWidget {
  const DifficultyLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final color = Theme.of(context).colorScheme.primary;

    return BlocBuilder<SudokuGameBloc, SudokuGameState>(
      buildWhen: (prev, curr) => curr is SudokuGameLoaded && prev is! SudokuGameLoaded,
      builder: (context, state) {
        final label = state is SudokuGameLoaded ? state.difficultyLabel : '';

        return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Уровень',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  height: 1.1,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: screenWidth * 0.053,
                  height: 1.1,
                  color: color,
                ),
              ),
            ],
          );
      },
    );
  }
}
