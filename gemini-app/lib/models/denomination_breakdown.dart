import 'package:flutter/material.dart';

enum DenominationType {
  bill100(10000, true, 'play_bill_100.webp', '100', Color(0xFFF59E0B)),
  bill50(5000, true, 'play_bill_50.webp', '50', Color(0xFFEF4444)),
  bill20(2000, true, 'play_bill_20.webp', '20', Color(0xFFA855F7)),
  bill10(1000, true, 'play_bill_10.webp', '10', Color(0xFFF97316)),
  bill5(500, true, 'play_bill_5.webp', '5', Color(0xFF3B82F6)),
  bill1(100, true, 'play_bill_1.webp', '1', Color(0xFF2DD4BF)),
  coin25(25, false, 'play_coin_25.webp', '25¢', Color(0xFFF59E0B)),
  coin10(10, false, 'play_coin_10.webp', '10¢', Color(0xFF94A3B8)),
  coin5(5, false, 'play_coin_5.webp', '5¢', Color(0xFFCBD5E1)),
  coin1(1, false, 'play_coin_1.webp', '1¢', Color(0xFFB45309));

  final int cents;
  final bool isBill;
  final String assetName;
  final String label;
  final dynamic colorValue;

  const DenominationType(
    this.cents,
    this.isBill,
    this.assetName,
    this.label,
    this.colorValue,
  );
}

class VisibleDenominationStack {
  final DenominationType type;
  final int visibleCount;
  final int totalCount;

  const VisibleDenominationStack({
    required this.type,
    required this.visibleCount,
    required this.totalCount,
  });

  bool get isCollapsed => visibleCount == 1 && totalCount > 1;
}

class DenominationBreakdown {
  final int hundreds;
  final int fifties;
  final int twenties;
  final int tens;
  final int fives;
  final int ones;
  final int quarters;
  final int dimes;
  final int nickels;
  final int pennies;

  const DenominationBreakdown({
    this.hundreds = 0,
    this.fifties = 0,
    required this.twenties,
    required this.tens,
    required this.fives,
    required this.ones,
    required this.quarters,
    required this.dimes,
    required this.nickels,
    required this.pennies,
  });

  int get totalItems =>
      hundreds + fifties + twenties + tens + fives + ones + quarters + dimes + nickels + pennies;
  int get totalBills => hundreds + fifties + twenties + tens + fives + ones;
  int get totalCoins => quarters + dimes + nickels + pennies;
  int get totalCents =>
      hundreds * 10000 +
      fifties * 5000 +
      twenties * 2000 +
      tens * 1000 +
      fives * 500 +
      ones * 100 +
      quarters * 25 +
      dimes * 10 +
      nickels * 5 +
      pennies;

  int countFor(DenominationType type) {
    switch (type) {
      case DenominationType.bill100:
        return hundreds;
      case DenominationType.bill50:
        return fifties;
      case DenominationType.bill20:
        return twenties;
      case DenominationType.bill10:
        return tens;
      case DenominationType.bill5:
        return fives;
      case DenominationType.bill1:
        return ones;
      case DenominationType.coin25:
        return quarters;
      case DenominationType.coin10:
        return dimes;
      case DenominationType.coin5:
        return nickels;
      case DenominationType.coin1:
        return pennies;
    }
  }

  factory DenominationBreakdown.fromCents(int cents) {
    if (cents <= 0) {
      return const DenominationBreakdown(
        hundreds: 0,
        fifties: 0,
        twenties: 0,
        tens: 0,
        fives: 0,
        ones: 0,
        quarters: 0,
        dimes: 0,
        nickels: 0,
        pennies: 0,
      );
    }

    int rem = cents;
    int w100 = rem ~/ 10000; rem %= 10000;
    int w50  = rem ~/ 5000;  rem %= 5000;
    int w20  = rem ~/ 2000;  rem %= 2000;
    int w10  = rem ~/ 1000;  rem %= 1000;
    int w5   = rem ~/ 500;   rem %= 500;
    int w1   = rem ~/ 100;   rem %= 100;
    int c25  = rem ~/ 25;    rem %= 25;
    int c10  = rem ~/ 10;    rem %= 10;
    int c5   = rem ~/ 5;     rem %= 5;
    int c1   = rem;

    return DenominationBreakdown(
      hundreds: w100,
      fifties: w50,
      twenties: w20,
      tens: w10,
      fives: w5,
      ones: w1,
      quarters: c25,
      dimes: c10,
      nickels: c5,
      pennies: c1,
    );
  }

  List<DenominationType> toFlatList() {
    final list = <DenominationType>[];
    for (final type in DenominationType.values) {
      final count = countFor(type);
      for (int i = 0; i < count; i++) {
        list.add(type);
      }
    }
    return list;
  }

  /// Caps visible pieces when counts are large (e.g. $2,499.99 or $10,000+),
  /// collapsing high-count denominations into a single sprite with an `x N` badge.
  List<VisibleDenominationStack> toVisibleStacks({
    int maxTotalVisible = 36,
    int collapseThresholdPerDenom = 12,
  }) {
    final active = <DenominationType>[
      for (final t in DenominationType.values)
        if (countFor(t) > 0) t,
    ];
    if (active.isEmpty) return const [];

    final visible = <DenominationType, int>{
      for (final t in active) t: countFor(t),
    };

    // Collapse any individual denomination above threshold first.
    for (final t in active) {
      if (visible[t]! > collapseThresholdPerDenom) {
        visible[t] = 1;
      }
    }

    // If total visible items still exceed maxTotalVisible, collapse largest counts first.
    int currentTotal() => visible.values.fold(0, (a, b) => a + b);
    while (currentTotal() > maxTotalVisible) {
      DenominationType? maxType;
      int maxCount = 1;
      for (final t in active) {
        final c = visible[t]!;
        if (c > maxCount) {
          maxCount = c;
          maxType = t;
        }
      }
      if (maxType == null) break;
      visible[maxType] = 1;
    }

    return [
      for (final t in active)
        VisibleDenominationStack(
          type: t,
          visibleCount: visible[t]!,
          totalCount: countFor(t),
        ),
    ];
  }
}
