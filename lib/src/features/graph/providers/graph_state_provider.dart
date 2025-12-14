import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewState {
  final double scale;
  final Offset offset;
  final bool showGrid;

  const ViewState({
    this.scale = 1.0,
    this.offset = Offset.zero,
    this.showGrid = true,
  });

  ViewState copyWith({
    double? scale,
    Offset? offset,
    bool? showGrid,
  }) {
    return ViewState(
      scale: scale ?? this.scale,
      offset: offset ?? this.offset,
      showGrid: showGrid ?? this.showGrid,
    );
  }
}

class ViewStateNotifier extends StateNotifier<ViewState> {
  ViewStateNotifier() : super(const ViewState());

  void setScale(double scale) {
    // Clamp scale between 0.1x and 10x
    final clampedScale = scale.clamp(0.1, 10.0);
    state = state.copyWith(scale: clampedScale);
  }

  void setOffset(Offset offset) {
    state = state.copyWith(offset: offset);
  }

  void updateScaleAndOffset({
    required double scale,
    required Offset offset,
  }) {
    final clampedScale = scale.clamp(0.1, 10.0);
    state = state.copyWith(scale: clampedScale, offset: offset);
  }

  void zoom(double delta, Offset focalPoint, Size canvasSize) {
    final newScale = (state.scale * delta).clamp(0.1, 10.0);

    // Calculate offset adjustment to zoom toward focal point
    final focalRatio = Offset(
      focalPoint.dx / canvasSize.width,
      focalPoint.dy / canvasSize.height,
    );

    final scaleDiff = newScale - state.scale;
    final offsetAdjust = Offset(
      -scaleDiff * canvasSize.width * (focalRatio.dx - 0.5) / newScale,
      -scaleDiff * canvasSize.height * (focalRatio.dy - 0.5) / newScale,
    );

    state = state.copyWith(
      scale: newScale,
      offset: state.offset + offsetAdjust,
    );
  }

  void pan(Offset delta) {
    state = state.copyWith(offset: state.offset + delta);
  }

  void reset() {
    state = const ViewState();
  }

  void toggleGrid() {
    state = state.copyWith(showGrid: !state.showGrid);
  }
}

final viewStateProvider =
    StateNotifierProvider<ViewStateNotifier, ViewState>((ref) {
  return ViewStateNotifier();
});
