import 'package:dataextractor_analyzer/res/app_colors.dart';
import 'package:flutter/material.dart';

class HomeButtons extends StatefulWidget {
  final IconData icon; // Dynamic icon
  final String iconName; // Dynamic icon name

  // Constructor
  const HomeButtons({super.key, required this.icon, required this.iconName});

  @override
  State<HomeButtons> createState() => _HomeButtonsState();
}

class _HomeButtonsState extends State<HomeButtons> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 2, color: AppColors.primaryColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.sectionsColor.withOpacity(0.5), // Shadow color with opacity
            spreadRadius: 5, // Spread radius
            blurRadius: 7, // Blur radius
            offset: Offset(0, 3), // Changes the position of the shadow (x, y)
          ),
        ],
      ),
      child: Icon(
        widget.icon, // Use the dynamic icon
        size: 60,
        color: AppColors.primaryColor,
      ),
    );
  }
}
