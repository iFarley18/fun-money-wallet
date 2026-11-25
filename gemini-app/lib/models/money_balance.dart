class MoneyBalance {
  final int totalCents;

  const MoneyBalance(this.totalCents) : assert(totalCents >= 0, 'Cents cannot be negative');

  double toDollars() => totalCents / 100.0;

  String toFormattedString() {
    final dollars = totalCents ~/ 100;
    final cents = totalCents % 100;
    return '\$${dollars.toString()}.${cents.toString().padLeft(2, '0')}';
  }

  static int parseDollarsToCents(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) return 0;
    final parts = cleaned.split('.');
    final dollars = int.tryParse(parts[0]) ?? 0;
    int cents = 0;
    if (parts.length > 1) {
      final centsStr = parts[1].padRight(2, '0').substring(0, 2);
      cents = int.tryParse(centsStr) ?? 0;
    }
    return (dollars * 100) + cents;
  }
}
