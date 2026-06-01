import 'package:flutter/material.dart';

class NumberInputRow extends StatelessWidget {
  const NumberInputRow({super.key, this.onNumberTap});

  final void Function(int number)? onNumberTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final cellHeight = MediaQuery.of(context).size.height * 0.06;

    return Center(
      child: FractionallySizedBox(
      widthFactor: 0.96,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(9, (i) {
          final number = i + 1;
          return Expanded(
            child: FractionallySizedBox(
              widthFactor: 0.8,
              child: GestureDetector(
                onTap: () => onNumberTap?.call(number),
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
            ),
            ),
          );

        }),
      ),
      ),
    );
  }
}
