import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'radar_chart_data.dart';

/// The [CustomPainter] responsible for rendering the radar/spider chart.
///
/// Draws in this order:
/// 1. Concentric polygon grid rings
/// 2. Axis spoke lines from center to each label
/// 3. Axis labels around the outside
/// 4. Dataset polygons (animated, filled + stroked)
/// 5. Dot indicators at each data point
class RadarChartPainter extends CustomPainter {
  /// The chart data containing datasets and all style configs.
  final RadarChartData data;

  /// Animation progress from 0.0 (nothing drawn) to 1.0 (fully drawn).
  final double animationProgress;

  /// Index of the highlighted dataset. -1 means all visible equally.
  final int selectedIndex;

  const RadarChartPainter({
    required this.data,
    required this.animationProgress,
    required this.selectedIndex,
  });

  // ─── Layout constants ──────────────────────────────────────────────────────
  static const double _labelPadding = 24.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - _labelPadding;

    if (radius <= 0) return;

    final axisCount = data.labels.length;
    if (axisCount < 3) return;

    _drawGrid(canvas, center, radius, axisCount);
    _drawSpokes(canvas, center, radius, axisCount);
    _drawLabels(canvas, center, radius, axisCount);
    _drawDatasets(canvas, center, radius, axisCount);
  }

  // ─── Grid rings ────────────────────────────────────────────────────────────

  void _drawGrid(
    Canvas canvas,
    Offset center,
    double radius,
    int axisCount,
  ) {
    if (!data.gridStyle.showGrid) return;

    final paint = Paint()
      ..color =
          data.gridStyle.gridColor.withValues(alpha: data.gridStyle.gridOpacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final levels = data.gridStyle.gridLevels;

    for (int level = 1; level <= levels; level++) {
      final r = radius * (level / levels);
      final path = Path();

      for (int i = 0; i < axisCount; i++) {
        final angle = _angleForAxis(i, axisCount);
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  // ─── Spokes ────────────────────────────────────────────────────────────────

  void _drawSpokes(
    Canvas canvas,
    Offset center,
    double radius,
    int axisCount,
  ) {
    final paint = Paint()
      ..color = data.gridStyle.spokeColor
          .withValues(alpha: data.gridStyle.spokeOpacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < axisCount; i++) {
      final angle = _angleForAxis(i, axisCount);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), paint);
    }
  }

  // ─── Labels ────────────────────────────────────────────────────────────────

  void _drawLabels(
    Canvas canvas,
    Offset center,
    double radius,
    int axisCount,
  ) {
    final labelRadius = radius + _labelPadding - 4;

    for (int i = 0; i < axisCount; i++) {
      final angle = _angleForAxis(i, axisCount);
      final x = center.dx + labelRadius * math.cos(angle);
      final y = center.dy + labelRadius * math.sin(angle);

      final tp = TextPainter(
        text: TextSpan(
          text: data.labels[i],
          style: data.gridStyle.labelStyle,
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 70);

      // Offset label so it doesn't overlap the spoke tip
      double dx = x - tp.width / 2;
      double dy = y - tp.height / 2;

      // Nudge based on quadrant
      if (math.cos(angle) > 0.1) dx += 4;
      if (math.cos(angle) < -0.1) dx -= 4;
      if (math.sin(angle) > 0.1) dy += 4;
      if (math.sin(angle) < -0.1) dy -= 4;

      tp.paint(canvas, Offset(dx, dy));
    }
  }

  // ─── Datasets ──────────────────────────────────────────────────────────────

  void _drawDatasets(
    Canvas canvas,
    Offset center,
    double radius,
    int axisCount,
  ) {
    for (int di = 0; di < data.datasets.length; di++) {
      final dataset = data.datasets[di];
      final style = dataset.style;
      final isSelected = selectedIndex == di;
      final isDeselected = selectedIndex != -1 && !isSelected;

      final opacity = isDeselected ? 0.2 : 1.0;
      final fillOpacity = isDeselected ? 0.05 : style.fillOpacity;

      // Build polygon points
      final points = _buildPoints(dataset, center, radius, axisCount);

      // ── Fill ──────────────────────────────────────────────────────────
      final fillPath = Path();
      for (int i = 0; i < points.length; i++) {
        if (i == 0) {
          fillPath.moveTo(points[i].dx, points[i].dy);
        } else {
          fillPath.lineTo(points[i].dx, points[i].dy);
        }
      }
      fillPath.close();

      final fillPaint = Paint()
        ..color = style.color.withValues(alpha: fillOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawPath(fillPath, fillPaint);

      // ── Stroke ────────────────────────────────────────────────────────
      final strokePaint = Paint()
        ..color = style.color.withValues(alpha: opacity)
        ..strokeWidth = isSelected ? style.strokeWidth + 1.0 : style.strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(fillPath, strokePaint);

      // ── Dots ──────────────────────────────────────────────────────────
      if (style.showDots) {
        for (final point in points) {
          // White background
          canvas.drawCircle(
            point,
            style.dotRadius,
            Paint()..color = Colors.white,
          );
          // Colored dot
          canvas.drawCircle(
            point,
            style.dotRadius - 1.5,
            Paint()
              ..color = style.color.withValues(alpha: opacity)
              ..style = PaintingStyle.fill,
          );
        }
      }
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /// Builds the list of pixel [Offset] points for a dataset polygon,
  /// scaled by [animationProgress] from the center outward.
  List<Offset> _buildPoints(
    RadarDataset dataset,
    Offset center,
    double radius,
    int axisCount,
  ) {
    final range = data.maxValue - data.minValue;
    final points = <Offset>[];

    for (int i = 0; i < axisCount; i++) {
      final value = i < dataset.values.length ? dataset.values[i] : 0.0;
      final clamped = value.clamp(data.minValue, data.maxValue);
      final fraction = range == 0 ? 0.0 : (clamped - data.minValue) / range;
      final r = radius * fraction * animationProgress;
      final angle = _angleForAxis(i, axisCount);
      points.add(Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      ));
    }
    return points;
  }

  /// Returns the angle in radians for axis [index] out of [total] axes.
  /// Starts from the top (−π/2) and goes clockwise.
  double _angleForAxis(int index, int total) {
    return (2 * math.pi * index / total) - math.pi / 2;
  }

  /// Returns the dataset index nearest to [localPosition], or -1 if none.
  int indexFromTap(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - _labelPadding;
    final axisCount = data.labels.length;

    double minDist = double.infinity;
    int bestIndex = -1;

    for (int di = 0; di < data.datasets.length; di++) {
      final points = _buildPoints(data.datasets[di], center, radius, axisCount);
      for (final point in points) {
        final dist = (localPosition - point).distance;
        if (dist < minDist) {
          minDist = dist;
          bestIndex = di;
        }
      }
    }

    // Only register tap if within 40px of a point
    return minDist < 40.0 ? bestIndex : -1;
  }

  @override
  bool shouldRepaint(RadarChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.data != data;
  }
}
