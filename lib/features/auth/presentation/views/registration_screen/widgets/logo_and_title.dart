import 'package:cr_assist/core/constants/colors.dart';
import 'package:cr_assist/core/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';


class ULogoAndTitle extends StatelessWidget {
  const ULogoAndTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: () {
          context.pop();
        }, icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white)),
        6.horizontalSpace,
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
              color: UColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6)
          ),
          child: Center(
            child: Image.asset(Constants.appLogo, height: 20, width: 20, fit: BoxFit.cover,),
          ),
        ),
        const SizedBox(width:8),
        Text(Constants.appName, style: TextStyle(fontSize: 16.spMin, fontWeight: FontWeight.bold, color: Colors.white),)
      ],
    );
  }
}