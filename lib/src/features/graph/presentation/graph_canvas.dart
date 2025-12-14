import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../input/providers/equation_provider.dart';
import '../../export/clipboard_service.dart';
import '../providers/graph_state_provider.dart';
import 'graph_painter.dart';
import 'selection_overlay.dart' show GraphSelectionOverlay;

// GlobalKey to access the canvas for image capture
final graphCanvasKey = GlobalKey();

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
    final isSelectionMode = viewState.isSelectionMode;

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

          return Stack(
            children: [
              // Main canvas with gesture detection (when not in selection mode)
              GraphSelectionOverlay(
                child: GestureDetector(
                  onScaleStart: isSelectionMode
                      ? null
                      : (details) {
                          _previousScale = viewState.scale;
                          _previousOffset = viewState.offset;
                        },
                  onScaleUpdate: isSelectionMode
                      ? null
                      : (details) {
                          final viewNotifier = ref.read(viewStateProvider.notifier);

                          // Handle zoom
                          if (details.scale != 1.0) {
                            final newScale =
                                (_previousScale * details.scale).clamp(0.1, 10.0);

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
                            final newOffsetX = focalMath.x -
                                (focalMath.x - _previousOffset.dx) / scaleFactor;
                            final newOffsetY = focalMath.y -
                                (focalMath.y - _previousOffset.dy) / scaleFactor;

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
                    key: graphCanvasKey,
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
                ),
              ),

              // Control buttons overlay
              _buildControlButtons(context, viewState, size),
            ],
          );
        },
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context, ViewState viewState, Size canvasSize) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: Stack(
          children: [
            // Top-left: Grid toggle button
            Positioned(
              top: 12,
              left: 12,
              child: _CanvasButton(
                icon: viewState.showGrid ? LucideIcons.grid : LucideIcons.square,
                tooltip: viewState.showGrid ? '격자 숨기기' : '격자 표시',
                onTap: () => ref.read(viewStateProvider.notifier).toggleGrid(),
              ),
            ),

            // Top-right: Selection mode toggle (scissors) and Copy button
            Positioned(
              top: 12,
              right: 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CanvasButton(
                    icon: LucideIcons.scissors,
                    tooltip: viewState.isSelectionMode ? '선택 모드 해제' : '영역 선택',
                    isActive: viewState.isSelectionMode,
                    onTap: () => ref.read(viewStateProvider.notifier).toggleSelectionMode(),
                  ),
                  const SizedBox(width: 8),
                  _CanvasButton(
                    icon: LucideIcons.copy,
                    tooltip: '클립보드에 복사',
                    onTap: () => _copyToClipboard(context, canvasSize),
                  ),
                ],
              ),
            ),

            // Bottom-right: Reset view button
            Positioned(
              bottom: 12,
              right: 12,
              child: _CanvasButton(
                icon: LucideIcons.home,
                tooltip: '원점 복귀',
                onTap: () => ref.read(viewStateProvider.notifier).reset(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyToClipboard(BuildContext context, Size canvasSize) async {
    final viewState = ref.read(viewStateProvider);
    final selectionRect = viewState.selectionRect;

    try {
      await ClipboardService.copyGraphToClipboard(
        graphCanvasKey,
        cropRect: selectionRect,
      );

      // Exit selection mode after copying
      if (viewState.isSelectionMode) {
        ref.read(viewStateProvider.notifier).setSelectionMode(false);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('스티커 복사 완료!'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('복사 실패: $e'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _CanvasButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isActive;

  const _CanvasButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? Colors.blue : Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 20,
              color: isActive ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
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
