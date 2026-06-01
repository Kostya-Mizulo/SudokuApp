import 'package:flutter/material.dart';

/// Нижняя панель навигации главного экрана.
///
/// Две кнопки без границ — «Главная» и «Я» — с иконкой над подписью.
/// Выбранная кнопка окрашивается в цвет темы, невыбранная — в серый
/// цвет задизейбленных элементов.
class MainBottomBar extends StatelessWidget {
  const MainBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// Индекс выбранной кнопки: 0 — «Главная», 1 — «Я».
  final int currentIndex;

  /// Вызывается при нажатии на кнопку с её индексом.
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
          // Кнопки сдвинуты к своим краям: расстояние между ними (flex 5)
          // на 25% больше, чем от каждой кнопки до её края (flex 4).
          child: Row(
            children: [
              const Spacer(flex: 4),
              _BottomBarItem(
                icon: Icons.home,
                label: 'Главная',
                selected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              const Spacer(flex: 5),
              _BottomBarItem(
                icon: Icons.account_circle_outlined,
                label: 'Я',
                selected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              const Spacer(flex: 4),
            ],
          ),
        ),
      ),
    );
  }
}

/// Отдельная кнопка нижней панели: иконка над текстом, без границ.
class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).disabledColor;
    final size = MediaQuery.of(context).size;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size.width * 0.032),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.08,
          vertical: size.height * 0.01,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: size.width * 0.08),
            SizedBox(height: size.height * 0.003),
            Text(
              label,
              style: TextStyle(color: color, fontSize: size.width * 0.04),
            ),
          ],
        ),
      ),
    );
  }
}
