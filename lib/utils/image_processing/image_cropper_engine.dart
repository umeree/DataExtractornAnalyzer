import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../models/crop_parameters.dart';

/// Core image processing engine for cropping operations
class ImageCropperEngine {
  /// Load image from file and decode it
  static Future<ui.Image> loadImage(File imageFile) async {
    final Uint8List bytes = await imageFile.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  /// Load image with EXIF orientation correction
  static Future<img.Image?> loadImageWithExif(File imageFile) async {
    try {
      final Uint8List bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      
      if (image == null) return null;

      // Auto-orient based on EXIF data
      image = img.bakeOrientation(image);
      
      return image;
    } catch (e) {
      debugPrint('Error loading image with EXIF: $e');
      return null;
    }
  }

  /// Crop image based on crop parameters
  static Future<File?> cropImage({
    required File sourceFile,
    required CropParameters params,
    required Size originalImageSize,
    int quality = 95,
  }) async {
    try {
      // Load image with EXIF correction
      img.Image? image = await loadImageWithExif(sourceFile);
      if (image == null) {
        debugPrint('Failed to load image');
        return null;
      }

      // Apply rotation if needed
      if (params.rotation != 0) {
        final degrees = params.rotationDegrees;
        image = img.copyRotate(image, angle: degrees);
      }

      // Calculate crop rectangle in image coordinates
      final double scaleX = image.width / originalImageSize.width;
      final double scaleY = image.height / originalImageSize.height;

      final int cropX = (params.cropRect.left * scaleX).round().clamp(0, image.width);
      final int cropY = (params.cropRect.top * scaleY).round().clamp(0, image.height);
      final int cropWidth = (params.cropRect.width * scaleX).round().clamp(1, image.width - cropX);
      final int cropHeight = (params.cropRect.height * scaleY).round().clamp(1, image.height - cropY);

      // Perform crop
      img.Image croppedImage = img.copyCrop(
        image,
        x: cropX,
        y: cropY,
        width: cropWidth,
        height: cropHeight,
      );

      // Apply zoom by resizing if zoom > 1
      if (params.zoom > 1.0) {
        final int zoomedWidth = (cropWidth * params.zoom).round();
        final int zoomedHeight = (cropHeight * params.zoom).round();
        
        // Resize to zoomed dimensions
        croppedImage = img.copyResize(
          croppedImage,
          width: zoomedWidth,
          height: zoomedHeight,
          interpolation: img.Interpolation.cubic,
        );
        
        // Crop to original dimensions (center crop)
        final int offsetX = ((zoomedWidth - cropWidth) / 2).round();
        final int offsetY = ((zoomedHeight - cropHeight) / 2).round();
        
        croppedImage = img.copyCrop(
          croppedImage,
          x: offsetX,
          y: offsetY,
          width: cropWidth,
          height: cropHeight,
        );
      }

      // Encode to JPEG with quality preservation
      final List<int> jpeg = img.encodeJpg(croppedImage, quality: quality);

      // Save to temporary file
      final Directory tempDir = await getTemporaryDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final File croppedFile = File('${tempDir.path}/cropped_$timestamp.jpg');
      await croppedFile.writeAsBytes(jpeg);

      return croppedFile;
    } catch (e) {
      debugPrint('Error cropping image: $e');
      return null;
    }
  }

  /// Get image dimensions without fully loading it
  static Future<Size?> getImageSize(File imageFile) async {
    try {
      final ui.Image image = await loadImage(imageFile);
      final Size size = Size(
        image.width.toDouble(),
        image.height.toDouble(),
      );
      image.dispose();
      return size;
    } catch (e) {
      debugPrint('Error getting image size: $e');
      return null;
    }
  }

  /// Create a thumbnail for efficient UI display
  static Future<ui.Image?> createThumbnail(
    File imageFile, {
    int maxWidth = 1200,
    int maxHeight = 1200,
  }) async {
    try {
      final img.Image? image = await loadImageWithExif(imageFile);
      if (image == null) return null;

      // Calculate thumbnail size maintaining aspect ratio
      double scale = 1.0;
      if (image.width > maxWidth || image.height > maxHeight) {
        final double scaleX = maxWidth / image.width;
        final double scaleY = maxHeight / image.height;
        scale = scaleX < scaleY ? scaleX : scaleY;
      }

      final int thumbWidth = (image.width * scale).round();
      final int thumbHeight = (image.height * scale).round();

      // Resize image
      final img.Image thumbnail = img.copyResize(
        image,
        width: thumbWidth,
        height: thumbHeight,
        interpolation: img.Interpolation.cubic,
      );

      // Convert to ui.Image
      final Uint8List bytes = Uint8List.fromList(img.encodeJpg(thumbnail, quality: 90));
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();

      return frameInfo.image;
    } catch (e) {
      debugPrint('Error creating thumbnail: $e');
      return null;
    }
  }

  /// Validate image file
  static Future<bool> validateImage(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        return false;
      }

      final int fileSize = await imageFile.length();
      // Check file size (max 50MB)
      if (fileSize > 50 * 1024 * 1024) {
        debugPrint('Image file too large: ${fileSize / (1024 * 1024)} MB');
        return false;
      }

      // Try to decode image
      final Uint8List bytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(bytes);
      
      return image != null;
    } catch (e) {
      debugPrint('Error validating image: $e');
      return false;
    }
  }
}
