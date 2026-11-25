import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemini_fun_money/models/money_balance.dart';
import 'package:gemini_fun_money/models/denomination_breakdown.dart';
import 'package:gemini_fun_money/models/physics_item.dart';

void main() {
  group('MoneyBalance Unit Tests', () {
    test('Stores and formats integer cents accurately', () {
      const balance = MoneyBalance(4350);
      expect(balance.totalCents, 4350);
      expect(balance.toDollars(), 43.50);
      expect(balance.toFormattedString(), '\$43.50');
    });

    test('Parses dollar string input to integer cents correctly', () {
      expect(MoneyBalance.parseDollarsToCents('43.50'), 4350);
      expect(MoneyBalance.parseDollarsToCents('\$18.25'), 1825);
      expect(MoneyBalance.parseDollarsToCents('0.99'), 99);
      expect(MoneyBalance.parseDollarsToCents('100'), 10000);
      expect(MoneyBalance.parseDollarsToCents('invalid'), 0);
    });
  });

  group('DenominationBreakdown Unit Tests', () {
    test('Decomposes \$0.01 accurately', () {
      final b = DenominationBreakdown.fromCents(1);
      expect(b.totalItems, 1);
      expect(b.pennies, 1);
      expect(b.totalCents, 1);
    });

    test('Decomposes \$3.41 accurately', () {
      final b = DenominationBreakdown.fromCents(341);
      expect(b.ones, 3);
      expect(b.quarters, 1);
      expect(b.dimes, 1);
      expect(b.nickels, 1);
      expect(b.pennies, 1);
      expect(b.totalItems, 7);
      expect(b.totalCents, 341);
    });

    test('Decomposes \$43.50 accurately', () {
      final b = DenominationBreakdown.fromCents(4350);
      expect(b.hundreds, 0);
      expect(b.fifties, 0);
      expect(b.twenties, 2);
      expect(b.tens, 0);
      expect(b.fives, 0);
      expect(b.ones, 3);
      expect(b.quarters, 2);
      expect(b.dimes, 0);
      expect(b.nickels, 0);
      expect(b.pennies, 0);
      expect(b.totalItems, 7);
      expect(b.totalCents, 4350);
    });

    test('Decomposes \$783.67 greedily with \$100 and \$50 and exact coins', () {
      final b = DenominationBreakdown.fromCents(78367);
      expect(b.hundreds, 7);
      expect(b.fifties, 1);
      expect(b.twenties, 1);
      expect(b.tens, 1);
      expect(b.fives, 0);
      expect(b.ones, 3);
      expect(b.quarters, 2);
      expect(b.dimes, 1);
      expect(b.nickels, 1);
      expect(b.pennies, 2);
      expect(b.totalItems, 19);
      expect(b.totalCents, 78367);
    });

    test('Decomposes \$2,499.99 and caps visible sprites cleanly', () {
      final b = DenominationBreakdown.fromCents(249999);
      expect(b.hundreds, 24);
      expect(b.fifties, 1);
      expect(b.twenties, 2);
      expect(b.tens, 0);
      expect(b.fives, 1);
      expect(b.ones, 4);
      expect(b.quarters, 3);
      expect(b.dimes, 2);
      expect(b.nickels, 0);
      expect(b.pennies, 4);
      expect(b.totalCents, 249999);

      final stacks = b.toVisibleStacks();
      final visibleTotal = stacks.fold<int>(0, (s, e) => s + e.visibleCount);
      expect(visibleTotal, lessThanOrEqualTo(36));
      final hundredStack = stacks.firstWhere((e) => e.type == DenominationType.bill100);
      expect(hundredStack.isCollapsed, isTrue);
      expect(hundredStack.totalCount, 24);
    });

    test('Decomposes \$25,000.00 and caps visible sprites with x250 badge', () {
      final b = DenominationBreakdown.fromCents(2500000);
      expect(b.hundreds, 250);
      expect(b.totalCents, 2500000);

      final stacks = b.toVisibleStacks();
      expect(stacks.length, 1);
      expect(stacks.first.visibleCount, 1);
      expect(stacks.first.totalCount, 250);
      expect(stacks.first.isCollapsed, isTrue);
    });

    test('Handles zero balance gracefully', () {
      final breakdown = DenominationBreakdown.fromCents(0);
      expect(breakdown.totalItems, 0);
      expect(breakdown.toVisibleStacks(), isEmpty);
    });

    test('Auto-scale shrinks proportionally and keeps coins smaller than bills', () {
      const phoneCanvas = Size(411, 891);
      final smallStacks = DenominationBreakdown.fromCents(4350).toVisibleStacks();
      final medStacks = DenominationBreakdown.fromCents(78367).toVisibleStacks();

      final smallScale = PhysicsItem.computeScaleForStacks(smallStacks, phoneCanvas);
      final medScale = PhysicsItem.computeScaleForStacks(medStacks, phoneCanvas);

      expect(smallScale, lessThanOrEqualTo(1.0));
      expect(medScale, inInclusiveRange(0.55, 1.0));
      expect(medScale, lessThan(smallScale));

      final billW = PhysicsItem.baseSizeFor(DenominationType.bill100).width * medScale;
      final coinW = PhysicsItem.baseSizeFor(DenominationType.coin25).width * medScale;
      expect(coinW, lessThan(billW));
    });
  });
}
