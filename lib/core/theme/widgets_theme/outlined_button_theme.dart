import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';




class UOutlinedButtonTheme {
  UOutlinedButtonTheme._();


  static final lightOutlinedButtonTheme  = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: UColors.dark,
      side: const BorderSide(color: UColors.borderPrimary),
      textStyle: const TextStyle(fontSize: 16, color: UColors.black, fontWeight: FontWeight.w600),
      padding: EdgeInsets.symmetric(vertical: USizes.buttonHeight, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(USizes.buttonRadius)),
    ),
  );


  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: UColors.light,
      side: const BorderSide(color: UColors.borderPrimary),
      textStyle: const TextStyle(fontSize: 16, color: UColors.textWhite, fontWeight: FontWeight.w600),
      padding: EdgeInsets.symmetric(vertical: USizes.buttonHeight, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(USizes.buttonRadius)),
    ),
  );


  // Theme-Aware Custom Modifications (Overriding Radius Dynamically)

  /// Returns the current global theme style with an overridden border radius of 12
  static ButtonStyle radius12(BuildContext context) {
    return Theme.of(context).outlinedButtonTheme.style!.copyWith(
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),        // Use: UOutlinedButtonTheme.radius12(context)
      ),
    );
  }

  /// Returns the current global theme style with an overridden border radius of 48
  static ButtonStyle radius48(BuildContext context) {
    return Theme.of(context).outlinedButtonTheme.style!.copyWith(
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(48)),        // Use : UOutlinedButtonTheme.radius48(context)
      ),
    );
  }
}
