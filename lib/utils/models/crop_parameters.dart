import 'dart:ui';

/// Aspect ratio presets for image cropping
enum AspectRatioPreset {
  free,
  square,    // 1:1
  ratio4x3,  // 4:3
  ratio16x9, // 16:9
}

/// Extension to get aspect ratio value from preset
extension AspectRatioPresetExtension on AspectRatioPreset {
  double? get ratio {
    switch (this) {
      case AspectRatioPreset.free:
        return null;
      case AspectRatioPreset.square:
        return 1.0;
      case AspectRatioPreset.ratio4x3:
        return 4.0 / 3.0;
      case AspectRatioPreset.ratio16x9:
        return 16.0 / 9.0;
    }
  }

  String get label {
    switch (this) {
      case AspectRatioPreset.free:
        return 'Free';
      case AspectRatioPreset.square:
        return '1:1';
      case AspectRatioPreset.ratio4x3:
        return '4:3';
      case AspectRatioPreset.ratio16x9:
        return '16:9';
    }
  }
}

/// Immutable data class representing all crop parameters
class CropParameters {
  final Rect cropRect;
  final double zoom;
  final double rotation; // in radians
  final AspectRatioPreset aspectRatio;
  final bool aspectRatioLocked;
  final Offset imageOffset;

  const CropParameters({
    required this.cropRect,
    this.zoom = 1.0,
    this.rotation = 0.0,
    this.aspectRatio = AspectRatioPreset.free,
    this.aspectRatioLocked = false,
    this.imageOffset = Offset.zero,
  });

  /// Create initial crop parameters from image size
  factory CropParameters.initial(Size imageSize, Size viewportSize) {
    // Start with the full image selected
    // This allows users to crop the entire image or adjust the crop box as needed
    final Rect cropRect = Rect.fromLTWH(
      0,
      0,
      imageSize.width,
      imageSize.height,
    );

    return CropParameters(
      cropRect: cropRect,
      zoom: 1.0,
      rotation: 0.0,
      aspectRatio: AspectRatioPreset.free,
      aspectRatioLocked: false,
      imageOffset: Offset.zero,
    );
  }

  /// Copy with method for immutable updates
  CropParameters copyWith({
    Rect? cropRect,
    double? zoom,
    double? rotation,
    AspectRatioPreset? aspectRatio,
    bool? aspectRatioLocked,
    Offset? imageOffset,
  }) {
    return CropParameters(
      cropRect: cropRect ?? this.cropRect,
      zoom: zoom ?? this.zoom,
      rotation: rotation ?? this.rotation,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      aspectRatioLocked: aspectRatioLocked ?? this.aspectRatioLocked,
      imageOffset: imageOffset ?? this.imageOffset,
    );
  }

  /// Get rotation in degrees
  double get rotationDegrees => rotation * 180 / 3.14159265359;

  /// Set rotation from degrees
  CropParameters withRotationDegrees(double degrees) {
    return copyWith(rotation: degrees * 3.14159265359 / 180);
  }

  @override
  String toString() {
    return 'CropParameters(cropRect: $cropRect, zoom: $zoom, '
        'rotation: ${rotationDegrees.toStringAsFixed(1)}°, '
        'aspectRatio: ${aspectRatio.label}, locked: $aspectRatioLocked)';
  }
}
