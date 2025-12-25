import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:dataextractor_analyzer/res/app_colors.dart';
import '../utils/models/crop_parameters.dart';
import '../utils/image_processing/image_cropper_engine.dart';
import '../utils/image_processing/crop_painter.dart';
import '../utils/image_processing/gesture_handler.dart';
import '../utils/components/aspect_ratio_selector.dart';
import '../utils/components/zoom_control.dart';
import '../utils/components/rotation_control.dart';

/// Professional image cropper screen with advanced features
class ImageCropperScreen extends StatefulWidget {
  final File imageFile;

  const ImageCropperScreen({
    Key? key,
    required this.imageFile,
  }) : super(key: key);

  @override
  State<ImageCropperScreen> createState() => _ImageCropperScreenState();
}

class _ImageCropperScreenState extends State<ImageCropperScreen> {
  ui.Image? _image;
  Size _imageSize = Size.zero;
  CropParameters? _params;
  CropGestureHandler? _gestureHandler;
  bool _isLoading = true;
  bool _isCropping = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  /// Load and validate image
  Future<void> _loadImage() async {
    try {
      // Validate image
      final bool isValid = await ImageCropperEngine.validateImage(widget.imageFile);
      if (!isValid) {
        setState(() {
          _errorMessage = 'Invalid or corrupted image file';
          _isLoading = false;
        });
        return;
      }

      // Get image size
      final Size? size = await ImageCropperEngine.getImageSize(widget.imageFile);
      if (size == null) {
        setState(() {
          _errorMessage = 'Failed to load image';
          _isLoading = false;
        });
        return;
      }

      // Load image for display
      final ui.Image? image = await ImageCropperEngine.createThumbnail(
        widget.imageFile,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (image == null) {
        setState(() {
          _errorMessage = 'Failed to process image';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _image = image;
        _imageSize = size;
        _isLoading = false;
      });

      // Initialize parameters after first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeCropParameters();
      });
    } catch (e) {
      debugPrint('Error loading image: $e');
      setState(() {
        _errorMessage = 'Error loading image: $e';
        _isLoading = false;
      });
    }
  }

  /// Initialize crop parameters based on viewport size
  void _initializeCropParameters() {
    if (!mounted) return;

    final Size viewportSize = MediaQuery.of(context).size;
    final CropParameters initialParams = CropParameters.initial(
      _imageSize,
      viewportSize,
    );

    setState(() {
      _params = initialParams;
      _gestureHandler = CropGestureHandler(
        imageSize: _imageSize,
        viewportSize: viewportSize,
        initialParams: initialParams,
      );
    });
  }

  /// Handle crop and save
  Future<void> _applyCrop() async {
    if (_params == null || _isCropping) return;

    setState(() {
      _isCropping = true;
    });

    try {
      final File? croppedFile = await ImageCropperEngine.cropImage(
        sourceFile: widget.imageFile,
        params: _params!,
        originalImageSize: _imageSize,
        quality: 95,
      );

      if (croppedFile != null && mounted) {
        Navigator.of(context).pop(croppedFile);
      } else {
        _showError('Failed to crop image');
        setState(() {
          _isCropping = false;
        });
      }
    } catch (e) {
      debugPrint('Error cropping image: $e');
      _showError('Error cropping image: $e');
      setState(() {
        _isCropping = false;
      });
    }
  }

  /// Show error message
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Update crop parameters
  void _updateParams(CropParameters newParams) {
    setState(() {
      _params = newParams;
      _gestureHandler?.updateParams(newParams);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Image',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (!_isLoading && _params != null)
            TextButton(
              onPressed: _isCropping ? null : _applyCrop,
              child: _isCropping
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Apply',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : _params == null
                  ? const SizedBox.shrink()
                  : Column(
                      children: [
                        // Image display area with crop overlay
                        Expanded(
                          child: GestureDetector(
                            onScaleStart: _gestureHandler?.onScaleStart,
                            onScaleUpdate: (details) {
                              final newParams = _gestureHandler?.onScaleUpdate(details);
                              if (newParams != null) {
                                _updateParams(newParams);
                              }
                            },
                            onScaleEnd: _gestureHandler?.onScaleEnd,
                            child: CustomPaint(
                              painter: CropPainter(
                                image: _image,
                                params: _params!,
                                imageSize: _imageSize,
                                showGrid: true,
                              ),
                              size: Size.infinite,
                            ),
                          ),
                        ),
                        // Control panel
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: SafeArea(
                            top: false,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Aspect Ratio Selector
                                  AspectRatioSelector(
                                    selectedRatio: _params!.aspectRatio,
                                    isLocked: _params!.aspectRatioLocked,
                                    onRatioChanged: (ratio) {
                                      final newParams = _gestureHandler?.updateAspectRatio(
                                        ratio,
                                        ratio != AspectRatioPreset.free,
                                      );
                                      if (newParams != null) {
                                        _updateParams(newParams);
                                      }
                                    },
                                    onLockChanged: (locked) {
                                      _updateParams(_params!.copyWith(
                                        aspectRatioLocked: locked,
                                      ));
                                    },
                                  ),
                                  const Divider(color: Colors.white24, height: 24),
                                  // Zoom Control
                                  ZoomControl(
                                    zoom: _params!.zoom,
                                    onZoomChanged: (zoom) {
                                      final newParams = _gestureHandler?.updateZoom(zoom);
                                      if (newParams != null) {
                                        _updateParams(newParams);
                                      }
                                    },
                                  ),
                                  const Divider(color: Colors.white24, height: 24),
                                  // Rotation Control
                                  RotationControl(
                                    rotationDegrees: _params!.rotationDegrees,
                                    onRotationChanged: (degrees) {
                                      final newParams = _gestureHandler?.updateRotation(degrees);
                                      if (newParams != null) {
                                        _updateParams(newParams);
                                      }
                                    },
                                    onRotate90CW: () {
                                      final newParams = _gestureHandler?.rotate90(true);
                                      if (newParams != null) {
                                        _updateParams(newParams);
                                      }
                                    },
                                    onRotate90CCW: () {
                                      final newParams = _gestureHandler?.rotate90(false);
                                      if (newParams != null) {
                                        _updateParams(newParams);
                                      }
                                    },
                                    onReset: () {
                                      final newParams = _gestureHandler?.updateRotation(0);
                                      if (newParams != null) {
                                        _updateParams(newParams);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}
