import 'package:flutter/material.dart';

/// A collection of static utility methods shared across all chart types.
///
/// These helpers handle common math and drawing operations so painters
/// stay clean and focused on rendering logic only.
class ChartUtils {
  ChartUtils._(); // prevent instantiation

  /// Calculates a "nice" maximum y-axis value from [maxDataValue].
  ///
  /// Adds 10% headroom above the highest data point and rounds up to
  /// the nearest "nice" number so axis labels look clean.
  ///
  /// Example:
  /// ```dart
  /// ChartUtils.niceMax(87.0) // → 100.0
  /// ChartUtils.niceMax(43.0) // → 50.0
  /// ```
  static double niceMax(double maxDataValue) {
    if (maxDataValue <= 0) return 10.0;
    final withPadding = maxDataValue * 1.1;
    final magnitude = _magnitude(withPadding);
    return (withPadding / magnitude).ceilToDouble() * magnitude;
  }

  /// Linearly interpolates a [value] from the data range [minY]..[maxY]
  /// into a pixel y-coordinate within [chartHeight].
  ///
  /// Returns the pixel offset from the **top** of the chart area.
  ///
  /// Example:
  /// ```dart
  /// ChartUtils.valueToY(50, 0, 100, 300) // → 150.0 (middle)
  /// ```
  static double valueToY(
    double value,
    double minY,
    double maxY,
    double chartHeight,
  ) {
    if (maxY == minY) return chartHeight;
    return chartHeight - ((value - minY) / (maxY - minY)) * chartHeight;
  }

  /// Formats a numeric [value] for display on axis labels and tooltips.
  ///
  /// - If the value is a whole number, returns it without decimals: `"42"`
  /// - Otherwise returns one decimal place: `"3.5"`
  ///
  /// Example:
  /// ```dart
  /// ChartUtils.formatValue(42.0)  // → "42"
  /// ChartUtils.formatValue(3.567) // → "3.6"
  /// ```
  static String formatValue(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  /// Returns a [Paint] configured for drawing grid lines.
  ///
  /// [color] and [opacity] come from [AxisStyle.gridColor] and
  /// [AxisStyle.gridOpacity].
  static Paint gridPaint(Color color, double opacity) => Paint()
    ..color = color.withValues(alpha: opacity)
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  /// Draws a single text [label] at position ([x], [y]) centered horizontally.
  ///
  /// Uses [style] for font. [maxWidth] constrains text layout.
  static void drawLabel(
    Canvas canvas,
    String label,
    double x,
    double y,
    TextStyle style, {
    double maxWidth = 60,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    tp.paint(canvas, Offset(x - tp.width / 2, y));
  }

  /// Draws a rounded rectangle tooltip bubble centered above ([x], [y]).
  ///
  /// [label] is the text shown inside the bubble.
  /// Uses values from [backgroundColor], [textStyle], [borderRadius],
  /// and [padding] — all sourced from [TooltipStyle].
  static void drawTooltip(
    Canvas canvas, {
    required String label,
    required double x,
    required double y,
    required Color backgroundColor,
    required TextStyle textStyle,
    required double borderRadius,
    required EdgeInsets padding,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: label, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final bubbleW = tp.width + padding.horizontal;
    final bubbleH = tp.height + padding.vertical;
    final left = x - bubbleW / 2;
    final top = y - bubbleH - 8;

    // Draw bubble background
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, bubbleW, bubbleH),
        Radius.circular(borderRadius),
      ),
      bgPaint,
    );

    // Draw triangle pointer
    final path = Path()
      ..moveTo(x - 5, top + bubbleH)
      ..lineTo(x + 5, top + bubbleH)
      ..lineTo(x, top + bubbleH + 6)
      ..close();
    canvas.drawPath(path, bgPaint);

    // Draw text
    tp.paint(canvas, Offset(left + padding.left, top + padding.top));
  }

  // ─── Private helpers ────────────────────────────────────────────────────────

  static double _magnitude(double value) {
    if (value <= 0) return 1;
    final log10 = (value.toString().split('.')[0].length - 1);
    return _pow10(log10);
  }

  static double _pow10(int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) {
      result *= 10;
    }
    return result;
  }
}
