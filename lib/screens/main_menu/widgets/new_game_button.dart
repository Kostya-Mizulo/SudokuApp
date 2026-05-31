import 'package:flutter/material.dart';

/// Кнопка «Новая игра» — пилюльная форма, белый фон,
/// узкая градиентная рамка изнутри (цвет темы) наружу (цвет фона экрана).
class NewGameButton extends StatelessWidget {
  const NewGameButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  static const double _borderRadius = 50;
  static const double _borderWidth = 2;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;

    return GestureDetector(
      onTap: onPressed,
      child: CustomPaint(
        painter: _GradientBorderPainter(
          innerColor: primary,
          outerColor: bgColor,
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

/// Рисует градиентную рамку: изнутри [innerColor] → снаружи [outerColor].
class _GradientBorderPainter extends CustomPainter {
  const _GradientBorderPainter({
    required this.innerColor,
    required this.outerColor,
    required this.borderWidth,
    required this.radius,
  });

  final Color innerColor;
  final Color outerColor;
  final double borderWidth;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final outerRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final outerRRect =
        RRect.fromRectAndRadius(outerRect, Radius.circular(radius));

    final innerRect = outerRect.deflate(borderWidth);
    final innerRRect =
        RRect.fromRectAndRadius(innerRect, Radius.circular(radius - borderWidth));

    final path = Path()
      ..addRRect(outerRRect)
      ..addRRect(innerRRect)
      ..fillType = PathFillType.evenOdd;

    // Позиция стопа = доля высоты, занимаемая шириной рамки.
    // Это позволяет рамке показывать innerColor прямо у края внутреннего контейнера.
    final stop = borderWidth / size.height;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [outerColor, innerColor, innerColor, outerColor],
        stops: [0.0, stop, 1.0 - stop, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(outerRect);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_GradientBorderPainter old) =>
      old.innerColor != innerColor ||
      old.outerColor != outerColor ||
      old.borderWidth != borderWidth ||
      old.radius != radius;
}
