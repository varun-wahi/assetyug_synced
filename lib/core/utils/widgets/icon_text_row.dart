import 'package:asset_yug_debugging/config/theme/text_styles.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class IconTextRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final double iconSize;
  final double fontSize;
  final Color iconColor;
  final Color textColor;
  final FontWeight fontWeight;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const IconTextRow({
    Key? key,
    required this.icon,
    required this.text,
    this.iconSize = 17,
    this.fontSize = 14,
    this.iconColor = const Color.fromARGB(255, 45, 45, 45),
    this.textColor = tBlack,
    this.fontWeight = FontWeight.w400,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Icon(icon, size: iconSize, color: iconColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: containerText(
            size: fontSize,
            color: textColor,
            weight: fontWeight,
          ),
        ),
      ],
    );
  }
}
