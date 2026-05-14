import 'package:flutter/material.dart';

/// Represents a single data series on a radar chart.
///
/// Each [RadarDataset] holds a list of [values] (one per axis),
/// a [label] for the legend, and a [style] controlling appearance.
///
/// The number of values must match [RadarChartData.labels].length.
///
/// Example:
/// ```dart
/// RadarDataset(
///   values: [80, 90, 70, 85, 60],
///   label: 'Flutter',
///   style: RadarDatasetStyle(
///     color: Color(0xFF5C6BC0),
///     fillOpacity: 0.3,
///   ),
/// )
/// ```
class RadarDataset {
  /// The data values for each axis. Must match the number of labels.
  final List<double> values;

  /// Display name for this dataset. Used in the legend.
  final String label;

  /// Visual style for this dataset.
  final RadarDatasetStyle style;

  const RadarDataset({
    required this.values,
    required this.label,
    this.style = const RadarDatasetStyle(),
  });
}

/// Style configuration for a single radar dataset.
///
/// Controls stroke color, width, fill opacity, and dot appearance.
///
/// Example:
/// ```dart
/// RadarDatasetStyle(
///   color: Colors.indigo,
///   strokeWidth: 2.5,
///   fillOpacity: 0.25,
///   showDots: true,
///   dotRadius: 4.0,
/// )
/// ```
class RadarDatasetStyle {
  /// The color of the polygon stroke and fill.
  final Color color;

  /// Width of the polygon stroke. Defaults to `2.5`.
  final double strokeWidth;

  /// Opacity of the filled polygon area. Defaults to `0.25`.
  final double fillOpacity;

  /// Whether to show dot indicators at each data point.
  final bool showDots;

  /// Radius of the dot indicators. Defaults to `4.0`.
  final double dotRadius;

  const RadarDatasetStyle({
    this.color = const Color(0xFF5C6BC0),
    this.strokeWidth = 2.5,
    this.fillOpacity = 0.25,
    this.showDots = true,
    this.dotRadius = 4.0,
  });
}

/// Style configuration for radar chart grid lines and axis.
///
/// Example:
/// ```dart
/// RadarGridStyle(
///   gridColor: Colors.grey,
///   gridOpacity: 0.25,
///   gridLevels: 5,
///   showGrid: true,
///   labelStyle: TextStyle(fontSize: 11),
/// )
/// ```
class RadarGridStyle {
  /// Color of the concentric polygon grid lines.
  final Color gridColor;

  /// Opacity of the grid lines. Defaults to `0.25`.
  final double gridOpacity;

  /// Number of concentric polygon rings. Defaults to `5`.
  final int gridLevels;

  /// Whether to show the grid rings. Defaults to `true`.
  final bool showGrid;

  /// Text style for axis labels around the chart.
  final TextStyle labelStyle;

  /// Color of the axis spoke lines from center to edge.
  final Color spokeColor;

  /// Opacity of the spoke lines. Defaults to `0.3`.
  final double spokeOpacity;

  const RadarGridStyle({
    this.gridColor = const Color(0xFF9E9E9E),
    this.gridOpacity = 0.25,
    this.gridLevels = 5,
    this.showGrid = true,
    this.labelStyle = const TextStyle(
      fontSize: 11,
      color: Color(0xFF616161),
    ),
    this.spokeColor = const Color(0xFF9E9E9E),
    this.spokeOpacity = 0.3,
  });
}

/// Style configuration for radar chart legend.
class RadarLegendStyle {
  /// Whether to show the legend. Defaults to `true`.
  final bool show;

  /// Text style for legend labels.
  final TextStyle textStyle;

  /// Size of the colored dot indicator. Defaults to `10.0`.
  final double dotSize;

  /// Horizontal spacing between legend items. Defaults to `16.0`.
  final double spacing;

  const RadarLegendStyle({
    this.show = true,
    this.textStyle = const TextStyle(
      fontSize: 12,
      color: Color(0xFF616161),
    ),
    this.dotSize = 10.0,
    this.spacing = 16.0,
  });
}

/// The main data class for [FlRadarChart].
///
/// Holds axis labels, one or more datasets, and all visual config.
///
/// Example:
/// ```dart
/// RadarChartData(
///   labels: ['Speed', 'Power', 'Agility', 'Defense', 'Stamina'],
///   datasets: [
///     RadarDataset(
///       values: [80, 90, 70, 85, 60],
///       label: 'Hero A',
///       style: RadarDatasetStyle(color: Color(0xFF5C6BC0)),
///     ),
///     RadarDataset(
///       values: [60, 70, 85, 60, 90],
///       label: 'Hero B',
///       style: RadarDatasetStyle(color: Color(0xFF26A69A)),
///     ),
///   ],
/// )
/// ```
class RadarChartData {
  /// The axis labels displayed around the chart.
  /// Length must match each [RadarDataset.values].length.
  final List<String> labels;

  /// One or more datasets to render on the chart.
  final List<RadarDataset> datasets;

  /// The maximum value on each axis. Defaults to `100.0`.
  final double maxValue;

  /// The minimum value on each axis. Defaults to `0.0`.
  final double minValue;

  /// Grid and axis style configuration.
  final RadarGridStyle gridStyle;

  /// Legend style configuration.
  final RadarLegendStyle legendStyle;

  const RadarChartData({
    required this.labels,
    required this.datasets,
    this.maxValue = 100.0,
    this.minValue = 0.0,
    this.gridStyle = const RadarGridStyle(),
    this.legendStyle = const RadarLegendStyle(),
  });
}
