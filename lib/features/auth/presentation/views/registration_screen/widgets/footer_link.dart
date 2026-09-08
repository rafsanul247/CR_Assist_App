import 'package:cr_assist/core/helpers/device_helpers.dart';
import 'package:cr_assist/features/auth/presentation/views/login_screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class UFooterLink extends StatelessWidget {
  const UFooterLink({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account?",
          style: context.tt.bodyMedium,
        ),
        4.horizontalSpace,
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
          },
          child: Text(
            "Login",
            style: TextStyle(
              fontSize: 16.spMin,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}