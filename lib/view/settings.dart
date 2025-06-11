import 'package:dataextractor_analyzer/utils/components/setting_tile.dart';
import 'package:flutter/material.dart';

import '../res/app_colors.dart';
import '../utils/components/custom_app_bar.dart';
import 'home.dart';

class Settings extends StatefulWidget {
  Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        onLeadingPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Settings",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          SettingTile(settingText: "Data Storage",),
          SettingTile(settingText: "Privacy Policy",top: false,),
          // SettingTile(settingText: "Profile", top: false,),
          // SettingTile(settingText: "Help and Support", top: false,)
        ],
      ),
    );
  }
}
