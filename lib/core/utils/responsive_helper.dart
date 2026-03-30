import 'package:flutter/material.dart';

/// A utility class to help with making the UI responsive for tablets and mobile devices.
class ResponsiveHelper {
  /// Threshold for tablet devices (Logical Pixels)
  static const double tabletBreakpoint = 600;

  /// Threshold for large tablets or desktop-like views
  static const double desktopBreakpoint = 1024;

  /// Returns true if the device is a tablet (Shortest side >= 600dp)
  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide >= tabletBreakpoint;
  }

  /// Returns true if the device is a mobile (Shortest side < 600dp)
  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide < tabletBreakpoint;
  }

  /// Returns true if the device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.landscape;
  }

  /// Helper to get the number of grid columns for product lists
  /// - Mobile: 2
  /// - Tablet Portrait: 3
  /// - Tablet Landscape: 4
  static int getGridColumnCount(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    
    if (width >= desktopBreakpoint) return 5; // Extra large tablet / Desktop
    if (width >= tabletBreakpoint) {
      return isLandscape(context) ? 4 : 3;
    }
    return 2; // Default Mobile
  }

  /// Helper to get the side-by-side split ratio for product details
  /// Returns null if mobile (should use vertical layout)
  static double? getProductDetailsSplitRatio(BuildContext context) {
    if (isMobile(context)) return null;
    return isLandscape(context) ? 0.45 : 0.40; // Left side (Images) %
  }
}
