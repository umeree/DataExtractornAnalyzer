import 'package:flutter/material.dart';

/// Widget for controlling rotation
class RotationControl extends StatelessWidget {
  final double rotationDegrees;
  final ValueChanged<double> onRotationChanged;
  final VoidCallback onRotate90CW;
  final VoidCallback onRotate90CCW;
  final VoidCallback onReset;

  const RotationControl({
    Key? key,
    required this.rotationDegrees,
    required this.onRotationChanged,
    required this.onRotate90CW,
    required this.onRotate90CCW,
    required this.onReset,
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
                'Rotation',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                '${rotationDegrees.toStringAsFixed(0)}°',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Quick rotation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _RotationButton(
                icon: Icons.rotate_left,
                label: '-90°',
                onPressed: onRotate90CCW,
              ),
              _RotationButton(
                icon: Icons.refresh,
                label: 'Reset',
                onPressed: onReset,
              ),
              _RotationButton(
                icon: Icons.rotate_right,
                label: '+90°',
                onPressed: onRotate90CW,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Fine rotation slider
          Row(
            children: [
              const Text(
                '-180°',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
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
                    value: rotationDegrees.clamp(-180.0, 180.0),
                    min: -180,
                    max: 180,
                    onChanged: onRotationChanged,
                  ),
                ),
              ),
              const Text(
                '180°',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Individual rotation button
class _RotationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _RotationButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
