import 'package:dataextractor_analyzer/res/app_colors.dart';
import 'package:dataextractor_analyzer/view/data_storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingTile extends StatelessWidget {
  final String settingText;
  bool top;
  bool bottom;
  SettingTile({super.key, required this.settingText,  this.top = true,  this.bottom = true});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return InkWell(
      onTap: () async{
        debugPrint("$settingText clicked");

        switch (settingText) {
          case "Data Storage": {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (context, animation, secondaryAnimation) => const DataStorage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0); // Starts from the right
                  const end = Offset.zero; // Ends at normal position
                  const curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          }
          case "Privacy Policy" : {

              final Uri url = Uri.parse('https://dataextractor.vercel.app/');
              if (!await launchUrl(url)) {
                throw Exception('Could not launch $url');
              }
            // Navigator.push(
            //   context,
            //   PageRouteBuilder(
            //     transitionDuration: const Duration(milliseconds: 300),
            //     pageBuilder: (context, animation, secondaryAnimation) => const DataStorage(),
            //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
            //       const begin = Offset(1.0, 0.0); // Starts from the right
            //       const end = Offset.zero; // Ends at normal position
            //       const curve = Curves.easeInOut;
            //
            //       var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            //
            //       return SlideTransition(
            //         position: animation.drive(tween),
            //         child: child,
            //       );
            //     },
            //   ),
            // );
          }
        }

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
