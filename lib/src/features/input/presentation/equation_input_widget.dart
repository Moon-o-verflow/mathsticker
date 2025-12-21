import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app.dart';
import '../providers/equation_provider.dart';

class EquationInputWidget extends ConsumerStatefulWidget {
  const EquationInputWidget({super.key});

  @override
  ConsumerState<EquationInputWidget> createState() =>
      _EquationInputWidgetState();
}

class _EquationInputWidgetState extends ConsumerState<EquationInputWidget> {
  final Map<String, bool> _previousErrorStates = {};

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(equationsProvider);
    final equations = state.equations;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: equations.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == equations.length) {
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

    final previousHadError = _previousErrorStates[equation.id] ?? false;
    final isNewError = hasError && !previousHadError;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _previousErrorStates[equation.id] = hasError;
    });

    Widget chipContent = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: hasError
            ? AppColors.error.withValues(alpha: 0.06)
            : (isSelected ? Colors.white : AppColors.surfaceLight),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasError
              ? AppColors.error
              : (isSelected ? equation.color : AppColors.separator),
          width: isSelected || hasError ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: (hasError ? AppColors.error : equation.color)
                      .withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildColorIndicator(equation, hasError),
          const SizedBox(width: 10),
          _buildEquationDisplay(equation),
          const SizedBox(width: 8),
          _buildDeleteButton(equation, ref),
        ],
      ),
    );

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
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(left: 14, top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.alertCircle,
                    size: 12,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    equation.errorText!,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.error,
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
      width: hasError ? 18 : 14,
      height: hasError ? 18 : 14,
      decoration: BoxDecoration(
        color: hasError ? AppColors.error : equation.color,
        shape: BoxShape.circle,
        boxShadow: hasError
            ? [
                BoxShadow(
                  color: AppColors.error.withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: hasError
          ? const Icon(LucideIcons.alertTriangle, size: 10, color: Colors.white)
          : null,
    );
  }

  Widget _buildDeleteButton(EquationItem equation, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref.read(equationsProvider.notifier).remove(equation.id);
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(
            LucideIcons.x,
            size: 14,
            color: AppColors.textSecondary,
          ),
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
            style: GoogleFonts.jetBrainsMono(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          if (isSelected)
            Container(
              width: 2,
              height: 18,
              decoration: BoxDecoration(
                color: equation.color,
                borderRadius: BorderRadius.circular(1),
              ),
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
            style: GoogleFonts.jetBrainsMono(
              fontSize: 15,
              color: AppColors.textSecondary,
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
      textStyle: GoogleFonts.jetBrainsMono(fontSize: 15),
      onErrorFallback: (error) => Text(
        expression,
        style: GoogleFonts.jetBrainsMono(fontSize: 15),
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
            textStyle: GoogleFonts.jetBrainsMono(fontSize: 15),
            onErrorFallback: (error) => Text(
              before,
              style: GoogleFonts.jetBrainsMono(fontSize: 15),
            ),
          ),
        Container(
          width: 2,
          height: 18,
          decoration: BoxDecoration(
            color: cursorColor,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        if (after.isNotEmpty)
          Math.tex(
            _convertToLatex(after),
            textStyle: GoogleFonts.jetBrainsMono(fontSize: 15),
            onErrorFallback: (error) => Text(
              after,
              style: GoogleFonts.jetBrainsMono(fontSize: 15),
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
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.separator),
        ),
        child: Icon(
          LucideIcons.plus,
          size: 18,
          color: AppColors.textSecondary,
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
      TweenSequenceItem(tween: Tween(begin: 0, end: -6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: -4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4, end: 4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4, end: -2), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -2, end: 0), weight: 1),
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
