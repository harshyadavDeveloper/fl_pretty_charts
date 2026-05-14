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
      const chartData = BarChartData(
        bars: [
          BarData(value: 10, label: 'A'),
          BarData(value: 20, label: 'B'),
        ],
      );
      expect(chartData.bars.length, equals(2));
      expect(chartData.minY, equals(0.0));
      expect(chartData.maxY, isNull);
      expect(chartData.defaultColor, equals(const Color(0xFF5C6BC0)));
    });

    test('accepts custom maxY and minY', () {
      const chartData = BarChartData(
        bars: [BarData(value: 50, label: 'X')],
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
        const MaterialApp(
          home: Scaffold(
            body: FlBarChart(
              data: BarChartData(
                bars: [
                  BarData(value: 30, label: 'Mon'),
                  BarData(value: 80, label: 'Tue'),
                  BarData(value: 55, label: 'Wed'),
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
              data: const BarChartData(
                bars: [
                  BarData(value: 100, label: 'A'),
                  BarData(value: 200, label: 'B'),
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
              data: const BarChartData(
                bars: [
                  BarData(value: 50, label: 'X'),
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
              data: const BarChartData(
                bars: [
                  BarData(value: 30, label: 'Mon'),
                  BarData(value: 80, label: 'Tue'),
                  BarData(value: 55, label: 'Wed'),
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

  // ── LinePoint ──────────────────────────────────────────────────────────────
  group('LinePoint', () {
    test('stores x, y and label correctly', () {
      const point = LinePoint(x: 0, y: 42.0, label: 'Jan');
      expect(point.x, equals(0));
      expect(point.y, equals(42.0));
      expect(point.label, equals('Jan'));
    });
  });

  // ── LineStyle ──────────────────────────────────────────────────────────────
  group('LineStyle', () {
    test('has correct defaults', () {
      const style = LineStyle();
      expect(style.color, equals(const Color(0xFF5C6BC0)));
      expect(style.strokeWidth, equals(3.0));
      expect(style.showFill, isTrue);
      expect(style.fillOpacity, equals(0.2));
      expect(style.showDots, isTrue);
      expect(style.dotRadius, equals(4.5));
      expect(style.smooth, isTrue);
      expect(style.gradient, isNull);
    });

    test('accepts custom values', () {
      const style = LineStyle(
        strokeWidth: 5.0,
        smooth: false,
        showFill: false,
        showDots: false,
        dotRadius: 8.0,
        fillOpacity: 0.5,
      );
      expect(style.strokeWidth, equals(5.0));
      expect(style.smooth, isFalse);
      expect(style.showFill, isFalse);
      expect(style.showDots, isFalse);
      expect(style.dotRadius, equals(8.0));
      expect(style.fillOpacity, equals(0.5));
    });
  });

  // ── LineData ───────────────────────────────────────────────────────────────
  group('LineData', () {
    test('stores points and label correctly', () {
      const data = LineData(
        points: [
          LinePoint(x: 0, y: 10, label: 'A'),
          LinePoint(x: 1, y: 20, label: 'B'),
        ],
        label: 'Revenue',
      );
      expect(data.points.length, equals(2));
      expect(data.label, equals('Revenue'));
    });

    test('uses default LineStyle when not provided', () {
      const data = LineData(
        points: [LinePoint(x: 0, y: 10, label: 'A')],
        label: 'Test',
      );
      expect(data.style.strokeWidth, equals(3.0));
      expect(data.style.smooth, isTrue);
    });

    test('accepts custom LineStyle', () {
      const data = LineData(
        points: [LinePoint(x: 0, y: 10, label: 'A')],
        label: 'Test',
        style: LineStyle(color: Colors.red, strokeWidth: 4.0),
      );
      expect(data.style.color, equals(Colors.red));
      expect(data.style.strokeWidth, equals(4.0));
    });
  });

  // ── AxisLineStyle ──────────────────────────────────────────────────────────
  group('AxisLineStyle', () {
    test('has correct defaults', () {
      const style = AxisLineStyle();
      expect(style.showGrid, isTrue);
      expect(style.yAxisDivisions, equals(5));
      expect(style.gridOpacity, equals(0.2));
    });

    test('accepts custom values', () {
      const style = AxisLineStyle(
        showGrid: false,
        yAxisDivisions: 3,
        gridOpacity: 0.5,
      );
      expect(style.showGrid, isFalse);
      expect(style.yAxisDivisions, equals(3));
      expect(style.gridOpacity, equals(0.5));
    });
  });

  // ── LineTooltipStyle ───────────────────────────────────────────────────────
  group('LineTooltipStyle', () {
    test('has correct defaults', () {
      const style = LineTooltipStyle();
      expect(style.borderRadius, equals(6.0));
      expect(style.backgroundColor, equals(const Color(0xDD000000)));
    });
  });

  // ── LineChartData ──────────────────────────────────────────────────────────
  group('LineChartData', () {
    test('stores lines and defaults correctly', () {
      const data = LineChartData(
        lines: [
          LineData(
            points: [
              LinePoint(x: 0, y: 10, label: 'A'),
              LinePoint(x: 1, y: 20, label: 'B'),
            ],
            label: 'Series 1',
          ),
        ],
      );
      expect(data.lines.length, equals(1));
      expect(data.minY, equals(0.0));
      expect(data.maxY, isNull);
    });

    test('stores multiple line series', () {
      const data = LineChartData(
        lines: [
          LineData(
            points: [LinePoint(x: 0, y: 10, label: 'A')],
            label: 'Series 1',
          ),
          LineData(
            points: [LinePoint(x: 0, y: 20, label: 'A')],
            label: 'Series 2',
          ),
        ],
      );
      expect(data.lines.length, equals(2));
      expect(data.lines[0].label, equals('Series 1'));
      expect(data.lines[1].label, equals('Series 2'));
    });

    test('accepts custom maxY and minY', () {
      const data = LineChartData(
        lines: [
          LineData(
            points: [LinePoint(x: 0, y: 50, label: 'X')],
            label: 'Test',
          ),
        ],
        maxY: 200.0,
        minY: 10.0,
      );
      expect(data.maxY, equals(200.0));
      expect(data.minY, equals(10.0));
    });
  });

  // ── FlLineChart Widget ─────────────────────────────────────────────────────
  group('FlLineChart widget', () {
    testWidgets('renders single line without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlLineChart(
              data: LineChartData(
                lines: [
                  LineData(
                    points: [
                      LinePoint(x: 0, y: 30, label: 'Jan'),
                      LinePoint(x: 1, y: 80, label: 'Feb'),
                      LinePoint(x: 2, y: 55, label: 'Mar'),
                    ],
                    label: 'Revenue',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.byType(FlLineChart), findsOneWidget);
    });

    testWidgets('renders multi-line without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlLineChart(
              data: LineChartData(
                lines: [
                  LineData(
                    points: [
                      LinePoint(x: 0, y: 30, label: 'Jan'),
                      LinePoint(x: 1, y: 60, label: 'Feb'),
                    ],
                    label: 'Revenue',
                    style: LineStyle(color: Color(0xFF5C6BC0)),
                  ),
                  LineData(
                    points: [
                      LinePoint(x: 0, y: 20, label: 'Jan'),
                      LinePoint(x: 1, y: 40, label: 'Feb'),
                    ],
                    label: 'Expenses',
                    style: LineStyle(color: Color(0xFFFF7043)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.byType(FlLineChart), findsOneWidget);
    });

    testWidgets('renders with no animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlLineChart(
              data: const LineChartData(
                lines: [
                  LineData(
                    points: [
                      LinePoint(x: 0, y: 50, label: 'A'),
                      LinePoint(x: 1, y: 80, label: 'B'),
                    ],
                    label: 'Test',
                  ),
                ],
              ),
              animation: ChartAnimation.none(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(FlLineChart), findsOneWidget);
    });

    testWidgets('renders straight lines without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlLineChart(
              data: LineChartData(
                lines: [
                  LineData(
                    points: [
                      LinePoint(x: 0, y: 40, label: 'Q1'),
                      LinePoint(x: 1, y: 70, label: 'Q2'),
                      LinePoint(x: 2, y: 90, label: 'Q3'),
                    ],
                    label: 'Target',
                    style: LineStyle(smooth: false, showFill: false),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.byType(FlLineChart), findsOneWidget);
    });

    testWidgets('onPointTapped callback is accepted by widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlLineChart(
              data: const LineChartData(
                lines: [
                  LineData(
                    points: [
                      LinePoint(x: 0, y: 30, label: 'Jan'),
                      LinePoint(x: 1, y: 80, label: 'Feb'),
                      LinePoint(x: 2, y: 55, label: 'Mar'),
                    ],
                    label: 'Revenue',
                  ),
                ],
              ),
              animation: ChartAnimation.none(),
              onPointTapped: (point, lineIndex, pointIndex) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Widget renders correctly with callback attached
      expect(find.byType(FlLineChart), findsOneWidget);
    });

    testWidgets('FlLineChart renders with custom height and decoration',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlLineChart(
              data: const LineChartData(
                lines: [
                  LineData(
                    points: [
                      LinePoint(x: 0, y: 30, label: 'Jan'),
                      LinePoint(x: 1, y: 80, label: 'Feb'),
                    ],
                    label: 'Revenue',
                  ),
                ],
              ),
              animation: ChartAnimation.none(),
              height: 320,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FlLineChart), findsOneWidget);
    });
  });

  // ── PieSegment ─────────────────────────────────────────────────────────────
  group('PieSegment', () {
    test('stores value, label and color correctly', () {
      const segment = PieSegment(
        value: 40,
        label: 'Flutter',
        color: Color(0xFF5C6BC0),
      );
      expect(segment.value, equals(40));
      expect(segment.label, equals('Flutter'));
      expect(segment.color, equals(const Color(0xFF5C6BC0)));
      expect(segment.gradient, isNull);
    });

    test('accepts optional gradient', () {
      const segment = PieSegment(
        value: 30,
        label: 'React',
        color: Color(0xFF26A69A),
        gradient: SweepGradient(
          colors: [Color(0xFF26A69A), Color(0xFF5C6BC0)],
        ),
      );
      expect(segment.gradient, isNotNull);
    });
  });

  // ── LegendStyle ────────────────────────────────────────────────────────────
  group('LegendStyle', () {
    test('has correct defaults', () {
      const style = LegendStyle();
      expect(style.show, isTrue);
      expect(style.position, equals(LegendPosition.bottom));
      expect(style.dotSize, equals(10.0));
      expect(style.spacing, equals(16.0));
    });

    test('accepts custom values', () {
      const style = LegendStyle(
        show: false,
        dotSize: 14.0,
        spacing: 24.0,
        position: LegendPosition.top,
      );
      expect(style.show, isFalse);
      expect(style.dotSize, equals(14.0));
      expect(style.spacing, equals(24.0));
      expect(style.position, equals(LegendPosition.top));
    });
  });

  // ── CenterLabelStyle ───────────────────────────────────────────────────────
  group('CenterLabelStyle', () {
    test('has correct defaults', () {
      const style = CenterLabelStyle();
      expect(style.title, isNull);
      expect(style.value, isNull);
    });

    test('accepts title and value', () {
      const style = CenterLabelStyle(
        title: 'Total',
        value: '1,250',
      );
      expect(style.title, equals('Total'));
      expect(style.value, equals('1,250'));
    });
  });

  // ── PieTooltipStyle ────────────────────────────────────────────────────────
  group('PieTooltipStyle', () {
    test('has correct defaults', () {
      const style = PieTooltipStyle();
      expect(style.borderRadius, equals(6.0));
      expect(style.backgroundColor, equals(const Color(0xDD000000)));
    });
  });

  // ── PieChartData ───────────────────────────────────────────────────────────
  group('PieChartData', () {
    test('stores segments and defaults correctly', () {
      const data = PieChartData(
        segments: [
          PieSegment(value: 40, label: 'A', color: Color(0xFF5C6BC0)),
          PieSegment(value: 60, label: 'B', color: Color(0xFF26A69A)),
        ],
      );
      expect(data.segments.length, equals(2));
      expect(data.donut, isFalse);
      expect(data.donutRadius, equals(0.55));
      expect(data.segmentGap, equals(1.5));
      expect(data.expandOffset, equals(10.0));
      expect(data.startAngle, equals(-90));
    });

    test('donut mode stores correct values', () {
      const data = PieChartData(
        segments: [
          PieSegment(value: 50, label: 'A', color: Color(0xFF5C6BC0)),
          PieSegment(value: 50, label: 'B', color: Color(0xFF26A69A)),
        ],
        donut: true,
        donutRadius: 0.6,
      );
      expect(data.donut, isTrue);
      expect(data.donutRadius, equals(0.6));
    });

    test('accepts custom segmentGap and expandOffset', () {
      const data = PieChartData(
        segments: [
          PieSegment(value: 100, label: 'A', color: Colors.blue),
        ],
        segmentGap: 4.0,
        expandOffset: 16.0,
      );
      expect(data.segmentGap, equals(4.0));
      expect(data.expandOffset, equals(16.0));
    });

    test('accepts centerLabel in donut mode', () {
      const data = PieChartData(
        segments: [
          PieSegment(value: 100, label: 'A', color: Colors.blue),
        ],
        donut: true,
        centerLabel: CenterLabelStyle(title: 'Total', value: '100'),
      );
      expect(data.centerLabel, isNotNull);
      expect(data.centerLabel!.title, equals('Total'));
      expect(data.centerLabel!.value, equals('100'));
    });

    test('accepts custom startAngle', () {
      const data = PieChartData(
        segments: [
          PieSegment(value: 100, label: 'A', color: Colors.blue),
        ],
        startAngle: 0,
      );
      expect(data.startAngle, equals(0));
    });
  });

  // ── FlPieChart Widget ──────────────────────────────────────────────────────
  group('FlPieChart widget', () {
    testWidgets('renders basic pie chart without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlPieChart(
              data: PieChartData(
                segments: [
                  PieSegment(value: 40, label: 'A', color: Color(0xFF5C6BC0)),
                  PieSegment(value: 30, label: 'B', color: Color(0xFF26A69A)),
                  PieSegment(value: 30, label: 'C', color: Color(0xFFFF7043)),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.byType(FlPieChart), findsOneWidget);
    });

    testWidgets('renders donut chart without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlPieChart(
              data: PieChartData(
                segments: [
                  PieSegment(value: 50, label: 'A', color: Color(0xFF5C6BC0)),
                  PieSegment(value: 50, label: 'B', color: Color(0xFF26A69A)),
                ],
                donut: true,
                donutRadius: 0.55,
                centerLabel: CenterLabelStyle(
                  title: 'Total',
                  value: '100',
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.byType(FlPieChart), findsOneWidget);
    });

    testWidgets('renders with no animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlPieChart(
              data: const PieChartData(
                segments: [
                  PieSegment(value: 60, label: 'A', color: Color(0xFF5C6BC0)),
                  PieSegment(value: 40, label: 'B', color: Color(0xFF26A69A)),
                ],
              ),
              animation: ChartAnimation.none(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(FlPieChart), findsOneWidget);
    });

    testWidgets('renders legend when show is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FlPieChart(
                data: PieChartData(
                  segments: [
                    PieSegment(
                        value: 40, label: 'Flutter', color: Color(0xFF5C6BC0)),
                    PieSegment(
                        value: 60, label: 'React', color: Color(0xFF26A69A)),
                  ],
                  legendStyle: LegendStyle(show: true),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Flutter (40.0%)'), findsOneWidget);
      expect(find.text('React (60.0%)'), findsOneWidget);
    });

    testWidgets('does not render legend when show is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlPieChart(
              data: PieChartData(
                segments: [
                  PieSegment(
                      value: 40, label: 'Flutter', color: Color(0xFF5C6BC0)),
                  PieSegment(
                      value: 60, label: 'React', color: Color(0xFF26A69A)),
                ],
                legendStyle: LegendStyle(show: false),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Flutter (40.0%)'), findsNothing);
      expect(find.text('React (60.0%)'), findsNothing);
    });

    testWidgets('onSegmentTapped callback is accepted by widget',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlPieChart(
              data: const PieChartData(
                segments: [
                  PieSegment(value: 40, label: 'A', color: Color(0xFF5C6BC0)),
                  PieSegment(value: 60, label: 'B', color: Color(0xFF26A69A)),
                ],
              ),
              animation: ChartAnimation.none(),
              onSegmentTapped: (segment, index) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FlPieChart), findsOneWidget);
    });

    testWidgets('renders with elegant animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlPieChart(
              data: const PieChartData(
                segments: [
                  PieSegment(value: 40, label: 'A', color: Color(0xFF5C6BC0)),
                  PieSegment(value: 60, label: 'B', color: Color(0xFF26A69A)),
                ],
              ),
              animation: ChartAnimation.elegant(),
            ),
          ),
        ),
      );
      expect(find.byType(FlPieChart), findsOneWidget);
    });
  });
  // ── RadarDatasetStyle ──────────────────────────────────────────────────────
  group('RadarDatasetStyle', () {
    test('has correct defaults', () {
      const style = RadarDatasetStyle();
      expect(style.color, equals(const Color(0xFF5C6BC0)));
      expect(style.strokeWidth, equals(2.5));
      expect(style.fillOpacity, equals(0.25));
      expect(style.showDots, isTrue);
      expect(style.dotRadius, equals(4.0));
    });

    test('accepts custom values', () {
      const style = RadarDatasetStyle(
        color: Colors.red,
        strokeWidth: 4.0,
        fillOpacity: 0.5,
        showDots: false,
        dotRadius: 6.0,
      );
      expect(style.color, equals(Colors.red));
      expect(style.strokeWidth, equals(4.0));
      expect(style.fillOpacity, equals(0.5));
      expect(style.showDots, isFalse);
      expect(style.dotRadius, equals(6.0));
    });
  });

  // ── RadarDataset ───────────────────────────────────────────────────────────
  group('RadarDataset', () {
    test('stores values and label correctly', () {
      const dataset = RadarDataset(
        values: [80, 90, 70, 85, 60],
        label: 'Hero A',
      );
      expect(dataset.values.length, equals(5));
      expect(dataset.label, equals('Hero A'));
      expect(dataset.values[0], equals(80));
      expect(dataset.values[4], equals(60));
    });

    test('uses default style when not provided', () {
      const dataset = RadarDataset(
        values: [50, 60, 70],
        label: 'Test',
      );
      expect(dataset.style.strokeWidth, equals(2.5));
      expect(dataset.style.showDots, isTrue);
    });

    test('accepts custom style', () {
      const dataset = RadarDataset(
        values: [50, 60, 70],
        label: 'Test',
        style: RadarDatasetStyle(
          color: Colors.purple,
          strokeWidth: 3.5,
        ),
      );
      expect(dataset.style.color, equals(Colors.purple));
      expect(dataset.style.strokeWidth, equals(3.5));
    });
  });

  // ── RadarGridStyle ─────────────────────────────────────────────────────────
  group('RadarGridStyle', () {
    test('has correct defaults', () {
      const style = RadarGridStyle();
      expect(style.showGrid, isTrue);
      expect(style.gridLevels, equals(5));
      expect(style.gridOpacity, equals(0.25));
      expect(style.spokeOpacity, equals(0.3));
    });

    test('accepts custom values', () {
      const style = RadarGridStyle(
        showGrid: false,
        gridLevels: 3,
        gridOpacity: 0.5,
        spokeOpacity: 0.6,
      );
      expect(style.showGrid, isFalse);
      expect(style.gridLevels, equals(3));
      expect(style.gridOpacity, equals(0.5));
      expect(style.spokeOpacity, equals(0.6));
    });
  });

  // ── RadarLegendStyle ───────────────────────────────────────────────────────
  group('RadarLegendStyle', () {
    test('has correct defaults', () {
      const style = RadarLegendStyle();
      expect(style.show, isTrue);
      expect(style.dotSize, equals(10.0));
      expect(style.spacing, equals(16.0));
    });

    test('accepts custom values', () {
      const style = RadarLegendStyle(
        show: false,
        dotSize: 14.0,
        spacing: 24.0,
      );
      expect(style.show, isFalse);
      expect(style.dotSize, equals(14.0));
      expect(style.spacing, equals(24.0));
    });
  });

  // ── RadarChartData ─────────────────────────────────────────────────────────
  group('RadarChartData', () {
    test('stores labels and datasets correctly', () {
      const data = RadarChartData(
        labels: ['Speed', 'Power', 'Agility', 'Defense', 'Stamina'],
        datasets: [
          RadarDataset(
            values: [80, 90, 70, 85, 60],
            label: 'Hero A',
          ),
        ],
      );
      expect(data.labels.length, equals(5));
      expect(data.datasets.length, equals(1));
      expect(data.maxValue, equals(100.0));
      expect(data.minValue, equals(0.0));
    });

    test('stores multiple datasets correctly', () {
      const data = RadarChartData(
        labels: ['A', 'B', 'C', 'D'],
        datasets: [
          RadarDataset(values: [50, 60, 70, 80], label: 'Series 1'),
          RadarDataset(values: [80, 70, 60, 50], label: 'Series 2'),
        ],
      );
      expect(data.datasets.length, equals(2));
      expect(data.datasets[0].label, equals('Series 1'));
      expect(data.datasets[1].label, equals('Series 2'));
    });

    test('accepts custom maxValue and minValue', () {
      const data = RadarChartData(
        labels: ['A', 'B', 'C'],
        datasets: [
          RadarDataset(values: [50, 60, 70], label: 'Test'),
        ],
        maxValue: 200.0,
        minValue: 10.0,
      );
      expect(data.maxValue, equals(200.0));
      expect(data.minValue, equals(10.0));
    });

    test('accepts custom grid and legend styles', () {
      const data = RadarChartData(
        labels: ['A', 'B', 'C'],
        datasets: [
          RadarDataset(values: [50, 60, 70], label: 'Test'),
        ],
        gridStyle: RadarGridStyle(gridLevels: 3, showGrid: false),
        legendStyle: RadarLegendStyle(show: false),
      );
      expect(data.gridStyle.gridLevels, equals(3));
      expect(data.gridStyle.showGrid, isFalse);
      expect(data.legendStyle.show, isFalse);
    });
  });

  // ── FlRadarChart Widget ────────────────────────────────────────────────────
  group('FlRadarChart widget', () {
    testWidgets('renders single dataset without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlRadarChart(
              data: RadarChartData(
                labels: ['Speed', 'Power', 'Agility', 'Defense', 'Stamina'],
                datasets: [
                  RadarDataset(
                    values: [80, 90, 70, 85, 60],
                    label: 'Hero A',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.byType(FlRadarChart), findsOneWidget);
    });

    testWidgets('renders multi-dataset without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlRadarChart(
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
            ),
          ),
        ),
      );
      expect(find.byType(FlRadarChart), findsOneWidget);
    });

    testWidgets('renders with no animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlRadarChart(
              data: const RadarChartData(
                labels: ['A', 'B', 'C', 'D', 'E'],
                datasets: [
                  RadarDataset(
                    values: [60, 70, 80, 90, 50],
                    label: 'Test',
                  ),
                ],
              ),
              animation: ChartAnimation.none(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(FlRadarChart), findsOneWidget);
    });

    testWidgets('renders legend when show is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FlRadarChart(
                data: RadarChartData(
                  labels: ['A', 'B', 'C', 'D', 'E'],
                  datasets: [
                    RadarDataset(
                      values: [60, 70, 80, 90, 50],
                      label: 'Hero A',
                    ),
                    RadarDataset(
                      values: [80, 60, 70, 50, 90],
                      label: 'Hero B',
                    ),
                  ],
                  legendStyle: RadarLegendStyle(show: true),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hero A'), findsOneWidget);
      expect(find.text('Hero B'), findsOneWidget);
    });

    testWidgets('does not render legend when show is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlRadarChart(
              data: RadarChartData(
                labels: ['A', 'B', 'C', 'D', 'E'],
                datasets: [
                  RadarDataset(
                    values: [60, 70, 80, 90, 50],
                    label: 'Hero A',
                  ),
                ],
                legendStyle: RadarLegendStyle(show: false),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hero A'), findsNothing);
    });

    testWidgets('renders with elegant animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlRadarChart(
              data: const RadarChartData(
                labels: ['A', 'B', 'C', 'D', 'E'],
                datasets: [
                  RadarDataset(
                    values: [60, 70, 80, 90, 50],
                    label: 'Test',
                  ),
                ],
              ),
              animation: ChartAnimation.elegant(),
            ),
          ),
        ),
      );
      expect(find.byType(FlRadarChart), findsOneWidget);
    });

    testWidgets('onDatasetTapped callback is accepted by widget',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlRadarChart(
              data: const RadarChartData(
                labels: ['A', 'B', 'C', 'D', 'E'],
                datasets: [
                  RadarDataset(
                    values: [60, 70, 80, 90, 50],
                    label: 'Test',
                  ),
                ],
              ),
              animation: ChartAnimation.none(),
              onDatasetTapped: (dataset, index) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FlRadarChart), findsOneWidget);
    });

    testWidgets('renders with 8 axes without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlRadarChart(
              data: RadarChartData(
                labels: [
                  'Jan',
                  'Feb',
                  'Mar',
                  'Apr',
                  'May',
                  'Jun',
                  'Jul',
                  'Aug',
                ],
                datasets: [
                  RadarDataset(
                    values: [65, 80, 55, 90, 70, 85, 60, 75],
                    label: 'Monthly',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.byType(FlRadarChart), findsOneWidget);
    });
  });
}
