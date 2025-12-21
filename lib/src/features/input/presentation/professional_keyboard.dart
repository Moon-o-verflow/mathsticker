import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app.dart';
import '../providers/equation_provider.dart';

/// Professional engineering calculator keyboard
class ProfessionalKeyboard extends ConsumerWidget {
  final bool isCompact;

  const ProfessionalKeyboard({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gap = isCompact ? 4.0 : 6.0;
    final padding = isCompact ? 6.0 : 10.0;
    final keyboardHeight = isCompact ? 220.0 : 300.0;

    return Container(
      height: keyboardHeight,
      padding: EdgeInsets.all(padding),
      decoration: const BoxDecoration(
        color: Color(0xFFE8E8ED),
        border: Border(
          top: BorderSide(color: AppColors.separator, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Row 1: Functions
          _buildRow(ref, [
            _Key('sin', type: KeyType.func),
            _Key('cos', type: KeyType.func),
            _Key('tan', type: KeyType.func),
            _Key('log', type: KeyType.func),
            _Key('ln', type: KeyType.func),
            _Key('abs', type: KeyType.func),
          ], gap, isCompact),
          SizedBox(height: gap),
          // Row 2: Operators & Constants
          _buildRow(ref, [
            _Key('(', type: KeyType.op),
            _Key(')', type: KeyType.op),
            _Key('^', type: KeyType.op),
            _Key('^2', display: 'x²', type: KeyType.op),
            _Key('sqrt', display: '√', type: KeyType.func),
            _Key('/', type: KeyType.op),
          ], gap, isCompact),
          SizedBox(height: gap),
          // Row 3: 7 8 9 * pi e
          _buildRow(ref, [
            _Key('7'),
            _Key('8'),
            _Key('9'),
            _Key('*', display: '×', type: KeyType.op),
            _Key('pi', display: 'π', type: KeyType.const_),
            _Key('e', type: KeyType.const_),
          ], gap, isCompact),
          SizedBox(height: gap),
          // Row 4: 4 5 6 - x y
          _buildRow(ref, [
            _Key('4'),
            _Key('5'),
            _Key('6'),
            _Key('-', type: KeyType.op),
            _Key('x', type: KeyType.variable),
            _Key('y', type: KeyType.variable),
          ], gap, isCompact),
          SizedBox(height: gap),
          // Row 5: 1 2 3 + < >
          _buildRow(ref, [
            _Key('1'),
            _Key('2'),
            _Key('3'),
            _Key('+', type: KeyType.op),
            _Key.icon(LucideIcons.chevronLeft, action: KeyAction.cursorLeft),
            _Key.icon(LucideIcons.chevronRight, action: KeyAction.cursorRight),
          ], gap, isCompact),
          SizedBox(height: gap),
          // Row 6: 0 . = Backspace (2x)
          _buildRow(ref, [
            _Key('0'),
            _Key('.'),
            _Key('=', type: KeyType.op),
            _Key.icon(LucideIcons.delete, action: KeyAction.backspace, flex: 2, type: KeyType.action),
          ], gap, isCompact),
        ],
      ),
    );
  }

  Widget _buildRow(WidgetRef ref, List<_Key> keys, double gap, bool isCompact) {
    final List<Widget> children = [];
    for (int i = 0; i < keys.length; i++) {
      if (i > 0) {
        children.add(SizedBox(width: gap));
      }
      children.add(
        Expanded(
          flex: keys[i].flex,
          child: _KeyButton(
            keyData: keys[i],
            ref: ref,
            isCompact: isCompact,
          ),
        ),
      );
    }
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

enum KeyType { number, op, func, const_, variable, action }
enum KeyAction { none, backspace, cursorLeft, cursorRight, clear }

class _Key {
  final String? value;
  final String? display;
  final IconData? icon;
  final KeyType type;
  final KeyAction action;
  final int flex;

  const _Key(
    this.value, {
    this.display,
    this.type = KeyType.number,
    this.flex = 1,
  })  : icon = null,
        action = KeyAction.none;

  const _Key.icon(
    this.icon, {
    required this.action,
    this.type = KeyType.number,
    this.flex = 1,
  })  : value = null,
        display = null;
}

class _KeyButton extends StatelessWidget {
  final _Key keyData;
  final WidgetRef ref;
  final bool isCompact;

  const _KeyButton({
    required this.keyData,
    required this.ref,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = isCompact ? 15.0 : 18.0;
    final iconSize = isCompact ? 18.0 : 22.0;

    // Determine colors based on key type
    Color bgColor;
    Color textColor;
    FontWeight fontWeight = FontWeight.w500;

    switch (keyData.type) {
      case KeyType.func:
        bgColor = const Color(0xFFF0F4FF);
        textColor = AppColors.primary;
        fontWeight = FontWeight.w600;
        break;
      case KeyType.op:
        bgColor = const Color(0xFFFFF5E6);
        textColor = const Color(0xFFE67E00);
        fontWeight = FontWeight.w600;
        break;
      case KeyType.const_:
        bgColor = const Color(0xFFF0FFF4);
        textColor = const Color(0xFF22863A);
        fontWeight = FontWeight.w600;
        break;
      case KeyType.variable:
        bgColor = const Color(0xFFF5F0FF);
        textColor = const Color(0xFF6F42C1);
        fontWeight = FontWeight.w700;
        break;
      case KeyType.action:
        bgColor = const Color(0xFFFFF0F0);
        textColor = AppColors.error;
        break;
      case KeyType.number:
      default:
        bgColor = Colors.white;
        textColor = AppColors.textPrimary;
        break;
    }

    return Material(
      color: bgColor,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(6),
        splashColor: textColor.withValues(alpha: 0.15),
        highlightColor: textColor.withValues(alpha: 0.08),
        child: Center(
          child: keyData.icon != null
              ? Icon(keyData.icon, size: iconSize, color: textColor)
              : Text(
                  keyData.display ?? keyData.value ?? '',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                    color: textColor,
                  ),
                ),
        ),
      ),
    );
  }

  void _handleTap() {
    final notifier = ref.read(equationsProvider.notifier);

    // Handle special actions
    switch (keyData.action) {
      case KeyAction.backspace:
        notifier.delete();
        return;
      case KeyAction.cursorLeft:
        notifier.moveCursorLeft();
        return;
      case KeyAction.cursorRight:
        notifier.moveCursorRight();
        return;
      case KeyAction.clear:
        notifier.clear();
        return;
      case KeyAction.none:
        break;
    }

    // Handle value insertion
    final value = keyData.value;
    if (value == null) return;

    switch (keyData.type) {
      case KeyType.func:
        // Functions add opening parenthesis
        notifier.insert('$value(');
        break;
      case KeyType.op:
        if (value == '^2') {
          notifier.insert('^2');
        } else {
          notifier.insert(value);
        }
        break;
      default:
        notifier.insert(value);
        break;
    }
  }
}
