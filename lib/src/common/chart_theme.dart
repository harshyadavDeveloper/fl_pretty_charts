import 'package:flutter/material.dart';

/// Defines a color theme for fl_pretty_charts.
///
/// A [ChartTheme] can be passed to any chart widget to apply a consistent
/// color palette across all chart types.
///
/// Use the built-in presets or create your own:
/// ```dart
/// // Use a preset
/// ChartTheme.ocean()
///
/// // Create a custom theme
/// ChartTheme(
///   colors: [Colors.pink, Colors.orange, Colors.yellow],
///   background: Colors.white,
///   legendTextStyle: TextStyle(fontSize: 12),
/// )
/// ```
class ChartTheme {
  /// The ordered list of colors used for bars, segments, lines, etc.
  final List<Color> colors;

  /// Background color of the chart canvas. Defaults to transparent.
  final Color background;

  /// Text style applied to legend labels.
  final TextStyle legendTextStyle;

  const ChartTheme({
    required this.colors,
    this.background = Colors.transparent,
    this.legendTextStyle = const TextStyle(
      fontSize: 12,
      color: Color(0xFF616161),
    ),
  });

  // ─── Built-in presets ───────────────────────────────────────────────────────

  /// A deep, rich indigo-to-teal palette. This is the default theme.
  ///
  /// Colors: Indigo → Teal → Amber → DeepOrange → Purple
  factory ChartTheme.defaultTheme() => const ChartTheme(
        colors: [
          Color(0xFF5C6BC0), // indigo
          Color(0xFF26A69A), // teal
          Color(0xFFFFCA28), // amber
          Color(0xFFFF7043), // deep orange
          Color(0xFFAB47BC), // purple
          Color(0xFF42A5F5), // blue
          Color(0xFF66BB6A), // green
          Color(0xFFEF5350), // red
        ],
      );

  /// A cool ocean-inspired blue-green palette.
  factory ChartTheme.ocean() => const ChartTheme(
        colors: [
          Color(0xFF0077B6),
          Color(0xFF00B4D8),
          Color(0xFF90E0EF),
          Color(0xFF0096C7),
          Color(0xFF48CAE4),
          Color(0xFFADE8F4),
        ],
      );

  /// A warm sunset palette of reds, oranges, and pinks.
  factory ChartTheme.sunset() => const ChartTheme(
        colors: [
          Color(0xFFFF4D6D),
          Color(0xFFFF7B54),
          Color(0xFFFFB26B),
          Color(0xFFFFD56F),
          Color(0xFFFF6B6B),
          Color(0xFFC9184A),
        ],
      );

  /// A nature-inspired green palette.
  factory ChartTheme.forest() => const ChartTheme(
        colors: [
          Color(0xFF2D6A4F),
          Color(0xFF40916C),
          Color(0xFF52B788),
          Color(0xFF74C69D),
          Color(0xFF95D5B2),
          Color(0xFFB7E4C7),
        ],
      );

  /// Returns the color at [index], cycling back to start if index exceeds
  /// the palette length. This ensures charts never run out of colors.
  Color colorAt(int index) => colors[index % colors.length];
}
