import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Next e Make this extension and helpers class separate
/// Extension file in: lib/core/extensions/context_extension.dart
/// Device helpers file: here


// EXTENSION PART (BuildContext shortcuts - No parameter needed)

extension UDeviceExtension on BuildContext {

  // ── Theme Shortcuts ──

  // Get text theme styles
  TextTheme get tt => Theme.of(this).textTheme;                                        // Use: TextStyle style = context.tt.bodyLarge;

  // Get color scheme colors
  ColorScheme get cs => Theme.of(this).colorScheme;                                    // Use: Color primaryColor = context.cs.primary;

  // Check if the current theme is dark mode
  bool get isDark => Theme.of(this).brightness == Brightness.dark;                     // Use: if (context.isDark) { ... }


  // ── MediaQuery Shortcuts ──

  // Get full MediaQueryData object
  MediaQueryData get mq => MediaQuery.of(this);                                        // Use: Size size = context.mq.size;

  // Get full screen height
  double get screenHeight => MediaQuery.of(this).size.height;                          // Use: double height = context.screenHeight;

  // Get full screen width
  double get screenWidth => MediaQuery.of(this).size.width;                            // Use: double width = context.screenWidth;

  // Get current keyboard height on screen
  double get keyboardHeight => MediaQuery.of(this).viewInsets.bottom;                  // Use: double kbHeight = context.keyboardHeight;


  // ── Responsive Breakpoints Shortcuts ──

  // Check if the device is a mobile phone (width less than 600)
  bool get isPhone => screenWidth < 600;                                               // Use: if (context.isPhone) { ... }

  // Check if the device is a tablet (width between 600 and 899)
  bool get isTablet => screenWidth >= 600 && screenWidth < 900;                        // Use: if (context.isTablet) { ... }

  // Check if the device is a desktop screen (width 900 or more)
  bool get isDesktop => screenWidth >= 900;                                            // Use: if (context.isDesktop) { ... }


  // ── Orientation Shortcuts ──

  // Check if screen is in portrait mode
  bool get isPortrait => MediaQuery.of(this).orientation == Orientation.portrait;      // Use: if (context.isPortrait) { ... }

  // Check if screen is in landscape mode
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;    // Use: if (context.isLandscape) { ... }


  // ── Actions Shortcuts ──

  // Hide software keyboard from screen
  void hideKeyboard() {
    FocusScope.of(this).requestFocus(FocusNode());                                     // Use: context.hideKeyboard();
  }
}



// HELPER CLASS PART (Global functions - No context required)

class UDeviceHelper {
  UDeviceHelper._(); // Private constructor to prevent object instantiation

  // Change the top status bar background color
  static Future<void> setStatusBarColor(Color color) async {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: color),                                     // Use: UDeviceHelper.setStatusBarColor(Colors.blue);
    );
  }

  // Toggle immersive fullscreen mode (Hide/Show status bar and navigation bar)
  static void setFullScreen(bool enable) {
    SystemChrome.setEnabledSystemUIMode(
      enable ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,                 // Use: UDeviceHelper.setFullScreen(true);
    );
  }

  // Get standard Flutter bottom navigation bar height (56.0 dp)
  static double getBottomNavigationBarHeight() {
    return kBottomNavigationBarHeight;                                                 // Use: double barHeight = UDeviceHelper.getBottomNavigationBarHeight();
  }

  // Get standard Flutter app bar / toolbar height (56.0 dp)
  static double getAppBarHeight() {
    return kToolbarHeight;                                                             // Use: double appBarH = UDeviceHelper.getAppBarHeight();
  }
}