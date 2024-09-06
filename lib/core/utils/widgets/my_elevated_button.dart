import 'package:flutter/material.dart';

class DElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? buttonColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  const DElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.buttonColor,
    this.textColor,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: textColor, backgroundColor: buttonColor,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
        ),
      ),
      child: child,
    );
  }
}
