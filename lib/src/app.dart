import 'package:flutter/material.dart';
import 'features/home/presentation/home_screen.dart';

class MathStickerApp extends StatelessWidget {
  const MathStickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MathSticker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
