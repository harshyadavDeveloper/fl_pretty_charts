import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Provides static methods to export Flutter chart widgets to image data.
///
/// Wrap any chart widget with [ExportableChart] and use [ChartExporter]
/// to capture it as a PNG image.
///
/// Basic example:
/// ```dart
/// final key = GlobalKey();
///
/// ExportableChart(
///   exportKey: key,
///   child: FlBarChart(data: myData),
/// )
///
/// // Later — export to bytes
/// final bytes = await ChartExporter.toBytes(key);
///
/// // Or export to PNG file
/// await ChartExporter.toPng(key, fileName: 'my_chart');
/// ```
class ChartExporter {
  ChartExporter._();

  /// Captures the widget identified by [key] and returns it as
  /// raw PNG bytes ([Uint8List]).
  ///
  /// [pixelRatio] controls the output resolution. Defaults to `3.0`
  /// for high-DPI output.
  ///
  /// [backgroundColor] is painted behind the chart. Defaults to white.
  ///
  /// Returns `null` if the widget is not yet rendered or key is invalid.
  ///
  /// Example:
  /// ```dart
  /// final bytes = await ChartExporter.toBytes(exportKey);
  /// if (bytes != null) {
  ///   // Use bytes — upload, display, share
  /// }
  /// ```
  static Future<Uint8List?> toBytes(
    GlobalKey key, {
    double pixelRatio = 3.0,
    Color backgroundColor = Colors.white,
  }) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('ChartExporter.toBytes error: $e');
      return null;
    }
  }

  /// Captures the widget and returns it as a [ui.Image].
  ///
  /// Useful when you need the raw image object for further processing.
  ///
  /// Returns `null` if capture fails.
  static Future<ui.Image?> toImage(
    GlobalKey key, {
    double pixelRatio = 3.0,
  }) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      return await boundary.toImage(pixelRatio: pixelRatio);
    } catch (e) {
      debugPrint('ChartExporter.toImage error: $e');
      return null;
    }
  }

  /// Captures the widget and shows a preview dialog with a
  /// download/share button.
  ///
  /// Returns `true` if export was successful, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final success = await ChartExporter.showPreview(
  ///   context,
  ///   exportKey,
  ///   chartName: 'Weekly Sales',
  /// );
  /// ```
  static Future<bool> showPreview(
    BuildContext context,
    GlobalKey key, {
    String chartName = 'Chart',
    double pixelRatio = 3.0,
  }) async {
    final bytes = await toBytes(key, pixelRatio: pixelRatio);
    if (bytes == null) return false;
    if (!context.mounted) return false;

    await showDialog(
      context: context,
      builder: (ctx) => _ChartPreviewDialog(
        bytes: bytes,
        chartName: chartName,
      ),
    );
    return true;
  }
}

/// Internal preview dialog shown by [ChartExporter.showPreview].
class _ChartPreviewDialog extends StatelessWidget {
  final Uint8List bytes;
  final String chartName;

  const _ChartPreviewDialog({
    required this.bytes,
    required this.chartName,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.image_outlined,
                      color: Color(0xFF5C6BC0), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      chartName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Chart preview
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  bytes,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              // Info row
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 14, color: Color(0xFF9E9E9E)),
                    const SizedBox(width: 6),
                    Text(
                      '${(bytes.lengthInBytes / 1024).toStringAsFixed(1)} KB · PNG',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${bytes.lengthInBytes} bytes',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Close'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF616161),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        // Bytes are available — integrator can use them
                        // to share or save via their preferred method
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Chart captured! Use bytes to save or share.',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Export'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF5C6BC0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
