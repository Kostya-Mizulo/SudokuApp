import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc.dart';

class NumberButton extends StatelessWidget {
  const NumberButton({
    super.key,
    required this.number,
    this.onTap,
  });

  final int number;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SudokuGameBloc, SudokuGameState>(
      buildWhen: (prev, curr) {
        if (curr is! SudokuGameLoaded) return false;
        if (prev is! SudokuGameLoaded) return true;
        return prev.numberButtonsVisibility[number] !=
            curr.numberButtonsVisibility[number];
      },
      builder: (context, state) {
        final isVisible = state is SudokuGameLoaded
            ? (state.numberButtonsVisibility[number] ?? true)
            : true;

        if (!isVisible) return const SizedBox.shrink();

        final color = Theme.of(context).colorScheme.primary;
        final cellHeight = MediaQuery.of(context).size.height * 0.06;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            height: cellHeight,
            margin: EdgeInsets.zero,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 48,
                  color: color,
                  height: 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
