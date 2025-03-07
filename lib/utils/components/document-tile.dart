import 'package:dataextractor_analyzer/res/app_colors.dart';
import 'package:flutter/material.dart';

class DocumentTile extends StatelessWidget {
  final IconData icon;
  final String text;
  Color color;
  VoidCallback onPress;

 DocumentTile({
    Key? key,
    required this.icon,
    required this.text,
    this.color = AppColors.greyColor,
   required this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 40,),
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
      ),
    );
  }
}
