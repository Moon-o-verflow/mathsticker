import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app.dart';
import '../providers/equation_provider.dart';
import 'equation_input_widget.dart';

class InputBar extends ConsumerWidget {
  final bool isCompact;

  const InputBar({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(equationsProvider);
    final selectedEquation = state.selectedEquation;
    final selectedColor = selectedEquation?.color ?? AppColors.primary;

    if (isCompact) {
      return _buildCompactLayout(ref, selectedColor, selectedEquation?.id);
    }

    return _buildStandardLayout(ref, selectedColor, selectedEquation?.id);
  }

  /// Standard horizontal layout for portrait mode
  Widget _buildStandardLayout(WidgetRef ref, Color selectedColor, String? selectedId) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Left: Color Picker
              _ColorPicker(
                selectedColor: selectedColor,
                selectedId: selectedId,
                ref: ref,
              ),
              const SizedBox(width: 12),
              // Center: Equation Input
              const Expanded(
                child: EquationInputWidget(),
              ),
              const SizedBox(width: 12),
              // Right: Action buttons
              _ActionButtons(ref: ref),
            ],
          ),
        ),
      ),
    );
  }

  /// Compact vertical layout for landscape mode
  Widget _buildCompactLayout(WidgetRef ref, Color selectedColor, String? selectedId) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.separator, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Top row: Color picker + action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                // Compact color picker
                Expanded(
                  child: _ColorPicker(
                    selectedColor: selectedColor,
                    selectedId: selectedId,
                    ref: ref,
                    size: 22,
                  ),
                ),
                // Action buttons
                _ActionButtons(ref: ref, size: 28),
              ],
            ),
          ),
          // Bottom: Equation list (takes remaining space)
          const Expanded(
            child: EquationInputWidget(),
          ),
        ],
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final Color selectedColor;
  final String? selectedId;
  final WidgetRef ref;
  final double size;

  const _ColorPicker({
    required this.selectedColor,
    required this.selectedId,
    required this.ref,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: equationColors.map((color) {
          final isSelected = color == selectedColor;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () {
                if (selectedId != null) {
                  ref.read(equationsProvider.notifier).updateColor(selectedId!, color);
                }
              },
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
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final WidgetRef ref;
  final double size;

  const _ActionButtons({required this.ref, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: LucideIcons.delete,
          onTap: () => ref.read(equationsProvider.notifier).delete(),
          size: size,
          tooltip: '삭제',
        ),
        const SizedBox(width: 6),
        _ActionButton(
          icon: LucideIcons.eraser,
          onTap: () => ref.read(equationsProvider.notifier).clear(),
          size: size,
          tooltip: '지우기',
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.size,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: size * 0.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
