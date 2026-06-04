import 'package:flutter/material.dart';

import '../../shared/pill_button.dart';

class NewGameButton extends StatelessWidget {
  const NewGameButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return PillButton(label: 'Новая игра', onPressed: onPressed);
  }
}
