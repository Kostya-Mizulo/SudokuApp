import 'package:flutter/material.dart';

import '../../shared/pill_button.dart';

class HomeButton extends StatelessWidget {
  const HomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PillButton(
      label: 'Главная',
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}
