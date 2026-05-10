# fl_pretty_charts

[![pub version](https://img.shields.io/pub/v/fl_pretty_charts.svg)](https://pub.dev/packages/fl_pretty_charts)
[![likes](https://img.shields.io/pub/likes/fl_pretty_charts)](https://pub.dev/packages/fl_pretty_charts)
[![pub points](https://img.shields.io/pub/points/fl_pretty_charts)](https://pub.dev/packages/fl_pretty_charts)
[![popularity](https://img.shields.io/pub/popularity/fl_pretty_charts)](https://pub.dev/packages/fl_pretty_charts)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/harshyadavDeveloper/fl_pretty_charts/blob/main/LICENSE)

A beautiful, animated Flutter charts package. Zero external dependencies — built entirely with Flutter's `CustomPainter`.

---

## ✨ Features

- 📊 **Bar Chart** — animated, customizable, interactive
- 🎨 **Gradients & custom colors** — per-bar or global
- 💫 **Smooth animations** — elegant, snappy, bouncy, or none
- 👆 **Interactive tooltips** — tap any bar to reveal its value
- 🎯 **Zero dependencies** — pure Flutter, no third-party packages
- 📐 **Grid lines & axis labels** — clean, configurable
- 🌈 **Built-in themes** — default, ocean, sunset, forest
- 🔒 **Null safe** — Dart 3.x, Flutter 3.10+

---

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  fl_pretty_charts: ^0.0.1
```

Then run:

```bash
flutter pub get
```

---

## 🚀 Quick Start

```dart
import 'package:fl_pretty_charts/fl_pretty_charts.dart';

FlBarChart(
  data: BarChartData(
    bars: [
      BarData(value: 30, label: 'Mon'),
      BarData(value: 80, label: 'Tue'),
      BarData(value: 55, label: 'Wed'),
      BarData(value: 65, label: 'Thu'),
      BarData(value: 40, label: 'Fri'),
    ],
  ),
)
```

---

## 📊 Bar Chart

### Basic usage

```dart
FlBarChart(
  data: BarChartData(
    bars: [
      BarData(value: 120, label: 'Q1'),
      BarData(value: 200, label: 'Q2'),
      BarData(value: 170, label: 'Q3'),
      BarData(value: 240, label: 'Q4'),
    ],
  ),
)
```

### With gradient bars

```dart
FlBarChart(
  data: BarChartData(
    bars: [
      BarData(value: 120, label: 'Q1'),
      BarData(value: 200, label: 'Q2'),
      BarData(value: 170, label: 'Q3'),
      BarData(value: 240, label: 'Q4'),
    ],
    barStyle: BarStyle(
      borderRadius: 12,
      barWidthFraction: 0.5,
      gradient: LinearGradient(
        colors: [Color(0xFF5C6BC0), Color(0xFF26A69A)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
    ),
  ),
  animation: ChartAnimation.elegant(),
  height: 300,
)
```

### With per-bar colors

```dart
FlBarChart(
  data: BarChartData(
    bars: [
      BarData(value: 45, label: 'Jan', color: Colors.red),
      BarData(value: 72, label: 'Feb', color: Colors.purple),
      BarData(value: 60, label: 'Mar', color: Colors.blue),
    ],
  ),
)
```

### With tap callback

```dart
FlBarChart(
  data: BarChartData(
    bars: [
      BarData(value: 30, label: 'Mon'),
      BarData(value: 80, label: 'Tue'),
    ],
  ),
  onBarTapped: (bar, index) {
    print('Tapped ${bar.label}: ${bar.value}');
  },
)
```

---

## 💫 Animation Presets

| Preset | Duration | Curve | Best For |
|---|---|---|---|
| `ChartAnimation()` | 900ms | easeOutCubic | General use (default) |
| `ChartAnimation.elegant()` | 1200ms | easeOutCubic | Dashboards, first impressions |
| `ChartAnimation.snappy()` | 400ms | easeOutBack | Frequently updated data |
| `ChartAnimation.bouncy()` | 800ms | elasticOut | Playful UIs |
| `ChartAnimation.none()` | 0ms | — | No animation |

Custom animation:

```dart
FlBarChart(
  data: myData,
  animation: ChartAnimation(
    duration: Duration(milliseconds: 600),
    curve: Curves.easeInOutQuart,
  ),
)
```

---

## 🌈 Built-in Themes

```dart
ChartTheme.defaultTheme() // indigo, teal, amber, orange, purple
ChartTheme.ocean()        // cool blue-green palette
ChartTheme.sunset()       // warm reds, oranges, pinks
ChartTheme.forest()       // nature-inspired greens
```

---

## 📐 API Reference

### `FlBarChart`

| Property | Type | Default | Description |
|---|---|---|---|
| `data` | `BarChartData` | required | Chart data and styles |
| `animation` | `ChartAnimation` | `ChartAnimation()` | Reveal animation config |
| `height` | `double` | `260.0` | Chart canvas height |
| `decoration` | `BoxDecoration?` | null | Container decoration |
| `padding` | `EdgeInsets` | `EdgeInsets.all(16)` | Outer padding |
| `onBarTapped` | `Function?` | null | Tap callback |

### `BarChartData`

| Property | Type | Default | Description |
|---|---|---|---|
| `bars` | `List<BarData>` | required | The bars to display |
| `defaultColor` | `Color` | indigo | Fallback bar color |
| `barStyle` | `BarStyle` | `BarStyle()` | Bar appearance config |
| `axisStyle` | `AxisStyle` | `AxisStyle()` | Axis and grid config |
| `tooltipStyle` | `TooltipStyle` | `TooltipStyle()` | Tooltip appearance |
| `maxY` | `double?` | auto | Fixed max y value |
| `minY` | `double` | `0.0` | Fixed min y value |

### `BarData`

| Property | Type | Default | Description |
|---|---|---|---|
| `value` | `double` | required | Bar height value |
| `label` | `String` | required | X-axis label |
| `color` | `Color?` | null | Per-bar color override |

### `BarStyle`

| Property | Type | Default | Description |
|---|---|---|---|
| `borderRadius` | `double` | `6.0` | Top corner radius |
| `barWidthFraction` | `double` | `0.55` | Bar width as slot fraction |
| `gradient` | `LinearGradient?` | null | Gradient override |

### `AxisStyle`

| Property | Type | Default | Description |
|---|---|---|---|
| `labelStyle` | `TextStyle` | grey 11px | Axis label text style |
| `gridColor` | `Color` | grey | Grid line color |
| `gridOpacity` | `double` | `0.2` | Grid line opacity |
| `showGrid` | `bool` | `true` | Show/hide grid lines |
| `yAxisDivisions` | `int` | `5` | Number of y divisions |

---

## 🗺️ Roadmap

| Version | Feature |
|---|---|
| `0.0.1` | ✅ Bar Chart |
| `0.1.0` | 🔜 Line Chart — smooth curves, gradient fill |
| `0.5.0` | 🔜 Pie Chart + Donut variant |
| `0.9.0` | 🔜 Radar / Spider Chart |
| `1.0.0` | 🔜 Theming system, Legend widget, stable API |

---

## 🤝 Contributing

Contributions are welcome! Please open an issue or pull request on
[GitHub](https://github.com/harshyadavDeveloper/fl_pretty_charts).

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.