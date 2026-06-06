import 'package:flutter/material.dart';
import 'number_button.dart';

class NumberInputRow extends StatelessWidget {
  const NumberInputRow({super.key, this.onNumberTap});

  final void Function(int number)? onNumberTap;

  Widget _buildRow(int from, int to) {
    return FractionallySizedBox(
      widthFactor: 0.96,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(to - from + 1, (i) {
          final number = from + i;
          return Expanded(
            child: FractionallySizedBox(
              widthFactor: 0.8,
              child: NumberButton(
                number: number,
                onTap: () => onNumberTap?.call(number),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(1, 9),
          SizedBox(height: screenHeight * 0.008),
          _buildRow(10, 16),
        ],
      ),
    );
  }
}
