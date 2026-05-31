import 'package:flutter/material.dart';
import 'chart_exporter.dart';

/// A wrapper widget that makes any chart exportable as a PNG image.
///
/// Wrap any fl_pretty_charts widget with [ExportableChart] and use
/// [ChartExporter] with the provided [exportKey] to capture it.
///
/// The widget optionally shows an export button overlay in the
/// top-right corner when [showExportButton] is `true`.
///
/// Basic example — manual export:
/// ```dart
/// final _exportKey = GlobalKey();
///
/// ExportableChart(
///   exportKey: _exportKey,
///   child: FlBarChart(data: myData),
/// )
///
/// // Trigger export
/// ElevatedButton(
///   onPressed: () async {
///     final bytes = await ChartExporter.toBytes(_exportKey);
///   },
///   child: Text('Export'),
/// )
/// ```
///
/// With built-in export button:
/// ```dart
/// ExportableChart(
///   exportKey: _exportKey,
///   chartName: 'Weekly Sales',
///   showExportButton: true,
///   child: FlBarChart(data: myData),
/// )
/// ```
class ExportableChart extends StatefulWidget {
  /// The key used by [ChartExporter] to locate this widget's render object.
  final GlobalKey exportKey;

  /// The chart widget to wrap.
  final Widget child;

  /// Whether to show the built-in export button overlay.
  /// Defaults to `true`.
  final bool showExportButton;

  /// Name shown in the export preview dialog title.
  /// Defaults to `'Chart'`.
  final String chartName;

  /// Pixel ratio for the exported image. Higher = sharper.
  /// Defaults to `3.0`.
  final double pixelRatio;

  /// Background color painted behind the chart in the export.
  /// Defaults to [Colors.white].
  final Color exportBackground;

  /// Optional callback fired after export bytes are captured.
  /// Receives the raw PNG bytes for custom save/share logic.
  final void Function(List<int> bytes)? onExported;

  /// Position of the export button. Defaults to top-right.
  final Alignment exportButtonAlignment;

  const ExportableChart({
    super.key,
    required this.exportKey,
    required this.child,
    this.showExportButton = true,
    this.chartName = 'Chart',
    this.pixelRatio = 3.0,
    this.exportBackground = Colors.white,
    this.onExported,
    this.exportButtonAlignment = Alignment.topRight,
  });

  @override
  State<ExportableChart> createState() => _ExportableChartState();
}

class _ExportableChartState extends State<ExportableChart> {
  bool _isExporting = false;
  bool _isCapturing = false;

  Future<void> _handleExport() async {
    if (_isExporting) return;
    setState(() {
      _isExporting = true;
      _isCapturing = true; // hide button before capture
    });

    // Wait one frame so button disappears before screenshot
    await Future.delayed(const Duration(milliseconds: 80));

    try {
      if (widget.onExported != null) {
        final bytes = await ChartExporter.toBytes(
          widget.exportKey,
          pixelRatio: widget.pixelRatio,
          backgroundColor: widget.exportBackground,
        );
        if (bytes != null) {
          widget.onExported!(bytes);
        } else {
          _showError();
        }
      } else {
        if (!mounted) return;
        final success = await ChartExporter.showPreview(
          context,
          widget.exportKey,
          chartName: widget.chartName,
          pixelRatio: widget.pixelRatio,
        );
        if (!success && mounted) _showError();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
          _isCapturing = false;
        });
      }
    }
  }

  void _showError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export failed. Try again after the chart renders.'),
        backgroundColor: Color(0xFFEF5350),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: widget.exportKey,
      child: Stack(
        children: [
          // ── Chart ────────────────────────────────────────────────────
          widget.child,

          // ── Export button — hidden during capture ─────────────────────
          if (widget.showExportButton && !_isCapturing)
            Positioned.fill(
              child: Align(
                alignment: widget.exportButtonAlignment,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _ExportButton(
                    isExporting: _isExporting,
                    onTap: _handleExport,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The small export button shown in the corner of [ExportableChart].
class _ExportButton extends StatelessWidget {
  final bool isExporting;
  final VoidCallback onTap;

  const _ExportButton({
    required this.isExporting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isExporting)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF5C6BC0),
                  ),
                ),
              )
            else
              const Icon(
                Icons.download_outlined,
                size: 14,
                color: Color(0xFF5C6BC0),
              ),
            const SizedBox(width: 5),
            Text(
              isExporting ? 'Exporting...' : 'Export',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5C6BC0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
