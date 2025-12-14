import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/equation_provider.dart';

class CustomKeyboard extends ConsumerWidget {
  const CustomKeyboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.grey[100],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Panel (Flex 2): Basic keys
          Expanded(
            flex: 2,
            child: _LeftPanel(ref: ref),
          ),
          // Right Panel (Flex 1): Function keys
          Expanded(
            flex: 1,
            child: _RightPanel(ref: ref),
          ),
        ],
      ),
    );
  }
}

class _LeftPanel extends StatelessWidget {
  final WidgetRef ref;

  const _LeftPanel({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          // Row 1: 7, 8, 9, /, <, >
          Expanded(
            child: Row(
              children: [
                _buildKey('7'),
                _buildKey('8'),
                _buildKey('9'),
                _buildKey('/'),
                _buildIconKey(LucideIcons.chevronLeft, _moveCursorLeft),
                _buildIconKey(LucideIcons.chevronRight, _moveCursorRight),
              ],
            ),
          ),
          // Row 2: 4, 5, 6, *, (, )
          Expanded(
            child: Row(
              children: [
                _buildKey('4'),
                _buildKey('5'),
                _buildKey('6'),
                _buildKey('*'),
                _buildKey('('),
                _buildKey(')'),
              ],
            ),
          ),
          // Row 3: 1, 2, 3, -, x, y
          Expanded(
            child: Row(
              children: [
                _buildKey('1'),
                _buildKey('2'),
                _buildKey('3'),
                _buildKey('-'),
                _buildKey('x'),
                _buildKey('y'),
              ],
            ),
          ),
          // Row 4: 0, ., =, +, Backspace (wide)
          Expanded(
            child: Row(
              children: [
                _buildKey('0'),
                _buildKey('.'),
                _buildKey('='),
                _buildKey('+'),
                Expanded(
                  flex: 2,
                  child: _buildIconKeyWithFlex(
                    LucideIcons.delete,
                    _backspace,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: ElevatedButton(
          onPressed: () => _onKeyPressed(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey[800],
            elevation: 2,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconKey(IconData icon, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey[700],
            elevation: 2,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }

  Widget _buildIconKeyWithFlex(IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[50],
          foregroundColor: Colors.orange[800],
          elevation: 2,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Icon(icon, size: 22),
      ),
    );
  }

  void _onKeyPressed(String key) {
    ref.read(equationsProvider.notifier).insert(key);
  }

  void _moveCursorLeft() {
    ref.read(equationsProvider.notifier).moveCursorLeft();
  }

  void _moveCursorRight() {
    ref.read(equationsProvider.notifier).moveCursorRight();
  }

  void _backspace() {
    ref.read(equationsProvider.notifier).delete();
  }
}

class _RightPanel extends StatelessWidget {
  final WidgetRef ref;

  const _RightPanel({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue[50],
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          // Row 1: sin, cos
          Expanded(
            child: Row(
              children: [
                _buildFuncKey('sin'),
                _buildFuncKey('cos'),
              ],
            ),
          ),
          // Row 2: tan, log
          Expanded(
            child: Row(
              children: [
                _buildFuncKey('tan'),
                _buildFuncKey('log'),
              ],
            ),
          ),
          // Row 3: ln, sqrt
          Expanded(
            child: Row(
              children: [
                _buildFuncKey('ln'),
                _buildFuncKey('sqrt'),
              ],
            ),
          ),
          // Row 4: ^, pi, e
          Expanded(
            child: Row(
              children: [
                _buildKey('^'),
                _buildKey('pi'),
                _buildKey('e'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuncKey(String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: ElevatedButton(
          onPressed: () => _onFuncPressed(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue[700],
            elevation: 2,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKey(String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: ElevatedButton(
          onPressed: () => _onKeyPressed(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue[700],
            elevation: 2,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _onFuncPressed(String func) {
    ref.read(equationsProvider.notifier).insert('$func(');
  }

  void _onKeyPressed(String key) {
    ref.read(equationsProvider.notifier).insert(key);
  }
}
