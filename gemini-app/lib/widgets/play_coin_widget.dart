import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/denomination_breakdown.dart';
import 'safe_asset_image.dart';

class PlayCoinWidget extends StatelessWidget {
  final DenominationType type;
  final double size;

  const PlayCoinWidget({
    super.key,
    required this.type,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return SafeAssetImage(
      filename: type.assetName,
      width: size,
      height: size,
      fallbackBuilder: (context) => _buildDrawnCoin(),
    );
  }

  Widget _buildDrawnCoin() {
    final color = type.colorValue as Color;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.95),
            color.withOpacity(0.7),
          ],
          center: const Alignment(-0.3, -0.3),
        ),
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black26, width: 1),
          ),
          child: Text(
            type.label,
            style: GoogleFonts.fredoka(
              color: type == DenominationType.coin25 || type == DenominationType.coin1
                  ? Colors.white
                  : Colors.black87,
              fontSize: size * 0.32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
