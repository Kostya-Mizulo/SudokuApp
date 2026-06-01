import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../user_menu/view/view.dart';
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

  static const _titles = ['Главная', 'Я'];

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
          _titles[_selectedIndex],
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              const SizedBox.expand(),
              Align(
                alignment: const Alignment(0, -0.4),
                child: SvgPicture.asset(
                  'lib/resources/images/sudoku_icon.svg',
                  width: 160,
                  height: 160,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 48),
                child: NewGameButton(
                  onPressed: () => DifficultyPopup.show(context),
                ),
              ),
            ],
          ),
          const UserMenuBody(),
        ],
      ),
      bottomNavigationBar: MainBottomBar(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
