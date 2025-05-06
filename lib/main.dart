import 'dart:ui';

import 'package:dataextractor_analyzer/utils/providers/provider.dart';
import 'package:dataextractor_analyzer/view/home.dart';
import 'package:dataextractor_analyzer/view/spalash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
        providers: providers,
        child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,

        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold), // Large headings
          displayLarge : TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold), // Medium headings
          displayMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal), // Standard body text
          displaySmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal), // Smaller body text
          labelMedium: TextStyle(fontSize: 12.0, color: Colors.grey),
          headlineMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),// Captions
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

