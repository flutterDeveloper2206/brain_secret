import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../core/values/app_constants.dart';

class NativeService {
  static const _channel = MethodChannel(AppConstants.channelName);
  static const _streamChannel = EventChannel('com.example.finger_print_scan/live_stream');

  Future<bool> startLiveScan({
    required bool isFrame,
    required bool isLfd,
    required bool isInvert,
    required bool isNfiq,
    required bool isUsbHost,
  }) async {
    if (kIsWeb || !isUsbHost) {
      return true;
    }
    final bool? result = await _channel.invokeMethod<bool>('startLiveScan', {
      'isFrame': isFrame,
      'isLfd': isLfd,
      'isInvert': isInvert,
      'isNfiq': isNfiq,
      'isUsbHost': isUsbHost,
    });
    return result ?? false;
  }

  Future<Uint8List?> stopLiveScan() async {
    if (kIsWeb) {
      return await _generateWebMockFingerprint();
    }
    return await _channel.invokeMethod<Uint8List>('stopLiveScan');
  }

  Stream<Map<dynamic, dynamic>> get liveScanStream {
    if (kIsWeb) {
      // Mock stream for web/emulator
      return Stream.periodic(const Duration(milliseconds: 300), (count) {
        return {
          'status': 'OK',
          'nfiq': 4,
        };
      }).asyncMap((event) async {
        event['image'] = await _generateWebMockFingerprint();
        return event;
      });
    }
    return _streamChannel.receiveBroadcastStream().cast<Map<dynamic, dynamic>>();
  }

  Future<Uint8List> scanFingerprint() async {
    if (kIsWeb) {
      // Simulation: Generate concentric ring bytes dynamically
      await Future.delayed(const Duration(milliseconds: 800));
      return await _generateWebMockFingerprint();
    }
    final Uint8List? result = await _channel.invokeMethod<Uint8List>('scanFingerprint');
    if (result == null) {
      throw PlatformException(code: 'CAPTURE_FAILED', message: 'No print data received');
    }
    return result;
  }

  Future<Uint8List> scanFingerprintDevice() async {
    if (kIsWeb) {
      await Future.delayed(const Duration(milliseconds: 800));
      return await _generateWebMockFingerprint();
    }
    final Uint8List? result = await _channel.invokeMethod<Uint8List>('scanFingerprintDevice');
    if (result == null) {
      throw PlatformException(code: 'CAPTURE_FAILED', message: 'No print data received');
    }
    return result;
  }

  Future<Uint8List> _generateWebMockFingerprint() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 300, 400));
    
    // Background: White
    canvas.drawRect(const Rect.fromLTWH(0, 0, 300, 400), Paint()..color = Colors.white);
    
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    
    // Draw loops and arches
    final center = const Offset(150, 220);
    for (double r = 15; r < 200; r += 12) {
      canvas.drawOval(
        Rect.fromCenter(center: center, width: r * 1.5, height: r * 2.0),
        paint,
      );
    }
    
    final picture = recorder.endRecording();
    final img = await picture.toImage(300, 400);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<Uint8List> processImage(String path, Uint8List fallbackBytes) async {
    if (kIsWeb) {
      // Simulation: Web cannot execute native MethodChannels.
      // Wait briefly to mimic processing time, then return original bytes.
      await Future.delayed(const Duration(milliseconds: 600));
      return fallbackBytes;
    }
    return await _channel.invokeMethod<Uint8List>('processImage', {'imagePath': path}) 
        ?? fallbackBytes;
  }

  Future<int> countRidges({
    required String path,
    required double startX,
    required double startY,
    required double endX,
    required double endY,
  }) async {
    if (kIsWeb) {
      // Simulation: Calculate a mock ridge count based on vector distance
      await Future.delayed(const Duration(milliseconds: 300));
      final dx = endX - startX;
      final dy = endY - startY;
      final distance = math.sqrt(dx * dx + dy * dy);
      // Produce a mock count of 5-25 ridges proportionally
      return (distance / 12).clamp(4, 25).round();
    }
    
    final int? result = await _channel.invokeMethod<int>('countRidges', {
      'imagePath': path,
      'coreX': startX,
      'coreY': startY,
      'endX': endX,
      'endY': endY,
    });
    return result ?? 0;
  }
}
