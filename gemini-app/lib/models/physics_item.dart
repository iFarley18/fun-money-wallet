import 'dart:math';
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
  final double scale;
  final int stackCount;

  PhysicsItem({
    required this.id,
    required this.type,
    required this.position,
    this.velocity = Offset.zero,
    this.rotation = 0.0,
    this.angularVelocity = 0.0,
    this.isDragging = false,
    this.inTray = false,
    this.scale = 1.0,
    this.stackCount = 1,
  });

  int get totalCents => type.cents * stackCount;

  static Size baseSizeFor(DenominationType type) {
    if (type.isBill) {
      return const Size(120, 60);
    }
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

  Size get size {
    final base = baseSizeFor(type);
    return Size(base.width * scale, base.height * scale);
  }

  /// Computes a proportional scale factor in [0.55, 1.0] based on visible piece
  /// count, total base area, and available vault area so bills and coins fit
  /// comfortably without overflowing, keeping coins proportionally smaller than bills.
  static double computeScaleForStacks(
    List<VisibleDenominationStack> stacks,
    Size canvasSize,
  ) {
    if (stacks.isEmpty || canvasSize == Size.zero) return 1.0;

    final availW = max(180.0, canvasSize.width - 28.0);
    final availH = max(240.0, canvasSize.height - 220.0);
    final vaultArea = availW * availH;

    double totalBaseArea = 0.0;
    int visibleCount = 0;
    for (final s in stacks) {
      final base = baseSizeFor(s.type);
      totalBaseArea += base.width * base.height * s.visibleCount;
      visibleCount += s.visibleCount;
    }

    if (visibleCount <= 6) return 1.0;

    // Target ~26% area coverage for comfortable scatter and tidy stacking.
    final areaScale = sqrt((vaultArea * 0.26) / max(totalBaseArea, 1.0));

    // Also constrain width so active bill columns can fit across the screen.
    final activeBillTypes = stacks.where((s) => s.type.isBill).length;
    final cols = min(max(activeBillTypes, 1), 3);
    final maxColBillWidth = (availW - (cols - 1) * 10.0) / cols;
    final widthScale = maxColBillWidth / 120.0;

    final raw = min(areaScale, widthScale);
    return raw.clamp(0.55, 1.0);
  }
}
