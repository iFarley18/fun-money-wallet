import 'package:flutter/material.dart';

class SafeAssetImage extends StatelessWidget {
  final String filename;
  final String? themeId;
  final double width;
  final double height;
  final Widget Function(BuildContext) fallbackBuilder;

  const SafeAssetImage({
    super.key,
    required this.filename,
    this.themeId,
    required this.width,
    required this.height,
    required this.fallbackBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPath = 'assets/images/$filename';
    final themedPath =
        (themeId != null && themeId!.isNotEmpty && themeId != 'default')
            ? 'assets/images/$themeId/$filename'
            : null;

    if (themedPath == null) {
      return Image.asset(
        defaultPath,
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => fallbackBuilder(context),
      );
    }

    return Image.asset(
      themedPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          defaultPath,
          width: width,
          height: height,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => fallbackBuilder(context),
        );
      },
    );
  }
}
