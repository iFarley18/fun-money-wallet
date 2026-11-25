import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/denomination_breakdown.dart';
import 'safe_asset_image.dart';

class PlayBillWidget extends StatelessWidget {
  final DenominationType type;
  final String? themeId;
  final double width;
  final double height;

  const PlayBillWidget({
    super.key,
    required this.type,
    this.themeId,
    this.width = 120,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return SafeAssetImage(
      filename: type.assetName,
      themeId: themeId,
      width: width,
      height: height,
      fallbackBuilder: (context) => _buildDrawnBill(),
    );
  }

  Widget _buildDrawnBill() {
    final color = type.colorValue as Color;
    final s = (width / 120.0).clamp(0.5, 1.5);
    final isLargeDenom = type.label.length >= 3;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.95),
            Color.lerp(color, Colors.black, 0.22)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(6 * s),
        border: Border.all(
          color: Colors.white.withOpacity(0.9),
          width: (1.8 * s).clamp(1.0, 2.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 4 * s,
            offset: Offset(2 * s, 3 * s),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5 * s),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _BillStripePainter(color.withOpacity(0.32), 12 * s),
              ),
            ),
            Positioned(top: 2 * s, left: 4 * s, child: _cornerText(type.label, s)),
            Positioned(top: 2 * s, right: 4 * s, child: _cornerText(type.label, s)),
            Positioned(bottom: 2 * s, left: 4 * s, child: _cornerText(type.label, s)),
            Positioned(bottom: 2 * s, right: 4 * s, child: _cornerText(type.label, s)),
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 2 * s),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withOpacity(0.88),
                  borderRadius: BorderRadius.circular(9 * s),
                  border: Border.all(
                    color: Colors.amberAccent,
                    width: (1.4 * s).clamp(0.8, 2.0),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${type.label}',
                      style: GoogleFonts.fredoka(
                        color: Colors.amberAccent,
                        fontSize: (isLargeDenom ? 13.5 : 16.0) * s,
                        fontWeight: FontWeight.bold,
                        height: 1.05,
                      ),
                    ),
                    Text(
                      'CREW PLAY CASH',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70,
                        fontSize: 5.5 * s,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 1.5 * s,
              left: 0,
              right: 0,
              child: Text(
                'NOT LEGAL TENDER',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white60,
                  fontSize: 5.0 * s,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cornerText(String text, double s) {
    return Text(
      text,
      style: GoogleFonts.jetBrainsMono(
        color: Colors.white,
        fontSize: (text.length >= 3 ? 7.5 : 9.5) * s,
        fontWeight: FontWeight.w900,
        height: 1.0,
      ),
    );
  }
}

class _BillStripePainter extends CustomPainter {
  final Color stripeColor;
  final double spacing;
  _BillStripePainter(this.stripeColor, this.spacing);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = stripeColor
      ..strokeWidth = 2.0;
    final step = spacing < 4 ? 4.0 : spacing;
    for (double i = -size.height; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
