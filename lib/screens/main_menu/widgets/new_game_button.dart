import 'package:flutter/material.dart';

/// Кнопка «Новая игра» — пилюльная форма, белый фон,
/// рамка: цвет темы у внутренней границы, плавно испаряется наружу.
class NewGameButton extends StatelessWidget {
  const NewGameButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  static const double _borderRadius = 50;
  static const double _borderWidth = 8;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onPressed,
      child: CustomPaint(
        painter: _FadingBorderPainter(
          color: primary,
          borderWidth: _borderWidth,
          radius: _borderRadius,
        ),
        child: Container(
          margin: const EdgeInsets.all(_borderWidth),
          padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_borderRadius - _borderWidth),
          ),
          child: Text(
            'Новая игра',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.5,
              color: primary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Рисует рамку: [color] у внутренней границы, затухает наружу (BlurStyle.outer).
class _FadingBorderPainter extends CustomPainter {
  const _FadingBorderPainter({
    required this.color,
    required this.borderWidth,
    required this.radius,
  });

  final Color color;
  final double borderWidth;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final outerRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final outerRRect =
        RRect.fromRectAndRadius(outerRect, Radius.circular(radius));
    final innerRect = outerRect.deflate(borderWidth);
    final innerRRect = RRect.fromRectAndRadius(
        innerRect, Radius.circular(radius - borderWidth));

    // Клип: рисуем только в полосе рамки.
    final borderPath = Path()
      ..addRRect(outerRRect)
      ..addRRect(innerRRect)
      ..fillType = PathFillType.evenOdd;

    canvas.save();
    canvas.clipPath(borderPath);

    // BlurStyle.outer распространяет гауссово затухание строго наружу от
    // внутренней границы кнопки — это даёт эффект «испарения» по всему периметру.
    canvas.drawRRect(
      innerRRect,
      Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.outer, borderWidth / 3),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_FadingBorderPainter old) =>
      old.color != color ||
      old.borderWidth != borderWidth ||
      old.radius != radius;
}
