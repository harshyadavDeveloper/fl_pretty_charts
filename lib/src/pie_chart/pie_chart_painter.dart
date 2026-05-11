import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'pie_chart_data.dart';

/// The [CustomPainter] responsible for rendering the pie/donut chart.
///
/// Draws in this order:
/// 1. Each segment (animated sweep, with optional expand on tap)
/// 2. Center label (donut mode only)
class PieChartPainter extends CustomPainter {
  /// The chart data containing segments and all style configs.
  final PieChartData data;

  /// Animation progress from 0.0 (nothing drawn) to 1.0 (fully drawn).
  final double animationProgress;

  /// Index of the currently tapped segment. -1 means none selected.
  final int selectedIndex;

  const PieChartPainter({
    required this.data,
    required this.animationProgress,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.segments.fold(0.0, (sum, s) => sum + s.value);
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final innerRadius = data.donut ? radius * data.donutRadius : 0.0;

    _drawSegments(canvas, size, center, radius, innerRadius, total);

    if (data.donut && data.centerLabel != null) {
      _drawCenterLabel(canvas, center, innerRadius);
    }
  }

  // ─── Segments ──────────────────────────────────────────────────────────────

  void _drawSegments(
    Canvas canvas,
    Size size,
    Offset center,
    double radius,
    double innerRadius,
    double total,
  ) {
    final gapRad = _degToRad(data.segmentGap);
    final startRad = _degToRad(data.startAngle);
    final totalGap = gapRad * data.segments.length;
    final availableAngle = 2 * math.pi * animationProgress - totalGap;

    double currentAngle = startRad;

    for (int i = 0; i < data.segments.length; i++) {
      final segment = data.segments[i];
      final sweepAngle = (segment.value / total) * availableAngle;
      final isSelected = i == selectedIndex;

      // Expand selected segment outward
      Offset segCenter = center;
      if (isSelected) {
        final midAngle = currentAngle + sweepAngle / 2;
        segCenter = Offset(
          center.dx + math.cos(midAngle) * data.expandOffset,
          center.dy + math.sin(midAngle) * data.expandOffset,
        );
      }

      _drawSegment(
        canvas,
        segCenter,
        radius,
        innerRadius,
        currentAngle,
        sweepAngle,
        segment,
        isSelected,
      );

      currentAngle += sweepAngle + gapRad;
    }
  }

  void _drawSegment(
    Canvas canvas,
    Offset center,
    double radius,
    double innerRadius,
    double startAngle,
    double sweepAngle,
    PieSegment segment,
    bool isSelected,
  ) {
    if (sweepAngle <= 0) return;

    final outerRect = Rect.fromCircle(center: center, radius: radius);
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    final path = Path();

    if (data.donut) {
      // Donut: outer arc → inner arc (reversed)
      path.arcTo(outerRect, startAngle, sweepAngle, false);
      path.arcTo(innerRect, startAngle + sweepAngle, -sweepAngle, false);
      path.close();
    } else {
      // Pie: move to center → outer arc → close
      path.moveTo(center.dx, center.dy);
      path.arcTo(outerRect, startAngle, sweepAngle, false);
      path.close();
    }

    // Glow for selected segment
    if (isSelected) {
      final glowPaint = Paint()
        ..color = segment.color.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawPath(path, glowPaint);
    }

    // Fill paint
    final Paint fillPaint;
    if (segment.gradient != null) {
      fillPaint = Paint()
        ..shader = segment.gradient!.createShader(outerRect)
        ..style = PaintingStyle.fill;
    } else {
      fillPaint = Paint()
        ..color =
            isSelected ? segment.color : segment.color.withValues(alpha: 0.88)
        ..style = PaintingStyle.fill;
    }

    canvas.drawPath(path, fillPaint);
  }

  // ─── Center Label ──────────────────────────────────────────────────────────

  void _drawCenterLabel(Canvas canvas, Offset center, double innerRadius) {
    final label = data.centerLabel!;
    final maxWidth = innerRadius * 1.6;

    double totalHeight = 0;
    TextPainter? titlePainter;
    TextPainter? valuePainter;

    if (label.title != null) {
      titlePainter = TextPainter(
        text: TextSpan(text: label.title, style: label.titleStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: maxWidth);
      totalHeight += titlePainter.height + 2;
    }

    if (label.value != null) {
      valuePainter = TextPainter(
        text: TextSpan(text: label.value, style: label.valueStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: maxWidth);
      totalHeight += valuePainter.height;
    }

    var currentY = center.dy - totalHeight / 2;

    if (titlePainter != null) {
      titlePainter.paint(
        canvas,
        Offset(center.dx - titlePainter.width / 2, currentY),
      );
      currentY += titlePainter.height + 2;
    }

    if (valuePainter != null) {
      valuePainter.paint(
        canvas,
        Offset(center.dx - valuePainter.width / 2, currentY),
      );
    }
  }

  // ─── Hit Test ──────────────────────────────────────────────────────────────

  /// Returns the index of the tapped segment or -1 if none was hit.
  int indexFromTap(Offset localPosition, Size size) {
    final total = data.segments.fold(0.0, (sum, s) => sum + s.value);
    if (total <= 0) return -1;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final innerRadius = data.donut ? radius * data.donutRadius : 0.0;

    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);

    // Must be within outer radius and outside inner radius
    if (distance > radius || (data.donut && distance < innerRadius)) {
      return -1;
    }

    // Angle of the tap (normalize to 0..2pi)
    double angle = math.atan2(dy, dx) - _degToRad(data.startAngle);
    if (angle < 0) angle += 2 * math.pi;

    final gapRad = _degToRad(data.segmentGap);
    final totalGap = gapRad * data.segments.length;
    final availableAngle = 2 * math.pi - totalGap;

    double currentAngle = 0;
    for (int i = 0; i < data.segments.length; i++) {
      final sweepAngle = (data.segments[i].value / total) * availableAngle;
      if (angle >= currentAngle && angle < currentAngle + sweepAngle) {
        return i;
      }
      currentAngle += sweepAngle + gapRad;
    }

    return -1;
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  double _degToRad(double degrees) => degrees * math.pi / 180;

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.data != data;
  }
}
