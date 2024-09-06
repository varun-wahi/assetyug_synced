
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class DSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final InputBorder? border;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final double elevation;

  const DSearchBar({
    Key? key,
    required this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.border,
    this.padding = const EdgeInsets.all(8.0),
    this.textStyle = const TextStyle(color: tBlack),
    this.backgroundColor = Colors.white,
    this.elevation = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        cursorColor: tBlack,
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: textStyle,
        decoration: InputDecoration(
          fillColor: tWhite,
          filled: true,
          
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          prefixIconColor: tPrimary,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(D_SEARCHBAR_RADIUS),
              borderSide: const BorderSide(color: tGreyLight, width: D_BORDER_WIDTH)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(D_SEARCHBAR_RADIUS),
              borderSide: const BorderSide(color: tPrimary,width: D_BORDER_WIDTH)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(D_SEARCHBAR_RADIUS),
              borderSide: const BorderSide(color: tRed,width: D_BORDER_WIDTH)),
        ),
      ),
    );
      }
    
  }

