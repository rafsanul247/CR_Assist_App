import 'package:cr_assist/core/constants/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class UForgetPasswordText extends StatelessWidget {
  const UForgetPasswordText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        UTexts.forgetPassword,
        style: TextStyle(fontSize: 14.spMin,
            color: Colors.blue,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
