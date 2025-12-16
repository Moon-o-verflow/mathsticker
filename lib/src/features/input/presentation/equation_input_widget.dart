import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../providers/equation_provider.dart';

class EquationInputWidget extends ConsumerStatefulWidget {
  const EquationInputWidget({super.key});

  @override
  ConsumerState<EquationInputWidget> createState() =>
      _EquationInputWidgetState();
}

class _EquationInputWidgetState extends ConsumerState<EquationInputWidget> {
  // Track previous error states for animation
  final Map<String, bool> _previousErrorStates = {};

  @override
  Widget build(BuildContext context) {
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
    final hasError = equation.hasError;

    // Check if this is a new error (for animation trigger)
    final previousHadError = _previousErrorStates[equation.id] ?? false;
    final isNewError = hasError && !previousHadError;

    // Update error state tracking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _previousErrorStates[equation.id] = hasError;
    });

    // Determine border color based on error state
    Color borderColor;
    if (hasError) {
      borderColor = Colors.red;
    } else if (isSelected) {
      borderColor = equation.color;
    } else {
      borderColor = Colors.grey[300]!;
    }

    Widget chipContent = Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasError
            ? Colors.red.withValues(alpha: 0.08)
            : (isSelected ? Colors.white : Colors.grey[100]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: (isSelected || hasError) ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: (hasError ? Colors.red : equation.color)
                      .withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Color indicator (with error warning)
          _buildColorIndicator(equation, hasError),
          const SizedBox(width: 8),
          // Equation display
          _buildEquationDisplay(equation),
          // Delete button
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
    );

    // Wrap with shake animation if there's a new error
    if (isNewError) {
      chipContent = _ShakeAnimation(
        key: ValueKey('shake_${equation.id}_${DateTime.now().millisecondsSinceEpoch}'),
        child: chipContent,
      );
    }

    return GestureDetector(
      onTap: () {
        ref.read(equationsProvider.notifier).select(equation.id);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          chipContent,
          // Error message - always show for equations with errors
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 12,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    equation.errorText!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildColorIndicator(EquationItem equation, bool hasError) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: hasError ? 16 : 12,
      height: hasError ? 16 : 12,
      decoration: BoxDecoration(
        color: hasError ? Colors.red : equation.color,
        shape: BoxShape.circle,
        boxShadow: hasError
            ? [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: hasError
          ? const Icon(Icons.priority_high, size: 12, color: Colors.white)
          : null,
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

/// Shake animation widget for error feedback
class _ShakeAnimation extends StatefulWidget {
  final Widget child;

  const _ShakeAnimation({super.key, required this.child});

  @override
  State<_ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<_ShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _offsetAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: -3), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -3, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_offsetAnimation.value, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
