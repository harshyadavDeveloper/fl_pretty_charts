import 'package:flutter/material.dart';
import '../bar_chart/bar_chart_data.dart';
import '../common/chart_utils.dart';

/// The [CustomPainter] responsible for rendering the bar chart.
///
/// Draws in this order:
/// 1. Horizontal grid lines + y-axis labels
/// 2. Bars (animated, with gradient or solid color)
/// 3. X-axis labels
/// 4. Tooltip bubble (if a bar is selected)
///
/// All drawing respects the current [animationProgress] value (0.0 → 1.0)
/// so bars grow upward smoothly from the baseline.
class BarChartPainter extends CustomPainter {
  /// The chart data containing bars and all style configs.
  final BarChartData data;

  /// Animation progress from 0.0 (nothing drawn) to 1.0 (fully drawn).
  final double animationProgress;

  /// Index of the currently tapped bar. -1 means no bar is selected.
  final int selectedIndex;

  /// The resolved maximum y value (from data.maxY or auto-calculated).
  final double maxY;

  BarChartPainter({
    required this.data,
    required this.animationProgress,
    required this.selectedIndex,
    required this.maxY,
  });

  // ─── Layout constants ──────────────────────────────────────────────────────

  /// Padding reserved on the left for y-axis labels.
  static const double _leftPadding = 48.0;

  /// Padding reserved on the bottom for x-axis labels.
  static const double _bottomPadding = 36.0;

  /// Padding reserved on the top so tallest bar never clips.
  static const double _topPadding = 16.0;

  @override
  void paint(Canvas canvas, Size size) {
    const chartLeft = _leftPadding;
    const chartTop = _topPadding;
    final chartRight = size.width;
    final chartBottom = size.height - _bottomPadding;
    final chartWidth = chartRight - chartLeft;
    final chartHeight = chartBottom - chartTop;

    _drawGrid(
        canvas, chartLeft, chartTop, chartWidth, chartHeight, chartBottom);
    _drawBars(
        canvas, chartLeft, chartTop, chartWidth, chartHeight, chartBottom);
    _drawTooltip(canvas, chartLeft, chartTop, chartWidth, chartHeight);
  }

  // ─── Grid + Y-axis labels ──────────────────────────────────────────────────

  void _drawGrid(
    Canvas canvas,
    double left,
    double top,
    double width,
    double height,
    double bottom,
  ) {
    final divisions = data.axisStyle.yAxisDivisions;
    final paint = ChartUtils.gridPaint(
      data.axisStyle.gridColor,
      data.axisStyle.gridOpacity,
    );

    for (int i = 0; i <= divisions; i++) {
      final fraction = i / divisions;
      final value = data.minY + (maxY - data.minY) * fraction;
      final y = top + height - (fraction * height);

      // Grid line
      if (data.axisStyle.showGrid) {
        canvas.drawLine(Offset(left, y), Offset(left + width, y), paint);
      }

      // Y-axis label
      ChartUtils.drawLabel(
        canvas,
        ChartUtils.formatValue(value),
        left - 4,
        y - 8,
        data.axisStyle.labelStyle,
        maxWidth: _leftPadding - 4,
      );
    }
  }

  // ─── Bars ──────────────────────────────────────────────────────────────────

  void _drawBars(
    Canvas canvas,
    double left,
    double top,
    double width,
    double height,
    double bottom,
  ) {
    final barCount = data.bars.length;
    final slotWidth = width / barCount;
    final barWidth = slotWidth * data.barStyle.barWidthFraction;
    final radius = Radius.circular(data.barStyle.borderRadius);

    for (int i = 0; i < barCount; i++) {
      final bar = data.bars[i];
      final animatedValue = bar.value * animationProgress;
      final barHeight = ChartUtils.valueToY(
            data.minY,
            data.minY,
            maxY,
            height,
          ) -
          ChartUtils.valueToY(animatedValue, data.minY, maxY, height);

      if (barHeight <= 0) continue;

      final slotCenter = left + slotWidth * i + slotWidth / 2;
      final barLeft = slotCenter - barWidth / 2;
      final barTop = bottom - barHeight;

      final rect = Rect.fromLTWH(barLeft, barTop, barWidth, barHeight);
      final rrect = RRect.fromRectAndCorners(
        rect,
        topLeft: radius,
        topRight: radius,
      );

      // Determine paint — gradient or solid
      final Paint barPaint;
      if (data.barStyle.gradient != null) {
        barPaint = Paint()
          ..shader = data.barStyle.gradient!.createShader(rect)
          ..style = PaintingStyle.fill;
      } else {
        final color = bar.color ?? data.defaultColor;
        barPaint = Paint()
          ..color = selectedIndex == i
              ? color.withValues(alpha: 1.0)
              : color.withValues(alpha: 0.85)
          ..style = PaintingStyle.fill;
      }

      // Highlight selected bar with a slight glow
      if (selectedIndex == i) {
        final glowPaint = Paint()
          ..color = (bar.color ?? data.defaultColor).withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawRRect(rrect, glowPaint);
      }

      canvas.drawRRect(rrect, barPaint);

      // X-axis label
      ChartUtils.drawLabel(
        canvas,
        bar.label,
        slotCenter,
        bottom + 6,
        data.axisStyle.labelStyle,
        maxWidth: slotWidth - 4,
      );
    }
  }

  // ─── Tooltip ───────────────────────────────────────────────────────────────

  void _drawTooltip(
    Canvas canvas,
    double left,
    double top,
    double width,
    double height,
  ) {
    if (selectedIndex < 0 || selectedIndex >= data.bars.length) return;

    final bar = data.bars[selectedIndex];
    final barCount = data.bars.length;
    final slotWidth = width / barCount;
    final slotCenter = left + slotWidth * selectedIndex + slotWidth / 2;

    final barHeight = ChartUtils.valueToY(
          data.minY,
          data.minY,
          maxY,
          height,
        ) -
        ChartUtils.valueToY(bar.value, data.minY, maxY, height);

    final bottom = top + height;
    final barTopY = bottom - barHeight;
    final style = data.tooltipStyle;

    ChartUtils.drawTooltip(
      canvas,
      label: ChartUtils.formatValue(bar.value),
      x: slotCenter,
      y: barTopY,
      backgroundColor: style.backgroundColor,
      textStyle: style.textStyle,
      borderRadius: style.borderRadius,
      padding: style.padding,
    );
  }

  @override
  bool shouldRepaint(BarChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.data != data ||
        oldDelegate.maxY != maxY;
  }

  /// Hit-tests a tap [localPosition] and returns the index of the tapped bar,
  /// or -1 if no bar was hit.
  ///
  /// Called by [FlBarChart] inside its [GestureDetector].
  int indexFromTap(Offset localPosition, Size size) {
    const chartLeft = _leftPadding;
    final chartRight = size.width;
    final chartWidth = chartRight - chartLeft;
    final barCount = data.bars.length;
    final slotWidth = chartWidth / barCount;

    if (localPosition.dx < chartLeft) return -1;

    final index = ((localPosition.dx - chartLeft) / slotWidth).floor();
    if (index < 0 || index >= barCount) return -1;
    return index;
  }
}
