import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app.dart';
import '../providers/equation_provider.dart';

class CustomKeyboard extends ConsumerWidget {
  final bool isCompact;

  const CustomKeyboard({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.separator, width: 0.5),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 300;

          return Padding(
            padding: EdgeInsets.all(isCompact || isNarrow ? 4 : 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Panel (Flex 2): Basic keys
                Expanded(
                  flex: 2,
                  child: _LeftPanel(
                    ref: ref,
                    isCompact: isCompact || isNarrow,
                  ),
                ),
                SizedBox(width: isCompact || isNarrow ? 4 : 8),
                // Right Panel (Flex 1): Function keys
                Expanded(
                  flex: 1,
                  child: _RightPanel(
                    ref: ref,
                    isCompact: isCompact || isNarrow,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LeftPanel extends StatelessWidget {
  final WidgetRef ref;
  final bool isCompact;

  const _LeftPanel({required this.ref, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    final gap = isCompact ? 3.0 : 6.0;

    return Column(
      children: [
        // Row 1: 7, 8, 9, /, <, >
        Expanded(
          child: Row(
            children: [
              _KeyButton(label: '7', onTap: () => _insert('7'), isCompact: isCompact),
              SizedBox(width: gap),
              _KeyButton(label: '8', onTap: () => _insert('8'), isCompact: isCompact),
              SizedBox(width: gap),
              _KeyButton(label: '9', onTap: () => _insert('9'), isCompact: isCompact),
              SizedBox(width: gap),
              _KeyButton(label: '/', onTap: () => _insert('/'), isCompact: isCompact),
              SizedBox(width: gap),
              _KeyButton(
                icon: LucideIcons.chevronLeft,
                onTap: () => ref.read(equationsProvider.notifier).moveCursorLeft(),
                isCompact: isCompact,
              ),
              SizedBox(width: gap),
              _KeyButton(
                icon: LucideIcons.chevronRight,
                onTap: () => ref.read(equationsProvider.notifier).moveCursorRight(),
                isCompact: isCompact,
              ),
            ],
          ),
        ),
        SizedBox(height: gap),
        // Row 2: 4, 5, 6, *, (, )
        Expanded(
          child: Row(
            children: [
              _KeyButton(label: '4', onTap: () => _insert('4'), isCompact: isCompact),
              SizedBox(width: gap),
              _KeyButton(label: '5', onTap: () => _insert('5'), isCompact: isCompact),
              SizedBox(width: gap),
              _KeyButton(label: '6', onTap: () => _insert('6'), isCompact: isCompact),
              SizedBox(width: gap),
              _KeyButton(label: '*', onTap: () => _insert('*'), isCompact: isCompact),
              SizedBox(width: gap),
              _KeyButton(label: '(', onTap: () => _insert('('), isCompact: isCompact),
              SizedBox(width: gap),
              _KeyButton(label: ')', onTap: () => _insert(')'), isCompact: isCompact),
            ],
          ),
        ),
        SizedBox(height: gap),
        // Row 3: 1, 2, 3, -, x, y
        Expanded(
          child: Row(
            children: [
              _KeyButton(label: '1', onTap: () => _insert('1'), isCompact: isCompact),
              SizedBox(width: gap),
              _KeyButton(label: '2', onTap: () => _insert('2'), isCompact: isCompact),
              SizedBox(width: gap),
              _KeyButton(label: '3', onTap: () => _insert('3'), isCompact: isCompact),
              SizedBox(width: gap),
              _KeyButton(label: '-', onTap: () => _insert('-'), isCompact: isCompact),
              SizedBox(width: gap),
              _KeyButton(
                label: 'x',
                onTap: () => _insert('x'),
                isCompact: isCompact,
                isVariable: true,
              ),
              SizedBox(width: gap),
              _KeyButton(
                label: 'y',
                onTap: () => _insert('y'),
                isCompact: isCompact,
                isVariable: true,
              ),
            ],
          ),
        ),
        SizedBox(height: gap),
        // Row 4: 0, ., =, +, Backspace (wide)
        Expanded(
          child: Row(
            children: [
              _KeyButton(label: '0', onTap: () => _insert('0'), isCompact: isCompact),
              SizedBox(width: gap),
              _KeyButton(label: '.', onTap: () => _insert('.'), isCompact: isCompact),
              SizedBox(width: gap),
              _KeyButton(label: '=', onTap: () => _insert('='), isCompact: isCompact),
              SizedBox(width: gap),
              _KeyButton(label: '+', onTap: () => _insert('+'), isCompact: isCompact),
              SizedBox(width: gap),
              Expanded(
                flex: 2,
                child: _KeyButton(
                  icon: LucideIcons.delete,
                  onTap: () => ref.read(equationsProvider.notifier).delete(),
                  isCompact: isCompact,
                  isAction: true,
                  expanded: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _insert(String text) {
    ref.read(equationsProvider.notifier).insert(text);
  }
}

class _RightPanel extends StatelessWidget {
  final WidgetRef ref;
  final bool isCompact;

  const _RightPanel({required this.ref, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    final gap = isCompact ? 3.0 : 6.0;

    return Container(
      padding: EdgeInsets.all(isCompact ? 4 : 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Row 1: sin, cos
          Expanded(
            child: Row(
              children: [
                _FuncButton(label: 'sin', onTap: () => _insertFunc('sin'), isCompact: isCompact),
                SizedBox(width: gap),
                _FuncButton(label: 'cos', onTap: () => _insertFunc('cos'), isCompact: isCompact),
              ],
            ),
          ),
          SizedBox(height: gap),
          // Row 2: tan, log
          Expanded(
            child: Row(
              children: [
                _FuncButton(label: 'tan', onTap: () => _insertFunc('tan'), isCompact: isCompact),
                SizedBox(width: gap),
                _FuncButton(label: 'log', onTap: () => _insertFunc('log'), isCompact: isCompact),
              ],
            ),
          ),
          SizedBox(height: gap),
          // Row 3: ln, sqrt
          Expanded(
            child: Row(
              children: [
                _FuncButton(label: 'ln', onTap: () => _insertFunc('ln'), isCompact: isCompact),
                SizedBox(width: gap),
                _FuncButton(label: 'sqrt', onTap: () => _insertFunc('sqrt'), isCompact: isCompact),
              ],
            ),
          ),
          SizedBox(height: gap),
          // Row 4: ^, pi, e
          Expanded(
            child: Row(
              children: [
                _FuncButton(label: '^', onTap: () => _insert('^'), isCompact: isCompact),
                SizedBox(width: gap),
                _FuncButton(label: 'pi', onTap: () => _insert('pi'), isCompact: isCompact, isSymbol: true),
                SizedBox(width: gap),
                _FuncButton(label: 'e', onTap: () => _insert('e'), isCompact: isCompact, isSymbol: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _insert(String text) {
    ref.read(equationsProvider.notifier).insert(text);
  }

  void _insertFunc(String func) {
    ref.read(equationsProvider.notifier).insert('$func(');
  }
}

/// Standard key button (numbers, operators)
class _KeyButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isCompact;
  final bool isVariable;
  final bool isAction;
  final bool expanded;

  const _KeyButton({
    this.label,
    this.icon,
    required this.onTap,
    this.isCompact = false,
    this.isVariable = false,
    this.isAction = false,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: isAction
          ? AppColors.error.withValues(alpha: 0.1)
          : (isVariable ? AppColors.primary.withValues(alpha: 0.1) : Colors.white),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: isAction
            ? AppColors.error.withValues(alpha: 0.2)
            : AppColors.primary.withValues(alpha: 0.2),
        highlightColor: isAction
            ? AppColors.error.withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: icon != null
                ? Icon(
                    icon,
                    size: isCompact ? 18 : 22,
                    color: isAction ? AppColors.error : AppColors.textPrimary,
                  )
                : FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        label ?? '',
                        style: GoogleFonts.inter(
                          fontSize: isCompact ? 16 : 20,
                          fontWeight: FontWeight.w500,
                          color: isVariable ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );

    return expanded ? Expanded(child: button) : button;
  }
}

/// Function key button (sin, cos, etc.)
class _FuncButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isCompact;
  final bool isSymbol;

  const _FuncButton({
    required this.label,
    required this.onTap,
    this.isCompact = false,
    this.isSymbol = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          splashColor: AppColors.primary.withValues(alpha: 0.2),
          highlightColor: AppColors.primary.withValues(alpha: 0.1),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    isSymbol ? _getSymbol(label) : label,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: isCompact ? 12 : 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getSymbol(String label) {
    switch (label) {
      case 'pi':
        return 'π';
      default:
        return label;
    }
  }
}
