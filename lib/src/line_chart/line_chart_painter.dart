import 'package:flutter/material.dart';
import 'line_chart_data.dart';
import '../common/chart_utils.dart';

/// The [CustomPainter] responsible for rendering the line chart.
///
/// Draws in this order:
/// 1. Horizontal grid lines + y-axis labels
/// 2. Gradient area fill below each line
/// 3. Line stroke (animated left to right)
/// 4. Dot indicators at each data point
/// 5. X-axis labels
/// 6. Tooltip bubble (if a point is selected)
class LineChartPainter extends CustomPainter {
  /// The chart data containing lines and all style configs.
  final LineChartData data;

  /// Animation progress from 0.0 (nothing drawn) to 1.0 (fully drawn).
  final double animationProgress;

  /// Index of the selected line series. -1 means none.
  final int selectedLineIndex;

  /// Index of the selected point within the line. -1 means none.
  final int selectedPointIndex;

  /// The resolved maximum y value.
  final double maxY;

  const LineChartPainter({
    required this.data,
    required this.animationProgress,
    required this.selectedLineIndex,
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

    for (int i = 0; i < data.lines.length; i++) {
      _drawLine(
        canvas,
        data.lines[i],
        chartLeft,
        chartTop,
        chartWidth,
        chartHeight,
        chartBottom,
      );
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
    if (data.lines.isEmpty) return;
    final points = data.lines.first.points;
    if (points.isEmpty) return;
    final count = points.length;
    final slotWidth = width / (count - 1 == 0 ? 1 : count - 1);

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

  // ─── Line + Fill + Dots ────────────────────────────────────────────────────

  void _drawLine(
    Canvas canvas,
    LineData lineData,
    double left,
    double top,
    double width,
    double height,
    double bottom,
  ) {
    final points = lineData.points;
    if (points.isEmpty) return;

    final style = lineData.style;
    final count = points.length;
    final slotWidth = count <= 1 ? width : width / (count - 1);

    // Build pixel offsets for all points
    List<Offset> offsets = List.generate(count, (i) {
      final x = count == 1 ? left + width / 2 : left + i * slotWidth;
      final y = top + ChartUtils.valueToY(points[i].y, data.minY, maxY, height);
      return Offset(x, y);
    });

    // Animated cutoff — how far along the line do we draw?
    final cutoffX = left + width * animationProgress;

    // Build the animated line path
    final linePath = style.smooth
        ? _buildSmoothPath(offsets, cutoffX)
        : _buildStraightPath(offsets, cutoffX);

    // ── Area fill ─────────────────────────────────────────────────────────
    if (style.showFill && linePath != null) {
      final fillPath = Path.from(linePath);

      // Find rightmost drawn x
      final rightmostX = _clamp(cutoffX, left, left + width);
      fillPath.lineTo(rightmostX, bottom);
      fillPath.lineTo(left, bottom);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            style.color.withValues(alpha: style.fillOpacity),
            style.color.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(left, top, width, height))
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, fillPaint);
    }

    // ── Line stroke ───────────────────────────────────────────────────────
    if (linePath != null) {
      final linePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = style.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      if (style.gradient != null) {
        linePaint.shader = style.gradient!.createShader(
          Rect.fromLTWH(left, top, width, height),
        );
      } else {
        linePaint.color = style.color;
      }

      canvas.drawPath(linePath, linePaint);
    }

    // ── Dots ──────────────────────────────────────────────────────────────
    if (style.showDots) {
      for (int i = 0; i < offsets.length; i++) {
        final o = offsets[i];
        if (o.dx > cutoffX + 1) break;

        final isSelected = selectedLineIndex >= 0 &&
            selectedPointIndex == i &&
            data.lines.indexOf(lineData) == selectedLineIndex;

        // Outer ring
        final outerPaint = Paint()
          ..color = style.color.withValues(alpha: 0.25)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(o, isSelected ? style.dotRadius + 4 : 0, outerPaint);

        // White background circle
        final bgPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(o, style.dotRadius, bgPaint);

        // Colored dot
        final dotPaint = Paint()
          ..color = style.color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
            o, isSelected ? style.dotRadius : style.dotRadius - 1.5, dotPaint);
      }
    }
  }

  // ─── Path builders ─────────────────────────────────────────────────────────

  Path? _buildSmoothPath(List<Offset> offsets, double cutoffX) {
    if (offsets.isEmpty) return null;
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);

    for (int i = 0; i < offsets.length - 1; i++) {
      final p0 = offsets[i];
      final p1 = offsets[i + 1];

      if (p0.dx > cutoffX) break;

      // Cubic bezier control points
      final cp1 = Offset((p0.dx + p1.dx) / 2, p0.dy);
      final cp2 = Offset((p0.dx + p1.dx) / 2, p1.dy);

      if (p1.dx <= cutoffX) {
        path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
      } else {
        // Partial segment — interpolate to cutoff
        final t = (cutoffX - p0.dx) / (p1.dx - p0.dx);
        final endPoint = _cubicBezierPoint(p0, cp1, cp2, p1, t);
        final partialCp1 = Offset(
          p0.dx + t * (cp1.dx - p0.dx),
          p0.dy + t * (cp1.dy - p0.dy),
        );
        final partialCp2 = Offset(
          cp1.dx + t * (cp2.dx - cp1.dx),
          cp1.dy + t * (cp2.dy - cp1.dy),
        );
        path.cubicTo(
          partialCp1.dx,
          partialCp1.dy,
          partialCp2.dx,
          partialCp2.dy,
          endPoint.dx,
          endPoint.dy,
        );
        break;
      }
    }
    return path;
  }

  Path? _buildStraightPath(List<Offset> offsets, double cutoffX) {
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

  Offset _cubicBezierPoint(
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3,
    double t,
  ) {
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
    if (selectedLineIndex < 0 || selectedPointIndex < 0) return;
    if (selectedLineIndex >= data.lines.length) return;

    final line = data.lines[selectedLineIndex];
    if (selectedPointIndex >= line.points.length) return;

    final point = line.points[selectedPointIndex];
    final count = line.points.length;
    final slotWidth = count <= 1 ? width : width / (count - 1);
    final x =
        count == 1 ? left + width / 2 : left + selectedPointIndex * slotWidth;
    final y = top + ChartUtils.valueToY(point.y, data.minY, maxY, height);
    final style = data.tooltipStyle;

    ChartUtils.drawTooltip(
      canvas,
      label: ChartUtils.formatValue(point.y),
      x: x,
      y: y,
      backgroundColor: style.backgroundColor,
      textStyle: style.textStyle,
      borderRadius: style.borderRadius,
      padding: style.padding,
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  double _clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.selectedLineIndex != selectedLineIndex ||
        oldDelegate.selectedPointIndex != selectedPointIndex ||
        oldDelegate.data != data ||
        oldDelegate.maxY != maxY;
  }

  /// Returns the [lineIndex, pointIndex] of the nearest data point
  /// to [localPosition], or [-1, -1] if none is close enough.
  List<int> indexFromTap(Offset localPosition, Size size) {
    const chartLeft = _leftPadding;
    const chartTop = _topPadding;
    final chartWidth = size.width - chartLeft;
    final chartHeight = size.height - _bottomPadding - chartTop;

    double minDist = 30.0; // tap threshold in pixels
    int bestLine = -1;
    int bestPoint = -1;

    for (int li = 0; li < data.lines.length; li++) {
      final points = data.lines[li].points;
      final count = points.length;
      final slotWidth = count <= 1 ? chartWidth : chartWidth / (count - 1);

      for (int pi = 0; pi < count; pi++) {
        final x = count == 1
            ? chartLeft + chartWidth / 2
            : chartLeft + pi * slotWidth;
        final y = chartTop +
            ChartUtils.valueToY(points[pi].y, data.minY, maxY, chartHeight);
        final dist = (localPosition - Offset(x, y)).distance;
        if (dist < minDist) {
          minDist = dist;
          bestLine = li;
          bestPoint = pi;
        }
      }
    }
    return [bestLine, bestPoint];
  }
}
