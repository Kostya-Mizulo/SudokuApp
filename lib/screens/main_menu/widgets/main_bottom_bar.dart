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
          padding: const EdgeInsets.symmetric(vertical: 8),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 7.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 2.6),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
