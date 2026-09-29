import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/glass_container.dart';
import '../../../../data/models/line_data.dart';
import '../../controllers/analysis_controller.dart';

class CanvasContainer extends GetView<AnalysisController> {
  const CanvasContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassContainer(
      elevated: true,
      borderRadius: 18,
      padding: const EdgeInsets.all(6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ColoredBox(
          color: theme.brightness == Brightness.dark
              ? Colors.black
              : Colors.black.withValues(alpha: 0.88),
          child: Obx(() {
            if (controller.isProcessingImage.value) {
              return Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              );
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
                      size: 64,
                      color: theme.colorScheme.primary.withValues(alpha: 0.45),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No fingerprint loaded',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              );
            }

            final displayedImage =
                (controller.showProcessed.value && processed != null)
                    ? processed
                    : original;

            // Touch observables so Obx rebuilds while drawing.
            controller.corePoint.value;
            controller.lines.length;
            controller.currentLine.value;

            return LayoutBuilder(
              builder: (context, constraints) {
                controller.canvasSize = Size(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );

                final imgAspect = controller.imageOriginalSize!.width /
                    controller.imageOriginalSize!.height;
                final canvasAspect = controller.canvasSize!.width /
                    controller.canvasSize!.height;

                late final double drawW;
                late final double drawH;
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
                      lines: List<LineData>.from(controller.lines),
                      currentLine: controller.currentLine.value,
                      destRect: controller.imageDestRect!,
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

class FingerprintPainter extends CustomPainter {
  FingerprintPainter({
    required this.image,
    this.corePoint,
    required this.lines,
    this.currentLine,
    required this.destRect,
  });

  final ui.Image image;
  final Offset? corePoint;
  final List<LineData> lines;
  final LineData? currentLine;
  final Rect destRect;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      destRect,
      Paint()..filterQuality = ui.FilterQuality.high,
    );

    final paint = Paint()
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    for (final line in lines) {
      paint.color = line.color;
      canvas.drawLine(line.start, line.end, paint);

      final endPaint = Paint()
        ..color = line.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(line.end, 6, endPaint);
      canvas.drawCircle(line.end, 8, paint..strokeWidth = 1.0);

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

    if (currentLine != null) {
      paint
        ..color = currentLine!.color
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(currentLine!.start, currentLine!.end, paint);
      canvas.drawCircle(
        currentLine!.end,
        5,
        Paint()
          ..color = currentLine!.color
          ..style = PaintingStyle.fill,
      );
    }

    if (corePoint != null) {
      canvas.drawCircle(
        corePoint!,
        12,
        Paint()
          ..color = Colors.blue.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      canvas.drawCircle(
        corePoint!,
        8,
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        corePoint!,
        8,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
      canvas.drawCircle(corePoint!, 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant FingerprintPainter oldDelegate) => true;
}
