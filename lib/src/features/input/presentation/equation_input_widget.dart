import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../providers/equation_provider.dart';

class EquationInputWidget extends ConsumerWidget {
  const EquationInputWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(equationsProvider);
    final equations = state.equations;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Equation list
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: equations.length + 1, // +1 for add button
              itemBuilder: (context, index) {
                if (index == equations.length) {
                  // Add button at the end
                  return _buildAddButton(ref);
                }
                return _buildEquationChip(context, ref, equations[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquationChip(
      BuildContext context, WidgetRef ref, EquationItem equation) {
    final isSelected = equation.isSelected;

    return GestureDetector(
      onTap: () {
        ref.read(equationsProvider.notifier).select(equation.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? equation.color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: equation.color.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color indicator
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: equation.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            // Equation display
            _buildEquationDisplay(equation),
            // Delete button (only show if more than one equation)
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                ref.read(equationsProvider.notifier).remove(equation.id);
              },
              child: Icon(
                Icons.close,
                size: 16,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquationDisplay(EquationItem equation) {
    final expression = equation.expression;
    final cursorPosition = equation.cursorPosition;
    final isSelected = equation.isSelected;

    if (expression.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'y = ',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
          if (isSelected)
            Container(
              width: 2,
              height: 20,
              color: equation.color,
            ),
        ],
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'y = ',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          if (isSelected)
            _buildEquationWithCursor(expression, cursorPosition, equation.color)
          else
            _buildEquationText(expression),
        ],
      ),
    );
  }

  Widget _buildEquationText(String expression) {
    return Math.tex(
      _convertToLatex(expression),
      textStyle: const TextStyle(fontSize: 16),
      onErrorFallback: (error) => Text(
        expression,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildEquationWithCursor(
      String equation, int cursorPosition, Color cursorColor) {
    final before = equation.substring(0, cursorPosition);
    final after = equation.substring(cursorPosition);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (before.isNotEmpty)
          Math.tex(
            _convertToLatex(before),
            textStyle: const TextStyle(fontSize: 16),
            onErrorFallback: (error) => Text(
              before,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        Container(
          width: 2,
          height: 20,
          color: cursorColor,
        ),
        if (after.isNotEmpty)
          Math.tex(
            _convertToLatex(after),
            textStyle: const TextStyle(fontSize: 16),
            onErrorFallback: (error) => Text(
              after,
              style: const TextStyle(fontSize: 16),
            ),
          ),
      ],
    );
  }

  Widget _buildAddButton(WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(equationsProvider.notifier).add();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Icon(
          Icons.add,
          size: 20,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  String _convertToLatex(String input) {
    // Basic conversion for display
    String result = input;
    result = result.replaceAll('*', r'\cdot ');
    result = result.replaceAll('pi', r'\pi ');
    result = result.replaceAll('sqrt(', r'\sqrt{');
    result = result.replaceAll('sin(', r'\sin(');
    result = result.replaceAll('cos(', r'\cos(');
    result = result.replaceAll('tan(', r'\tan(');
    result = result.replaceAll('log(', r'\log(');
    result = result.replaceAll('ln(', r'\ln(');
    return result;
  }
}
