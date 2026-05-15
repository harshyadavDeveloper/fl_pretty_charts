# Changelog

All notable changes to `fl_pretty_charts` will be documented here.
This project follows [Semantic Versioning](https://semver.org/).

---

## 1.1.0

### Added
- ↔️ `FlHorizontalBarChart` — animated horizontal bar chart widget
- Bars grow left to right with smooth animation
- Reuses all existing `BarChartData` models — zero new data classes needed
- Gradient support via `BarStyle.gradient` (use `centerLeft` → `centerRight`)
- Per-bar color override via `BarData.color`
- Tap-to-tooltip interaction on each bar
- `ChartTheme` support via `theme` parameter
- Y-axis category labels on the left
- Vertical grid lines with configurable divisions and opacity
- 📸 Added chart screenshots to README

---

## 1.0.0 — Stable Release 🎉

### Added

- 🎨 `ChartTheme` integration across all 4 chart widgets
  - `FlBarChart(theme: ChartTheme.ocean())` — overrides bar color
  - `FlLineChart(theme: ChartTheme.sunset())` — overrides line series colors
  - `FlPieChart(theme: ChartTheme.forest())` — overrides segment colors
  - `FlRadarChart(theme: ChartTheme.defaultTheme())` — overrides dataset colors
- 🏷️ `LegendWidget` — standalone reusable legend widget
  - `LegendItem` — single color + label item
  - Configurable dot size, spacing, alignment, shape
  - Per-item text style override
- All 4 chart types stable and production ready
- Full backward compatibility — no breaking changes

### Charts Included

- ✅ `FlBarChart` — animated bar chart with tap tooltips
- ✅ `FlLineChart` — smooth bezier line chart, multi-line
- ✅ `FlPieChart` — animated pie and donut chart
- ✅ `FlRadarChart` — radar/spider chart, multi-dataset

---

## 0.9.0

### Added

- 🕸️ `FlRadarChart` — animated radar/spider chart widget
- `RadarChartData` — main data model with labels, datasets, and style config
- `RadarDataset` — single data series with values, label, and style
- `RadarDatasetStyle` — stroke, fill opacity, dot radius configuration
- `RadarGridStyle` — concentric polygon grid, spoke lines, axis labels
- `RadarLegendStyle` — legend with dot size and spacing config
- Multi-dataset support — overlay multiple series on one chart
- Animated polygon reveal from center outward
- Concentric polygon grid rings with configurable levels
- Axis spoke lines from center to each label
- Axis labels with smart quadrant-based nudging
- Tap-to-highlight datasets with opacity fade on others
- Legend tap to highlight/deselect datasets
- Dot indicators at each data point
- Full dartdoc on all public APIs

---

## 0.5.0

### Added

- 🥧 `FlPieChart` — animated pie and donut chart widget
- `PieChartData` — main data model with full style configuration
- `PieSegment` — single segment with value, label, color, optional gradient
- `LegendStyle` — configurable legend with position, dot size, spacing
- `CenterLabelStyle` — title + value label for donut center
- `PieTooltipStyle` — tooltip appearance configuration
- Donut variant via `PieChartData.donut = true`
- Configurable inner radius via `donutRadius`
- Tap-to-expand segments with glow highlight effect
- Legend tap to highlight/deselect segments
- Animated opacity on unselected legend items
- Percentage display in legend labels
- Configurable segment gap and start angle
- Full dartdoc on all public APIs

---

## 0.1.2

### Fixed

- Replaced `withOpacity()` with `withValues()` for Flutter 3.27+ compatibility
- Switched CI analyze flag from `--fatal-infos` to `--fatal-warnings`
- Bumped Flutter version in all CI/CD workflows to 3.27.0

---

## 0.1.1

### Fixed

- Improved CI/CD pipeline with pub-credentials.json based publishing
- Updated publish workflow for more reliable pub.dev deployment

## 0.1.0

### Added

- 📈 `FlLineChart` — animated line chart widget with left-to-right draw
- `LineChartData` — main data model for line charts
- `LineData` — single line series with points and style config
- `LinePoint` — individual data point with x, y, and label
- `LineStyle` — stroke width, color, gradient, fill, dots, smooth toggle
- `AxisLineStyle` — grid and axis config for line charts
- `LineTooltipStyle` — tooltip appearance for line charts
- Smooth bezier curves between data points
- Gradient area fill below each line
- Animated left-to-right line draw
- Dot indicators at each data point with tap highlight
- Multi-line support — render multiple series on one chart
- Tap-to-tooltip interaction on data points

## 0.0.1

### Added

- 📊 `FlBarChart` — animated bar chart widget
- `BarChartData` — main data model with full style configuration
- `BarData` — single bar model with value, label, optional color override
- `BarStyle` — border radius, width fraction, gradient support
- `AxisStyle` — grid lines, y-axis divisions, label text style
- `TooltipStyle` — tap tooltip appearance configuration
- `ChartAnimation` — animation config with 4 presets:
  - `elegant()` — 1200ms easeOutCubic
  - `snappy()` — 400ms easeOutBack
  - `bouncy()` — 800ms elasticOut
  - `none()` — instant render
- `ChartTheme` — 4 built-in color palettes:
  - `defaultTheme()` — indigo, teal, amber, orange, purple
  - `ocean()` — cool blue-green palette
  - `sunset()` — warm reds and oranges
  - `forest()` — nature-inspired greens
- `ChartUtils` — shared drawing utilities (niceMax, valueToY, formatValue)
- `ChartAnimationMixin` — reusable animation lifecycle mixin
- Zero external dependencies — pure Flutter CustomPainter
- Full dartdoc documentation on all public APIs
- Full test suite — 27 tests passing
- Example app demonstrating all bar chart configurations
