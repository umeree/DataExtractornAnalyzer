import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/crop_parameters.dart';
import 'dart:math' as math;

/// Custom painter for rendering the crop overlay and image
class CropPainter extends CustomPainter {
  final ui.Image? image;
  final CropParameters params;
  final Size imageSize;
  final bool showGrid;

  CropPainter({
    required this.image,
    required this.params,
    required this.imageSize,
    this.showGrid = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;

    // Save canvas state
    canvas.save();

    // Calculate image display rect (centered and scaled to fit)
    final Rect imageRect = _calculateImageRect(size);

    // Apply transformations
    final Offset center = imageRect.center;
    canvas.translate(center.dx, center.dy);
    canvas.rotate(params.rotation);
    canvas.scale(params.zoom);
    canvas.translate(-center.dx, -center.dy);

    // Draw the image
    paintImage(
      canvas: canvas,
      rect: imageRect,
      image: image!,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    // Restore canvas for overlay
    canvas.restore();

    // Draw crop overlay
    _drawCropOverlay(canvas, size, imageRect);
  }

  /// Calculate the rect where the image should be displayed
  Rect _calculateImageRect(Size canvasSize) {
    final double imageAspect = imageSize.width / imageSize.height;
    final double canvasAspect = canvasSize.width / canvasSize.height;

    double displayWidth, displayHeight;
    if (imageAspect > canvasAspect) {
      // Image is wider
      displayWidth = canvasSize.width;
      displayHeight = canvasSize.width / imageAspect;
    } else {
      // Image is taller
      displayHeight = canvasSize.height;
      displayWidth = canvasSize.height * imageAspect;
    }

    final double left = (canvasSize.width - displayWidth) / 2;
    final double top = (canvasSize.height - displayHeight) / 2;

    return Rect.fromLTWH(left, top, displayWidth, displayHeight);
  }

  /// Draw the crop overlay with dimmed areas and grid
  void _drawCropOverlay(Canvas canvas, Size size, Rect imageRect) {
    // Calculate crop rect in screen coordinates
    final Rect cropRect = _getCropRectInScreenCoords(imageRect);

    // Draw dimmed overlay outside crop area
    final Paint dimPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Top
    canvas.drawRect(
      Rect.fromLTRB(0, 0, size.width, cropRect.top),
      dimPaint,
    );
    // Bottom
    canvas.drawRect(
      Rect.fromLTRB(0, cropRect.bottom, size.width, size.height),
      dimPaint,
    );
    // Left
    canvas.drawRect(
      Rect.fromLTRB(0, cropRect.top, cropRect.left, cropRect.bottom),
      dimPaint,
    );
    // Right
    canvas.drawRect(
      Rect.fromLTRB(cropRect.right, cropRect.top, size.width, cropRect.bottom),
      dimPaint,
    );

    // Draw crop frame
    final Paint framePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(cropRect, framePaint);

    // Draw rule of thirds grid
    if (showGrid) {
      _drawGrid(canvas, cropRect);
    }

    // Draw corner handles
    _drawCornerHandles(canvas, cropRect);
  }

  /// Get crop rectangle in screen coordinates
  Rect _getCropRectInScreenCoords(Rect imageRect) {
    // Scale crop rect from image coordinates to screen coordinates
    final double scaleX = imageRect.width / imageSize.width;
    final double scaleY = imageRect.height / imageSize.height;

    return Rect.fromLTWH(
      imageRect.left + params.cropRect.left * scaleX,
      imageRect.top + params.cropRect.top * scaleY,
      params.cropRect.width * scaleX,
      params.cropRect.height * scaleY,
    );
  }

  /// Draw rule of thirds grid
  void _drawGrid(Canvas canvas, Rect cropRect) {
    final Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Vertical lines
    final double thirdWidth = cropRect.width / 3;
    canvas.drawLine(
      Offset(cropRect.left + thirdWidth, cropRect.top),
      Offset(cropRect.left + thirdWidth, cropRect.bottom),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cropRect.left + thirdWidth * 2, cropRect.top),
      Offset(cropRect.left + thirdWidth * 2, cropRect.bottom),
      gridPaint,
    );

    // Horizontal lines
    final double thirdHeight = cropRect.height / 3;
    canvas.drawLine(
      Offset(cropRect.left, cropRect.top + thirdHeight),
      Offset(cropRect.right, cropRect.top + thirdHeight),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cropRect.left, cropRect.top + thirdHeight * 2),
      Offset(cropRect.right, cropRect.top + thirdHeight * 2),
      gridPaint,
    );
  }

  /// Draw corner handles for visual feedback
  void _drawCornerHandles(Canvas canvas, Rect cropRect) {
    final Paint handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final double handleSize = 20.0;
    final double handleThickness = 3.0;

    // Helper to draw L-shaped corner handle
    void drawCornerHandle(Offset corner, bool isLeft, bool isTop) {
      // Horizontal line
      canvas.drawRect(
        Rect.fromLTWH(
          isLeft ? corner.dx : corner.dx - handleSize,
          corner.dy - handleThickness / 2,
          handleSize,
          handleThickness,
        ),
        handlePaint,
      );
      // Vertical line
      canvas.drawRect(
        Rect.fromLTWH(
          corner.dx - handleThickness / 2,
          isTop ? corner.dy : corner.dy - handleSize,
          handleThickness,
          handleSize,
        ),
        handlePaint,
      );
    }

    // Top-left
    drawCornerHandle(cropRect.topLeft, true, true);
    // Top-right
    drawCornerHandle(cropRect.topRight, false, true);
    // Bottom-left
    drawCornerHandle(cropRect.bottomLeft, true, false);
    // Bottom-right
    drawCornerHandle(cropRect.bottomRight, false, false);
  }

  @override
  bool shouldRepaint(CropPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.params != params ||
        oldDelegate.showGrid != showGrid;
  }
}
