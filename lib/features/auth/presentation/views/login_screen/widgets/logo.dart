import 'package:cr_assist/core/constants/colors.dart';
import 'package:cr_assist/core/helpers/device_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

class ULogo extends StatelessWidget {
  const ULogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 40.r,
      backgroundColor: context.isDarkMode? Colors.grey[200] : UColors.grey ,
      child: CircleAvatar(
        radius: 35.r,
        backgroundColor: Colors.white,
        backgroundImage: AssetImage(
          context.isDark? "assets/icons/app_icon_white.png" : "assets/icons/app_icon_black.png",
        ),
      ),
    );
  }
}