import 'package:dataextractor_analyzer/res/app_colors.dart';
import 'package:flutter/material.dart';

class SettingTile extends StatelessWidget {
  final String settingText;
  bool top;
  bool bottom;
  SettingTile({super.key, required this.settingText,  this.top = true,  this.bottom = true});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return InkWell(
      onTap: () {
        debugPrint("$settingText clicked");
      },
      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: size.width * .05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(top)Container(
              width: size.width * .9,
              height: 2,
              color: AppColors.greyColor,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              child: Text(
                settingText,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
            ),
            if(bottom)Container(
              width: MediaQuery.sizeOf(context).width * .9,
              height: 2,
              color: AppColors.greyColor,
            ),
          ],
        ),
      ),
    );
  }
}
