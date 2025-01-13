import 'package:flutter/material.dart';
import 'package:eurojackpot/utils/app_utils.dart';
import 'package:eurojackpot/resources/app_dimens.dart';

class NumberWidget extends StatelessWidget {
  const NumberWidget({super.key, required this.number, required this.isStar});

  final int number;
  final bool isStar;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimens.statisticNumWidth,
      width: AppDimens.statisticNumWidth,
      decoration: AppUtils.starDecoration(isStar),
      child: Center(
        child: Text(
          number.toString(),
          style: const TextStyle(
            fontSize: AppDimens.statisticFontWidth,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
