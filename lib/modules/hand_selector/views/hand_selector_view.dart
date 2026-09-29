import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/gradient_background.dart';
import '../controllers/hand_selector_controller.dart';

class HandSelectorView extends GetView<HandSelectorController> {
  HandSelectorView({super.key});

  /// Keeps the selected hand inside this screen.
  /// No CustomPainter is required anymore.
  final RxString activeHand = 'Left'.obs;

  static const String _leftHandAsset =
      'assets/images/hands/left_hand.png';
  static const String _rightHandAsset =
      'assets/images/hands/right_hand.png';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final name = controller.entityDisplayName;

          if (name.isEmpty) {
            return const Text(
              'Holographic Biometric Scanner',
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Holographic Biometric Scanner',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                name,
                style: textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
            ],
          );
        }),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset All',
            onPressed: () {
              controller.scannedFingers.clear();
              controller.selectedFinger.value = null;
              Get.snackbar(
                'Reset',
                'Cleared all scanned fingerprints.',
              );
            },
          ),
        ],
      ),
      body: GradientBackground(
        child: Column(
          children: [
            // ==================================================
            // 1. LEFT / RIGHT HAND SELECTOR
            // ==================================================
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              child: Obx(
                    () => SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(
                      value: 'Left',
                      label: Text('Left Hand'),
                      icon: Icon(Icons.pan_tool_outlined),
                    ),
                    ButtonSegment<String>(
                      value: 'Right',
                      label: Text('Right Hand'),
                      icon: Icon(Icons.pan_tool_outlined),
                    ),
                  ],
                  selected: {activeHand.value},
                  onSelectionChanged: (selection) {
                    activeHand.value = selection.first;
                    controller.selectedFinger.value = null;
                  },
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor:
                    theme.colorScheme.primary,
                    selectedForegroundColor: Colors.white,
                  ),
                ),
              ),
            ),

            // ==================================================
            // 2. STATUS MESSAGE
            // ==================================================
            Obx(() {
              final selected = controller.selectedFinger.value;

              String message =
                  'Select a finger on the hand to begin.';

              if (selected != null) {
                message =
                "Selected: ${controller.getFingerName(selected)}. "
                    "Tap 'Start Fingerprint Scan' below.";
              }

              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  message,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: selected != null
                        ? theme.colorScheme.primary
                        : textTheme.bodyMedium?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }),

            // ==================================================
            // 3. HAND IMAGE + FINGER HOTSPOTS
            // ==================================================
            Expanded(
              child: Obx(() {
                final isLeft = activeHand.value == 'Left';

                final imagePath = isLeft
                    ? _leftHandAsset
                    : _rightHandAsset;

                final fingerCodes = isLeft
                    ? const [
                  'L1', // Thumb
                  'L2', // Index
                  'L3', // Middle
                  'L4', // Ring
                  'L5', // Pinky
                ]
                    : const [
                  'R1', // Thumb
                  'R2', // Index
                  'R3', // Middle
                  'R4', // Ring
                  'R5', // Pinky
                ];

                return LayoutBuilder(
                  builder: (context, constraints) {
                    // PNG ratio: 285 x 342.
                    const handAspectRatio = 285 / 342;

                    final availableWidth = constraints.maxWidth;
                    final availableHeight = constraints.maxHeight;

                    double imageWidth = availableWidth;
                    double imageHeight =
                        imageWidth / handAspectRatio;

                    if (imageHeight > availableHeight) {
                      imageHeight = availableHeight;
                      imageWidth =
                          imageHeight * handAspectRatio;
                    }

                    return Center(
                      child: SizedBox(
                        width: imageWidth,
                        height: imageHeight,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // ----------------------------------
                            // PNG HAND
                            // ----------------------------------
                            Positioned.fill(
                              child: Image.asset(
                                imagePath,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                            ),

                            // ----------------------------------
                            // FINGER TOUCH TARGETS
                            // ----------------------------------
                            ...fingerCodes.map((code) {
                              final position =
                              _getFingertipPosition(
                                code,
                                imageWidth,
                                imageHeight,
                              );

                              final isSelected =
                                  controller.selectedFinger.value ==
                                      code;

                              final isScanned =
                              controller.isFingerScanned(code);

                              Color circleColor =
                                  theme.colorScheme.primary;

                              if (isScanned) {
                                circleColor = Colors.green;
                              } else if (isSelected) {
                                circleColor = Colors.orange;
                              }

                              return Positioned(
                                left: position.dx - 28,
                                top: position.dy - 28,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius:
                                    BorderRadius.circular(32),
                                    onTap: () => controller
                                        .selectFinger(code),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? circleColor.withValues(
                                          alpha: 0.18,
                                        )
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: circleColor,
                                          width: isSelected
                                              ? 3
                                              : 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: circleColor
                                                .withValues(
                                              alpha: isSelected
                                                  ? 0.45
                                                  : 0.15,
                                            ),
                                            blurRadius: isSelected
                                                ? 10
                                                : 5,
                                            spreadRadius: isSelected
                                                ? 1
                                                : 0,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          code,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight:
                                            FontWeight.bold,
                                            color: circleColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            // ==================================================
            // 4. SCAN BUTTON
            // ==================================================
            Padding(
              padding: const EdgeInsets.all(24),
              child: Obx(() {
                final selected =
                    controller.selectedFinger.value;

                return SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton.icon(
                    onPressed: selected == null
                        ? null
                        : controller.startScanning,
                    icon: const Icon(
                      Icons.fingerprint,
                      size: 28,
                    ),
                    label: Text(
                      selected != null
                          ? 'Start Fingerprint Scan ($selected)'
                          : 'Select Finger Above',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                      theme.disabledColor.withValues(
                        alpha: 0.15,
                      ),
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

  // ============================================================
  // FINGERTIP POSITIONS
  // ============================================================
  //
  // These coordinates are relative to the PNG itself.
  //
  // LEFT PNG:
  //   thumb  -> left
  //   index  -> next
  //   middle -> center
  //   ring   -> next
  //   pinky  -> right
  //
  // RIGHT PNG is the exact horizontal mirror.
  // ============================================================

  Offset _getFingertipPosition(
      String code,
      double width,
      double height,
      ) {
    double x;
    double y;

    switch (code) {
    // ---------------- LEFT HAND ----------------
      case 'L1':
        x = 0.100;
        y = 0.350;
        break;
      case 'L2':
        x = 0.250;
        y = 0.229;
        break;
      case 'L3':
        x = 0.410;
        y = 0.170;
        break;
      case 'L4':
        x = 0.580;
        y = 0.200;
        break;
      case 'L5':
        x = 0.800;
        y = 0.500;
        break;

    // ---------------- RIGHT HAND ----------------
      case 'R1':
        x = 0.889;
        y = 0.350;
        break;
      case 'R2':
        x = 0.730;
        y = 0.200;
        break;
      case 'R3':
        x = 0.580;
        y = 0.150;
        break;
      case 'R4':
        x = 0.400;
        y = 0.170;
        break;
      case 'R5':
        x = 0.200;
        y = 0.45;
        break;

      default:
        x = 0.5;
        y = 0.5;
    }

    return Offset(
      width * x,
      height * y,
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../core/widgets/gradient_background.dart';
// import '../controllers/hand_selector_controller.dart';
//
// class HandSelectorView extends GetView<HandSelectorController> {
//   const HandSelectorView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final textTheme = theme.textTheme;
//
//     // Toggle for Left/Right hand display
//     final RxString activeHand = 'Left'.obs; // 'Left' or 'Right'
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Obx(() {
//           final name = controller.entityDisplayName;
//           if (name.isEmpty) {
//             return const Text('Holographic Biometric Scanner');
//           }
//           return Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 'Holographic Biometric Scanner',
//                 style: TextStyle(fontSize: 16),
//               ),
//               Text(
//                 name,
//                 style: textTheme.labelSmall?.copyWith(
//                   color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
//                 ),
//               ),
//             ],
//           );
//         }),
//         centerTitle: true,
//         actions: [
//           // Clear All saved scans button
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               controller.scannedFingers.clear();
//               controller.selectedFinger.value = null;
//               Get.snackbar("Reset", "Cleared all scanned fingerprints.");
//             },
//             tooltip: "Reset All",
//           )
//         ],
//       ),
//       body: GradientBackground(
//         child: Column(
//           children: [
//             // 1. Selector Tab (Left / Right Hand)
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//               child: Obx(() => SegmentedButton<String>(
//                     segments: const [
//                       ButtonSegment(
//                         value: 'Left',
//                         label: Text('Left Hand'),
//                         icon: Icon(Icons.pan_tool_outlined),
//                       ),
//                       ButtonSegment(
//                         value: 'Right',
//                         label: Text('Right Hand'),
//                         icon: Icon(Icons.pan_tool_outlined),
//                       ),
//                     ],
//                     selected: {activeHand.value},
//                     onSelectionChanged: (selection) {
//                       activeHand.value = selection.first;
//                       controller.selectedFinger.value = null; // Clear selection on tab switch
//                     },
//                     style: SegmentedButton.styleFrom(
//                       selectedBackgroundColor: theme.colorScheme.primary,
//                       selectedForegroundColor: Colors.white,
//                     ),
//                   )),
//             ),
//
//             // 2. Status / Instructions Banner
//             Obx(() {
//               final selected = controller.selectedFinger.value;
//               String msg = "Select a finger on the hand to begin.";
//               if (selected != null) {
//                 msg = "Selected: ${controller.getFingerName(selected)}. Tap 'Start Fingerprint Scan' below.";
//               }
//               return Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 padding: const EdgeInsets.all(12),
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.primary.withValues(alpha: 0.1),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
//                 ),
//                 child: Text(
//                   msg,
//                   style: textTheme.bodyMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                     color: selected != null ? theme.colorScheme.primary : textTheme.bodyMedium?.color,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               );
//             }),
//
//             // 3. Interactive Hand CustomPaint Canvas Area
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: LayoutBuilder(
//                   builder: (context, constraints) {
//                     return Obx(() {
//                       final isLeft = activeHand.value == 'Left';
//                       // Finger mapping codes
//                       final fingerCodes = isLeft
//                           ? ['L5', 'L4', 'L3', 'L2', 'L1']
//                           : ['R1', 'R2', 'R3', 'R4', 'R5'];
//
//                       return Stack(
//                         children: [
//                           // Holographic Hand Grid & Outline Painter
//                           Positioned.fill(
//                             child: CustomPaint(
//                               painter: HolographicHandPainter(
//                                 isLeftHand: isLeft,
//                                 brightness: theme.brightness,
//                                 primaryColor: theme.colorScheme.primary,
//                               ),
//                             ),
//                           ),
//
//                           // Touch Hotspots overlaid on fingertips
//                           ...fingerCodes.map((code) {
//                             final pos = _getFingertipOffset(code, constraints);
//                             final isSelected = controller.selectedFinger.value == code;
//                             final isScanned = controller.isFingerScanned(code);
//
//                             Color glowColor = theme.colorScheme.primary;
//                             if (isScanned) {
//                               glowColor = Colors.greenAccent;
//                             } else if (isSelected) {
//                               glowColor = Colors.orangeAccent;
//                             }
//
//                             return Positioned(
//                               left: pos.dx - 28,
//                               top: pos.dy - 28,
//                               child: InkWell(
//                                 borderRadius: BorderRadius.circular(30),
//                                 onTap: () => controller.selectFinger(code),
//                                 child: Container(
//                                   width: 56,
//                                   height: 56,
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     color: isSelected
//                                         ? glowColor.withValues(alpha: 0.25)
//                                         : Colors.transparent,
//                                     border: Border.all(
//                                       color: glowColor,
//                                       width: isSelected ? 3.0 : 2.0,
//                                     ),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: glowColor.withValues(alpha: isSelected ? 0.6 : 0.2),
//                                         blurRadius: isSelected ? 12 : 6,
//                                         spreadRadius: isSelected ? 2 : 1,
//                                       ),
//                                     ],
//                                   ),
//                                   child: Center(
//                                     child: Column(
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         Text(
//                                           code,
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.bold,
//                                             color: isSelected || isScanned
//                                                 ? glowColor
//                                                 : textTheme.bodyLarge?.color,
//                                           ),
//                                         ),
//                                         if (isScanned)
//                                           const Icon(
//                                             Icons.check_circle,
//                                             size: 12,
//                                             color: Colors.greenAccent,
//                                           ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }),
//                         ],
//                       );
//                     });
//                   },
//                 ),
//               ),
//             ),
//
//             // 4. Primary Bottom Scan Trigger Button
//             Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Obx(() {
//                 final selected = controller.selectedFinger.value;
//                 return SizedBox(
//                   width: double.infinity,
//                   height: 58,
//                   child: ElevatedButton.icon(
//                     onPressed: selected == null
//                         ? null
//                         : () => controller.startScanning(),
//                     icon: const Icon(Icons.fingerprint, size: 28),
//                     label: Text(
//                       selected != null
//                           ? 'Start Fingerprint Scan ($selected)'
//                           : 'Select Finger Above',
//                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: theme.colorScheme.primary,
//                       foregroundColor: Colors.white,
//                       disabledBackgroundColor: theme.disabledColor.withValues(alpha: 0.15),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       elevation: selected != null ? 8 : 0,
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Returns relative positioning of fingertip nodes on the canvas.
//   // Positions match AnatomicalHandPainter proportions (palm facing viewer).
//   Offset _getFingertipOffset(String code, BoxConstraints constraints) {
//     double rx = 0.5;
//     double ry = 0.5;
//
//     switch (code) {
//       // Left Hand (thumb on right)
//       case 'L5': // Pinky
//         rx = 0.17;
//         ry = 0.24;
//         break;
//       case 'L4': // Ring
//         rx = 0.34;
//         ry = 0.10;
//         break;
//       case 'L3': // Middle
//         rx = 0.49;
//         ry = 0.05;
//         break;
//       case 'L2': // Index
//         rx = 0.64;
//         ry = 0.12;
//         break;
//       case 'L1': // Thumb (up-and-out tip)
//         rx = 0.92;
//         ry = 0.36;
//         break;
//
//       // Right Hand (mirrored)
//       case 'R1': // Thumb
//         rx = 0.08;
//         ry = 0.36;
//         break;
//       case 'R2': // Index
//         rx = 0.36;
//         ry = 0.12;
//         break;
//       case 'R3': // Middle
//         rx = 0.51;
//         ry = 0.05;
//         break;
//       case 'R4': // Ring
//         rx = 0.66;
//         ry = 0.10;
//         break;
//       case 'R5': // Pinky
//         rx = 0.83;
//         ry = 0.24;
//         break;
//     }
//
//     return Offset(
//       constraints.maxWidth * rx,
//       constraints.maxHeight * ry,
//     );
//   }
// }
// // import 'package:flutter/material.dart';
//
// /// Hand illustration painter designed to closely match the
// /// supplied reference hand image.
// ///
// /// IMPORTANT:
// /// isLeftHand == true  -> reference orientation (thumb LEFT)
// /// isLeftHand == false -> mirrored orientation (thumb RIGHT)
// class HolographicHandPainter extends CustomPainter {
//   HolographicHandPainter({
//     required this.isLeftHand,
//     required this.brightness,
//     required this.primaryColor,
//   });
//
//   final bool isLeftHand;
//   final Brightness brightness;
//   final Color primaryColor;
//
//   // ============================================================
//   // REFERENCE COLORS
//   // ============================================================
//
//   static const Color _skin = Color(0xFFF8D5B6);
//   static const Color _skinHighlight = Color(0xFFFBDDBF);
//
//   static const Color _outline = Color(0xFF594238);
//   static const Color _crease = Color(0xFF76584B);
//
//   static const Color _nail = Color(0xFFF6D5BA);
//
//   // ============================================================
//   // NORMALIZED COORDINATE SYSTEM
//   // ============================================================
//   //
//   // The original reference is designed inside:
//   //
//   // X: 0.00 -> 1.00
//   // Y: 0.00 -> 1.00
//   //
//   // The hand itself occupies most of the canvas.
//   //
//   // ============================================================
//
//   double _x(
//       double x,
//       double width,
//       ) {
//     // TRUE = exact reference orientation.
//     //
//     // Reference:
//     // thumb is on LEFT.
//     //
//     // FALSE:
//     // mirror horizontally.
//     if (isLeftHand) {
//       return x * width;
//     }
//
//     return (1.0 - x) * width;
//   }
//
//   Offset _point(
//       double x,
//       double y,
//       Size size,
//       ) {
//     return Offset(
//       _x(x, size.width),
//       y * size.height,
//     );
//   }
//
//   // ============================================================
//   // PAINT
//   // ============================================================
//
//   @override
//   void paint(
//       Canvas canvas,
//       Size size,
//       ) {
//     final hand = _handPath(size);
//
//     // ----------------------------------------------------------
//     // VERY SUBTLE SHADOW
//     // ----------------------------------------------------------
//
//     final shadowPaint = Paint()
//       ..color = Colors.black.withValues(alpha: 0.035)
//       ..maskFilter = const MaskFilter.blur(
//         BlurStyle.normal,
//         2.5,
//       );
//
//     canvas.drawPath(
//       hand.shift(
//         const Offset(0.8, 1.2),
//       ),
//       shadowPaint,
//     );
//
//     // ----------------------------------------------------------
//     // MAIN SKIN
//     // ----------------------------------------------------------
//
//     final skinPaint = Paint()
//       ..color = _skin
//       ..style = PaintingStyle.fill;
//
//     canvas.drawPath(
//       hand,
//       skinPaint,
//     );
//
//     // ----------------------------------------------------------
//     // VERY SOFT HIGHLIGHT
//     // ----------------------------------------------------------
//
//     canvas.save();
//
//     canvas.clipPath(hand);
//
//     final highlightPaint = Paint()
//       ..shader = RadialGradient(
//         center: const Alignment(
//           -0.05,
//           -0.15,
//         ),
//         radius: 0.9,
//         colors: [
//           _skinHighlight.withValues(alpha: 0.25),
//           Colors.transparent,
//         ],
//       ).createShader(
//         Offset.zero & size,
//       );
//
//     canvas.drawRect(
//       Offset.zero & size,
//       highlightPaint,
//     );
//
//     canvas.restore();
//
//     // ----------------------------------------------------------
//     // FINGER CREASES
//     // ----------------------------------------------------------
//
//     _drawFingerCreases(
//       canvas,
//       size,
//     );
//
//     // ----------------------------------------------------------
//     // THUMB CREASES
//     // ----------------------------------------------------------
//
//     _drawThumbCreases(
//       canvas,
//       size,
//     );
//
//     // ----------------------------------------------------------
//     // NAILS
//     // ----------------------------------------------------------
//
//     _drawNails(
//       canvas,
//       size,
//     );
//
//     // ----------------------------------------------------------
//     // OUTLINE
//     // ----------------------------------------------------------
//
//     final outlinePaint = Paint()
//       ..color = _outline
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.35
//       ..strokeCap = StrokeCap.round
//       ..strokeJoin = StrokeJoin.round;
//
//     canvas.drawPath(
//       hand,
//       outlinePaint,
//     );
//   }
//
//   // ============================================================
//   // MAIN HAND PATH
//   // ============================================================
//
//   Path _handPath(
//       Size size,
//       ) {
//     final path = Path();
//
//     // ==========================================================
//     // WRIST - LEFT SIDE
//     // ==========================================================
//
//     path.moveTo(
//       _x(0.36, size.width),
//       size.height * 0.995,
//     );
//
//     // ==========================================================
//     // LEFT OUTER WRIST -> PALM
//     // ==========================================================
//
//     path.cubicTo(
//       _x(0.35, size.width),
//       size.height * 0.955,
//       _x(0.31, size.width),
//       size.height * 0.91,
//       _x(0.27, size.width),
//       size.height * 0.86,
//     );
//
//     path.cubicTo(
//       _x(0.22, size.width),
//       size.height * 0.80,
//       _x(0.18, size.width),
//       size.height * 0.73,
//       _x(0.15, size.width),
//       size.height * 0.65,
//     );
//
//     // ==========================================================
//     // THUMB BASE / WEB
//     // ==========================================================
//     //
//     // This is one of the most important changes.
//     //
//     // The reference thumb starts from the left-middle palm,
//     // not from the far bottom-left.
//     //
//     // ==========================================================
//
//     path.cubicTo(
//       _x(0.13, size.width),
//       size.height * 0.59,
//       _x(0.12, size.width),
//       size.height * 0.55,
//       _x(0.115, size.width),
//       size.height * 0.515,
//     );
//
//     // ==========================================================
//     // THUMB - LOWER SIDE
//     // ==========================================================
//
//     path.cubicTo(
//       _x(0.105, size.width),
//       size.height * 0.48,
//       _x(0.09, size.width),
//       size.height * 0.45,
//       _x(0.08, size.width),
//       size.height * 0.425,
//     );
//
//     // ==========================================================
//     // THUMB TIP
//     // ==========================================================
//
//     path.cubicTo(
//       _x(0.072, size.width),
//       size.height * 0.405,
//       _x(0.078, size.width),
//       size.height * 0.385,
//       _x(0.098, size.width),
//       size.height * 0.382,
//     );
//
//     path.cubicTo(
//       _x(0.118, size.width),
//       size.height * 0.378,
//       _x(0.14, size.width),
//       size.height * 0.395,
//       _x(0.155, size.width),
//       size.height * 0.415,
//     );
//
//     // ==========================================================
//     // THUMB UPPER SIDE
//     // ==========================================================
//
//     path.cubicTo(
//       _x(0.175, size.width),
//       size.height * 0.445,
//       _x(0.195, size.width),
//       size.height * 0.465,
//       _x(0.215, size.width),
//       size.height * 0.475,
//     );
//
//     // ==========================================================
//     // THUMB -> INDEX WEB
//     // ==========================================================
//
//     path.cubicTo(
//       _x(0.23, size.width),
//       size.height * 0.482,
//       _x(0.245, size.width),
//       size.height * 0.475,
//       _x(0.255, size.width),
//       size.height * 0.455,
//     );
//
//     // ==========================================================
//     // INDEX FINGER OUTER SIDE
//     // ==========================================================
//
//     path.cubicTo(
//       _x(0.26, size.width),
//       size.height * 0.38,
//       _x(0.265, size.width),
//       size.height * 0.27,
//       _x(0.27, size.width),
//       size.height * 0.17,
//     );
//
//     // ==========================================================
//     // INDEX FINGERTIP
//     // ==========================================================
//
//     path.cubicTo(
//       _x(0.273, size.width),
//       size.height * 0.11,
//       _x(0.285, size.width),
//       size.height * 0.085,
//       _x(0.31, size.width),
//       size.height * 0.085,
//     );
//
//     path.cubicTo(
//       _x(0.337, size.width),
//       size.height * 0.085,
//       _x(0.35, size.width),
//       size.height * 0.105,
//       _x(0.35, size.width),
//       size.height * 0.16,
//     );
//
//     // ==========================================================
//     // INDEX INNER SIDE
//     // ==========================================================
//
//     path.cubicTo(
//       _x(0.35, size.width),
//       size.height * 0.265,
//       _x(0.345, size.width),
//       size.height * 0.38,
//       _x(0.345, size.width),
//       size.height * 0.47,
//     );
//
//     // ==========================================================
//     // INDEX / MIDDLE VALLEY
//     // ==========================================================
//
//     path.cubicTo(
//       _x(0.345, size.width),
//       size.height * 0.50,
//       _x(0.36, size.width),
//       size.height * 0.515,
//       _x(0.375, size.width),
//       size.height * 0.485,
//     );
//
//     // ==========================================================
//     // MIDDLE FINGER OUTER SIDE
//     // ==========================================================
//
//     path.cubicTo(
//       _x(0.38, size.width),
//       size.height * 0.36,
//       _x(0.38, size.width),
//       size.height * 0.20,
//       _x(0.385, size.width),
//       size.height * 0.085,
//     );
//
//     // ==========================================================
//     // MIDDLE TIP
//     // ==========================================================
//
//     path.cubicTo(
//       _x(0.387, size.width),
//       size.height * 0.03,
//       _x(0.402, size.width),
//       size.height * 0.008,
//       _x(0.425, size.width),
//       size.height * 0.008,
//     );
//
//     path.cubicTo(
//       _x(0.45, size.width),
//       size.height * 0.008,
//       _x(0.465, size.width),
//       size.height * 0.03,
//       _x(0.465, size.width),
//       size.height * 0.085,
//     );
//
//     // ==========================================================
//     // MIDDLE INNER SIDE
//     // ==========================================================
//
//     path.cubicTo(
//       _x(0.465, size.width),
//       size.height * 0.20,
//       _x(0.46, size.width),
//       size.height * 0.36,
//       _x(0.46, size.width),
//       size.height * 0.485,
//     );
//
//     // ==========================================================
//     // MIDDLE / RING VALLEY
//     // ==========================================================
//
//     path.cubicTo(
//       _x(0.46, size.width),
//       size.height * 0.51,
//       _x(0.475, size.width),
//       size.height * 0.52,
//       _x(0.49, size.width),
//       size.height * 0.49,
//     );
//
//     // ==========================================================
//     // RING FINGER OUTER
//     // ==========================================================
//
//     path.cubicTo(
//       _x(0.495, size.width),
//       size.height * 0.37,
//       _x(0.495, size.width),
//       size.height * 0.25,
//       _x(0.50, size.width),
//       size.height * 0.16,
//     );
//
//     // ==========================================================
//     // RING TIP
//     // ==========================================================
//
//     path.cubicTo(
//       _x(0.503, size.width),
//       size.height * 0.105,
//       _x(0.518, size.width),
//       size.height * 0.085,
//       _x(0.542, size.width),
//       size.height * 0.085,
//     );
//
//     path.cubicTo(
//       _x(0.568, size.width),
//       size.height * 0.085,
//       _x(0.582, size.width),
//       size.height * 0.105,
//       _x(0.582, size.width),
//       size.height * 0.16,
//     );
//
//     // ==========================================================
//     // RING INNER
//     // ==========================================================
//
//     path.cubicTo(
//       _x(0.582, size.width),
//       size.height * 0.26,
//       _x(0.578, size.width),
//       size.height * 0.38,
//       _x(0.578, size.width),
//       size.height * 0.49,
//     );
//
//     // ==========================================================
//     // RING / PINKY VALLEY
//     // ==========================================================
//
//     path.cubicTo(
//       _x(0.578, size.width),
//       size.height * 0.515,
//       _x(0.592, size.width),
//       size.height * 0.525,
//       _x(0.607, size.width),
//       size.height * 0.495,
//     );
//
//     // ==========================================================
//     // PINKY / OUTER FINGER
//     // ==========================================================
//
//     path.cubicTo(
//       _x(0.612, size.width),
//       size.height * 0.40,
//       _x(0.612, size.width),
//       size.height * 0.30,
//       _x(0.617, size.width),
//       size.height * 0.225,
//     );
//
//     // ==========================================================
//     // PINKY TIP
//     // ==========================================================
//
//     path.cubicTo(
//       _x(0.62, size.width),
//       size.height * 0.185,
//       _x(0.635, size.width),
//       size.height * 0.17,
//       _x(0.657, size.width),
//       size.height * 0.175,
//     );
//
//     path.cubicTo(
//       _x(0.68, size.width),
//       size.height * 0.18,
//       _x(0.692, size.width),
//       size.height * 0.20,
//       _x(0.688, size.width),
//       size.height * 0.24,
//     );
//
//     // ==========================================================
//     // PINKY INNER SIDE
//     // ==========================================================
//
//     path.cubicTo(
//       _x(0.68, size.width),
//       size.height * 0.32,
//       _x(0.67, size.width),
//       size.height * 0.405,
//       _x(0.665, size.width),
//       size.height * 0.50,
//     );
//
//     // ==========================================================
//     // RIGHT PALM / THENAR SIDE
//     // ==========================================================
//
//     path.cubicTo(
//       _x(0.66, size.width),
//       size.height * 0.60,
//       _x(0.65, size.width),
//       size.height * 0.70,
//       _x(0.63, size.width),
//       size.height * 0.79,
//     );
//
//     path.cubicTo(
//       _x(0.615, size.width),
//       size.height * 0.86,
//       _x(0.60, size.width),
//       size.height * 0.93,
//       _x(0.59, size.width),
//       size.height * 0.995,
//     );
//
//     // ==========================================================
//     // BOTTOM WRIST
//     // ==========================================================
//
//     path.lineTo(
//       _x(0.36, size.width),
//       size.height * 0.995,
//     );
//
//     path.close();
//
//     return path;
//   }
//
//   // ============================================================
//   // FINGER CREASES
//   // ============================================================
//
//   void _drawFingerCreases(
//       Canvas canvas,
//       Size size,
//       ) {
//     final paint = Paint()
//       ..color = _crease.withValues(alpha: 0.72)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 0.9
//       ..strokeCap = StrokeCap.round;
//
//     // ----------------------------------------------------------
//     // INDEX
//     // ----------------------------------------------------------
//
//     _line(
//       canvas,
//       size,
//       paint,
//       0.277,
//       0.205,
//       0.345,
//       0.205,
//     );
//
//     _line(
//       canvas,
//       size,
//       paint,
//       0.275,
//       0.30,
//       0.345,
//       0.30,
//     );
//
//     // ----------------------------------------------------------
//     // MIDDLE
//     // ----------------------------------------------------------
//
//     _line(
//       canvas,
//       size,
//       paint,
//       0.392,
//       0.14,
//       0.458,
//       0.14,
//     );
//
//     _line(
//       canvas,
//       size,
//       paint,
//       0.39,
//       0.27,
//       0.458,
//       0.27,
//     );
//
//     // ----------------------------------------------------------
//     // RING
//     // ----------------------------------------------------------
//
//     _line(
//       canvas,
//       size,
//       paint,
//       0.507,
//       0.205,
//       0.575,
//       0.205,
//     );
//
//     _line(
//       canvas,
//       size,
//       paint,
//       0.505,
//       0.31,
//       0.575,
//       0.31,
//     );
//
//     // ----------------------------------------------------------
//     // PINKY
//     // ----------------------------------------------------------
//
//     _line(
//       canvas,
//       size,
//       paint,
//       0.625,
//       0.275,
//       0.685,
//       0.285,
//     );
//
//     _line(
//       canvas,
//       size,
//       paint,
//       0.62,
//       0.355,
//       0.675,
//       0.365,
//     );
//   }
//
//   // ============================================================
//   // THUMB CREASES
//   // ============================================================
//
//   void _drawThumbCreases(
//       Canvas canvas,
//       Size size,
//       ) {
//     final paint = Paint()
//       ..color = _crease.withValues(alpha: 0.65)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 0.9
//       ..strokeCap = StrokeCap.round;
//
//     // ----------------------------------------------------------
//     // Thumb tip crease
//     // ----------------------------------------------------------
//
//     final crease1 = Path()
//       ..moveTo(
//         _x(0.09, size.width),
//         size.height * 0.405,
//       )
//       ..cubicTo(
//         _x(0.105, size.width),
//         size.height * 0.40,
//         _x(0.12, size.width),
//         size.height * 0.405,
//         _x(0.135, size.width),
//         size.height * 0.415,
//       );
//
//     canvas.drawPath(
//       crease1,
//       paint,
//     );
//
//     // ----------------------------------------------------------
//     // Thumb middle crease
//     // ----------------------------------------------------------
//
//     final crease2 = Path()
//       ..moveTo(
//         _x(0.13, size.width),
//         size.height * 0.445,
//       )
//       ..cubicTo(
//         _x(0.15, size.width),
//         size.height * 0.45,
//         _x(0.17, size.width),
//         size.height * 0.465,
//         _x(0.19, size.width),
//         size.height * 0.475,
//       );
//
//     canvas.drawPath(
//       crease2,
//       paint,
//     );
//   }
//
//   // ============================================================
//   // NAILS
//   // ============================================================
//
//   void _drawNails(
//       Canvas canvas,
//       Size size,
//       ) {
//     // Index
//     _drawNail(
//       canvas,
//       size,
//       0.31,
//       0.087,
//       0.045,
//       0.038,
//     );
//
//     // Middle
//     _drawNail(
//       canvas,
//       size,
//       0.425,
//       0.01,
//       0.045,
//       0.038,
//     );
//
//     // Ring
//     _drawNail(
//       canvas,
//       size,
//       0.542,
//       0.087,
//       0.045,
//       0.038,
//     );
//
//     // Pinky
//     _drawNail(
//       canvas,
//       size,
//       0.655,
//       0.175,
//       0.040,
//       0.034,
//     );
//
//     // Thumb
//     _drawThumbNail(
//       canvas,
//       size,
//     );
//   }
//
//   // ============================================================
//   // NORMAL FINGER NAIL
//   // ============================================================
//
//   void _drawNail(
//       Canvas canvas,
//       Size size,
//       double centerX,
//       double topY,
//       double width,
//       double height,
//       ) {
//     final center = _point(
//       centerX,
//       topY + height / 2,
//       size,
//     );
//
//     final rect = Rect.fromCenter(
//       center: center,
//       width: size.width * width,
//       height: size.height * height,
//     );
//
//     final nailPath = Path()
//       ..addRRect(
//         RRect.fromRectAndRadius(
//           rect,
//           Radius.circular(
//             size.width * 0.008,
//           ),
//         ),
//       );
//
//     // Fill
//     canvas.drawPath(
//       nailPath,
//       Paint()
//         ..color = _nail
//         ..style = PaintingStyle.fill,
//     );
//
//     // Outline
//     canvas.drawPath(
//       nailPath,
//       Paint()
//         ..color = _outline.withValues(alpha: 0.70)
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 0.75,
//     );
//   }
//
//   // ============================================================
//   // THUMB NAIL
//   // ============================================================
//
//   void _drawThumbNail(
//       Canvas canvas,
//       Size size,
//       ) {
//     final center = _point(
//       0.105,
//       0.397,
//       size,
//     );
//
//     canvas.save();
//
//     canvas.translate(
//       center.dx,
//       center.dy,
//     );
//
//     canvas.rotate(
//       isLeftHand ? -0.65 : 0.65,
//     );
//
//     final rect = Rect.fromCenter(
//       center: Offset.zero,
//       width: size.width * 0.045,
//       height: size.height * 0.034,
//     );
//
//     final nailPath = Path()
//       ..addRRect(
//         RRect.fromRectAndRadius(
//           rect,
//           Radius.circular(
//             size.width * 0.008,
//           ),
//         ),
//       );
//
//     canvas.drawPath(
//       nailPath,
//       Paint()
//         ..color = _nail
//         ..style = PaintingStyle.fill,
//     );
//
//     canvas.drawPath(
//       nailPath,
//       Paint()
//         ..color = _outline.withValues(alpha: 0.70)
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 0.75,
//     );
//
//     canvas.restore();
//   }
//
//   // ============================================================
//   // SMALL LINE HELPER
//   // ============================================================
//
//   void _line(
//       Canvas canvas,
//       Size size,
//       Paint paint,
//       double x1,
//       double y1,
//       double x2,
//       double y2,
//       ) {
//     canvas.drawLine(
//       _point(x1, y1, size),
//       _point(x2, y2, size),
//       paint,
//     );
//   }
//
//   // ============================================================
//   // REPAINT
//   // ============================================================
//
//   @override
//   bool shouldRepaint(
//       covariant HolographicHandPainter oldDelegate,
//       ) {
//     return oldDelegate.isLeftHand != isLeftHand ||
//         oldDelegate.brightness != brightness ||
//         oldDelegate.primaryColor != primaryColor;
//   }
// }
// /// Filled anatomical hand matching the palm illustration (peach skin, dark outline).
// // class HolographicHandPainter extends CustomPainter {
// //   HolographicHandPainter({
// //     required this.isLeftHand,
// //     required this.brightness,
// //     required this.primaryColor,
// //   });
// //
// //   final bool isLeftHand;
// //   final Brightness brightness;
// //   final Color primaryColor;
// //
// //   static const _skin = Color(0xFFF3C9A0);
// //   static const _skinMid = Color(0xFFE8B48A);
// //   static const _skinShadow = Color(0xFFD49A72);
// //   static const _outline = Color(0xFF4A3728);
// //   static const _crease = Color(0xFF5C4030);
// //
// //   double _x(double n, double w) => isLeftHand ? n * w : (1.0 - n) * w;
// //
// //   Offset _p(double nx, double ny, Size size) =>
// //       Offset(_x(nx, size.width), ny * size.height);
// //
// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     final path = _handPath(size);
// //
// //     // Soft drop shadow under hand
// //     canvas.drawPath(
// //       path.shift(const Offset(3, 5)),
// //       Paint()
// //         ..color = Colors.black.withValues(alpha: 0.08)
// //         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
// //     );
// //
// //     // Base skin fill
// //     canvas.drawPath(
// //       path,
// //       Paint()
// //         ..shader = LinearGradient(
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //           colors: [
// //             _skin,
// //             _skinMid,
// //             _skinShadow.withValues(alpha: 0.95),
// //           ],
// //           stops: const [0.15, 0.55, 1.0],
// //         ).createShader(Offset.zero & size),
// //     );
// //
// //     // Left-edge shading (matches illustration light from right)
// //     canvas.save();
// //     canvas.clipPath(path);
// //     final shade = Paint()
// //       ..shader = LinearGradient(
// //         begin: isLeftHand ? Alignment.centerLeft : Alignment.centerRight,
// //         end: isLeftHand ? Alignment.centerRight : Alignment.centerLeft,
// //         colors: [
// //           _skinShadow.withValues(alpha: 0.45),
// //           _skinShadow.withValues(alpha: 0.12),
// //           Colors.transparent,
// //         ],
// //         stops: const [0.0, 0.35, 0.7],
// //       ).createShader(Offset.zero & size);
// //     canvas.drawRect(Offset.zero & size, shade);
// //
// //     // Finger center highlights
// //     final highlight = Paint()
// //       ..shader = LinearGradient(
// //         begin: Alignment.topCenter,
// //         end: Alignment.bottomCenter,
// //         colors: [
// //           Colors.white.withValues(alpha: 0.28),
// //           Colors.white.withValues(alpha: 0.0),
// //         ],
// //       ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.55));
// //     canvas.drawRect(
// //       Rect.fromLTWH(size.width * 0.15, 0, size.width * 0.7, size.height * 0.5),
// //       highlight,
// //     );
// //     canvas.restore();
// //
// //     // Palm + knuckle creases
// //     _drawCreases(canvas, size);
// //
// //     // Thumb nail tip
// //     _drawThumbNail(canvas, size);
// //
// //     // Outer outline
// //     canvas.drawPath(
// //       path,
// //       Paint()
// //         ..color = _outline
// //         ..style = PaintingStyle.stroke
// //         ..strokeWidth = 2.2
// //         ..strokeJoin = StrokeJoin.round
// //         ..strokeCap = StrokeCap.round,
// //     );
// //   }
// //
// //   /// Closed path: wrist → pinky → ring → middle → index → thumb → wrist.
// //   /// Normalized coords assume left hand (thumb on the right); mirrored via [_x].
// //   Path _handPath(Size size) {
// //     final path = Path();
// //
// //     // Start left wrist
// //     path.moveTo(_x(0.30, size.width), size.height * 0.96);
// //
// //     // Outer pinky side of palm up to pinky base
// //     path.cubicTo(
// //       _x(0.22, size.width), size.height * 0.88,
// //       _x(0.16, size.width), size.height * 0.72,
// //       _x(0.14, size.width), size.height * 0.52,
// //     );
// //
// //     // --- Pinky ---
// //     path.cubicTo(
// //       _x(0.10, size.width), size.height * 0.40,
// //       _x(0.10, size.width), size.height * 0.28,
// //       _x(0.14, size.width), size.height * 0.22,
// //     );
// //     path.quadraticBezierTo(
// //       _x(0.17, size.width), size.height * 0.18,
// //       _x(0.22, size.width), size.height * 0.22,
// //     );
// //     path.cubicTo(
// //       _x(0.24, size.width), size.height * 0.30,
// //       _x(0.24, size.width), size.height * 0.40,
// //       _x(0.25, size.width), size.height * 0.48,
// //     );
// //
// //     // --- Ring ---
// //     path.cubicTo(
// //       _x(0.26, size.width), size.height * 0.32,
// //       _x(0.27, size.width), size.height * 0.16,
// //       _x(0.30, size.width), size.height * 0.09,
// //     );
// //     path.quadraticBezierTo(
// //       _x(0.34, size.width), size.height * 0.05,
// //       _x(0.38, size.width), size.height * 0.09,
// //     );
// //     path.cubicTo(
// //       _x(0.40, size.width), size.height * 0.18,
// //       _x(0.40, size.width), size.height * 0.32,
// //       _x(0.40, size.width), size.height * 0.46,
// //     );
// //
// //     // --- Middle ---
// //     path.cubicTo(
// //       _x(0.41, size.width), size.height * 0.28,
// //       _x(0.42, size.width), size.height * 0.12,
// //       _x(0.45, size.width), size.height * 0.04,
// //     );
// //     path.quadraticBezierTo(
// //       _x(0.49, size.width), size.height * 0.005,
// //       _x(0.53, size.width), size.height * 0.04,
// //     );
// //     path.cubicTo(
// //       _x(0.55, size.width), size.height * 0.14,
// //       _x(0.55, size.width), size.height * 0.30,
// //       _x(0.55, size.width), size.height * 0.45,
// //     );
// //
// //     // --- Index ---
// //     path.cubicTo(
// //       _x(0.57, size.width), size.height * 0.28,
// //       _x(0.58, size.width), size.height * 0.14,
// //       _x(0.60, size.width), size.height * 0.09,
// //     );
// //     path.quadraticBezierTo(
// //       _x(0.64, size.width), size.height * 0.05,
// //       _x(0.68, size.width), size.height * 0.10,
// //     );
// //     path.cubicTo(
// //       _x(0.70, size.width), size.height * 0.20,
// //       _x(0.69, size.width), size.height * 0.34,
// //       _x(0.67, size.width), size.height * 0.47,
// //     );
// //
// //     // Web between index and thumb (deep V dip like the reference)
// //     path.cubicTo(
// //       _x(0.69, size.width), size.height * 0.52,
// //       _x(0.71, size.width), size.height * 0.56,
// //       _x(0.74, size.width), size.height * 0.55,
// //     );
// //
// //     // --- Thumb: thick, ~45° up-and-out (matches illustration) ---
// //     // Outer/top edge rising to tip
// //     path.cubicTo(
// //       _x(0.80, size.width), size.height * 0.48,
// //       _x(0.86, size.width), size.height * 0.38,
// //       _x(0.90, size.width), size.height * 0.34,
// //     );
// //     // Rounded tip (slightly flattened, nail sits here)
// //     path.cubicTo(
// //       _x(0.93, size.width), size.height * 0.31,
// //       _x(0.97, size.width), size.height * 0.34,
// //       _x(0.96, size.width), size.height * 0.40,
// //     );
// //     // Inner/bottom edge back toward thenar (thick shaft)
// //     path.cubicTo(
// //       _x(0.94, size.width), size.height * 0.48,
// //       _x(0.88, size.width), size.height * 0.56,
// //       _x(0.82, size.width), size.height * 0.62,
// //     );
// //     // Thenar mound (bulge under thumb base)
// //     path.cubicTo(
// //       _x(0.76, size.width), size.height * 0.70,
// //       _x(0.72, size.width), size.height * 0.78,
// //       _x(0.70, size.width), size.height * 0.86,
// //     );
// //     // Down to right wrist
// //     path.cubicTo(
// //       _x(0.68, size.width), size.height * 0.90,
// //       _x(0.66, size.width), size.height * 0.94,
// //       _x(0.64, size.width), size.height * 0.96,
// //     );
// //
// //     // Wrist base
// //     path.lineTo(_x(0.30, size.width), size.height * 0.96);
// //     path.close();
// //
// //     return path;
// //   }
// //
// //   void _drawCreases(Canvas canvas, Size size) {
// //     final paint = Paint()
// //       ..color = _crease.withValues(alpha: 0.75)
// //       ..style = PaintingStyle.stroke
// //       ..strokeWidth = 1.4
// //       ..strokeCap = StrokeCap.round;
// //
// //     // Heart / head / life-style palm lines
// //     final palm1 = Path()
// //       ..moveTo(_x(0.22, size.width), size.height * 0.58)
// //       ..cubicTo(
// //         _x(0.38, size.width), size.height * 0.54,
// //         _x(0.55, size.width), size.height * 0.56,
// //         _x(0.66, size.width), size.height * 0.62,
// //       );
// //     final palm2 = Path()
// //       ..moveTo(_x(0.24, size.width), size.height * 0.66)
// //       ..cubicTo(
// //         _x(0.40, size.width), size.height * 0.62,
// //         _x(0.52, size.width), size.height * 0.64,
// //         _x(0.62, size.width), size.height * 0.72,
// //       );
// //     final palm3 = Path()
// //       ..moveTo(_x(0.28, size.width), size.height * 0.72)
// //       ..cubicTo(
// //         _x(0.36, size.width), size.height * 0.78,
// //         _x(0.42, size.width), size.height * 0.84,
// //         _x(0.48, size.width), size.height * 0.90,
// //       );
// //
// //     canvas.drawPath(palm1, paint);
// //     canvas.drawPath(palm2, paint);
// //     canvas.drawPath(palm3, paint);
// //
// //     // Wrist ticks
// //     canvas.drawLine(
// //       _p(0.44, 0.93, size),
// //       _p(0.44, 0.97, size),
// //       paint..strokeWidth = 1.2,
// //     );
// //     canvas.drawLine(
// //       _p(0.50, 0.93, size),
// //       _p(0.50, 0.97, size),
// //       paint,
// //     );
// //
// //     // Knuckle creases — pinky, ring, middle, index
// //     void fingerCreases(double cx, double y1, double y2, double halfW) {
// //       final p = Paint()
// //         ..color = _crease.withValues(alpha: 0.7)
// //         ..strokeWidth = 1.15
// //         ..strokeCap = StrokeCap.round;
// //       canvas.drawLine(
// //         Offset(_x(cx - halfW, size.width), size.height * y1),
// //         Offset(_x(cx + halfW, size.width), size.height * y1),
// //         p,
// //       );
// //       canvas.drawLine(
// //         Offset(_x(cx - halfW * 0.9, size.width), size.height * y2),
// //         Offset(_x(cx + halfW * 0.9, size.width), size.height * y2),
// //         p,
// //       );
// //     }
// //
// //     fingerCreases(0.17, 0.30, 0.38, 0.028); // pinky
// //     fingerCreases(0.34, 0.20, 0.30, 0.032); // ring
// //     fingerCreases(0.49, 0.16, 0.28, 0.034); // middle
// //     fingerCreases(0.64, 0.20, 0.32, 0.032); // index
// //
// //     // Thumb joint creases (perpendicular to ~45° thumb axis)
// //     final thumbPaint = Paint()
// //       ..color = _crease.withValues(alpha: 0.7)
// //       ..strokeWidth = 1.15
// //       ..strokeCap = StrokeCap.round;
// //     // Distal crease near tip
// //     canvas.drawLine(
// //       _p(0.86, 0.38, size),
// //       _p(0.92, 0.42, size),
// //       thumbPaint,
// //     );
// //     // Proximal crease mid-thumb
// //     canvas.drawLine(
// //       _p(0.80, 0.48, size),
// //       _p(0.87, 0.54, size),
// //       thumbPaint,
// //     );
// //     // IP crease
// //     canvas.drawLine(
// //       _p(0.76, 0.56, size),
// //       _p(0.82, 0.61, size),
// //       thumbPaint,
// //     );
// //   }
// //
// //   void _drawThumbNail(Canvas canvas, Size size) {
// //     // Oval nail at tip, slightly rotated with the thumb angle
// //     final nail = Path()
// //       ..moveTo(_x(0.89, size.width), size.height * 0.33)
// //       ..cubicTo(
// //         _x(0.92, size.width), size.height * 0.30,
// //         _x(0.96, size.width), size.height * 0.32,
// //         _x(0.96, size.width), size.height * 0.37,
// //       )
// //       ..cubicTo(
// //         _x(0.95, size.width), size.height * 0.41,
// //         _x(0.91, size.width), size.height * 0.41,
// //         _x(0.89, size.width), size.height * 0.38,
// //       )
// //       ..close();
// //
// //     canvas.drawPath(
// //       nail,
// //       Paint()..color = const Color(0xFFF8E4D0),
// //     );
// //     canvas.drawPath(
// //       nail,
// //       Paint()
// //         ..color = _outline.withValues(alpha: 0.85)
// //         ..style = PaintingStyle.stroke
// //         ..strokeWidth = 1.1,
// //     );
// //   }
// //
// //   @override
// //   bool shouldRepaint(covariant HolographicHandPainter oldDelegate) {
// //     return oldDelegate.isLeftHand != isLeftHand ||
// //         oldDelegate.brightness != brightness ||
// //         oldDelegate.primaryColor != primaryColor;
// //   }
// // }
