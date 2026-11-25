import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/denomination_breakdown.dart';
import 'safe_asset_image.dart';

class PlayBillWidget extends StatelessWidget {
  final DenominationType type;
  final double width;
  final double height;

  const PlayBillWidget({
    super.key,
    required this.type,
    this.width = 120,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return SafeAssetImage(
      filename: type.assetName,
      width: width,
      height: height,
      fallbackBuilder: (context) => _buildDrawnBill(),
    );
  }

  Widget _buildDrawnBill() {
    final color = type.colorValue as Color;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.9), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background subtle stripes
          Positioned.fill(
            child: CustomPaint(
              painter: _BillStripePainter(color.withOpacity(0.3)),
            ),
          ),
          // Corners Denomination
          Positioned(top: 2, left: 4, child: _cornerText(type.label)),
          Positioned(top: 2, right: 4, child: _cornerText(type.label)),
          Positioned(bottom: 2, left: 4, child: _cornerText(type.label)),
          Positioned(bottom: 2, right: 4, child: _cornerText(type.label)),
          // Center Medallion
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.85),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amberAccent, width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '\$${type.label}',
                    style: GoogleFonts.fredoka(
                      color: Colors.amberAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'CREW PLAY CASH',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white70,
                      fontSize: 6,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Disclaimer
          Positioned(
            bottom: 2,
            left: 0,
            right: 0,
            child: Text(
              'NOT LEGAL TENDER',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white54,
                fontSize: 5.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cornerText(String text) {
    return Text(
      text,
      style: GoogleFonts.jetBrainsMono(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _BillStripePainter extends CustomPainter {
  final Color stripeColor;
  _BillStripePainter(this.stripeColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = stripeColor
      ..strokeWidth = 2.0;
    for (double i = -size.height; i < size.width; i += 12) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
