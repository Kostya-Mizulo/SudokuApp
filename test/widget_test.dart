// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sudokuapp/main.dart';

void main() {
  testWidgets('Bottom bar shows both tabs and toggles selection',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Both bottom-bar buttons are present.
    expect(find.text('Главная'), findsOneWidget);
    expect(find.text('Я'), findsOneWidget);

    Color colorOf(String label) =>
        (tester.widget<Text>(find.text(label)).style!.color)!;

    final ThemeData theme = Theme.of(tester.element(find.text('Главная')));

    // «Главная» starts selected (theme color), «Я» is disabled grey.
    expect(colorOf('Главная'), theme.colorScheme.primary);
    expect(colorOf('Я'), theme.disabledColor);

    // Tapping «Я» moves the selection to it.
    await tester.tap(find.text('Я'));
    await tester.pump();

    expect(colorOf('Я'), theme.colorScheme.primary);
    expect(colorOf('Главная'), theme.disabledColor);
  });
}
