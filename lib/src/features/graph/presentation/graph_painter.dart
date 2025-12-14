import 'package:flutter/material.dart';
import 'package:function_tree/function_tree.dart';
import '../logic/coordinate_system.dart';

class EquationData {
  final String expression;
  final Color color;

  const EquationData({
    required this.expression,
    required this.color,
  });
}

class GraphPainter extends CustomPainter {
  final List<EquationData> equations;
  final double strokeWidth;
  final bool showGrid;
  final double scale;
  final Offset offset;

  GraphPainter({
    required this.equations,
    this.strokeWidth = 2.0,
    this.showGrid = true,
    this.scale = 1.0,
    this.offset = Offset.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    final coords = CoordinateSystem(
      canvasSize: size,
      scale: scale,
      offset: offset,
    );

    // Draw grid first (behind everything)
    if (showGrid) {
      _drawGrid(canvas, size, coords);
    }

    // Draw axes
    _drawAxes(canvas, size, coords);

    // Draw all graphs
    for (final eq in equations) {
      if (eq.expression.isNotEmpty) {
        _drawGraph(canvas, size, coords, eq.expression, eq.color);
      }
    }
  }

  void _drawGrid(Canvas canvas, Size size, CoordinateSystem coords) {
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 1.0;

    // Vertical grid lines
    for (int x = coords.xMin.ceil(); x <= coords.xMax.floor(); x++) {
      final pixelX = coords.mathToPixelX(x.toDouble());
      canvas.drawLine(
        Offset(pixelX, 0),
        Offset(pixelX, size.height),
        gridPaint,
      );
    }

    // Horizontal grid lines
    for (int y = coords.yMin.ceil(); y <= coords.yMax.floor(); y++) {
      final pixelY = coords.mathToPixelY(y.toDouble());
      canvas.drawLine(
        Offset(0, pixelY),
        Offset(size.width, pixelY),
        gridPaint,
      );
    }
  }

  void _drawAxes(Canvas canvas, Size size, CoordinateSystem coords) {
    final axisPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.5)
      ..strokeWidth = 1.5;

    final origin = coords.originPixel;

    // X axis
    if (origin.dy >= 0 && origin.dy <= size.height) {
      canvas.drawLine(
        Offset(0, origin.dy),
        Offset(size.width, origin.dy),
        axisPaint,
      );
    }

    // Y axis
    if (origin.dx >= 0 && origin.dx <= size.width) {
      canvas.drawLine(
        Offset(origin.dx, 0),
        Offset(origin.dx, size.height),
        axisPaint,
      );
    }

    // Draw tick marks and labels
    _drawTickMarks(canvas, size, coords);
  }

  void _drawTickMarks(Canvas canvas, Size size, CoordinateSystem coords) {
    final tickPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.6)
      ..strokeWidth = 1.0;

    final textStyle = TextStyle(
      color: Colors.grey[600],
      fontSize: 10,
    );

    final origin = coords.originPixel;

    // X axis ticks
    for (int x = coords.xMin.ceil(); x <= coords.xMax.floor(); x++) {
      if (x == 0) continue;
      final pixelX = coords.mathToPixelX(x.toDouble());
      final tickY = origin.dy.clamp(10.0, size.height - 10);

      canvas.drawLine(
        Offset(pixelX, tickY - 5),
        Offset(pixelX, tickY + 5),
        tickPaint,
      );

      // Label
      final textSpan = TextSpan(text: '$x', style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pixelX - textPainter.width / 2, tickY + 8),
      );
    }

    // Y axis ticks
    for (int y = coords.yMin.ceil(); y <= coords.yMax.floor(); y++) {
      if (y == 0) continue;
      final pixelY = coords.mathToPixelY(y.toDouble());
      final tickX = origin.dx.clamp(10.0, size.width - 10);

      canvas.drawLine(
        Offset(tickX - 5, pixelY),
        Offset(tickX + 5, pixelY),
        tickPaint,
      );

      // Label
      final textSpan = TextSpan(text: '$y', style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(tickX + 8, pixelY - textPainter.height / 2),
      );
    }
  }

  void _drawGraph(Canvas canvas, Size size, CoordinateSystem coords,
      String equation, Color color) {
    final graphPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Try to parse the equation
    SingleVariableFunction? func;
    try {
      func = equation.toSingleVariableFunction();
    } catch (e) {
      // Invalid equation, don't draw anything
      return;
    }

    final path = Path();
    bool isFirstPoint = true;
    bool wasDiscontinuous = false;
    double? prevMathY;

    // Clamp value for drawing lines that go off-screen
    const double clampValue = 5000.0;

    // Threshold for detecting steep slopes (potential asymptotes)
    final slopeThreshold = coords.yRange * 2;

    // Iterate through each pixel column (finer sampling for accuracy)
    for (double pixelX = 0; pixelX <= size.width; pixelX += 0.5) {
      final mathX = coords.pixelToMathX(pixelX);

      double mathY;
      try {
        mathY = func(mathX).toDouble();
      } catch (e) {
        // Error calculating y (e.g., log of negative number)
        wasDiscontinuous = true;
        prevMathY = null;
        continue;
      }

      // Check 1: NaN - always break the path
      if (mathY.isNaN) {
        wasDiscontinuous = true;
        prevMathY = null;
        continue;
      }

      // Check 2: Infinity - always break the path
      if (mathY.isInfinite) {
        wasDiscontinuous = true;
        prevMathY = null;
        continue;
      }

      // Check 3: Sign change with large jump = discontinuity (like tan at pi/2)
      // Only break if signs are DIFFERENT (y1 * y2 < 0)
      if (prevMathY != null) {
        final deltaY = (mathY - prevMathY).abs();
        final signChanged = prevMathY * mathY < 0; // Different signs

        if (signChanged && deltaY > slopeThreshold) {
          // True discontinuity: sign reversal with big jump
          wasDiscontinuous = true;
          prevMathY = mathY;
          continue;
        }
        // If signs are the same, DON'T break - just clamp and draw
      }

      // Clamp y value to reasonable range for drawing
      final clampedMathY = mathY.clamp(-clampValue, clampValue);
      final pixelY = coords.mathToPixelY(clampedMathY);

      if (isFirstPoint || wasDiscontinuous) {
        path.moveTo(pixelX, pixelY);
        isFirstPoint = false;
        wasDiscontinuous = false;
      } else {
        path.lineTo(pixelX, pixelY);
      }

      prevMathY = mathY;
    }

    canvas.drawPath(path, graphPaint);
  }

  @override
  bool shouldRepaint(covariant GraphPainter oldDelegate) {
    if (oldDelegate.equations.length != equations.length ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.showGrid != showGrid ||
        oldDelegate.scale != scale ||
        oldDelegate.offset != offset) {
      return true;
    }

    for (int i = 0; i < equations.length; i++) {
      if (oldDelegate.equations[i].expression != equations[i].expression ||
          oldDelegate.equations[i].color != equations[i].color) {
        return true;
      }
    }

    return false;
  }
}
