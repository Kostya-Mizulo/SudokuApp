import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/main_menu/view/view.dart';

// Цвет текста/иконок в топбаре, боттомбаре, кнопках и границах кнопок.
const Color kAccentColor = Color(0xFF00B5C8);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Полноэкранный режим: прячем системные кнопки (назад/дом/последние).
  // По свайпу снизу они показываются полупрозрачным оверлеем и сами
  // скрываются через несколько секунд (immersiveSticky).
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // При возврате из фона система может вернуть навигационные кнопки —
    // повторно включаем полноэкранный режим, чтобы они снова скрылись.
    if (state == AppLifecycleState.resumed) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Судоку',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 238, 233, 246)).copyWith(primary: kAccentColor),
      ),
      home: const MainMenuScreen(title: 'Судоку здесь'),
    );
  }
}