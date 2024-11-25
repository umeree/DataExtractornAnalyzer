import 'package:dataextractor_analyzer/res/app_colors.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const   CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color = AppColors.primaryColor,
    this.textColor = AppColors.backgroundColor,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
