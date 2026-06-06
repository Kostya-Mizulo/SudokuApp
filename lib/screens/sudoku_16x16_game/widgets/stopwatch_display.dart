import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc.dart';

class StopwatchDisplay extends StatelessWidget {
  const StopwatchDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final color = Theme.of(context).colorScheme.primary;

    return BlocBuilder<SudokuGameBloc, SudokuGameState>(
      buildWhen: (prev, curr) {
        if (curr is! SudokuGameLoaded) return false;
        if (prev is! SudokuGameLoaded) return true;
        return prev.elapsedTime != curr.elapsedTime;
      },
      builder: (context, state) {
        final time = state is SudokuGameLoaded ? state.elapsedTime : '00:00';

        return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Время',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  height: 1.1,
                  color: color,
                ),
              ),
              Text(
                time,
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
