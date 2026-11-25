import 'package:flutter/material.dart';
import 'denomination_breakdown.dart';

class PhysicsItem {
  final String id;
  final DenominationType type;
  Offset position;
  Offset velocity;
  double rotation;
  double angularVelocity;
  bool isDragging;
  bool inTray;

  PhysicsItem({
    required this.id,
    required this.type,
    required this.position,
    this.velocity = Offset.zero,
    this.rotation = 0.0,
    this.angularVelocity = 0.0,
    this.isDragging = false,
    this.inTray = false,
  });

  Size get size {
    if (type.isBill) {
      return const Size(120, 60);
    } else {
      switch (type) {
        case DenominationType.coin25:
          return const Size(54, 54);
        case DenominationType.coin10:
          return const Size(42, 42);
        case DenominationType.coin5:
          return const Size(48, 48);
        case DenominationType.coin1:
          return const Size(44, 44);
        default:
          return const Size(48, 48);
      }
    }
  }
}
