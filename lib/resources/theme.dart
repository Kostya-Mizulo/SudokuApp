import 'package:flutter/material.dart';

// Цвет текста/иконок в топбаре, боттомбаре, кнопках и границах кнопок.
const Color kAccentColor = Color(0xFF00B5C8);

final ThemeData miamiBlueTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 238, 233, 246),
  ).copyWith(primary: kAccentColor),
);
