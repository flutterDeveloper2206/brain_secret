import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/line_data.dart';
import '../../controllers/analysis_controller.dart';

class CanvasContainer extends GetView<AnalysisController> {
  const CanvasContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Obx(() {
        if (controller.isProcessingImage.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final original = controller.originalImage.value;
        final processed = controller.processedImage.value;

        if (original == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.fingerprint,
                  size: 80,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  "No fingerprint loaded",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        }

        final displayedImage = (controller.showProcessed.value && processed != null)
            ? processed
            : original;

        return LayoutBuilder(
          builder: (context, constraints) {
            controller.canvasSize = Size(
              constraints.maxWidth,
              constraints.maxHeight,
            );

            // Calculate destination rect matching BoxFit.contain
            double imgAspect = controller.imageOriginalSize!.width /
                controller.imageOriginalSize!.height;
            double canvasAspect =
                controller.canvasSize!.width / controller.canvasSize!.height;

            double drawW, drawH;
            if (imgAspect > canvasAspect) {
              drawW = controller.canvasSize!.width;
              drawH = drawW / imgAspect;
            } else {
              drawH = controller.canvasSize!.height;
              drawW = drawH * imgAspect;
            }

            controller.imageDestRect = Rect.fromLTWH(
              (controller.canvasSize!.width - drawW) / 2,
              (controller.canvasSize!.height - drawH) / 2,
              drawW,
              drawH,
            );

            return GestureDetector(
              onTapDown: (details) {
                controller.setCorePoint(details.localPosition);
              },
              onPanStart: (details) {
                controller.startCurrentLine(details.localPosition);
              },
              onPanUpdate: (details) {
                controller.updateCurrentLine(details.localPosition);
              },
              onPanEnd: (details) {
                controller.finishCurrentLine(details.localPosition);
              },
              child: CustomPaint(
                size: Size.infinite,
                painter: FingerprintPainter(
                  image: displayedImage,
                  corePoint: controller.corePoint.value,
                  lines: controller.lines,
                  currentLine: controller.currentLine.value,
                  destRect: controller.imageDestRect!,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class FingerprintPainter extends CustomPainter {
  final ui.Image image;
  final Offset? corePoint;
  final List<LineData> lines;
  final LineData? currentLine;
  final Rect destRect;

  FingerprintPainter({
    required this.image,
    this.corePoint,
    required this.lines,
    this.currentLine,
    required this.destRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw Background Fingerprint Image
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      destRect,
      Paint()..filterQuality = ui.FilterQuality.high,
    );

    final paint = Paint()
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Draw saved lines
    for (var line in lines) {
      paint.color = line.color;
      canvas.drawLine(line.start, line.end, paint);

      // Draw endpoint
      final endPaint = Paint()
        ..color = line.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(line.end, 6, endPaint);
      canvas.drawCircle(line.end, 8, paint..strokeWidth = 1.0);

      // Draw label near endpoint if count exists
      if (line.ridgeCount != null) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${line.ridgeCount}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        // Background box for label readability
        final textRect = Rect.fromLTWH(
          line.end.dx + 12,
          line.end.dy - 10,
          textPainter.width + 8,
          textPainter.height + 4,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(textRect, const Radius.circular(4)),
          Paint()..color = Colors.black87,
        );

        textPainter.paint(canvas, Offset(line.end.dx + 16, line.end.dy - 8));
      }
    }

    // Draw active drawing line
    if (currentLine != null) {
      paint.color = currentLine!.color;
      paint.strokeWidth = 2.0;
      canvas.drawLine(currentLine!.start, currentLine!.end, paint);
      canvas.drawCircle(currentLine!.end, 5, paint..style = PaintingStyle.fill);
    }

    // Draw Core Point
    if (corePoint != null) {
      // Outer glow/shadow
      canvas.drawCircle(
        corePoint!,
        12,
        Paint()
          ..color = Colors.blue.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      final corePaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;
      canvas.drawCircle(corePoint!, 8, corePaint);

      final coreStrokePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(corePoint!, 8, coreStrokePaint);

      // Inner center dot
      canvas.drawCircle(corePoint!, 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant FingerprintPainter oldDelegate) {
    return true;
  }
}
