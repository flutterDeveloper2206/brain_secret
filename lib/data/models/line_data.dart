import 'package:flutter/material.dart';

class LineData {
  final String id;
  final Offset start; // Canvas coordinates
  Offset end; // Canvas coordinates
  final Color color;
  int? ridgeCount;

  LineData({
    required this.id,
    required this.start,
    required this.end,
    required this.color,
    this.ridgeCount,
  });
}
