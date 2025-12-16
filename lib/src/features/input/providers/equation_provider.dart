import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:function_tree/function_tree.dart';

// Default colors for equations
const List<Color> equationColors = [
  Colors.black,
  Colors.blue,
  Colors.red,
  Colors.green,
  Colors.purple,
  Colors.orange,
];

class EquationItem {
  final String id;
  final String expression;
  final Color color;
  final bool isSelected;
  final int cursorPosition;
  final String? errorText;

  const EquationItem({
    required this.id,
    this.expression = '',
    this.color = Colors.black,
    this.isSelected = false,
    this.cursorPosition = 0,
    this.errorText,
  });

  bool get hasError => errorText != null;
  bool get isValid => errorText == null && expression.isNotEmpty;

  EquationItem copyWith({
    String? id,
    String? expression,
    Color? color,
    bool? isSelected,
    int? cursorPosition,
    String? errorText,
    bool clearError = false,
  }) {
    return EquationItem(
      id: id ?? this.id,
      expression: expression ?? this.expression,
      color: color ?? this.color,
      isSelected: isSelected ?? this.isSelected,
      cursorPosition: cursorPosition ?? this.cursorPosition,
      errorText: clearError ? null : (errorText ?? this.errorText),
    );
  }
}

class EquationsState {
  final List<EquationItem> equations;

  const EquationsState({
    this.equations = const [],
  });

  EquationItem? get selectedEquation {
    try {
      return equations.firstWhere((e) => e.isSelected);
    } catch (_) {
      return null;
    }
  }

  EquationsState copyWith({
    List<EquationItem>? equations,
  }) {
    return EquationsState(
      equations: equations ?? this.equations,
    );
  }
}

class EquationsNotifier extends StateNotifier<EquationsState> {
  int _nextId = 1;

  EquationsNotifier() : super(const EquationsState()) {
    // Initialize with one empty equation
    add();
  }

  String _generateId() {
    return 'eq_${_nextId++}';
  }

  Color _getNextColor() {
    final usedColors = state.equations.map((e) => e.color).toSet();
    for (final color in equationColors) {
      if (!usedColors.contains(color)) {
        return color;
      }
    }
    return equationColors[state.equations.length % equationColors.length];
  }

  void add() {
    final newEquation = EquationItem(
      id: _generateId(),
      color: _getNextColor(),
      isSelected: true,
    );

    // Deselect all others and add new one
    final updatedEquations = state.equations
        .map((e) => e.copyWith(isSelected: false))
        .toList();
    updatedEquations.add(newEquation);

    state = state.copyWith(equations: updatedEquations);
  }

  void remove(String id) {
    final updatedEquations = state.equations.where((e) => e.id != id).toList();

    // If we removed the selected one, select the last one
    if (updatedEquations.isNotEmpty &&
        !updatedEquations.any((e) => e.isSelected)) {
      updatedEquations[updatedEquations.length - 1] =
          updatedEquations.last.copyWith(isSelected: true);
    }

    // Ensure at least one equation exists
    if (updatedEquations.isEmpty) {
      updatedEquations.add(EquationItem(
        id: _generateId(),
        color: equationColors[0],
        isSelected: true,
      ));
    }

    state = state.copyWith(equations: updatedEquations);
  }

  void select(String id) {
    final updatedEquations = state.equations.map((e) {
      return e.copyWith(isSelected: e.id == id);
    }).toList();

    state = state.copyWith(equations: updatedEquations);
  }

  void updateExpression(String id, String expression, int cursorPosition) {
    final updatedEquations = state.equations.map((e) {
      if (e.id == id) {
        // Validate expression
        String? errorText;
        if (expression.isNotEmpty) {
          errorText = _validateExpression(expression);
        }

        return e.copyWith(
          expression: expression,
          cursorPosition: cursorPosition,
          errorText: errorText,
          clearError: errorText == null,
        );
      }
      return e;
    }).toList();

    state = state.copyWith(equations: updatedEquations);
  }

  String? _validateExpression(String expression) {
    try {
      expression.toSingleVariableFunction();
      return null;
    } catch (e) {
      return _formatErrorMessage(e.toString());
    }
  }

  String _formatErrorMessage(String error) {
    final lowerError = error.toLowerCase();

    if (lowerError.contains('bad expression') ||
        lowerError.contains('formatexception')) {
      return '수식 형식이 올바르지 않습니다';
    }
    if (lowerError.contains('parenthes') ||
        lowerError.contains('bracket') ||
        lowerError.contains('unbalanced') ||
        lowerError.contains('unclosed')) {
      return '괄호를 확인해주세요';
    }
    if (lowerError.contains('unknown') ||
        lowerError.contains('undefined') ||
        lowerError.contains('unrecognized')) {
      return '알 수 없는 함수입니다';
    }
    if (lowerError.contains('unexpected') ||
        lowerError.contains('invalid') ||
        lowerError.contains('syntax')) {
      return '수식 형식이 올바르지 않습니다';
    }
    return '수식 오류';
  }

  void updateColor(String id, Color color) {
    final updatedEquations = state.equations.map((e) {
      if (e.id == id) {
        return e.copyWith(color: color);
      }
      return e;
    }).toList();

    state = state.copyWith(equations: updatedEquations);
  }

  // Input operations on selected equation
  void insert(String text) {
    final selected = state.selectedEquation;
    if (selected == null) return;

    final before = selected.expression.substring(0, selected.cursorPosition);
    final after = selected.expression.substring(selected.cursorPosition);
    final newExpression = before + text + after;
    final newPosition = selected.cursorPosition + text.length;

    updateExpression(selected.id, newExpression, newPosition);
  }

  void delete() {
    final selected = state.selectedEquation;
    if (selected == null || selected.cursorPosition <= 0) return;

    final before =
        selected.expression.substring(0, selected.cursorPosition - 1);
    final after = selected.expression.substring(selected.cursorPosition);
    final newExpression = before + after;
    final newPosition = selected.cursorPosition - 1;

    updateExpression(selected.id, newExpression, newPosition);
  }

  void clear() {
    final selected = state.selectedEquation;
    if (selected == null) return;

    updateExpression(selected.id, '', 0);
  }

  void moveCursorLeft() {
    final selected = state.selectedEquation;
    if (selected == null || selected.cursorPosition <= 0) return;

    updateExpression(
        selected.id, selected.expression, selected.cursorPosition - 1);
  }

  void moveCursorRight() {
    final selected = state.selectedEquation;
    if (selected == null ||
        selected.cursorPosition >= selected.expression.length) return;

    updateExpression(
        selected.id, selected.expression, selected.cursorPosition + 1);
  }

  void setCursorPosition(int position) {
    final selected = state.selectedEquation;
    if (selected == null) return;

    final clampedPosition =
        position.clamp(0, selected.expression.length);
    updateExpression(selected.id, selected.expression, clampedPosition);
  }
}

final equationsProvider =
    StateNotifierProvider<EquationsNotifier, EquationsState>((ref) {
  return EquationsNotifier();
});

// Legacy provider for backward compatibility (returns selected equation)
final equationProvider = Provider<EquationItem?>((ref) {
  final state = ref.watch(equationsProvider);
  return state.selectedEquation;
});
