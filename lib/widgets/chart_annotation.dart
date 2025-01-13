import 'package:eurojackpot/resources/app_colors.dart';
import 'package:eurojackpot/resources/app_dimens.dart';
import 'package:flutter/material.dart';

class ChartAnnotation extends StatelessWidget {
  const ChartAnnotation({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.chartAnotationHeight,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                      color: AppColors.chartLatestColor, height: 10, width: 20),
                  const Text(' Latest',
                      style: TextStyle(color: AppColors.chartLatestColor)),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Container(
                      color: AppColors.chart1DayBeforeColor,
                      height: 10,
                      width: 20),
                  const Text(' 1 day before',
                      style: TextStyle(color: AppColors.chart1DayBeforeColor)),
                ],
              ),
              Row(
                children: [
                  Container(
                      color: AppColors.chart2DayBeforeColor,
                      height: 10,
                      width: 20),
                  const Text(' 2 day before',
                      style: TextStyle(color: AppColors.chart2DayBeforeColor)),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Container(
                      color: AppColors.chart3DayBeforeColor,
                      height: 10,
                      width: 20),
                  const Text(' 3 day before',
                      style: TextStyle(color: AppColors.chart3DayBeforeColor)),
                ],
              ),
              Row(
                children: [
                  Container(
                      color: AppColors.chart4DayBeforeColor,
                      height: 10,
                      width: 20),
                  const Text(' 4 day before',
                      style: TextStyle(color: AppColors.chart4DayBeforeColor)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
