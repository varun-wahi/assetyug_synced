 import 'package:flutter/material.dart';



 List<BoxShadow> dBoxShadow({
  Color color = Colors.black45,
  Offset offset = const Offset(0, 1),
  double blurRadius = 1.0,
 }){

 return   [BoxShadow(
            color: color,
            offset: offset,
            blurRadius: blurRadius,
          )];
 }
