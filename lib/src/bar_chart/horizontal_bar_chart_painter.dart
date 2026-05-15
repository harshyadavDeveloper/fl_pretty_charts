import 'package:flutter/material.dart';
import 'bar_chart_data.dart';
import '../common/chart_utils.dart';

/// The [CustomPainter] responsible for rendering the horizontal bar chart.
///
/// Draws in this order:
/// 1. Vertical grid lines + x-axis labels
/// 2. Bars (animated left to right, gradient or solid)
/// 3. Y-axis category labels
/// 4. Tooltip bubble (if a bar is selected)
class HorizontalBarChartPainter extends CustomPainter {
  /// The chart data containing bars and all style configs.
  final BarChartData data;

  /// Animation progress from 0.0 (nothing drawn) to 1.0 (fully drawn).
  final double animationProgress;

  /// Index of the currently tapped bar. -1 means none selected.
  final int selectedIndex;

  /// The resolved maximum x value.
  final double maxX;

  const HorizontalBarChartPainter({
    required this.data,
    required this.animationProgress,
    required this.selectedIndex,
    required this.maxX,
  });

  // ─── Layout constants ──────────────────────────────────────────────────────
  static const double _leftPadding = 90.0;
  static const double _rightPadding = 16.0;
  static const double _topPadding = 16.0;
  static const double _bottomPadding = 32.0;

  @override
  void paint(Canvas canvas, Size size) {
    const chartLeft = _leftPadding;
    const chartTop = _topPadding;
    final chartRight = size.width - _rightPadding;
    final chartBottom = size.height - _bottomPadding;
    final chartWidth = chartRight - chartLeft;
    final chartHeight = chartBottom - chartTop;

    _drawGrid(
        canvas, chartLeft, chartTop, chartWidth, chartHeight, chartBottom);
    _drawBars(
        canvas, chartLeft, chartTop, chartWidth, chartHeight, chartBottom);
    _drawXAxisLabels(canvas, chartLeft, chartBottom, chartWidth);
    _drawTooltip(canvas, chartLeft, chartTop, chartWidth, chartHeight);
  }

  // ─── Grid + X-axis labels ──────────────────────────────────────────────────

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
      final value = data.minY + (maxX - data.minY) * fraction;
      final x = left + fraction * width;

      if (data.axisStyle.showGrid) {
        canvas.drawLine(Offset(x, top), Offset(x, bottom), paint);
      }

      ChartUtils.drawLabel(
        canvas,
        ChartUtils.formatValue(value),
        x,
        bottom + 6,
        data.axisStyle.labelStyle,
        maxWidth: width / divisions,
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
    final slotHeight = height / barCount;
    final barHeight = slotHeight * data.barStyle.barWidthFraction;
    final radius = Radius.circular(data.barStyle.borderRadius);

    for (int i = 0; i < barCount; i++) {
      final bar = data.bars[i];
      final animatedValue = bar.value * animationProgress;
      final barWidth =
          ((animatedValue - data.minY) / (maxX - data.minY)) * width;

      if (barWidth <= 0) continue;

      final slotCenterY = top + slotHeight * i + slotHeight / 2;
      final barTop = slotCenterY - barHeight / 2;

      final rect = Rect.fromLTWH(left, barTop, barWidth, barHeight);
      final rrect = RRect.fromRectAndCorners(
        rect,
        topRight: radius,
        bottomRight: radius,
      );

      // Paint — gradient or solid
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

      // Glow for selected bar
      if (selectedIndex == i) {
        final glowPaint = Paint()
          ..color = (bar.color ?? data.defaultColor).withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawRRect(rrect, glowPaint);
      }

      canvas.drawRRect(rrect, barPaint);

      // Y-axis category label
      ChartUtils.drawLabel(
        canvas,
        bar.label,
        left - 8,
        slotCenterY - 8,
        data.axisStyle.labelStyle,
        maxWidth: _leftPadding - 10,
      );
    }
  }

  // ─── X-axis bottom labels ──────────────────────────────────────────────────

  void _drawXAxisLabels(
    Canvas canvas,
    double left,
    double bottom,
    double width,
  ) {
    // Already drawn in _drawGrid — skip
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
    final slotHeight = height / barCount;
    final slotCenterY = top + slotHeight * selectedIndex + slotHeight / 2;
    final barWidth = ((bar.value - data.minY) / (maxX - data.minY)) * width;
    final barTipX = left + barWidth;
    final style = data.tooltipStyle;

    ChartUtils.drawTooltip(
      canvas,
      label: ChartUtils.formatValue(bar.value),
      x: barTipX,
      y: slotCenterY,
      backgroundColor: style.backgroundColor,
      textStyle: style.textStyle,
      borderRadius: style.borderRadius,
      padding: style.padding,
    );
  }

  @override
  bool shouldRepaint(HorizontalBarChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.data != data ||
        oldDelegate.maxX != maxX;
  }

  /// Returns the index of the tapped bar or -1 if none was hit.
  int indexFromTap(Offset localPosition, Size size) {
    const chartTop = _topPadding;
    final chartBottom = size.height - _bottomPadding;
    final chartHeight = chartBottom - chartTop;
    final barCount = data.bars.length;
    final slotHeight = chartHeight / barCount;

    if (localPosition.dy < chartTop || localPosition.dy > chartBottom) {
      return -1;
    }

    final index = ((localPosition.dy - chartTop) / slotHeight).floor();
    if (index < 0 || index >= barCount) return -1;
    return index;
  }
}
