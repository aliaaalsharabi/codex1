import 'package:flutter/material.dart';
import 'package:codex_firebase/constants/colors.dart';

class TShadowStyle {
  static final verticalProductShadow = BoxShadow(
      color: TColors.darkergrey.withOpacity(0.1),
      blurRadius: 50,
      spreadRadius: 7,
      offset: Offset(2, 0));

  static final horizontalProductShadow = BoxShadow(
      color: TColors.darkergrey.withOpacity(0.1),
      blurRadius: 50,
      spreadRadius: 7,
      offset: Offset(0, 2));
}
