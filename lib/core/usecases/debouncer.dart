import 'dart:async';

import 'package:flutter/material.dart';

class Debouncer {
  Debouncer({required this.milliseconds});
  final int milliseconds;

  VoidCallback? action;
  Timer? _timer;

  void runTimer(VoidCallback action){
    if(_timer != null) _timer!.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);

  }

}