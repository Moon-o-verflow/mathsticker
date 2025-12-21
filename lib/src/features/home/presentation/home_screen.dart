import 'package:flutter/material.dart';
import '../../graph/presentation/graph_canvas.dart';
import '../../input/presentation/equation_list.dart';
import '../../input/presentation/equation_toolbar.dart';
import '../../input/presentation/professional_keyboard.dart';

/// Professional gray background color
const kPanelBackground = Color(0xFFF5F5F7);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.landscape) {
              return _buildLandscapeLayout();
            } else {
              return _buildPortraitLayout();
            }
          },
        ),
      ),
    );
  }

  /// Portrait Mode: Vertical layout
  Widget _buildPortraitLayout() {
    return const Column(
      children: [
        // Graph Canvas (Top 40%)
        Expanded(
          flex: 40,
          child: GraphCanvas(),
        ),
        // Control Panel (Bottom 60%)
        Expanded(
          flex: 60,
          child: _ControlPanel(isCompact: false),
        ),
      ],
    );
  }

  /// Landscape Mode: Horizontal layout
  Widget _buildLandscapeLayout() {
    return const Row(
      children: [
        // Left: Graph Canvas (70%)
        Expanded(
          flex: 7,
          child: GraphCanvas(),
        ),
        // Right: Control Panel (30%)
        Expanded(
          flex: 3,
          child: _ControlPanel(isCompact: true),
        ),
      ],
    );
  }
}

/// Control panel containing equation list, toolbar, and keyboard
class _ControlPanel extends StatelessWidget {
  final bool isCompact;

  const _ControlPanel({required this.isCompact});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPanelBackground,
      child: Column(
        children: [
          // Equation List (Expanded)
          Expanded(
            child: EquationList(isCompact: isCompact),
          ),
          // Toolbar
          EquationToolbar(isCompact: isCompact),
          // Professional Keyboard
          ProfessionalKeyboard(isCompact: isCompact),
        ],
      ),
    );
  }
}
