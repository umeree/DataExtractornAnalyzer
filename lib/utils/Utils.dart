import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
class Utils {

  void showSuccessFlushbar(BuildContext context, String pdfPath) {
    Flushbar(
      message: "PDF saved successfully!\nLocation: $pdfPath",
      icon: const Icon(Icons.check_circle, color: Colors.green),
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      backgroundColor: Colors.green.shade700,
      flushbarPosition: FlushbarPosition.TOP,
      mainButton: TextButton(
        onPressed: () {
          OpenFilex.open(pdfPath);
        },
        child: const Text(
          "OPEN",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    ).show(context);
  }

}