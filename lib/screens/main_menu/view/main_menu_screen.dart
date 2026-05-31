import 'package:flutter/material.dart';

import '../widgets/widgets.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key, required this.title});

  final String title;

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  /// Индекс выбранной вкладки нижней панели: 0 — «Главная», 1 — «Я».
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          widget.title,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        centerTitle: true,
      ),
      body: const Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox.expand(),
          Padding(
            padding: EdgeInsets.only(bottom: 48),
            child: NewGameButton(),
          ),
        ],
      ),
      bottomNavigationBar: MainBottomBar(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
