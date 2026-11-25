import 'package:flutter_test/flutter_test.dart';
import 'package:gemini_fun_money/models/money_balance.dart';
import 'package:gemini_fun_money/models/denomination_breakdown.dart';

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
    test('Decomposes cents into optimal physical currency counts', () {
      // $43.50 -> 2 x $20, 3 x $1, 2 x 25¢
      final breakdown = DenominationBreakdown.fromCents(4350);
      expect(breakdown.twenties, 2);
      expect(breakdown.tens, 0);
      expect(breakdown.fives, 0);
      expect(breakdown.ones, 3);
      expect(breakdown.quarters, 2);
      expect(breakdown.dimes, 0);
      expect(breakdown.nickels, 0);
      expect(breakdown.pennies, 0);
      expect(breakdown.totalItems, 7);
    });

    test('Handles zero balance gracefully', () {
      final breakdown = DenominationBreakdown.fromCents(0);
      expect(breakdown.totalItems, 0);
    });

    test('Clamps large balance sprite count to maximum limit', () {
      // Very large balance ($9,999.99) should cap sprite count under threshold
      final breakdown = DenominationBreakdown.fromCents(999999);
      expect(breakdown.totalItems, lessThanOrEqualTo(45));
    });
  });
}
