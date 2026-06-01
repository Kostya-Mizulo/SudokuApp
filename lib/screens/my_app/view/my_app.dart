import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../resources/theme.dart';
import '../../main_menu/view/view.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Судоку',
      theme: miamiBlueTheme,
      home: const MainMenuScreen(title: 'Судоку здесь'),
    );
  }
}
