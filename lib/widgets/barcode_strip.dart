import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';

/// Dekoracyjny kod kreskowy - wygląd metki sklepowej. Wzór jest
/// deterministyczny (ten sam dla danego ubrania za każdym razem), ale nie
/// koduje żadnej realnej informacji ani nie da się go zeskanować.
class BarcodeStrip extends StatelessWidget {
  final String seed;
  final double height;

  const BarcodeStrip({super.key, required this.seed, this.height = 26});

  String get _fakeCode {
    final n = seed.hashCode.abs().toString().padLeft(12, '0');
    return n.substring(0, 12);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(painter: _BarcodePainter(seed)),
        ),
        const SizedBox(height: 2),
        Text(
          _fakeCode,
          style: monoFont(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.inkSoft, letterSpacing: 1.5),
        ),
      ],
    );
  }
}

class _BarcodePainter extends CustomPainter {
  final String seed;
  _BarcodePainter(this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(seed.hashCode);
    final paint = Paint()..color = AppColors.ink;
    double x = 0;
    while (x < size.width) {
      final barWidth = (1 + rnd.nextInt(3)).toDouble();
      final isBar = rnd.nextDouble() > 0.42;
      if (isBar) {
        canvas.drawRect(Rect.fromLTWH(x, 0, barWidth, size.height), paint);
      }
      x += barWidth;
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodePainter oldDelegate) =>
      oldDelegate.seed != seed;
}
