import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String svgPath;
  final double svgWidth;
  final Color svgColor;
  final String text;
  final List<Color> lightColors;
  final List<Color> darkColors;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.svgPath,
    required this.svgWidth,
    this.svgColor=Colors.white,
    required this.text,
    required this.lightColors,
    required this.darkColors,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1.2,
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.light ? lightColors : darkColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              SvgPicture.asset(svgPath, width: svgWidth, color: svgColor),
              const SizedBox(width: 20),
              Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, fontFamily: 'WorkSans', color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}