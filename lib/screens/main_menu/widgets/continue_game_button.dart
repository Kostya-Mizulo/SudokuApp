import 'package:flutter/material.dart';

import '../../shared/pill_button.dart';

class ContinueGameButton extends StatelessWidget {
  const ContinueGameButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return PillButton(label: 'Продолжить', onPressed: onPressed);
  }
}
