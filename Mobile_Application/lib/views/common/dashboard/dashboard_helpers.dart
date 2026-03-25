import 'package:flutter/material.dart';

String statusFromLoss(double loss) {
  if (loss >= 8) return "CRITICAL";
  if (loss >= 5) return "ATTENTION";
  return "OK";
}

Color statusColorFromStatus(String status) {
  switch (status) {
    case "OK":
      return Colors.greenAccent;
    case "ATTENTION":
      return Colors.amberAccent;
    default:
      return Colors.redAccent;
  }
}