import 'package:flutter/material.dart';

class NumberButton extends StatefulWidget {
  const NumberButton({
    super.key,
    required this.number,
    this.onTap,
  });

  final int number;
  final VoidCallback? onTap;

  @override
  State<NumberButton> createState() => _NumberButtonState();
}

class _NumberButtonState extends State<NumberButton> {
  // TODO: replace with value from BLoC
  bool numberAvailable = true;

  @override
  Widget build(BuildContext context) {
    if (!numberAvailable) return const SizedBox.shrink();

    final color = Theme.of(context).colorScheme.primary;
    final cellHeight = MediaQuery.of(context).size.height * 0.06;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: cellHeight,
        margin: EdgeInsets.zero,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            '${widget.number}',
            style: TextStyle(
              fontSize: 48,
              color: color,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
