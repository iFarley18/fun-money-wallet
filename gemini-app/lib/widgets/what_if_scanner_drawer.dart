import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/money_balance.dart';

class WhatIfScannerDrawer extends StatefulWidget {
  final ValueChanged<int> onTargetPriceSet;
  final VoidCallback onClose;
  final int currentTargetCents;

  const WhatIfScannerDrawer({
    super.key,
    required this.onTargetPriceSet,
    required this.onClose,
    required this.currentTargetCents,
  });

  @override
  State<WhatIfScannerDrawer> createState() => _WhatIfScannerDrawerState();
}

class _WhatIfScannerDrawerState extends State<WhatIfScannerDrawer> {
  late String _inputDigits;

  @override
  void initState() {
    super.initState();
    _inputDigits = widget.currentTargetCents > 0
        ? (widget.currentTargetCents / 100.0).toStringAsFixed(2)
        : '14.00';
  }

  void _appendDigit(String d) {
    setState(() {
      if (_inputDigits == '0.00' || _inputDigits == '0') {
        _inputDigits = d;
      } else {
        _inputDigits += d;
      }
    });
  }

  void _clear() {
    setState(() {
      _inputDigits = '0';
    });
  }

  void _applyTarget() {
    final cents = MoneyBalance.parseDollarsToCents(_inputDigits);
    widget.onTargetPriceSet(cents);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black87, blurRadius: 12, spreadRadius: 2),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mandatory Non-negotiable Disclaimer Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B00),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'PRETEND PLAY ONLY — REAL CARD BALANCE UNCHANGED',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '"What-If" Toy Price Scanner',
                style: GoogleFonts.fredoka(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: widget.onClose,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Target Price Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF00E5FF), width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Item Test Cost:',
                  style: GoogleFonts.fredoka(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  '\$\$_inputDigits',
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFF00E5FF),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Quick Selector Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [500, 1000, 1500, 2000].map((c) {
              final text = '\$${(c ~/ 100)}';
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.amberAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _inputDigits = (c / 100.0).toStringAsFixed(2);
                  });
                },
                child: Text(text, style: GoogleFonts.fredoka(fontWeight: FontWeight.bold)),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _clear,
                  child: Text('Reset Tray', style: GoogleFonts.fredoka(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    _applyTarget();
                    widget.onClose();
                  },
                  child: Text('Drop Purchase Tray', style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
