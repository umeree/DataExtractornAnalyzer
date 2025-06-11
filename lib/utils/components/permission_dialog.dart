import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> checkPermissionAndShowDialog({
  required BuildContext context,
  required Permission permission,
  required String title,
  required String message,
  String? positiveButtonText,
  VoidCallback? onPositivePressed,
}) async {
  final status = await permission.status;

  if (status.isDenied || status.isPermanentlyDenied) {
    if (Platform.isIOS) {
      await showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: Text(positiveButtonText ?? 'Open Settings'),
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
                if (onPositivePressed != null) onPositivePressed();
              },
            ),
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } else {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text(positiveButtonText ?? 'Open Settings'),
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
                if (onPositivePressed != null) onPositivePressed();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }
}
