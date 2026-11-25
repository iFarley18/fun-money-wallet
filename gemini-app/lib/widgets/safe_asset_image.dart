import 'package:flutter/material.dart';

class SafeAssetImage extends StatelessWidget {
  final String filename;
  final double width;
  final double height;
  final Widget Function(BuildContext) fallbackBuilder;

  const SafeAssetImage({
    super.key,
    required this.filename,
    required this.width,
    required this.height,
    required this.fallbackBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/$filename',
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return fallbackBuilder(context);
      },
    );
  }
}
