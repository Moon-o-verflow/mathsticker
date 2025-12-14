import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/graph_state_provider.dart';

class GraphSelectionOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const GraphSelectionOverlay({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<GraphSelectionOverlay> createState() => _GraphSelectionOverlayState();
}

class _GraphSelectionOverlayState extends ConsumerState<GraphSelectionOverlay> {
  Offset? _dragStart;

  @override
  Widget build(BuildContext context) {
    final viewState = ref.watch(viewStateProvider);
    final isSelectionMode = viewState.isSelectionMode;
    final selectionRect = viewState.selectionRect;

    return Stack(
      children: [
        // The graph canvas child
        widget.child,

        // Selection mode overlay
        if (isSelectionMode)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: CustomPaint(
                painter: SelectionPainter(
                  selectionRect: selectionRect,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _onPanStart(DragStartDetails details) {
    _dragStart = details.localPosition;
    ref.read(viewStateProvider.notifier).setSelectionRect(null);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_dragStart != null) {
      ref.read(viewStateProvider.notifier).updateSelectionRect(
            _dragStart!,
            details.localPosition,
          );
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _dragStart = null;
  }
}

class SelectionPainter extends CustomPainter {
  final Rect? selectionRect;

  SelectionPainter({
    this.selectionRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw dimmed background if there's a selection
    if (selectionRect != null && selectionRect!.width > 0 && selectionRect!.height > 0) {
      final normalizedRect = Rect.fromLTRB(
        selectionRect!.left.clamp(0, size.width),
        selectionRect!.top.clamp(0, size.height),
        selectionRect!.right.clamp(0, size.width),
        selectionRect!.bottom.clamp(0, size.height),
      );

      // Draw dimmed overlay outside selection
      final dimPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill;

      // Top region
      canvas.drawRect(
        Rect.fromLTRB(0, 0, size.width, normalizedRect.top),
        dimPaint,
      );

      // Bottom region
      canvas.drawRect(
        Rect.fromLTRB(0, normalizedRect.bottom, size.width, size.height),
        dimPaint,
      );

      // Left region
      canvas.drawRect(
        Rect.fromLTRB(0, normalizedRect.top, normalizedRect.left, normalizedRect.bottom),
        dimPaint,
      );

      // Right region
      canvas.drawRect(
        Rect.fromLTRB(normalizedRect.right, normalizedRect.top, size.width, normalizedRect.bottom),
        dimPaint,
      );

      // Draw selection border
      final borderPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawRect(normalizedRect, borderPaint);

      // Draw corner handles
      final handlePaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;

      const handleSize = 10.0;

      // Top-left
      canvas.drawRect(
        Rect.fromCenter(
          center: normalizedRect.topLeft,
          width: handleSize,
          height: handleSize,
        ),
        handlePaint,
      );

      // Top-right
      canvas.drawRect(
        Rect.fromCenter(
          center: normalizedRect.topRight,
          width: handleSize,
          height: handleSize,
        ),
        handlePaint,
      );

      // Bottom-left
      canvas.drawRect(
        Rect.fromCenter(
          center: normalizedRect.bottomLeft,
          width: handleSize,
          height: handleSize,
        ),
        handlePaint,
      );

      // Bottom-right
      canvas.drawRect(
        Rect.fromCenter(
          center: normalizedRect.bottomRight,
          width: handleSize,
          height: handleSize,
        ),
        handlePaint,
      );
    } else {
      // When no selection yet, show a subtle hint overlay
      final hintPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.1)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        hintPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SelectionPainter oldDelegate) {
    return oldDelegate.selectionRect != selectionRect;
  }
}
