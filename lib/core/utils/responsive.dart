import 'package:flutter/widgets.dart';
import '../constants/app_constants.dart';

class Responsive {
  Responsive._();

  static bool isMobile(BuildContext context) => MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= AppConstants.mobileBreakpoint && width < AppConstants.tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= AppConstants.tabletBreakpoint;

  static int gridColumnsForWidth(double width) {
    if (width < AppConstants.mobileBreakpoint) return 2;
    if (width < AppConstants.tabletBreakpoint) return 3;
    return 4;
  }

  static double responsivePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < AppConstants.mobileBreakpoint) return 16;
    if (width < AppConstants.tabletBreakpoint) return 20;
    return 24;
  }
}