import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pasteboard/pasteboard.dart';

class ClipboardService {
  /// Copies the graph canvas to the system clipboard as a PNG image.
  /// If [cropRect] is provided, only that region will be copied.
  static Future<void> copyGraphToClipboard(
    GlobalKey canvasKey, {
    Rect? cropRect,
  }) async {
    // Get the RenderRepaintBoundary from the key
    final boundary = canvasKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;

    if (boundary == null) {
      throw Exception('Canvas not found');
    }

    // Capture the full canvas at device pixel ratio for high quality
    final pixelRatio = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    final fullImage = await boundary.toImage(pixelRatio: pixelRatio);

    ui.Image finalImage;

    if (cropRect != null && cropRect.width > 0 && cropRect.height > 0) {
      // Normalize the crop rect (handle negative width/height from drag direction)
      final normalizedRect = Rect.fromLTRB(
        cropRect.left < cropRect.right ? cropRect.left : cropRect.right,
        cropRect.top < cropRect.bottom ? cropRect.top : cropRect.bottom,
        cropRect.left < cropRect.right ? cropRect.right : cropRect.left,
        cropRect.top < cropRect.bottom ? cropRect.bottom : cropRect.top,
      );

      // Scale the crop rect by pixel ratio
      final scaledRect = Rect.fromLTRB(
        normalizedRect.left * pixelRatio,
        normalizedRect.top * pixelRatio,
        normalizedRect.right * pixelRatio,
        normalizedRect.bottom * pixelRatio,
      );

      // Clamp to image bounds
      final clampedRect = Rect.fromLTRB(
        scaledRect.left.clamp(0, fullImage.width.toDouble()),
        scaledRect.top.clamp(0, fullImage.height.toDouble()),
        scaledRect.right.clamp(0, fullImage.width.toDouble()),
        scaledRect.bottom.clamp(0, fullImage.height.toDouble()),
      );

      // Crop the image
      finalImage = await _cropImage(fullImage, clampedRect);
    } else {
      // Use the full image
      finalImage = fullImage;
    }

    // Convert to PNG bytes
    final byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Failed to convert image to PNG');
    }

    final pngBytes = byteData.buffer.asUint8List();

    // Copy to clipboard using pasteboard
    await Pasteboard.writeImage(pngBytes);
  }

  /// Crops an image to the specified rectangle.
  static Future<ui.Image> _cropImage(ui.Image source, Rect cropRect) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw the source image, offsetting by the crop rect origin
    canvas.drawImageRect(
      source,
      cropRect,
      Rect.fromLTWH(0, 0, cropRect.width, cropRect.height),
      Paint(),
    );

    final picture = recorder.endRecording();
    return picture.toImage(cropRect.width.toInt(), cropRect.height.toInt());
  }
}
