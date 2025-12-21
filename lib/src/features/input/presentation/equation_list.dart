import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app.dart';
import '../../ads/native_ad_widget.dart';
import '../providers/equation_provider.dart';

class EquationList extends ConsumerStatefulWidget {
  final bool isCompact;

  const EquationList({super.key, this.isCompact = false});

  @override
  ConsumerState<EquationList> createState() => _EquationListState();
}

class _EquationListState extends ConsumerState<EquationList> {
  final Map<String, bool> _previousErrorStates = {};

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(equationsProvider);
    final equations = state.equations;

    if (equations.isEmpty) {
      return _buildEmptyState();
    }

    // Calculate ad position: at index 1 if there are 2+ equations, otherwise at the end
    final adIndex = equations.length >= 2 ? 1 : equations.length;
    final totalItems = equations.length + 1; // equations + 1 ad

    return ListView.separated(
      padding: EdgeInsets.all(widget.isCompact ? 8 : 12),
      itemCount: totalItems,
      separatorBuilder: (context, index) => SizedBox(height: widget.isCompact ? 6 : 8),
      itemBuilder: (context, index) {
        // Show ad at the designated position
        if (index == adIndex) {
          return const NativeAdWidget();
        }

        // Adjust equation index based on ad position
        final equationIndex = index < adIndex ? index : index - 1;
        return _buildEquationCard(equations[equationIndex]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.functionSquare,
            size: widget.isCompact ? 32 : 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          SizedBox(height: widget.isCompact ? 8 : 12),
          Text(
            '수식을 추가하세요',
            style: GoogleFonts.inter(
              fontSize: widget.isCompact ? 13 : 15,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: widget.isCompact ? 4 : 6),
          Text(
            '아래 + 버튼을 눌러 시작',
            style: GoogleFonts.inter(
              fontSize: widget.isCompact ? 11 : 12,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquationCard(EquationItem equation) {
    final isSelected = equation.isSelected;
    final hasError = equation.hasError;

    final previousHadError = _previousErrorStates[equation.id] ?? false;
    final isNewError = hasError && !previousHadError;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _previousErrorStates[equation.id] = hasError;
    });

    Widget card = GestureDetector(
      onTap: () {
        ref.read(equationsProvider.notifier).select(equation.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.all(widget.isCompact ? 10 : 14),
        decoration: BoxDecoration(
          color: hasError
              ? AppColors.error.withValues(alpha: 0.06)
              : (isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasError
                ? AppColors.error
                : (isSelected ? equation.color : Colors.transparent),
            width: isSelected || hasError ? 2 : 0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (hasError ? AppColors.error : equation.color)
                        .withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Color indicator
            _buildColorDot(equation, hasError),
            SizedBox(width: widget.isCompact ? 10 : 14),
            // Equation content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildEquationDisplay(equation),
                  if (hasError) ...[
                    SizedBox(height: widget.isCompact ? 4 : 6),
                    _buildErrorMessage(equation.errorText!),
                  ],
                ],
              ),
            ),
            // Delete button
            _buildDeleteButton(equation),
          ],
        ),
      ),
    );

    if (isNewError) {
      card = _ShakeAnimation(
        key: ValueKey('shake_${equation.id}_${DateTime.now().millisecondsSinceEpoch}'),
        child: card,
      );
    }

    return card;
  }

  Widget _buildColorDot(EquationItem equation, bool hasError) {
    final size = widget.isCompact ? 14.0 : 18.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: hasError ? AppColors.error : equation.color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (hasError ? AppColors.error : equation.color)
                .withValues(alpha: 0.3),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: hasError
          ? Icon(
              LucideIcons.alertTriangle,
              size: size * 0.6,
              color: Colors.white,
            )
          : null,
    );
  }

  Widget _buildEquationDisplay(EquationItem equation) {
    final expression = equation.expression;
    final cursorPosition = equation.cursorPosition;
    final isSelected = equation.isSelected;
    final fontSize = widget.isCompact ? 14.0 : 16.0;

    if (expression.isEmpty) {
      return Row(
        children: [
          Text(
            'y = ',
            style: GoogleFonts.jetBrainsMono(
              fontSize: fontSize,
              color: AppColors.textSecondary,
            ),
          ),
          if (isSelected)
            Container(
              width: 2,
              height: fontSize + 4,
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
        children: [
          Text(
            'y = ',
            style: GoogleFonts.jetBrainsMono(
              fontSize: fontSize,
              color: AppColors.textSecondary,
            ),
          ),
          if (isSelected)
            _buildWithCursor(expression, cursorPosition, equation.color, fontSize)
          else
            _buildMathText(expression, fontSize),
        ],
      ),
    );
  }

  Widget _buildMathText(String expression, double fontSize) {
    return Math.tex(
      _convertToLatex(expression),
      textStyle: GoogleFonts.jetBrainsMono(fontSize: fontSize),
      onErrorFallback: (error) => Text(
        expression,
        style: GoogleFonts.jetBrainsMono(fontSize: fontSize),
      ),
    );
  }

  Widget _buildWithCursor(String expression, int cursorPosition, Color cursorColor, double fontSize) {
    final before = expression.substring(0, cursorPosition);
    final after = expression.substring(cursorPosition);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (before.isNotEmpty) _buildMathText(before, fontSize),
        Container(
          width: 2,
          height: fontSize + 4,
          decoration: BoxDecoration(
            color: cursorColor,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        if (after.isNotEmpty) _buildMathText(after, fontSize),
      ],
    );
  }

  Widget _buildErrorMessage(String error) {
    return Row(
      children: [
        Icon(
          LucideIcons.alertCircle,
          size: widget.isCompact ? 11 : 12,
          color: AppColors.error,
        ),
        const SizedBox(width: 4),
        Text(
          error,
          style: GoogleFonts.inter(
            fontSize: widget.isCompact ? 10 : 11,
            color: AppColors.error,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteButton(EquationItem equation) {
    final size = widget.isCompact ? 28.0 : 32.0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref.read(equationsProvider.notifier).remove(equation.id);
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          child: Icon(
            LucideIcons.x,
            size: size * 0.5,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  String _convertToLatex(String input) {
    String result = input;
    result = result.replaceAll('*', r'\cdot ');
    result = result.replaceAll('pi', r'\pi ');
    result = result.replaceAll('sqrt(', r'\sqrt{');
    result = result.replaceAll('abs(', r'|');
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
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -5, end: 5), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 5, end: -3), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -3, end: 3), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 3, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

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
      animation: _animation,
      builder: (context, child) => Transform.translate(
        offset: Offset(_animation.value, 0),
        child: child,
      ),
      child: widget.child,
    );
  }
}
