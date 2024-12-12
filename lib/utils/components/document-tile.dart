import 'package:dataextractor_analyzer/res/app_colors.dart';
import 'package:flutter/material.dart';

class DocumentTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const DocumentTile({
    Key? key,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.greyColor, size: 40,),
              const SizedBox(width: 5),
              Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            height: 1,
            color: AppColors.greyColor,
          ),
        ],
      ),
    );
  }
}
