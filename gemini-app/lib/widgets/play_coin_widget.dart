import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/denomination_breakdown.dart';
import 'safe_asset_image.dart';

class PlayCoinWidget extends StatelessWidget {
  final DenominationType type;
  final String? themeId;
  final double size;

  const PlayCoinWidget({
    super.key,
    required this.type,
    this.themeId,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return SafeAssetImage(
      filename: type.assetName,
      themeId: themeId,
      width: size,
      height: size,
      fallbackBuilder: (context) => _buildDrawnCoin(),
    );
  }

  Widget _buildDrawnCoin() {
    final color = type.colorValue as Color;
    final borderW = (size * 0.045).clamp(1.0, 2.2);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.98),
            Color.lerp(color, Colors.black, 0.25)!,
          ],
          center: const Alignment(-0.3, -0.3),
        ),
        border: Border.all(color: Colors.white.withOpacity(0.85), width: borderW),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.78,
          height: size * 0.78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black26, width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            type.label,
            style: GoogleFonts.fredoka(
              color: type == DenominationType.coin25 || type == DenominationType.coin1
                  ? Colors.white
                  : Colors.black87,
              fontSize: size * 0.30,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
