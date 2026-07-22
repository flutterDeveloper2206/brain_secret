import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/gradient_background.dart';
import '../controllers/hand_selector_controller.dart';

class HandSelectorView extends GetView<HandSelectorController> {
  const HandSelectorView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Toggle for Left/Right hand display
    final RxString activeHand = 'Left'.obs; // 'Left' or 'Right'

    return Scaffold(
      appBar: AppBar(
        title: const Text('Holographic Biometric Scanner'),
        centerTitle: true,
        actions: [
          // Clear All saved scans button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.scannedFingers.clear();
              controller.selectedFinger.value = null;
              Get.snackbar("Reset", "Cleared all scanned fingerprints.");
            },
            tooltip: "Reset All",
          )
        ],
      ),
      body: GradientBackground(
        child: Column(
          children: [
            // 1. Selector Tab (Left / Right Hand)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Obx(() => SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'Left',
                        label: Text('Left Hand'),
                        icon: Icon(Icons.pan_tool_outlined),
                      ),
                      ButtonSegment(
                        value: 'Right',
                        label: Text('Right Hand'),
                        icon: Icon(Icons.pan_tool_outlined),
                      ),
                    ],
                    selected: {activeHand.value},
                    onSelectionChanged: (selection) {
                      activeHand.value = selection.first;
                      controller.selectedFinger.value = null; // Clear selection on tab switch
                    },
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: theme.colorScheme.primary,
                      selectedForegroundColor: Colors.white,
                    ),
                  )),
            ),

            // 2. Status / Instructions Banner
            Obx(() {
              final selected = controller.selectedFinger.value;
              String msg = "Select a finger from the holographic interface to begin.";
              if (selected != null) {
                msg = "Selected: ${controller.getFingerName(selected)}. Tap 'Start Fingerprint Scan' below.";
              }
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  msg,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: selected != null ? theme.colorScheme.primary : textTheme.bodyMedium?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }),

            // 3. Interactive Hand CustomPaint Canvas Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Obx(() {
                      final isLeft = activeHand.value == 'Left';
                      // Finger mapping codes
                      final fingerCodes = isLeft 
                          ? ['L5', 'L4', 'L3', 'L2', 'L1'] 
                          : ['R1', 'R2', 'R3', 'R4', 'R5'];

                      return Stack(
                        children: [
                          // Holographic Hand Grid & Outline Painter
                          Positioned.fill(
                            child: CustomPaint(
                              painter: HolographicHandPainter(
                                isLeftHand: isLeft,
                                brightness: theme.brightness,
                                primaryColor: theme.colorScheme.primary,
                              ),
                            ),
                          ),

                          // Touch Hotspots overlaid on fingertips
                          ...fingerCodes.map((code) {
                            final pos = _getFingertipOffset(code, constraints);
                            final isSelected = controller.selectedFinger.value == code;
                            final isScanned = controller.isFingerScanned(code);

                            Color glowColor = theme.colorScheme.primary;
                            if (isScanned) {
                              glowColor = Colors.greenAccent;
                            } else if (isSelected) {
                              glowColor = Colors.orangeAccent;
                            }

                            return Positioned(
                              left: pos.dx - 28,
                              top: pos.dy - 28,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: () => controller.selectFinger(code),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected 
                                        ? glowColor.withValues(alpha: 0.25)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: glowColor,
                                      width: isSelected ? 3.0 : 2.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: glowColor.withValues(alpha: isSelected ? 0.6 : 0.2),
                                        blurRadius: isSelected ? 12 : 6,
                                        spreadRadius: isSelected ? 2 : 1,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          code,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected || isScanned 
                                                ? glowColor 
                                                : textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                        if (isScanned)
                                          const Icon(
                                            Icons.check_circle,
                                            size: 12,
                                            color: Colors.greenAccent,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    });
                  },
                ),
              ),
            ),

            // 4. Primary Bottom Scan Trigger Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Obx(() {
                final selected = controller.selectedFinger.value;
                return SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton.icon(
                    onPressed: selected == null 
                        ? null 
                        : () => controller.startScanning(),
                    icon: const Icon(Icons.fingerprint, size: 28),
                    label: Text(
                      selected != null 
                          ? 'Start Fingerprint Scan ($selected)'
                          : 'Select Finger Above',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: theme.disabledColor.withValues(alpha: 0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: selected != null ? 8 : 0,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Returns relative positioning of fingertip nodes on the canvas.
  Offset _getFingertipOffset(String code, BoxConstraints constraints) {
    double rx = 0.5;
    double ry = 0.5;

    switch (code) {
      // Left Hand Codes
      case 'L5': // Pinky
        rx = 0.14; ry = 0.35; break;
      case 'L4': // Ring
        rx = 0.28; ry = 0.16; break;
      case 'L3': // Middle
        rx = 0.47; ry = 0.11; break;
      case 'L2': // Index
        rx = 0.69; ry = 0.17; break;
      case 'L1': // Thumb
        rx = 0.86; ry = 0.48; break;

      // Right Hand Codes (Mirrored horizontally)
      case 'R1': // Thumb
        rx = 0.14; ry = 0.48; break;
      case 'R2': // Index
        rx = 0.31; ry = 0.17; break;
      case 'R3': // Middle
        rx = 0.53; ry = 0.11; break;
      case 'R4': // Ring
        rx = 0.72; ry = 0.16; break;
      case 'R5': // Pinky
        rx = 0.86; ry = 0.35; break;
    }

    return Offset(
      constraints.maxWidth * rx,
      constraints.maxHeight * ry,
    );
  }
}

/// A CustomPainter that draws a glowing wireframe/holographic hand outline with network lines.
class HolographicHandPainter extends CustomPainter {
  final bool isLeftHand;
  final Brightness brightness;
  final Color primaryColor;

  HolographicHandPainter({
    required this.isLeftHand,
    required this.brightness,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Draw Holographic Circular Radar Grids in the background
    final gridPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    final center = Offset(w / 2, h * 0.65);
    canvas.drawCircle(center, w * 0.2, gridPaint);
    canvas.drawCircle(center, w * 0.4, gridPaint);
    canvas.drawCircle(center, w * 0.6, gridPaint);

    // Fine Scanner Grid Lines
    for (double i = 0; i < h; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(w, i), gridPaint);
    }
    for (double i = 0; i < w; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, h), gridPaint);
    }

    // 2. Setup Neon Hand Paints
    final neonPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final meshPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Define palm/finger joints based on hand type (left vs right)
    // Left hand starts pinky-left, thumb-right. Right hand is mirrored.
    double flex(double val) {
      return isLeftHand ? val : (1.0 - val);
    }

    // fingertip and knuckle points
    final f5 = Offset(w * flex(0.14), h * 0.35); // Pinky Tip
    final f4 = Offset(w * flex(0.28), h * 0.16); // Ring Tip
    final f3 = Offset(w * flex(0.47), h * 0.11); // Middle Tip
    final f2 = Offset(w * flex(0.69), h * 0.17); // Index Tip
    final f1 = Offset(w * flex(0.86), h * 0.48); // Thumb Tip

    final k5 = Offset(w * flex(0.25), h * 0.52); // Pinky Knuckle
    final k4 = Offset(w * flex(0.36), h * 0.46); // Ring Knuckle
    final k3 = Offset(w * flex(0.48), h * 0.43); // Middle Knuckle
    final k2 = Offset(w * flex(0.60), h * 0.45); // Index Knuckle
    final k1 = Offset(w * flex(0.72), h * 0.62); // Thumb Base

    final wristL = Offset(w * flex(0.35), h * 0.90); // Left Wrist Base
    final wristR = Offset(w * flex(0.65), h * 0.90); // Right Wrist Base
    final palmCenter = Offset(w * flex(0.48), h * 0.65);

    // 3. Draw Hand Mesh Lines (Connecting nodes to give cyberwireframe appearance)
    canvas.drawLine(f5, k5, meshPaint);
    canvas.drawLine(f4, k4, meshPaint);
    canvas.drawLine(f3, k3, meshPaint);
    canvas.drawLine(f2, k2, meshPaint);
    canvas.drawLine(f1, k1, meshPaint);

    // Knuckle lines
    canvas.drawLine(k5, k4, meshPaint);
    canvas.drawLine(k4, k3, meshPaint);
    canvas.drawLine(k3, k2, meshPaint);
    canvas.drawLine(k2, k1, meshPaint);

    // Diagonal Wireframe Webbing
    canvas.drawLine(f5, k4, meshPaint);
    canvas.drawLine(f4, k3, meshPaint);
    canvas.drawLine(f3, k2, meshPaint);
    canvas.drawLine(f2, k1, meshPaint);
    canvas.drawLine(k5, palmCenter, meshPaint);
    canvas.drawLine(k4, palmCenter, meshPaint);
    canvas.drawLine(k3, palmCenter, meshPaint);
    canvas.drawLine(k2, palmCenter, meshPaint);
    canvas.drawLine(k1, palmCenter, meshPaint);
    canvas.drawLine(wristL, palmCenter, meshPaint);
    canvas.drawLine(wristR, palmCenter, meshPaint);
    canvas.drawLine(wristL, k5, meshPaint);
    canvas.drawLine(wristR, k1, meshPaint);

    // 4. Draw Neon Outline Path
    final path = Path();
    
    // Wrist Left
    path.moveTo(wristL.dx, wristL.dy);
    
    // Up to Pinky side base
    path.quadraticBezierTo(w * flex(0.20), h * 0.75, w * flex(0.18), h * 0.58);
    
    // Pinky Finger Outlines
    path.lineTo(w * flex(0.10), h * 0.42);
    path.quadraticBezierTo(f5.dx, f5.dy - 10, w * flex(0.20), h * 0.38);
    path.lineTo(w * flex(0.27), h * 0.52);

    // Ring Finger Outlines
    path.lineTo(w * flex(0.21), h * 0.25);
    path.quadraticBezierTo(f4.dx, f4.dy - 10, w * flex(0.35), h * 0.20);
    path.lineTo(w * flex(0.40), h * 0.47);

    // Middle Finger Outlines
    path.lineTo(w * flex(0.40), h * 0.18);
    path.quadraticBezierTo(f3.dx, f3.dy - 10, w * flex(0.54), h * 0.16);
    path.lineTo(w * flex(0.55), h * 0.46);

    // Index Finger Outlines
    path.lineTo(w * flex(0.62), h * 0.22);
    path.quadraticBezierTo(f2.dx, f2.dy - 10, w * flex(0.74), h * 0.24);
    path.lineTo(w * flex(0.70), h * 0.49);

    // Webbing to Thumb
    path.quadraticBezierTo(w * flex(0.72), h * 0.56, w * flex(0.78), h * 0.54);

    // Thumb Finger Outlines
    path.lineTo(w * flex(0.92), h * 0.45);
    path.quadraticBezierTo(f1.dx + 5, f1.dy - 5, w * flex(0.83), h * 0.58);
    path.lineTo(w * flex(0.72), h * 0.72);

    // Thumb Base to Right Wrist
    path.quadraticBezierTo(w * flex(0.75), h * 0.82, wristR.dx, wristR.dy);

    // Wrist Base Line
    path.lineTo(wristL.dx, wristL.dy);

    // Draw the neon paths
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, neonPaint);
  }

  @override
  bool shouldRepaint(covariant HolographicHandPainter oldDelegate) {
    return oldDelegate.isLeftHand != isLeftHand ||
        oldDelegate.brightness != brightness ||
        oldDelegate.primaryColor != primaryColor;
  }
}
