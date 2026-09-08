import 'package:cr_assist/core/constants/colors.dart';
import 'package:cr_assist/core/constants/sizes.dart';
import 'package:cr_assist/core/helpers/device_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class UDivider extends StatelessWidget {
  const UDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(thickness: 1, indent : USizes.lg.w , endIndent: USizes.sm.w , color: UColors.darkGrey,)),
        Text("OR", style: context.tt.bodySmall),
        Expanded(child: Divider(thickness: 1, indent: USizes.sm.w , endIndent: USizes.lg.w, color: UColors.darkGrey,))
      ],
    );
  }
}