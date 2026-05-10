import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_pretty_charts/fl_pretty_charts.dart';

void main() {
  // ── ChartUtils ─────────────────────────────────────────────────────────────
  group('ChartUtils', () {
    group('niceMax', () {
      test('returns 10 for zero or negative input', () {
        expect(ChartUtils.niceMax(0), equals(10.0));
        expect(ChartUtils.niceMax(-5), equals(10.0));
      });

      test('rounds up to nearest nice number with headroom', () {
        expect(ChartUtils.niceMax(87.0), equals(100.0));
        expect(ChartUtils.niceMax(43.0), equals(50.0));
        expect(ChartUtils.niceMax(10.0), equals(20.0));
        expect(ChartUtils.niceMax(100.0), equals(200.0));
      });

      test('result is always greater than input', () {
        final values = [1.0, 25.0, 50.0, 99.0, 150.0, 999.0];
        for (final v in values) {
          expect(ChartUtils.niceMax(v), greaterThan(v));
        }
      });
    });

    group('valueToY', () {
      test('maps min value to chartHeight (bottom)', () {
        expect(ChartUtils.valueToY(0, 0, 100, 300), equals(300.0));
      });

      test('maps max value to 0 (top)', () {
        expect(ChartUtils.valueToY(100, 0, 100, 300), equals(0.0));
      });

      test('maps midpoint value to half chartHeight', () {
        expect(ChartUtils.valueToY(50, 0, 100, 300), equals(150.0));
      });

      test('returns chartHeight when maxY equals minY', () {
        expect(ChartUtils.valueToY(50, 50, 50, 300), equals(300.0));
      });
    });

    group('formatValue', () {
      test('whole numbers have no decimal point', () {
        expect(ChartUtils.formatValue(42.0), equals('42'));
        expect(ChartUtils.formatValue(0.0), equals('0'));
        expect(ChartUtils.formatValue(100.0), equals('100'));
      });

      test('decimal numbers show one decimal place', () {
        expect(ChartUtils.formatValue(3.567), equals('3.6'));
        expect(ChartUtils.formatValue(0.1), equals('0.1'));
        expect(ChartUtils.formatValue(99.95), equals('100.0'));
      });
    });

    group('gridPaint', () {
      test('returns a Paint with stroke style', () {
        final paint = ChartUtils.gridPaint(Colors.grey, 0.3);
        expect(paint.style, equals(PaintingStyle.stroke));
        expect(paint.strokeWidth, equals(1.0));
      });
    });
  });

  // ── BarData ────────────────────────────────────────────────────────────────
  group('BarData', () {
    test('stores value and label correctly', () {
      const bar = BarData(value: 42.0, label: 'Jan');
      expect(bar.value, equals(42.0));
      expect(bar.label, equals('Jan'));
      expect(bar.color, isNull);
    });

    test('stores optional color override', () {
      const bar = BarData(value: 10.0, label: 'Feb', color: Colors.red);
      expect(bar.color, equals(Colors.red));
    });
  });

  // ── BarStyle ───────────────────────────────────────────────────────────────
  group('BarStyle', () {
    test('has correct defaults', () {
      const style = BarStyle();
      expect(style.borderRadius, equals(6.0));
      expect(style.barWidthFraction, equals(0.55));
      expect(style.gradient, isNull);
    });

    test('accepts custom values', () {
      const style = BarStyle(borderRadius: 12.0, barWidthFraction: 0.7);
      expect(style.borderRadius, equals(12.0));
      expect(style.barWidthFraction, equals(0.7));
    });
  });

  // ── AxisStyle ──────────────────────────────────────────────────────────────
  group('AxisStyle', () {
    test('has correct defaults', () {
      const style = AxisStyle();
      expect(style.showGrid, isTrue);
      expect(style.yAxisDivisions, equals(5));
      expect(style.gridOpacity, equals(0.2));
    });
  });

  // ── TooltipStyle ───────────────────────────────────────────────────────────
  group('TooltipStyle', () {
    test('has correct defaults', () {
      const style = TooltipStyle();
      expect(style.borderRadius, equals(6.0));
      expect(style.backgroundColor, equals(const Color(0xDD000000)));
    });
  });

  // ── BarChartData ───────────────────────────────────────────────────────────
  group('BarChartData', () {
    test('stores bars and defaults correctly', () {
      final chartData = BarChartData(
        bars: [
          const BarData(value: 10, label: 'A'),
          const BarData(value: 20, label: 'B'),
        ],
      );
      expect(chartData.bars.length, equals(2));
      expect(chartData.minY, equals(0.0));
      expect(chartData.maxY, isNull);
      expect(chartData.defaultColor, equals(const Color(0xFF5C6BC0)));
    });

    test('accepts custom maxY and minY', () {
      final chartData = BarChartData(
        bars: [const BarData(value: 50, label: 'X')],
        maxY: 200.0,
        minY: 10.0,
      );
      expect(chartData.maxY, equals(200.0));
      expect(chartData.minY, equals(10.0));
    });
  });

  // ── ChartAnimation ─────────────────────────────────────────────────────────
  group('ChartAnimation', () {
    test('default has correct values', () {
      const anim = ChartAnimation();
      expect(anim.enabled, isTrue);
      expect(anim.duration, equals(const Duration(milliseconds: 900)));
      expect(anim.curve, equals(Curves.easeOutCubic));
    });

    test('elegant preset has 1200ms duration', () {
      final anim = ChartAnimation.elegant();
      expect(anim.duration, equals(const Duration(milliseconds: 1200)));
      expect(anim.enabled, isTrue);
    });

    test('snappy preset has 400ms duration', () {
      final anim = ChartAnimation.snappy();
      expect(anim.duration, equals(const Duration(milliseconds: 400)));
    });

    test('bouncy preset has 800ms duration', () {
      final anim = ChartAnimation.bouncy();
      expect(anim.duration, equals(const Duration(milliseconds: 800)));
    });

    test('none preset is disabled', () {
      final anim = ChartAnimation.none();
      expect(anim.enabled, isFalse);
      expect(anim.duration, equals(Duration.zero));
    });
  });

  // ── ChartTheme ─────────────────────────────────────────────────────────────
  group('ChartTheme', () {
    test('defaultTheme has 8 colors', () {
      final theme = ChartTheme.defaultTheme();
      expect(theme.colors.length, equals(8));
    });

    test('colorAt wraps around for out-of-range index', () {
      final theme = ChartTheme.defaultTheme();
      expect(theme.colorAt(0), equals(theme.colorAt(8)));
      expect(theme.colorAt(1), equals(theme.colorAt(9)));
    });

    test('ocean preset has correct first color', () {
      final theme = ChartTheme.ocean();
      expect(theme.colors.first, equals(const Color(0xFF0077B6)));
    });

    test('sunset preset has correct first color', () {
      final theme = ChartTheme.sunset();
      expect(theme.colors.first, equals(const Color(0xFFFF4D6D)));
    });

    test('forest preset has correct first color', () {
      final theme = ChartTheme.forest();
      expect(theme.colors.first, equals(const Color(0xFF2D6A4F)));
    });

    test('custom theme stores background and legendTextStyle', () {
      const theme = ChartTheme(
        colors: [Colors.red, Colors.blue],
        background: Colors.black,
        legendTextStyle: TextStyle(fontSize: 14),
      );
      expect(theme.background, equals(Colors.black));
      expect(theme.colors.length, equals(2));
    });
  });

  // ── FlBarChart Widget ──────────────────────────────────────────────────────
  group('FlBarChart widget', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlBarChart(
              data: BarChartData(
                bars: [
                  const BarData(value: 30, label: 'Mon'),
                  const BarData(value: 80, label: 'Tue'),
                  const BarData(value: 55, label: 'Wed'),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.byType(FlBarChart), findsOneWidget);
    });

    testWidgets('renders with elegant animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlBarChart(
              data: BarChartData(
                bars: [
                  const BarData(value: 100, label: 'A'),
                  const BarData(value: 200, label: 'B'),
                ],
              ),
              animation: ChartAnimation.elegant(),
            ),
          ),
        ),
      );
      expect(find.byType(FlBarChart), findsOneWidget);
    });

    testWidgets('renders with no animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlBarChart(
              data: BarChartData(
                bars: [
                  const BarData(value: 50, label: 'X'),
                ],
              ),
              animation: ChartAnimation.none(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(FlBarChart), findsOneWidget);
    });

    testWidgets('onBarTapped callback fires on tap', (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlBarChart(
              data: BarChartData(
                bars: [
                  const BarData(value: 30, label: 'Mon'),
                  const BarData(value: 80, label: 'Tue'),
                  const BarData(value: 55, label: 'Wed'),
                ],
              ),
              animation: ChartAnimation.none(),
              onBarTapped: (bar, index) => tappedIndex = index,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tapAt(tester.getCenter(find.byType(FlBarChart)));
      expect(tappedIndex, isNotNull);
    });
  });
}
