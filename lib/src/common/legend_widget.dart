import 'package:flutter/material.dart';

/// A standalone legend widget usable with any fl_pretty_charts chart
/// or independently in your own layouts.
///
/// Displays a row of colored dot + label pairs, wrapping onto
/// multiple lines if needed.
///
/// Example — use alongside any chart:
/// ```dart
/// Column(
///   children: [
///     FlBarChart(data: myData),
///     LegendWidget(
///       items: [
///         LegendItem(color: Color(0xFF5C6BC0), label: 'Revenue'),
///         LegendItem(color: Color(0xFF26A69A), label: 'Expenses'),
///       ],
///     ),
///   ],
/// )
/// ```
class LegendWidget extends StatelessWidget {
  /// The list of items to display in the legend.
  final List<LegendItem> items;

  /// Size of each colored dot. Defaults to `10.0`.
  final double dotSize;

  /// Horizontal spacing between items. Defaults to `16.0`.
  final double spacing;

  /// Vertical spacing between wrapped rows. Defaults to `8.0`.
  final double runSpacing;

  /// Text style for all legend labels.
  final TextStyle textStyle;

  /// Alignment of the legend items. Defaults to [WrapAlignment.center].
  final WrapAlignment alignment;

  /// Shape of the color indicator. Defaults to [BoxShape.circle].
  final BoxShape dotShape;

  const LegendWidget({
    super.key,
    required this.items,
    this.dotSize = 10.0,
    this.spacing = 16.0,
    this.runSpacing = 8.0,
    this.textStyle = const TextStyle(
      fontSize: 12,
      color: Color(0xFF616161),
    ),
    this.alignment = WrapAlignment.center,
    this.dotShape = BoxShape.circle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: alignment,
      spacing: spacing,
      runSpacing: runSpacing,
      children: items.map((item) => _buildItem(item)).toList(),
    );
  }

  Widget _buildItem(LegendItem item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: item.color,
            shape: dotShape,
          ),
        ),
        const SizedBox(width: 5),
        Text(item.label, style: item.textStyle ?? textStyle),
      ],
    );
  }
}

/// A single item in a [LegendWidget].
///
/// Example:
/// ```dart
/// LegendItem(color: Color(0xFF5C6BC0), label: 'Revenue')
/// LegendItem(color: Color(0xFF26A69A), label: 'Expenses',
///   textStyle: TextStyle(fontWeight: FontWeight.bold))
/// ```
class LegendItem {
  /// The color of the dot indicator.
  final Color color;

  /// The label text displayed next to the dot.
  final String label;

  /// Optional per-item text style override.
  /// If null, the [LegendWidget.textStyle] is used.
  final TextStyle? textStyle;

  const LegendItem({
    required this.color,
    required this.label,
    this.textStyle,
  });
}
