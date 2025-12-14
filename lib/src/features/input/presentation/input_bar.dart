import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/equation_provider.dart';
import 'equation_input_widget.dart';

class InputBar extends ConsumerWidget {
  const InputBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(equationsProvider);
    final selectedEquation = state.selectedEquation;
    final selectedColor = selectedEquation?.color ?? Colors.black;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Color Picker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: equationColors.map((color) {
                return _buildColorButton(
                  ref,
                  color,
                  color == selectedColor,
                  selectedEquation?.id,
                );
              }).toList(),
            ),
          ),
          // Center: Equation Input
          const Expanded(
            child: EquationInputWidget(),
          ),
          // Right: Backspace / Clear buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _buildActionButton(
                  icon: LucideIcons.delete,
                  onTap: () => ref.read(equationsProvider.notifier).delete(),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: LucideIcons.x,
                  onTap: () => ref.read(equationsProvider.notifier).clear(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton(
    WidgetRef ref,
    Color color,
    bool isSelected,
    String? selectedId,
  ) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: GestureDetector(
        onTap: () {
          if (selectedId != null) {
            ref.read(equationsProvider.notifier).updateColor(selectedId, color);
          }
        },
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(color: Colors.blue, width: 3)
                : Border.all(color: Colors.grey[300]!, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: Colors.grey[700]),
        ),
      ),
    );
  }
}
