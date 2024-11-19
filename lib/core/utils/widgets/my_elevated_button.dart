import 'package:flutter/material.dart';

class DElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? buttonColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Icon? icon; // Add an optional icon

  const DElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.buttonColor,
    this.textColor,
    this.padding,
    this.borderRadius,
    this.icon, // Optional icon parameter
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: textColor,
        backgroundColor: buttonColor,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
        ),
      ),
      // Conditionally display the icon with the child
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min, // Adjust the size to match content
              children: [
                icon!, // Show the icon
                const SizedBox(width: 8), // Add spacing between the icon and text
                child, // Show the button's child (text or another widget)
              ],
            )
          : child, // If no icon, just show the child
    );
  }
}