import 'package:flutter/material.dart';
import '../theme.dart';

/// Elegancki, narysowany liniami manekin - tło "Przymierzalni".
/// Ma tylko sugerować sylwetkę, na której układa się ubrania.
class MannequinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Delikatna poświata za manekinem - dodaje głębi zamiast płaskiego tła.
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [AppColors.primarySoft.withOpacity(0.4), Colors.transparent],
      ).createShader(
        Rect.fromCircle(center: Offset(w * 0.5, h * 0.32), radius: w * 0.6),
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), glowPaint);

    final line = Paint()
      ..color = AppColors.gold.withOpacity(0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = AppColors.primarySoft.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final centerX = w * 0.5;

    // Proporcje sylwetki - wyraźniejsze niż poprzednio, żeby faktycznie
    // czytało się jako kobiecy manekin krawiecki, nie jak lejek.
    final headTop = h * 0.025;
    final headH = h * 0.075;
    final headW = headH * 0.86;
    final neckTop = headTop + headH - h * 0.005; // lekkie zachodzenie na głowę
    final neckBottom = neckTop + h * 0.035;
    final neckTopW = headW * 0.42;
    final neckBottomW = headW * 0.62;

    final shoulderY = neckBottom + h * 0.008;
    final shoulderW = w * 0.29;
    final bustY = shoulderY + h * 0.075;
    final bustW = w * 0.275;
    final waistY = h * 0.445;
    final waistW = w * 0.155;
    final hipY = h * 0.545;
    final hipW = w * 0.235;
    final legEndY = h * 0.93;
    final ankleW = w * 0.042;

    // Głowa (owal).
    final headRect = Rect.fromCenter(
      center: Offset(centerX, headTop + headH / 2),
      width: headW,
      height: headH,
    );
    canvas.drawOval(headRect, fill);
    canvas.drawOval(headRect, line);

    // Szyja - trapezoid ze złagodzonymi krawędziami, nie dwie oddzielne
    // kreski w powietrzu.
    final neck = Path()
      ..moveTo(centerX - neckTopW / 2, neckTop)
      ..lineTo(centerX - neckBottomW / 2, neckBottom)
      ..lineTo(centerX + neckBottomW / 2, neckBottom)
      ..lineTo(centerX + neckTopW / 2, neckTop)
      ..close();
    canvas.drawPath(neck, fill);
    canvas.drawPath(neck, line);

    // Tors - ramiona → biust → talia (wcięcie) → biodra (rozszerzenie),
    // wszystko na gładkich krzywych, żeby sylwetka czytała się jako
    // kobiecy manekin krawiecki, nie geometryczny lejek.
    final torso = Path()
      ..moveTo(centerX - neckBottomW / 2, neckBottom)
      // ramię (lekko zaokrąglone, nie ostry kąt)
      ..quadraticBezierTo(
        centerX - shoulderW / 2, shoulderY - h * 0.01,
        centerX - shoulderW / 2, shoulderY,
      )
      // ramię → biust
      ..quadraticBezierTo(
        centerX - bustW / 2 - w * 0.008, (shoulderY + bustY) / 2,
        centerX - bustW / 2, bustY,
      )
      // biust → talia (wyraźne wcięcie)
      ..quadraticBezierTo(
        centerX - bustW / 2 + w * 0.01, (bustY + waistY) / 2,
        centerX - waistW / 2, waistY,
      )
      // talia → biodro (wyraźne rozszerzenie)
      ..quadraticBezierTo(
        centerX - hipW / 2 + w * 0.01, (waistY + hipY) / 2,
        centerX - hipW / 2, hipY,
      )
      ..lineTo(centerX + hipW / 2, hipY)
      // biodro → talia
      ..quadraticBezierTo(
        centerX + hipW / 2 - w * 0.01, (waistY + hipY) / 2,
        centerX + waistW / 2, waistY,
      )
      // talia → biust
      ..quadraticBezierTo(
        centerX + bustW / 2 - w * 0.01, (bustY + waistY) / 2,
        centerX + bustW / 2, bustY,
      )
      // biust → ramię
      ..quadraticBezierTo(
        centerX + bustW / 2 + w * 0.008, (shoulderY + bustY) / 2,
        centerX + shoulderW / 2, shoulderY,
      )
      ..quadraticBezierTo(
        centerX + shoulderW / 2, shoulderY - h * 0.01,
        centerX + neckBottomW / 2, neckBottom,
      )
      ..close();
    canvas.drawPath(torso, fill);
    canvas.drawPath(torso, line);

    // Nogi (od bioder w dół, delikatnie zwężające się do kostek).
    final legGap = w * 0.012;
    final leftLeg = Path()
      ..moveTo(centerX - hipW / 2 + w * 0.01, hipY)
      ..lineTo(centerX - ankleW - legGap, legEndY)
      ..lineTo(centerX - legGap, legEndY)
      ..lineTo(centerX - legGap, hipY);
    final rightLeg = Path()
      ..moveTo(centerX + hipW / 2 - w * 0.01, hipY)
      ..lineTo(centerX + ankleW + legGap, legEndY)
      ..lineTo(centerX + legGap, legEndY)
      ..lineTo(centerX + legGap, hipY);
    canvas.drawPath(leftLeg, line);
    canvas.drawPath(rightLeg, line);

    // Miękki, rozmyty cień pod stopami zamiast prostej kreski - sugeruje,
    // że manekin "stoi", zamiast płasko wisieć na tle.
    final shadowPaint = Paint()
      ..color = AppColors.ink.withOpacity(0.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final baseY = legEndY + h * 0.02;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX, baseY), width: w * 0.22, height: h * 0.018),
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant MannequinPainter oldDelegate) => false;
}
