import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class DDropdown extends StatefulWidget {
  final String label;
  final List<DropdownMenuItem> items;
  final bool isMandatory;
  final EdgeInsets padding;
  final ValueChanged<dynamic> onChanged;
  final dynamic value; // Add this line

  const DDropdown({
    Key? key,
    required this.label,
    required this.items,
    this.isMandatory = false,
    required this.onChanged,
    this.padding = EdgeInsets.zero,
    this.value, // Add this line
  }) : super(key: key);

  @override
  State<DDropdown> createState() => DDropdownState();
}

class DDropdownState extends State<DDropdown> {
  var selectedOption;

   void clearDropdown(){
    setState(() {
      
    selectedOption = null;
    });
   }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: DropdownButtonFormField(
        value: widget.value, // Use widget.value instead of selectedOption
        decoration: InputDecoration(
          labelText: widget.isMandatory ? "${widget.label}*" : widget.label,
          labelStyle: const TextStyle(color: tBlack),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: tBlack)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: tBlack)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: tRed)),
        ),
        items: widget.items,
        onChanged: (option) {
          widget.onChanged(option);
        },
      ),
    );
    
  }
}

