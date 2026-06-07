import 'package:flutter/material.dart';

/// Ограничивает содержимое экрана соотношением сторон 9:19 (ширина:высота).
/// Если экран шире (h/w < 19/9) — ужимает ширину, сохраняя высоту.
/// Если экран уже (h/w >= 19/9) — использует полную ширину.
/// Переопределяет MediaQuery.size, чтобы дочерние виджеты работали
/// относительно размеров фрейма, а не полного экрана.
class ScreenFrame extends StatelessWidget {
  const ScreenFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: AspectRatio(
          aspectRatio: 9 / 19,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                ),
                child: child,
              );
            },
          ),
        ),
      ),
    );
  }
}
