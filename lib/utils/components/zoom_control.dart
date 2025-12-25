import 'package:flutter/material.dart';

/// Widget for controlling zoom level
class ZoomControl extends StatelessWidget {
  final double zoom;
  final ValueChanged<double> onZoomChanged;
  final double minZoom;
  final double maxZoom;

  const ZoomControl({
    Key? key,
    required this.zoom,
    required this.onZoomChanged,
    this.minZoom = 1.0,
    this.maxZoom = 3.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                'Zoom',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                '${(zoom * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Zoom out button
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                onPressed: zoom > minZoom
                    ? () => onZoomChanged((zoom - 0.1).clamp(minZoom, maxZoom))
                    : null,
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              // Zoom slider
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white.withOpacity(0.3),
                    thumbColor: Colors.white,
                    overlayColor: Colors.white.withOpacity(0.2),
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                  ),
                  child: Slider(
                    value: zoom,
                    min: minZoom,
                    max: maxZoom,
                    onChanged: onZoomChanged,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Zoom in button
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                onPressed: zoom < maxZoom
                    ? () => onZoomChanged((zoom + 0.1).clamp(minZoom, maxZoom))
                    : null,
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
