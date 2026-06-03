import 'package:flutter/material.dart';
import 'number_button.dart';

class NumberInputRow extends StatelessWidget {
  const NumberInputRow({super.key, this.onNumberTap});

  final void Function(int number)? onNumberTap;

  @override
  Widget build(BuildContext context) {
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
                child: NumberButton(
                  number: number,
                  onTap: () => onNumberTap?.call(number),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
