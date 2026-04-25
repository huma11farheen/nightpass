import 'package:flutter/material.dart';

class DashedLine extends StatelessWidget {
  final Color color;
  final double strokeWidth;
  final double gapWidth;
  final double height;

  const DashedLine({super.key, 
    this.color = Colors.black,
    this.strokeWidth = 1.0,
    this.gapWidth = 4.0,
    this.height = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedLinePainter(
        color: color,
        strokeWidth: strokeWidth,
        gapWidth: gapWidth,
      ),
      size: Size(double.infinity, height),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gapWidth;

  _DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.gapWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    final dashSpace = gapWidth;

    double startX = 0.0;

    while (startX < size.width) {
      canvas.drawPath(
        Path()
          ..moveTo(startX, 0.0)
          ..lineTo(startX + dashWidth, 0.0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) {
    return color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        gapWidth != oldDelegate.gapWidth;
  }
}
