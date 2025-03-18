import 'package:flutter/material.dart';

import '../../res/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onLeadingPressed;
  final VoidCallback? onHomePressed;
  final VoidCallback? onSettingsPressed;
  final bool action;

  const CustomAppBar({
    Key? key,
    this.onLeadingPressed,
    this.onHomePressed,
    this.onSettingsPressed,
    this.action = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      leading: IconButton(
        icon: const Icon(Icons.home_filled,  size: 30, color: AppColors.primaryColor,), // Left-side icon
        onPressed: onLeadingPressed,
      ),
      actions: [
        action ?  IconButton(
          icon: const Icon(Icons.menu_outlined,  size: 30, color: AppColors.primaryColor,), // Home icon
          onPressed: onSettingsPressed,
        ):const SizedBox(),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
