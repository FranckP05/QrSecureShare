import 'package:flutter/material.dart';

class GradientContainer extends StatelessWidget {
  final List<Color> colors;
  final Widget? child;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;

  const GradientContainer({
    super.key,
    required this.colors,
    this.child,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: borderRadius,
      ),
      padding: padding,
      child: child,
    );
  }
}