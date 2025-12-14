import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../input/providers/equation_provider.dart';
import '../providers/graph_state_provider.dart';
import 'graph_painter.dart';

class GraphCanvas extends ConsumerStatefulWidget {
  const GraphCanvas({super.key});

  @override
  ConsumerState<GraphCanvas> createState() => _GraphCanvasState();
}

class _GraphCanvasState extends ConsumerState<GraphCanvas> {
  double _previousScale = 1.0;
  Offset _previousOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final equationsState = ref.watch(equationsProvider);
    final viewState = ref.watch(viewStateProvider);

    // Convert EquationItem list to EquationData list for the painter
    final equationDataList = equationsState.equations
        .map((eq) => EquationData(
              expression: eq.expression,
              color: eq.color,
            ))
        .toList();

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          return GestureDetector(
            onScaleStart: (details) {
              _previousScale = viewState.scale;
              _previousOffset = viewState.offset;
            },
            onScaleUpdate: (details) {
              final viewNotifier = ref.read(viewStateProvider.notifier);

              // Handle zoom
              if (details.scale != 1.0) {
                final newScale = (_previousScale * details.scale).clamp(0.1, 10.0);

                // Calculate focal point in math coordinates for zoom centering
                final focalPixel = details.localFocalPoint;
                final baseCoords = CoordinateSystemHelper.create(
                  size: size,
                  scale: _previousScale,
                  offset: _previousOffset,
                );

                final focalMath = baseCoords.pixelToMath(focalPixel);

                // Calculate new offset to keep focal point stationary
                final scaleFactor = newScale / _previousScale;
                final newOffsetX = focalMath.x - (focalMath.x - _previousOffset.dx) / scaleFactor;
                final newOffsetY = focalMath.y - (focalMath.y - _previousOffset.dy) / scaleFactor;

                viewNotifier.updateScaleAndOffset(
                  scale: newScale,
                  offset: Offset(newOffsetX, newOffsetY),
                );
              }

              // Handle pan
              if (details.scale == 1.0) {
                final panDelta = details.focalPointDelta;
                final currentCoords = CoordinateSystemHelper.create(
                  size: size,
                  scale: viewState.scale,
                  offset: viewState.offset,
                );

                // Convert pixel delta to math delta
                final mathDeltaX = -panDelta.dx / currentCoords.scaleX;
                final mathDeltaY = panDelta.dy / currentCoords.scaleY;

                viewNotifier.setOffset(
                  viewState.offset + Offset(mathDeltaX, mathDeltaY),
                );
              }
            },
            child: RepaintBoundary(
              child: CustomPaint(
                painter: GraphPainter(
                  equations: equationDataList,
                  strokeWidth: 2.0,
                  showGrid: viewState.showGrid,
                  scale: viewState.scale,
                  offset: viewState.offset,
                ),
                size: Size.infinite,
              ),
            ),
          );
        },
      ),
    );
  }
}

// Helper class to create CoordinateSystem without importing it directly
class CoordinateSystemHelper {
  static _TempCoords create({
    required Size size,
    required double scale,
    required Offset offset,
  }) {
    return _TempCoords(size: size, scale: scale, offset: offset);
  }
}

class _TempCoords {
  final Size size;
  final double scale;
  final Offset offset;

  static const double baseXMin = -10.0;
  static const double baseXMax = 10.0;

  _TempCoords({
    required this.size,
    required this.scale,
    required this.offset,
  });

  double get xMin => baseXMin / scale + offset.dx;
  double get xMax => baseXMax / scale + offset.dx;
  double get xRange => xMax - xMin;
  double get scaleX => size.width / xRange;

  double get yMin {
    final aspectRatio = size.height / size.width;
    final baseYRange = (baseXMax - baseXMin) * aspectRatio;
    return -baseYRange / 2 / scale + offset.dy;
  }

  double get yMax {
    final aspectRatio = size.height / size.width;
    final baseYRange = (baseXMax - baseXMin) * aspectRatio;
    return baseYRange / 2 / scale + offset.dy;
  }

  double get yRange => yMax - yMin;
  double get scaleY => size.height / yRange;

  ({double x, double y}) pixelToMath(Offset pixel) {
    final mathX = xMin + pixel.dx / scaleX;
    final mathY = yMin + (size.height - pixel.dy) / scaleY;
    return (x: mathX, y: mathY);
  }
}
