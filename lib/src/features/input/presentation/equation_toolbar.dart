import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app.dart';
import '../providers/equation_provider.dart';

class EquationToolbar extends ConsumerWidget {
  final bool isCompact;

  const EquationToolbar({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(equationsProvider);
    final selectedEquation = state.selectedEquation;
    final equationCount = state.equations.length;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.separator, width: 0.5),
          bottom: BorderSide(color: AppColors.separator, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Color picker (compact)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: equationColors.map((color) {
                  final isSelected = selectedEquation?.color == color;
                  return _ColorDot(
                    color: color,
                    isSelected: isSelected,
                    size: isCompact ? 22 : 26,
                    onTap: () {
                      if (selectedEquation != null) {
                        ref.read(equationsProvider.notifier)
                            .updateColor(selectedEquation.id, color);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(width: isCompact ? 8 : 12),
          // Equation count
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 8 : 10,
              vertical: isCompact ? 4 : 5,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$equationCount',
              style: GoogleFonts.jetBrainsMono(
                fontSize: isCompact ? 12 : 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: isCompact ? 6 : 8),
          // Add button
          _ToolbarButton(
            icon: LucideIcons.plus,
            tooltip: '수식 추가',
            isCompact: isCompact,
            isPrimary: true,
            onTap: () {
              ref.read(equationsProvider.notifier).add();
            },
          ),
          SizedBox(width: isCompact ? 4 : 6),
          // Clear all button
          _ToolbarButton(
            icon: LucideIcons.trash2,
            tooltip: '전체 삭제',
            isCompact: isCompact,
            isDanger: true,
            onTap: () {
              _showClearConfirmation(context, ref);
            },
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '전체 삭제',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          '모든 수식을 삭제하시겠습니까?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              // Clear all equations and add a new empty one
              final notifier = ref.read(equationsProvider.notifier);
              final equations = ref.read(equationsProvider).equations;
              for (final eq in equations) {
                notifier.remove(eq.id);
              }
              Navigator.pop(context);
            },
            child: Text(
              '삭제',
              style: GoogleFonts.inter(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final double size;
  final VoidCallback onTap;

  const _ColorDot({
    required this.color,
    required this.isSelected,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isCompact;
  final bool isPrimary;
  final bool isDanger;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.isCompact,
    this.isPrimary = false,
    this.isDanger = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = isCompact ? 32.0 : 36.0;
    final iconSize = isCompact ? 16.0 : 18.0;

    Color backgroundColor;
    Color iconColor;

    if (isPrimary) {
      backgroundColor = AppColors.primary;
      iconColor = Colors.white;
    } else if (isDanger) {
      backgroundColor = AppColors.error.withValues(alpha: 0.1);
      iconColor = AppColors.error;
    } else {
      backgroundColor = AppColors.surface;
      iconColor = AppColors.textSecondary;
    }

    return Tooltip(
      message: tooltip,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
        ),
      ),
    );
  }
}
