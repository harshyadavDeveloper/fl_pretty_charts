# Changelog

All notable changes to `fl_pretty_charts` will be documented here.
This project follows [Semantic Versioning](https://semver.org/).

---

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