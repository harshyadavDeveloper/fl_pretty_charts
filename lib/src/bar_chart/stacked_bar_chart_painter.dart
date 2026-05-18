import 'package:flutter/material.dart';
import 'stacked_bar_chart_data.dart';
import '../common/chart_utils.dart';

/// The [CustomPainter] responsible for rendering the stacked bar chart.
///
/// Draws in this order:
/// 1. Horizontal grid lines + y-axis labels
/// 2. Stacked bar segments (animated, bottom to top)
/// 3. X-axis group labels
/// 4. Tooltip bubble (if a segment is selected)
class StackedBarChartPainter extends CustomPainter {
  /// The chart data containing series and all style configs.
  final StackedBarChartData data;

  /// Animation progress from 0.0 (nothing drawn) to 1.0 (fully drawn).
  final double animationProgress;

  /// Index of the selected bar group. -1 means none.
  final int selectedGroupIndex;

  /// Index of the selected series within the group. -1 means none.
  final int selectedSeriesIndex;

  /// The resolved maximum y value.
  final double maxY;

  const StackedBarChartPainter({
    required this.data,
    required this.animationProgress,
    required this.selectedGroupIndex,
    required this.selectedSeriesIndex,
    required this.maxY,
  });

  // ─── Layout constants ──────────────────────────────────────────────────────
  static const double _leftPadding = 48.0;
  static const double _bottomPadding = 36.0;
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

  // ─── Grid ──────────────────────────────────────────────────────────────────

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
      final value = maxY * fraction;
      final y = top + height - (fraction * height);

      if (data.axisStyle.showGrid) {
        canvas.drawLine(Offset(left, y), Offset(left + width, y), paint);
      }

      final label = data.percentageMode
          ? '${(fraction * 100).toInt()}%'
          : ChartUtils.formatValue(value);

      ChartUtils.drawLabel(
        canvas,
        label,
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
    final groupCount = data.groups.length;
    final slotWidth = width / groupCount;
    final barWidth = slotWidth * data.barStyle.barWidthFraction;
    final radius = Radius.circular(data.barStyle.borderRadius);

    for (int gi = 0; gi < groupCount; gi++) {
      final slotCenter = left + slotWidth * gi + slotWidth / 2;
      final barLeft = slotCenter - barWidth / 2;

      // Calculate total for this group
      double groupTotal = 0;
      for (final series in data.series) {
        if (gi < series.values.length) groupTotal += series.values[gi];
      }

      double currentBottom = bottom;

      for (int si = 0; si < data.series.length; si++) {
        final series = data.series[si];
        if (gi >= series.values.length) continue;

        final rawValue = series.values[gi];
        final value = data.percentageMode && groupTotal > 0
            ? (rawValue / groupTotal) * maxY
            : rawValue;

        final segmentHeight = (value / maxY) * height * animationProgress;

        if (segmentHeight <= 0) continue;

        final segTop = currentBottom - segmentHeight;
        final isTopSegment =
            si == data.series.length - 1 || _isTopVisibleSegment(gi, si);
        final isSelected =
            gi == selectedGroupIndex && si == selectedSeriesIndex;

        final rect = Rect.fromLTWH(barLeft, segTop, barWidth, segmentHeight);

        // Only round top corners of the topmost segment
        final rrect = isTopSegment
            ? RRect.fromRectAndCorners(
                rect,
                topLeft: radius,
                topRight: radius,
              )
            : RRect.fromRectAndCorners(rect);

        // Glow for selected segment
        if (isSelected) {
          final glowPaint = Paint()
            ..color = series.color.withValues(alpha: 0.2)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
          canvas.drawRRect(rrect, glowPaint);
        }

        final segPaint = Paint()
          ..color =
              isSelected ? series.color : series.color.withValues(alpha: 0.85)
          ..style = PaintingStyle.fill;

        canvas.drawRRect(rrect, segPaint);
        currentBottom = segTop;
      }

      // X-axis group label
      ChartUtils.drawLabel(
        canvas,
        data.groups[gi],
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
    if (selectedGroupIndex < 0 || selectedSeriesIndex < 0) return;
    if (selectedGroupIndex >= data.groups.length) return;
    if (selectedSeriesIndex >= data.series.length) return;

    final series = data.series[selectedSeriesIndex];
    if (selectedGroupIndex >= series.values.length) return;

    final groupCount = data.groups.length;
    final slotWidth = width / groupCount;
    final slotCenter = left + slotWidth * selectedGroupIndex + slotWidth / 2;

    // Calculate y position of selected segment top
    double groupTotal = 0;
    for (final s in data.series) {
      if (selectedGroupIndex < s.values.length) {
        groupTotal += s.values[selectedGroupIndex];
      }
    }

    double stackedHeight = 0;
    for (int si = 0; si <= selectedSeriesIndex; si++) {
      final s = data.series[si];
      if (selectedGroupIndex >= s.values.length) continue;
      final rawValue = s.values[selectedGroupIndex];
      final value = data.percentageMode && groupTotal > 0
          ? (rawValue / groupTotal) * maxY
          : rawValue;
      stackedHeight += (value / maxY) * height;
    }

    final bottom = top + height;
    final segTopY = bottom - stackedHeight;
    final style = data.tooltipStyle;
    final rawValue = series.values[selectedGroupIndex];
    final label = data.percentageMode && groupTotal > 0
        ? '${((rawValue / groupTotal) * 100).toStringAsFixed(1)}%'
        : ChartUtils.formatValue(rawValue);

    ChartUtils.drawTooltip(
      canvas,
      label: '${series.label}: $label',
      x: slotCenter,
      y: segTopY,
      backgroundColor: style.backgroundColor,
      textStyle: style.textStyle,
      borderRadius: style.borderRadius,
      padding: style.padding,
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  bool _isTopVisibleSegment(int groupIndex, int seriesIndex) {
    for (int si = seriesIndex + 1; si < data.series.length; si++) {
      final series = data.series[si];
      if (groupIndex < series.values.length && series.values[groupIndex] > 0) {
        return false;
      }
    }
    return true;
  }

  /// Returns [groupIndex, seriesIndex] of the tapped segment or [-1, -1].
  List<int> indexFromTap(Offset localPosition, Size size) {
    const chartLeft = _leftPadding;
    const chartTop = _topPadding;
    final chartRight = size.width;
    final chartBottom = size.height - _bottomPadding;
    final chartWidth = chartRight - chartLeft;
    final chartHeight = chartBottom - chartTop;

    if (localPosition.dx < chartLeft) return [-1, -1];
    if (localPosition.dy < chartTop || localPosition.dy > chartBottom) {
      return [-1, -1];
    }

    final groupCount = data.groups.length;
    final slotWidth = chartWidth / groupCount;
    final gi = ((localPosition.dx - chartLeft) / slotWidth).floor();
    if (gi < 0 || gi >= groupCount) return [-1, -1];

    // Find which series segment was tapped by checking y ranges
    double groupTotal = 0;
    for (final s in data.series) {
      if (gi < s.values.length) groupTotal += s.values[gi];
    }

    double currentBottom = chartBottom;
    for (int si = 0; si < data.series.length; si++) {
      final series = data.series[si];
      if (gi >= series.values.length) continue;
      final rawValue = series.values[gi];
      final value = data.percentageMode && groupTotal > 0
          ? (rawValue / groupTotal) * maxY
          : rawValue;
      final segmentHeight = (value / maxY) * chartHeight;
      final segTop = currentBottom - segmentHeight;

      if (localPosition.dy >= segTop && localPosition.dy <= currentBottom) {
        return [gi, si];
      }
      currentBottom = segTop;
    }
    return [-1, -1];
  }

  @override
  bool shouldRepaint(StackedBarChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.selectedGroupIndex != selectedGroupIndex ||
        oldDelegate.selectedSeriesIndex != selectedSeriesIndex ||
        oldDelegate.data != data ||
        oldDelegate.maxY != maxY;
  }
}
