import 'package:dataextractor_analyzer/res/app_colors.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Center(
            child: CircleAvatar(radius: 50,backgroundColor: AppColors.primaryColor,),
          ),
          Text("Login")
        ],
      ),
    );
  }
}
