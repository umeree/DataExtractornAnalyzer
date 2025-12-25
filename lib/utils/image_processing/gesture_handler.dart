import 'package:flutter/material.dart';
import '../models/crop_parameters.dart';

/// Handles all gesture interactions for the crop interface
class CropGestureHandler {
  final Size imageSize;
  final Size viewportSize;
  CropParameters _params;

  // Gesture state
  Offset? _lastFocalPoint;
  double _initialZoom = 1.0;
  double _initialRotation = 0.0;

  CropGestureHandler({
    required this.imageSize,
    required this.viewportSize,
    required CropParameters initialParams,
  }) : _params = initialParams;

  CropParameters get params => _params;

  /// Update parameters
  void updateParams(CropParameters newParams) {
    _params = newParams;
  }

  /// Handle scale start (handles both pan and pinch-to-zoom)
  void onScaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.focalPoint;
    _initialZoom = _params.zoom;
    _initialRotation = _params.rotation;
  }

  /// Handle scale update (handles pan, pinch-to-zoom, and rotation)
  CropParameters onScaleUpdate(ScaleUpdateDetails details) {
    CropParameters updatedParams = _params;

    // Detect if this is a pan (single finger) or pinch/rotate (multi-finger)
    // When pointerCount is 1, it's a pan gesture
    // When scale is very close to 1.0, it's likely just panning
    final bool isPanning = details.pointerCount == 1 || 
                          (details.scale - 1.0).abs() < 0.05;

    if (_lastFocalPoint != null) {
      final Offset delta = details.focalPoint - _lastFocalPoint!;
      
      // Always handle panning when there's movement
      if (isPanning && delta.distance > 0.5) {
        // Convert screen delta to image coordinates
        final double scaleX = imageSize.width / viewportSize.width;
        final double scaleY = imageSize.height / viewportSize.height;

        final Offset imageDelta = Offset(
          delta.dx * scaleX,
          delta.dy * scaleY,
        );

        // Move crop rect
        Rect newCropRect = _params.cropRect.shift(imageDelta);
        newCropRect = _constrainCropRect(newCropRect);
        
        updatedParams = updatedParams.copyWith(cropRect: newCropRect);
      }
    }

    // Only update zoom and rotation if it's a multi-finger gesture
    if (!isPanning) {
      // Update zoom (when scale changes significantly)
      double newZoom = (_initialZoom * details.scale).clamp(1.0, 3.0);

      // Update rotation (two-finger rotation)
      double newRotation = _initialRotation + details.rotation;

      updatedParams = updatedParams.copyWith(
        zoom: newZoom,
        rotation: newRotation,
      );
    }

    // Always update focal point for next calculation
    _lastFocalPoint = details.focalPoint;

    return updatedParams;
  }

  /// Handle scale end
  void onScaleEnd(ScaleEndDetails details) {
    // Reset gesture state
    _lastFocalPoint = null;
    _initialZoom = _params.zoom;
    _initialRotation = _params.rotation;
  }

  /// Update zoom from slider
  CropParameters updateZoom(double zoom) {
    return _params.copyWith(zoom: zoom.clamp(1.0, 3.0));
  }

  /// Update rotation from slider (in degrees)
  CropParameters updateRotation(double degrees) {
    final double radians = degrees * 3.14159265359 / 180;
    return _params.copyWith(rotation: radians);
  }

  /// Rotate by 90 degrees
  CropParameters rotate90(bool clockwise) {
    final double currentDegrees = _params.rotationDegrees;
    final double newDegrees = clockwise 
        ? currentDegrees + 90 
        : currentDegrees - 90;
    return updateRotation(newDegrees);
  }

  /// Update aspect ratio
  CropParameters updateAspectRatio(
    AspectRatioPreset aspectRatio,
    bool locked,
  ) {
    if (aspectRatio == AspectRatioPreset.free) {
      return _params.copyWith(
        aspectRatio: aspectRatio,
        aspectRatioLocked: false,
      );
    }

    // Adjust crop rect to match aspect ratio
    Rect newCropRect = _params.cropRect;
    final double? targetRatio = aspectRatio.ratio;

    if (targetRatio != null) {
      final double currentRatio = newCropRect.width / newCropRect.height;

      if (currentRatio > targetRatio) {
        // Too wide, reduce width
        final double newWidth = newCropRect.height * targetRatio;
        final double widthDiff = newCropRect.width - newWidth;
        newCropRect = Rect.fromLTWH(
          newCropRect.left + widthDiff / 2,
          newCropRect.top,
          newWidth,
          newCropRect.height,
        );
      } else {
        // Too tall, reduce height
        final double newHeight = newCropRect.width / targetRatio;
        final double heightDiff = newCropRect.height - newHeight;
        newCropRect = Rect.fromLTWH(
          newCropRect.left,
          newCropRect.top + heightDiff / 2,
          newCropRect.width,
          newHeight,
        );
      }

      // Constrain to image bounds
      newCropRect = _constrainCropRect(newCropRect);
    }

    return _params.copyWith(
      cropRect: newCropRect,
      aspectRatio: aspectRatio,
      aspectRatioLocked: locked,
    );
  }

  /// Constrain crop rect to image bounds
  Rect _constrainCropRect(Rect rect) {
    double left = rect.left.clamp(0.0, imageSize.width - rect.width);
    double top = rect.top.clamp(0.0, imageSize.height - rect.height);
    double width = rect.width.clamp(50.0, imageSize.width);
    double height = rect.height.clamp(50.0, imageSize.height);

    // Ensure rect fits within image
    if (left + width > imageSize.width) {
      left = imageSize.width - width;
    }
    if (top + height > imageSize.height) {
      top = imageSize.height - height;
    }

    return Rect.fromLTWH(left, top, width, height);
  }

  /// Reset to initial state
  CropParameters reset() {
    return CropParameters.initial(imageSize, viewportSize);
  }
}
