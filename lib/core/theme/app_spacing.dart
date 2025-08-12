import 'package:flutter/widgets.dart';

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;

  static const double elevationSm = 2;
  static const double elevationMd = 4;
  static const double elevationLg = 8;

  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 20, vertical: 16);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
}

extension SpaceExt on num {
  SizedBox get vspace => SizedBox(height: toDouble());
  SizedBox get hspace => SizedBox(width: toDouble());
}