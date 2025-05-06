import 'package:dataextractor_analyzer/res/app_colors.dart';
import 'package:dataextractor_analyzer/view/home.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/icons/data_extarct_icons.png", width: 80, height: 80,),
            Text("Data Extractor", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: AppColors.backgroundColor),)
          ],
        ),
      ),
    );
  }
}
