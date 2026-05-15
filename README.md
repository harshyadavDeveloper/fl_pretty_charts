# fl_pretty_charts

[![pub version](https://img.shields.io/pub/v/fl_pretty_charts.svg)](https://pub.dev/packages/fl_pretty_charts)
[![likes](https://img.shields.io/pub/likes/fl_pretty_charts)](https://pub.dev/packages/fl_pretty_charts)
[![pub points](https://img.shields.io/pub/points/fl_pretty_charts)](https://pub.dev/packages/fl_pretty_charts)
[![popularity](https://img.shields.io/pub/popularity/fl_pretty_charts)](https://pub.dev/packages/fl_pretty_charts)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/harshyadavDeveloper/fl_pretty_charts/blob/main/LICENSE)

A beautiful, animated Flutter charts package with zero external dependencies — built entirely with Flutter's `CustomPainter`.

---

## ✨ Features

- 📊 **Bar Chart** — animated, gradient, per-bar colors, tap tooltips
- 📈 **Line Chart** — smooth bezier curves, gradient fill, multi-line
- 🥧 **Pie Chart** — animated sweep, donut variant, center label
- 🕸️ **Radar Chart** — spider/radar, multi-dataset comparison
- 💫 **Smooth animations** — elegant, snappy, bouncy, or none
- 🎨 **Theming system** — apply a palette across all charts in one line
- 🏷️ **Standalone LegendWidget** — reusable anywhere in your layout
- 👆 **Interactive** — tap bars, points, segments, datasets
- 🎯 **Zero dependencies** — pure Flutter, no third-party packages
- 🔒 **Null safe** — Dart 3.x, Flutter 3.10+

---

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  fl_pretty_charts: ^1.0.0
```

Then run:

```bash
flutter pub get
```

---

## 🚀 Quick Start

```dart
import 'package:fl_pretty_charts/fl_pretty_charts.dart';
```

---

## 📊 Bar Chart

```dart
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
  animation: ChartAnimation.elegant(),
  onBarTapped: (bar, index) => print('${bar.label}: ${bar.value}'),
)
```

### With gradient bars

```dart
FlBarChart(
  data: BarChartData(
    bars: [...],
    barStyle: BarStyle(
      borderRadius: 12,
      gradient: LinearGradient(
        colors: [Color(0xFF5C6BC0), Color(0xFF26A69A)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
    ),
  ),
)
```

### API — `FlBarChart`

| Property      | Type             | Default            | Description           |
| ------------- | ---------------- | ------------------ | --------------------- |
| `data`        | `BarChartData`   | required           | Chart data and styles |
| `animation`   | `ChartAnimation` | `ChartAnimation()` | Reveal animation      |
| `theme`       | `ChartTheme?`    | null               | Color theme override  |
| `height`      | `double`         | `260.0`            | Canvas height         |
| `decoration`  | `BoxDecoration?` | null               | Container decoration  |
| `padding`     | `EdgeInsets`     | `all(16)`          | Outer padding         |
| `onBarTapped` | `Function?`      | null               | Tap callback          |

### API — `BarChartData`

| Property       | Type            | Default          | Description         |
| -------------- | --------------- | ---------------- | ------------------- |
| `bars`         | `List<BarData>` | required         | The bars to display |
| `defaultColor` | `Color`         | indigo           | Fallback bar color  |
| `barStyle`     | `BarStyle`      | `BarStyle()`     | Bar appearance      |
| `axisStyle`    | `AxisStyle`     | `AxisStyle()`    | Axis and grid       |
| `tooltipStyle` | `TooltipStyle`  | `TooltipStyle()` | Tooltip appearance  |
| `maxY`         | `double?`       | auto             | Fixed max y value   |
| `minY`         | `double`        | `0.0`            | Fixed min y value   |

---

## 📈 Line Chart

```dart
FlLineChart(
  data: LineChartData(
    lines: [
      LineData(
        points: [
          LinePoint(x: 0, y: 30, label: 'Jan'),
          LinePoint(x: 1, y: 80, label: 'Feb'),
          LinePoint(x: 2, y: 55, label: 'Mar'),
        ],
        label: 'Revenue',
        style: LineStyle(color: Color(0xFF5C6BC0)),
      ),
    ],
  ),
  animation: ChartAnimation.elegant(),
)
```

### Multi-line

```dart
FlLineChart(
  data: LineChartData(
    lines: [
      LineData(points: [...], label: 'Revenue',
        style: LineStyle(color: Color(0xFF5C6BC0))),
      LineData(points: [...], label: 'Expenses',
        style: LineStyle(color: Color(0xFFFF7043))),
    ],
  ),
)
```

### API — `FlLineChart`

| Property        | Type             | Default            | Description           |
| --------------- | ---------------- | ------------------ | --------------------- |
| `data`          | `LineChartData`  | required           | Chart data and styles |
| `animation`     | `ChartAnimation` | `ChartAnimation()` | Reveal animation      |
| `theme`         | `ChartTheme?`    | null               | Color theme override  |
| `height`        | `double`         | `260.0`            | Canvas height         |
| `decoration`    | `BoxDecoration?` | null               | Container decoration  |
| `padding`       | `EdgeInsets`     | `all(16)`          | Outer padding         |
| `onPointTapped` | `Function?`      | null               | Tap callback          |

### API — `LineStyle`

| Property      | Type              | Default | Description          |
| ------------- | ----------------- | ------- | -------------------- |
| `color`       | `Color`           | indigo  | Line stroke color    |
| `strokeWidth` | `double`          | `3.0`   | Line stroke width    |
| `gradient`    | `LinearGradient?` | null    | Gradient stroke      |
| `showFill`    | `bool`            | `true`  | Area fill below line |
| `fillOpacity` | `double`          | `0.2`   | Fill opacity         |
| `showDots`    | `bool`            | `true`  | Dot indicators       |
| `dotRadius`   | `double`          | `4.5`   | Dot radius           |
| `smooth`      | `bool`            | `true`  | Bezier curves        |

---

## 🥧 Pie / Donut Chart

```dart
// Pie chart
FlPieChart(
  data: PieChartData(
    segments: [
      PieSegment(value: 40, label: 'Flutter', color: Color(0xFF5C6BC0)),
      PieSegment(value: 30, label: 'React',   color: Color(0xFF26A69A)),
      PieSegment(value: 20, label: 'Vue',     color: Color(0xFFFFCA28)),
      PieSegment(value: 10, label: 'Other',   color: Color(0xFFEF5350)),
    ],
  ),
)

// Donut chart
FlPieChart(
  data: PieChartData(
    segments: [...],
    donut: true,
    donutRadius: 0.55,
    centerLabel: CenterLabelStyle(
      title: 'Total',
      value: '1,250',
    ),
  ),
)
```

### API — `FlPieChart`

| Property          | Type             | Default            | Description           |
| ----------------- | ---------------- | ------------------ | --------------------- |
| `data`            | `PieChartData`   | required           | Chart data and styles |
| `animation`       | `ChartAnimation` | `ChartAnimation()` | Reveal animation      |
| `theme`           | `ChartTheme?`    | null               | Color theme override  |
| `size`            | `double`         | `260.0`            | Canvas size           |
| `decoration`      | `BoxDecoration?` | null               | Container decoration  |
| `padding`         | `EdgeInsets`     | `all(16)`          | Outer padding         |
| `onSegmentTapped` | `Function?`      | null               | Tap callback          |

### API — `PieChartData`

| Property       | Type                | Default         | Description          |
| -------------- | ------------------- | --------------- | -------------------- |
| `segments`     | `List<PieSegment>`  | required        | Segments to display  |
| `donut`        | `bool`              | `false`         | Enable donut mode    |
| `donutRadius`  | `double`            | `0.55`          | Inner hole fraction  |
| `segmentGap`   | `double`            | `1.5`           | Gap between segments |
| `expandOffset` | `double`            | `10.0`          | Tap expand distance  |
| `legendStyle`  | `LegendStyle`       | `LegendStyle()` | Legend config        |
| `centerLabel`  | `CenterLabelStyle?` | null            | Donut center label   |
| `startAngle`   | `double`            | `-90`           | Start angle degrees  |

---

## 🕸️ Radar Chart

```dart
FlRadarChart(
  data: RadarChartData(
    labels: ['Speed', 'Power', 'Agility', 'Defense', 'Stamina'],
    datasets: [
      RadarDataset(
        values: [80, 90, 70, 85, 60],
        label: 'Hero A',
        style: RadarDatasetStyle(color: Color(0xFF5C6BC0)),
      ),
      RadarDataset(
        values: [60, 70, 85, 60, 90],
        label: 'Hero B',
        style: RadarDatasetStyle(color: Color(0xFF26A69A)),
      ),
    ],
  ),
  animation: ChartAnimation.elegant(),
)
```

### API — `FlRadarChart`

| Property          | Type             | Default            | Description           |
| ----------------- | ---------------- | ------------------ | --------------------- |
| `data`            | `RadarChartData` | required           | Chart data and styles |
| `animation`       | `ChartAnimation` | `ChartAnimation()` | Reveal animation      |
| `theme`           | `ChartTheme?`    | null               | Color theme override  |
| `size`            | `double`         | `280.0`            | Canvas size           |
| `decoration`      | `BoxDecoration?` | null               | Container decoration  |
| `padding`         | `EdgeInsets`     | `all(16)`          | Outer padding         |
| `onDatasetTapped` | `Function?`      | null               | Tap callback          |

### API — `RadarDatasetStyle`

| Property      | Type     | Default | Description           |
| ------------- | -------- | ------- | --------------------- |
| `color`       | `Color`  | indigo  | Stroke and fill color |
| `strokeWidth` | `double` | `2.5`   | Polygon stroke width  |
| `fillOpacity` | `double` | `0.25`  | Fill area opacity     |
| `showDots`    | `bool`   | `true`  | Dot indicators        |
| `dotRadius`   | `double` | `4.0`   | Dot radius            |

---

## 🎨 Theming

Apply a consistent color palette across all chart types:

```dart
// Built-in themes
ChartTheme.defaultTheme() // indigo, teal, amber, orange, purple
ChartTheme.ocean()        // cool blue-green palette
ChartTheme.sunset()       // warm reds, oranges, pinks
ChartTheme.forest()       // nature-inspired greens

// Apply to any chart
FlBarChart(data: myData, theme: ChartTheme.ocean())
FlLineChart(data: myData, theme: ChartTheme.sunset())
FlPieChart(data: myData, theme: ChartTheme.forest())
FlRadarChart(data: myData, theme: ChartTheme.ocean())

// Custom theme
ChartTheme(
  colors: [Colors.pink, Colors.orange, Colors.yellow],
)
```

---

## 🏷️ LegendWidget

A standalone legend widget usable anywhere in your layout:

```dart
LegendWidget(
  items: [
    LegendItem(color: Color(0xFF5C6BC0), label: 'Revenue'),
    LegendItem(color: Color(0xFF26A69A), label: 'Expenses'),
    LegendItem(color: Color(0xFFFF7043), label: 'Profit'),
  ],
)

// Square dots
LegendWidget(
  dotShape: BoxShape.rectangle,
  dotSize: 12,
  items: [...],
)
```

| Property     | Type               | Default  | Description         |
| ------------ | ------------------ | -------- | ------------------- |
| `items`      | `List<LegendItem>` | required | Legend items        |
| `dotSize`    | `double`           | `10.0`   | Dot indicator size  |
| `spacing`    | `double`           | `16.0`   | Item spacing        |
| `runSpacing` | `double`           | `8.0`    | Row spacing         |
| `dotShape`   | `BoxShape`         | `circle` | Circle or rectangle |
| `alignment`  | `WrapAlignment`    | `center` | Item alignment      |

---

## 💫 Animation Presets

| Preset                     | Duration | Curve        | Best For     |
| -------------------------- | -------- | ------------ | ------------ |
| `ChartAnimation()`         | 900ms    | easeOutCubic | General use  |
| `ChartAnimation.elegant()` | 1200ms   | easeOutCubic | Dashboards   |
| `ChartAnimation.snappy()`  | 400ms    | easeOutBack  | Live data    |
| `ChartAnimation.bouncy()`  | 800ms    | elasticOut   | Playful UIs  |
| `ChartAnimation.none()`    | 0ms      | —            | No animation |

---

## 🗺️ Roadmap

| Version | Feature                           | Status  |
| ------- | --------------------------------- | ------- |
| `0.0.1` | Bar Chart                         | ✅ Done |
| `0.1.0` | Line Chart                        | ✅ Done |
| `0.5.0` | Pie + Donut Chart                 | ✅ Done |
| `0.9.0` | Radar / Spider Chart              | ✅ Done |
| `1.0.0` | Theming, LegendWidget, Stable API | ✅ Done |

---

## 🤝 Contributing

Contributions are welcome! Please open an issue or pull request on
[GitHub](https://github.com/harshyadavDeveloper/fl_pretty_charts).

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.
