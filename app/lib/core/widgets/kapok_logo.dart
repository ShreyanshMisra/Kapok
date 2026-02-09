import 'package:flutter/material.dart';

/// Reusable Kapok logo widget for AppBars
class KapokLogo extends StatelessWidget {
  final double height;
  final double width;

  const KapokLogo({super.key, this.height = 32, this.width = 32});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Image.asset(
        'assets/images/kapok_icon.png',
        height: height,
        width: width,
      ),
    );
  }
}
