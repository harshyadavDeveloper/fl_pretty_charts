import 'package:flutter/material.dart';

/// The axis along which an annotation line is drawn.
enum AnnotationAxis {
  /// A horizontal line drawn at a specific y value.
  horizontal,

  /// A vertical line drawn at a specific x index.
  vertical,
}

/// Position of the annotation label relative to the line.
enum AnnotationLabelPosition {
  /// Label drawn at the start (left for horizontal, top for vertical).
  start,

  /// Label drawn in the center of the line.
  center,

  /// Label drawn at the end (right for horizontal, bottom for vertical).
  end,
}

/// A single annotation line drawn on top of a chart.
///
/// Use [ChartAnnotation.horizontal] for y-value reference lines
/// (e.g. target, average, threshold) and [ChartAnnotation.vertical]
/// for x-index reference lines (e.g. a specific date or event).
///
/// Example — horizontal target line:
/// ```dart
/// ChartAnnotation.horizontal(
///   value: 80,
///   label: 'Target',
///   color: Colors.red,
/// )
/// ```
///
/// Example — vertical event line:
/// ```dart
/// ChartAnnotation.vertical(
///   index: 3,
///   label: 'Launch',
///   color: Colors.green,
/// )
/// ```
class ChartAnnotation {
  /// The axis this annotation is drawn on.
  final AnnotationAxis axis;

  /// The y value for horizontal annotations.
  /// Ignored for vertical annotations.
  final double? value;

  /// The x index for vertical annotations.
  /// Ignored for horizontal annotations.
  final int? index;

  /// Optional label shown next to the annotation line.
  final String? label;

  /// Color of the annotation line and label. Defaults to red.
  final Color color;

  /// Width of the annotation line. Defaults to `1.5`.
  final double strokeWidth;

  /// Dash pattern for the line. Empty list means solid line.
  /// Example: `[8, 4]` — 8px dash, 4px gap.
  final List<double> dashPattern;

  /// Text style for the label.
  final TextStyle? labelStyle;

  /// Position of the label along the line.
  final AnnotationLabelPosition labelPosition;

  /// Vertical offset of the label from the line. Defaults to `-14.0`.
  final double labelOffsetY;

  const ChartAnnotation._({
    required this.axis,
    this.value,
    this.index,
    this.label,
    this.color = const Color(0xFFEF5350),
    this.strokeWidth = 1.5,
    this.dashPattern = const [8, 4],
    this.labelStyle,
    this.labelPosition = AnnotationLabelPosition.end,
    this.labelOffsetY = -14.0,
  });

  /// Creates a horizontal annotation line at [value] on the y-axis.
  ///
  /// Example:
  /// ```dart
  /// ChartAnnotation.horizontal(
  ///   value: 80,
  ///   label: 'Target',
  ///   color: Colors.red,
  ///   dashPattern: [8, 4],
  /// )
  /// ```
  factory ChartAnnotation.horizontal({
    required double value,
    String? label,
    Color color = const Color(0xFFEF5350),
    double strokeWidth = 1.5,
    List<double> dashPattern = const [8, 4],
    TextStyle? labelStyle,
    AnnotationLabelPosition labelPosition = AnnotationLabelPosition.end,
    double labelOffsetY = -14.0,
  }) =>
      ChartAnnotation._(
        axis: AnnotationAxis.horizontal,
        value: value,
        label: label,
        color: color,
        strokeWidth: strokeWidth,
        dashPattern: dashPattern,
        labelStyle: labelStyle,
        labelPosition: labelPosition,
        labelOffsetY: labelOffsetY,
      );

  /// Creates a vertical annotation line at x-axis [index].
  ///
  /// Example:
  /// ```dart
  /// ChartAnnotation.vertical(
  ///   index: 3,
  ///   label: 'Launch',
  ///   color: Colors.green,
  /// )
  /// ```
  factory ChartAnnotation.vertical({
    required int index,
    String? label,
    Color color = const Color(0xFF66BB6A),
    double strokeWidth = 1.5,
    List<double> dashPattern = const [8, 4],
    TextStyle? labelStyle,
    AnnotationLabelPosition labelPosition = AnnotationLabelPosition.start,
    double labelOffsetY = -14.0,
  }) =>
      ChartAnnotation._(
        axis: AnnotationAxis.vertical,
        index: index,
        label: label,
        color: color,
        strokeWidth: strokeWidth,
        dashPattern: dashPattern,
        labelStyle: labelStyle,
        labelPosition: labelPosition,
        labelOffsetY: labelOffsetY,
      );
}

/// Utility class for drawing [ChartAnnotation] lines on a [Canvas].
///
/// Used internally by bar, line, and area chart painters.
class AnnotationPainter {
  AnnotationPainter._();

  /// Draws all [annotations] on the [canvas] within the chart area defined
  /// by [chartLeft], [chartTop], [chartWidth], [chartHeight], [chartBottom].
  ///
  /// [maxY] and [minY] are used to convert y values to pixel positions.
  /// [pointCount] and [slotWidth] are used for vertical annotations.
  static void draw({
    required Canvas canvas,
    required List<ChartAnnotation> annotations,
    required double chartLeft,
    required double chartTop,
    required double chartWidth,
    required double chartHeight,
    required double chartBottom,
    required double maxY,
    required double minY,
    required int pointCount,
    required double slotWidth,
    required double animationProgress,
  }) {
    for (final annotation in annotations) {
      if (annotation.axis == AnnotationAxis.horizontal) {
        _drawHorizontal(
          canvas: canvas,
          annotation: annotation,
          chartLeft: chartLeft,
          chartTop: chartTop,
          chartWidth: chartWidth * animationProgress,
          chartHeight: chartHeight,
          chartBottom: chartBottom,
          maxY: maxY,
          minY: minY,
        );
      } else {
        _drawVertical(
          canvas: canvas,
          annotation: annotation,
          chartLeft: chartLeft,
          chartTop: chartTop,
          chartWidth: chartWidth,
          chartHeight: chartHeight,
          chartBottom: chartBottom,
          pointCount: pointCount,
          slotWidth: slotWidth,
          animationProgress: animationProgress,
        );
      }
    }
  }

  // ── Horizontal ─────────────────────────────────────────────────────────────

  static void _drawHorizontal({
    required Canvas canvas,
    required ChartAnnotation annotation,
    required double chartLeft,
    required double chartTop,
    required double chartWidth,
    required double chartHeight,
    required double chartBottom,
    required double maxY,
    required double minY,
  }) {
    if (annotation.value == null) return;
    final range = maxY - minY;
    if (range <= 0) return;

    final fraction = (annotation.value! - minY) / range;
    final y = chartBottom - fraction * chartHeight;

    if (y < chartTop || y > chartBottom) return;

    final paint = Paint()
      ..color = annotation.color
      ..strokeWidth = annotation.strokeWidth
      ..style = PaintingStyle.stroke;

    _drawDashedLine(
      canvas: canvas,
      start: Offset(chartLeft, y),
      end: Offset(chartLeft + chartWidth, y),
      paint: paint,
      dashPattern: annotation.dashPattern,
    );

    if (annotation.label != null) {
      double labelX;
      switch (annotation.labelPosition) {
        case AnnotationLabelPosition.start:
          labelX = chartLeft + 4;
          break;
        case AnnotationLabelPosition.center:
          labelX = chartLeft + chartWidth / 2;
          break;
        case AnnotationLabelPosition.end:
          labelX = chartLeft + chartWidth - 4;
          break;
      }

      _drawAnnotationLabel(
        canvas: canvas,
        label: annotation.label!,
        x: labelX,
        y: y + annotation.labelOffsetY,
        color: annotation.color,
        style: annotation.labelStyle,
        position: annotation.labelPosition,
      );
    }
  }

  // ── Vertical ───────────────────────────────────────────────────────────────

  static void _drawVertical({
    required Canvas canvas,
    required ChartAnnotation annotation,
    required double chartLeft,
    required double chartTop,
    required double chartWidth,
    required double chartHeight,
    required double chartBottom,
    required int pointCount,
    required double slotWidth,
    required double animationProgress,
  }) {
    if (annotation.index == null) return;
    if (annotation.index! < 0 || annotation.index! >= pointCount) return;

    double x;
    if (pointCount <= 1) {
      x = chartLeft + chartWidth / 2;
    } else if (slotWidth == 0) {
      // Bar chart slot-based
      x = chartLeft + slotWidth * annotation.index! + slotWidth / 2;
    } else {
      // Line/area point-based
      x = chartLeft + annotation.index! * slotWidth;
    }

    if (x * animationProgress < chartLeft) return;

    final paint = Paint()
      ..color = annotation.color
      ..strokeWidth = annotation.strokeWidth
      ..style = PaintingStyle.stroke;

    _drawDashedLine(
      canvas: canvas,
      start: Offset(x, chartTop),
      end: Offset(x, chartBottom),
      paint: paint,
      dashPattern: annotation.dashPattern,
    );

    if (annotation.label != null) {
      double labelY;
      switch (annotation.labelPosition) {
        case AnnotationLabelPosition.start:
          labelY = chartTop + 4;
          break;
        case AnnotationLabelPosition.center:
          labelY = chartTop + chartHeight / 2;
          break;
        case AnnotationLabelPosition.end:
          labelY = chartBottom - 20;
          break;
      }

      _drawAnnotationLabel(
        canvas: canvas,
        label: annotation.label!,
        x: x + 4,
        y: labelY,
        color: annotation.color,
        style: annotation.labelStyle,
        position: AnnotationLabelPosition.start,
      );
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static void _drawDashedLine({
    required Canvas canvas,
    required Offset start,
    required Offset end,
    required Paint paint,
    required List<double> dashPattern,
  }) {
    if (dashPattern.isEmpty) {
      canvas.drawLine(start, end, paint);
      return;
    }

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = (dx * dx + dy * dy) < 0 ? 0.0 : (dx * dx + dy * dy);
    final total = length < 0 ? 0.0 : length;
    if (total == 0) return;

    final distance = (Offset(dx, dy)).distance;
    if (distance == 0) return;

    final unitX = dx / distance;
    final unitY = dy / distance;

    double drawn = 0;
    int dashIndex = 0;
    bool drawing = true;

    while (drawn < distance) {
      final dashLen = dashPattern[dashIndex % dashPattern.length];
      final segEnd = (drawn + dashLen).clamp(0.0, distance);

      if (drawing) {
        canvas.drawLine(
          Offset(start.dx + unitX * drawn, start.dy + unitY * drawn),
          Offset(start.dx + unitX * segEnd, start.dy + unitY * segEnd),
          paint,
        );
      }

      drawn = segEnd;
      dashIndex++;
      drawing = !drawing;
    }
  }

  static void _drawAnnotationLabel({
    required Canvas canvas,
    required String label,
    required double x,
    required double y,
    required Color color,
    required TextStyle? style,
    required AnnotationLabelPosition position,
  }) {
    final effectiveStyle = style ??
        TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        );

    final tp = TextPainter(
      text: TextSpan(text: label, style: effectiveStyle),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 100);

    double paintX = x;
    if (position == AnnotationLabelPosition.end) {
      paintX = x - tp.width;
    } else if (position == AnnotationLabelPosition.center) {
      paintX = x - tp.width / 2;
    }

    // Background pill
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        paintX - 3,
        y - 2,
        tp.width + 6,
        tp.height + 4,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      bgRect,
      Paint()..color = color.withValues(alpha: 0.12),
    );

    tp.paint(canvas, Offset(paintX, y));
  }
}
