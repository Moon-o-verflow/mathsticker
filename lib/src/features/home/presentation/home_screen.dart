import 'package:flutter/material.dart';
import '../../graph/presentation/graph_canvas.dart';
import '../../input/presentation/input_bar.dart';
import '../../input/presentation/custom_keyboard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: const [
            // Zone A: Graph Canvas (Top 45%)
            Expanded(
              flex: 45,
              child: GraphCanvas(),
            ),
            // Zone B: Input Bar (Middle 15%)
            Expanded(
              flex: 15,
              child: InputBar(),
            ),
            // Zone C: Custom Keyboard (Bottom 40%)
            Expanded(
              flex: 40,
              child: CustomKeyboard(),
            ),
          ],
        ),
      ),
    );
  }
}
