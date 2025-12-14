import 'dart:ui';

class CoordinateSystem {
  final Size canvasSize;
  final double scale;
  final Offset offset;

  // Base range (at scale = 1.0)
  static const double baseXMin = -10.0;
  static const double baseXMax = 10.0;

  CoordinateSystem({
    required this.canvasSize,
    this.scale = 1.0,
    this.offset = Offset.zero,
  });

  // Effective range after applying scale and offset
  double get xMin => baseXMin / scale + offset.dx;
  double get xMax => baseXMax / scale + offset.dx;

  double get yMin {
    final aspectRatio = canvasSize.height / canvasSize.width;
    final baseYRange = (baseXMax - baseXMin) * aspectRatio;
    return -baseYRange / 2 / scale + offset.dy;
  }

  double get yMax {
    final aspectRatio = canvasSize.height / canvasSize.width;
    final baseYRange = (baseXMax - baseXMin) * aspectRatio;
    return baseYRange / 2 / scale + offset.dy;
  }

  double get xRange => xMax - xMin;
  double get yRange => yMax - yMin;

  double get scaleX => canvasSize.width / xRange;
  double get scaleY => canvasSize.height / yRange;

  /// Convert math coordinate X to pixel X
  double mathToPixelX(double mathX) {
    return (mathX - xMin) * scaleX;
  }

  /// Convert math coordinate Y to pixel Y (inverted because screen Y grows downward)
  double mathToPixelY(double mathY) {
    return canvasSize.height - (mathY - yMin) * scaleY;
  }

  /// Convert pixel X to math coordinate X
  double pixelToMathX(double pixelX) {
    return xMin + pixelX / scaleX;
  }

  /// Convert pixel Y to math coordinate Y
  double pixelToMathY(double pixelY) {
    return yMin + (canvasSize.height - pixelY) / scaleY;
  }

  /// Convert math point to pixel offset
  Offset mathToPixel(double mathX, double mathY) {
    return Offset(mathToPixelX(mathX), mathToPixelY(mathY));
  }

  /// Convert pixel offset to math point
  ({double x, double y}) pixelToMath(Offset pixel) {
    return (x: pixelToMathX(pixel.dx), y: pixelToMathY(pixel.dy));
  }

  /// Get origin (0, 0) in pixel coordinates
  Offset get originPixel => mathToPixel(0, 0);

  /// Create a new CoordinateSystem with different parameters
  CoordinateSystem copyWith({
    Size? canvasSize,
    double? scale,
    Offset? offset,
  }) {
    return CoordinateSystem(
      canvasSize: canvasSize ?? this.canvasSize,
      scale: scale ?? this.scale,
      offset: offset ?? this.offset,
    );
  }
}
