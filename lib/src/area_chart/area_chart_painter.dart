import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'area_chart_data.dart';
import '../common/chart_utils.dart';

/// The [CustomPainter] responsible for rendering the area chart.
///
/// Draws in this order:
/// 1. Horizontal grid lines + y-axis labels
/// 2. Filled area for each series (animated left to right)
/// 3. Line stroke on top of each area
/// 4. Dot indicators at each data point
/// 5. X-axis labels
/// 6. Tooltip bubble (if a point is selected)
class AreaChartPainter extends CustomPainter {
  /// The chart data containing series and all style configs.
  final AreaChartData data;

  /// Animation progress from 0.0 (nothing drawn) to 1.0 (fully drawn).
  final double animationProgress;

  /// Index of the selected series. -1 means none.
  final int selectedSeriesIndex;

  /// Index of the selected point within the series. -1 means none.
  final int selectedPointIndex;

  /// The resolved maximum y value.
  final double maxY;

  const AreaChartPainter({
    required this.data,
    required this.animationProgress,
    required this.selectedSeriesIndex,
    required this.selectedPointIndex,
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

    _drawGrid(canvas, chartLeft, chartTop, chartWidth, chartHeight);
    _drawXLabels(canvas, chartLeft, chartBottom, chartWidth);

    if (data.stacked) {
      _drawStackedSeries(
          canvas, chartLeft, chartTop, chartWidth, chartHeight, chartBottom);
    } else {
      for (int i = 0; i < data.series.length; i++) {
        _drawSeries(
          canvas,
          i,
          data.series[i],
          chartLeft,
          chartTop,
          chartWidth,
          chartHeight,
          chartBottom,
          null,
        );
      }
    }

    _drawTooltip(canvas, chartLeft, chartTop, chartWidth, chartHeight);
  }

  // ─── Grid ──────────────────────────────────────────────────────────────────

  void _drawGrid(
    Canvas canvas,
    double left,
    double top,
    double width,
    double height,
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

      if (data.axisStyle.showGrid) {
        canvas.drawLine(Offset(left, y), Offset(left + width, y), paint);
      }

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

  // ─── X Labels ─────────────────────────────────────────────────────────────

  void _drawXLabels(
    Canvas canvas,
    double left,
    double bottom,
    double width,
  ) {
    if (data.series.isEmpty) return;
    final points = data.series.first.points;
    if (points.isEmpty) return;
    final count = points.length;
    final slotWidth = count <= 1 ? width : width / (count - 1);

    for (int i = 0; i < count; i++) {
      final x = count == 1 ? left + width / 2 : left + i * slotWidth;
      ChartUtils.drawLabel(
        canvas,
        points[i].label,
        x,
        bottom + 6,
        data.axisStyle.labelStyle,
        maxWidth: slotWidth > 0 ? slotWidth - 4 : 60,
      );
    }
  }

  // ─── Single Series ─────────────────────────────────────────────────────────

  void _drawSeries(
    Canvas canvas,
    int seriesIndex,
    AreaSeries series,
    double left,
    double top,
    double width,
    double height,
    double bottom,
    List<double>? baselineOffsets,
  ) {
    final points = series.points;
    if (points.isEmpty) return;

    final style = series.style;
    final count = points.length;
    final slotWidth = count <= 1 ? width : width / (count - 1);
    final isSelected = selectedSeriesIndex == seriesIndex;
    final isDeselected =
        selectedSeriesIndex != -1 && selectedSeriesIndex != seriesIndex;
    final opacity = isDeselected ? 0.25 : 1.0;
    final fillOpacity = isDeselected ? 0.05 : style.fillOpacity;

    // Build pixel offsets
    final offsets = List.generate(count, (i) {
      final x = count == 1 ? left + width / 2 : left + i * slotWidth;
      final baseline = baselineOffsets != null ? baselineOffsets[i] : bottom;
      final y =
          baseline - ((points[i].y - data.minY) / (maxY - data.minY)) * height;
      return Offset(x, y);
    });

    // Baseline offsets for fill (bottom of fill area)
    final baselinePoints = baselineOffsets != null
        ? List.generate(count, (i) {
            final x = count == 1 ? left + width / 2 : left + i * slotWidth;
            return Offset(x, baselineOffsets[i]);
          })
        : List.generate(count, (i) {
            final x = count == 1 ? left + width / 2 : left + i * slotWidth;
            return Offset(x, bottom);
          });

    // Animated cutoff
    final cutoffX = left + width * animationProgress;

    // ── Fill path ─────────────────────────────────────────────────────────
    final fillPath = _buildFillPath(
        offsets, baselinePoints, cutoffX, left, bottom, style.smooth);

    if (fillPath != null) {
      final fillRect = Rect.fromLTWH(left, top, width, height);
      final Paint fillPaint;
      if (style.fillGradient != null) {
        fillPaint = Paint()
          ..shader = style.fillGradient!.createShader(fillRect)
          ..style = PaintingStyle.fill;
      } else {
        fillPaint = Paint()
          ..shader = LinearGradient(
            colors: [
              style.color.withValues(alpha: fillOpacity),
              style.color.withValues(alpha: fillOpacity * 0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(fillRect)
          ..style = PaintingStyle.fill;
      }
      canvas.drawPath(fillPath, fillPaint);
    }

    // ── Line stroke ───────────────────────────────────────────────────────
    final linePath = style.smooth
        ? _buildSmoothLinePath(offsets, cutoffX)
        : _buildStraightLinePath(offsets, cutoffX);

    if (linePath != null) {
      final linePaint = Paint()
        ..color = style.color.withValues(alpha: opacity)
        ..strokeWidth = isSelected ? style.strokeWidth + 1 : style.strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(linePath, linePaint);
    }

    // ── Dots ──────────────────────────────────────────────────────────────
    if (style.showDots) {
      for (int i = 0; i < offsets.length; i++) {
        final o = offsets[i];
        if (o.dx > cutoffX + 1) break;

        final isSelectedPoint = isSelected && selectedPointIndex == i;

        canvas.drawCircle(
          o,
          isSelectedPoint ? style.dotRadius + 3 : style.dotRadius,
          Paint()
            ..color = style.color.withValues(alpha: isSelectedPoint ? 0.2 : 0.0)
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          o,
          style.dotRadius,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          o,
          style.dotRadius - 1.5,
          Paint()
            ..color = style.color.withValues(alpha: opacity)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  // ─── Stacked Series ────────────────────────────────────────────────────────

  void _drawStackedSeries(
    Canvas canvas,
    double left,
    double top,
    double width,
    double height,
    double bottom,
  ) {
    final count = data.series.first.points.length;

    // Cumulative baselines per point
    List<double> baselines = List.filled(count, bottom);

    for (int si = 0; si < data.series.length; si++) {
      final series = data.series[si];
      final currentBaselines = List<double>.from(baselines);

      // Update baselines for next series
      for (int i = 0; i < count; i++) {
        if (i >= series.points.length) continue;
        final segH =
            ((series.points[i].y - data.minY) / (maxY - data.minY)) * height;
        baselines[i] = baselines[i] - segH;
      }

      _drawSeries(
        canvas,
        si,
        series,
        left,
        top,
        width,
        height,
        bottom,
        currentBaselines,
      );
    }
  }

  // ─── Path builders ─────────────────────────────────────────────────────────

  Path? _buildFillPath(
    List<Offset> offsets,
    List<Offset> baselinePoints,
    double cutoffX,
    double left,
    double bottom,
    bool smooth,
  ) {
    if (offsets.isEmpty) return null;

    final linePath = smooth
        ? _buildSmoothLinePath(offsets, cutoffX)
        : _buildStraightLinePath(offsets, cutoffX);
    if (linePath == null) return null;

    final fillPath = Path.from(linePath);
    final rightmostX = offsets
        .where((o) => o.dx <= cutoffX)
        .fold(offsets.first.dx, (prev, o) => math.max(prev, o.dx));

    // Find baseline y at rightmost x
    final rightmostBaseline = _interpolateBaseline(baselinePoints, rightmostX);

    fillPath.lineTo(rightmostX, rightmostBaseline);

    // Trace baseline back to start (reversed)
    for (int i = baselinePoints.length - 1; i >= 0; i--) {
      if (baselinePoints[i].dx <= rightmostX) {
        fillPath.lineTo(baselinePoints[i].dx, baselinePoints[i].dy);
      }
    }

    fillPath.close();
    return fillPath;
  }

  double _interpolateBaseline(List<Offset> baselinePoints, double x) {
    for (int i = 0; i < baselinePoints.length - 1; i++) {
      if (x >= baselinePoints[i].dx && x <= baselinePoints[i + 1].dx) {
        final t = (x - baselinePoints[i].dx) /
            (baselinePoints[i + 1].dx - baselinePoints[i].dx);
        return baselinePoints[i].dy +
            t * (baselinePoints[i + 1].dy - baselinePoints[i].dy);
      }
    }
    return baselinePoints.last.dy;
  }

  Path? _buildSmoothLinePath(List<Offset> offsets, double cutoffX) {
    if (offsets.isEmpty) return null;
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);

    for (int i = 0; i < offsets.length - 1; i++) {
      final p0 = offsets[i];
      final p1 = offsets[i + 1];
      if (p0.dx > cutoffX) break;

      final cp1 = Offset((p0.dx + p1.dx) / 2, p0.dy);
      final cp2 = Offset((p0.dx + p1.dx) / 2, p1.dy);

      if (p1.dx <= cutoffX) {
        path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
      } else {
        final t = (cutoffX - p0.dx) / (p1.dx - p0.dx);
        final endPoint = _cubicBezier(p0, cp1, cp2, p1, t);
        final pcp1 = Offset(
          p0.dx + t * (cp1.dx - p0.dx),
          p0.dy + t * (cp1.dy - p0.dy),
        );
        final pcp2 = Offset(
          cp1.dx + t * (cp2.dx - cp1.dx),
          cp1.dy + t * (cp2.dy - cp1.dy),
        );
        path.cubicTo(
          pcp1.dx,
          pcp1.dy,
          pcp2.dx,
          pcp2.dy,
          endPoint.dx,
          endPoint.dy,
        );
        break;
      }
    }
    return path;
  }

  Path? _buildStraightLinePath(List<Offset> offsets, double cutoffX) {
    if (offsets.isEmpty) return null;
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (int i = 1; i < offsets.length; i++) {
      final o = offsets[i];
      if (o.dx <= cutoffX) {
        path.lineTo(o.dx, o.dy);
      } else {
        final prev = offsets[i - 1];
        final t = (cutoffX - prev.dx) / (o.dx - prev.dx);
        path.lineTo(
          prev.dx + t * (o.dx - prev.dx),
          prev.dy + t * (o.dy - prev.dy),
        );
        break;
      }
    }
    return path;
  }

  Offset _cubicBezier(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final mt = 1 - t;
    return Offset(
      mt * mt * mt * p0.dx +
          3 * mt * mt * t * p1.dx +
          3 * mt * t * t * p2.dx +
          t * t * t * p3.dx,
      mt * mt * mt * p0.dy +
          3 * mt * mt * t * p1.dy +
          3 * mt * t * t * p2.dy +
          t * t * t * p3.dy,
    );
  }

  // ─── Tooltip ───────────────────────────────────────────────────────────────

  void _drawTooltip(
    Canvas canvas,
    double left,
    double top,
    double width,
    double height,
  ) {
    if (selectedSeriesIndex < 0 || selectedPointIndex < 0) return;
    if (selectedSeriesIndex >= data.series.length) return;

    final series = data.series[selectedSeriesIndex];
    if (selectedPointIndex >= series.points.length) return;

    final point = series.points[selectedPointIndex];
    final count = series.points.length;
    final slotWidth = count <= 1 ? width : width / (count - 1);
    final x =
        count == 1 ? left + width / 2 : left + selectedPointIndex * slotWidth;
    final y =
        top + height - ((point.y - data.minY) / (maxY - data.minY)) * height;
    final style = data.tooltipStyle;

    ChartUtils.drawTooltip(
      canvas,
      label: '${series.label}: ${ChartUtils.formatValue(point.y)}',
      x: x,
      y: y,
      backgroundColor: style.backgroundColor,
      textStyle: style.textStyle,
      borderRadius: style.borderRadius,
      padding: style.padding,
    );
  }

  // ─── Hit test ──────────────────────────────────────────────────────────────

  /// Returns [seriesIndex, pointIndex] of the nearest point or [-1, -1].
  List<int> indexFromTap(Offset localPosition, Size size) {
    const chartLeft = _leftPadding;
    const chartTop = _topPadding;
    final chartWidth = size.width - chartLeft;
    final chartHeight = size.height - _bottomPadding - chartTop;

    double minDist = 30.0;
    int bestSeries = -1;
    int bestPoint = -1;

    for (int si = 0; si < data.series.length; si++) {
      final points = data.series[si].points;
      final count = points.length;
      final slotWidth = count <= 1 ? chartWidth : chartWidth / (count - 1);

      for (int pi = 0; pi < count; pi++) {
        final x = count == 1
            ? chartLeft + chartWidth / 2
            : chartLeft + pi * slotWidth;
        final y = chartTop +
            chartHeight -
            ((points[pi].y - data.minY) / (maxY - data.minY)) * chartHeight;
        final dist = (localPosition - Offset(x, y)).distance;
        if (dist < minDist) {
          minDist = dist;
          bestSeries = si;
          bestPoint = pi;
        }
      }
    }
    return [bestSeries, bestPoint];
  }

  @override
  bool shouldRepaint(AreaChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.selectedSeriesIndex != selectedSeriesIndex ||
        oldDelegate.selectedPointIndex != selectedPointIndex ||
        oldDelegate.data != data ||
        oldDelegate.maxY != maxY;
  }
}
