import 'package:flutter/material.dart';
import '../models/crop_parameters.dart';

/// Widget for selecting aspect ratio presets
class AspectRatioSelector extends StatelessWidget {
  final AspectRatioPreset selectedRatio;
  final bool isLocked;
  final ValueChanged<AspectRatioPreset> onRatioChanged;
  final ValueChanged<bool> onLockChanged;

  const AspectRatioSelector({
    Key? key,
    required this.selectedRatio,
    required this.isLocked,
    required this.onRatioChanged,
    required this.onLockChanged,
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
                'Aspect Ratio',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              // Lock/Unlock button
              IconButton(
                icon: Icon(
                  isLocked ? Icons.lock : Icons.lock_open,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => onLockChanged(!isLocked),
                tooltip: isLocked ? 'Unlock aspect ratio' : 'Lock aspect ratio',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: AspectRatioPreset.values.map((preset) {
                final bool isSelected = preset == selectedRatio;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _AspectRatioChip(
                    label: preset.label,
                    isSelected: isSelected,
                    onTap: () => onRatioChanged(preset),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual aspect ratio chip
class _AspectRatioChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AspectRatioChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
