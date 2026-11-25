import 'package:flutter/material.dart';

enum DenominationType {
  bill20(2000, true, 'play_bill_20.png', '20', Color(0xFFA855F7)),
  bill10(1000, true, 'play_bill_10.png', '10', Color(0xFFF97316)),
  bill5(500, true, 'play_bill_5.png', '5', Color(0xFF3B82F6)),
  bill1(100, true, 'play_bill_1.png', '1', Color(0xFF2DD4BF)),
  coin25(25, false, 'play_coin_25.png', '25¢', Color(0xFFF59E0B)),
  coin10(10, false, 'play_coin_10.png', '10¢', Color(0xFF94A3B8)),
  coin5(5, false, 'play_coin_5.png', '5¢', Color(0xFFCBD5E1)),
  coin1(1, false, 'play_coin_1.png', '1¢', Color(0xFFB45309));

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

class DenominationBreakdown {
  final int twenties;
  final int tens;
  final int fives;
  final int ones;
  final int quarters;
  final int dimes;
  final int nickels;
  final int pennies;

  const DenominationBreakdown({
    required this.twenties,
    required this.tens,
    required this.fives,
    required this.ones,
    required this.quarters,
    required this.dimes,
    required this.nickels,
    required this.pennies,
  });

  int get totalItems => twenties + tens + fives + ones + quarters + dimes + nickels + pennies;
  int get totalBills => twenties + tens + fives + ones;
  int get totalCoins => quarters + dimes + nickels + pennies;

  factory DenominationBreakdown.fromCents(int cents) {
    if (cents <= 0) {
      return const DenominationBreakdown(
        twenties: 0, tens: 0, fives: 0, ones: 0,
        quarters: 0, dimes: 0, nickels: 0, pennies: 0,
      );
    }

    int rem = cents;
    int w20 = rem ~/ 2000; rem %= 2000;
    int w10 = rem ~/ 1000; rem %= 1000;
    int w5  = rem ~/ 500;  rem %= 500;
    int w1  = rem ~/ 100;  rem %= 100;
    int c25 = rem ~/ 25;   rem %= 25;
    int c10 = rem ~/ 10;   rem %= 10;
    int c5  = rem ~/ 5;    rem %= 5;
    int c1  = rem;

    int totalSprites = w20 + w10 + w5 + w1 + c25 + c10 + c5 + c1;
    if (totalSprites > 40) {
      return DenominationBreakdown._clampedBreakdown(cents);
    }

    return DenominationBreakdown(
      twenties: w20, tens: w10, fives: w5, ones: w1,
      quarters: c25, dimes: c10, nickels: c5, pennies: c1,
    );
  }

  static DenominationBreakdown _clampedBreakdown(int cents) {
    int rem = cents;
    int w20 = rem ~/ 2000; rem %= 2000;
    int w10 = rem ~/ 1000; rem %= 1000;
    int w5  = rem ~/ 500;  rem %= 500;
    int w1  = rem ~/ 100;  rem %= 100;
    int c25 = rem ~/ 25;   rem %= 25;
    return DenominationBreakdown(
      twenties: w20, tens: w10, fives: w5, ones: w1,
      quarters: c25, dimes: 0, nickels: 0, pennies: rem % 25,
    );
  }

  List<DenominationType> toFlatList() {
    final list = <DenominationType>[];
    for (int i = 0; i < twenties; i++) list.add(DenominationType.bill20);
    for (int i = 0; i < tens; i++) list.add(DenominationType.bill10);
    for (int i = 0; i < fives; i++) list.add(DenominationType.bill5);
    for (int i = 0; i < ones; i++) list.add(DenominationType.bill1);
    for (int i = 0; i < quarters; i++) list.add(DenominationType.coin25);
    for (int i = 0; i < dimes; i++) list.add(DenominationType.coin10);
    for (int i = 0; i < nickels; i++) list.add(DenominationType.coin5);
    for (int i = 0; i < pennies; i++) list.add(DenominationType.coin1);
    return list;
  }
}
