import 'package:cr_assist/core/constants/sizes.dart';
import 'package:cr_assist/core/constants/texts.dart';
import 'package:cr_assist/features/auth/presentation/views/registration_screen/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class UHaveAnyAccount extends StatelessWidget {
  const UHaveAnyAccount({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(UTexts.dontHave, style: TextStyle(fontSize: 14.spMin)),
        const SizedBox(width: USizes.sm),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationScreen()));
          },
          child: Text(
            UTexts.signUp,
            style: TextStyle(fontSize: 14.spMin,
                fontWeight: FontWeight.bold,
                color: Colors.blue),
          ),
        ),
      ],
    );
  }
}