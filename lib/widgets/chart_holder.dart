import 'package:eurojackpot/resources/app_resources.dart';
import 'package:eurojackpot/utils/app_utils.dart';
import 'package:eurojackpot/widgets/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChartHolder extends ConsumerWidget {
  const ChartHolder({super.key, required this.general});
  final bool general;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //print('Chart Holder');
    // double? chartHolderHeight;
    // double? chartHolderWidth;
    // bool isGeneralNum = this.general;

    // //ref.watch(reloadMyNumbers);

    // if (AppUtils.isLandscape(context)) {
    //   chartHolderHeight = AppUtils.screenHight -
    //       AppDimens.bottomBarHeight -
    //       4 * AppDimens.generalPadding;
    //   //AppDimens.safePaddingTop; // -
    //   //AppDimens.myNumbersWidth;
    //   chartHolderWidth = isGeneralNum
    //       ? AppUtils.screenWidth -
    //           AppDimens.myNumbersWidth -
    //           3 * AppDimens.generalPadding
    //       : null;
    // } else {
    //   chartHolderHeight = AppUtils.screenHight -
    //       AppDimens.appBarHeight -
    //       AppDimens.myNumbersWidth -
    //       AppDimens.bottomBarHeight -
    //       AppDimens.chartAnotationHeight -
    //       //4 * AppDimens.generalPadding -
    //       kToolbarHeight;
    //   chartHolderWidth = AppUtils.screenWidth - 2 * AppDimens.generalPadding;
    // }
    return Flexible(
      fit: FlexFit.loose,
      child: Container(
        margin: const EdgeInsets.only(
            left: AppDimens.generalPadding, right: AppDimens.generalPadding),
        //height: chartHolderHeight,
        //width: chartHolderWidth,
        decoration: AppUtils.generalBoxDecoration(),
        child: Chart(
          general: general,
        ),
      ),
    );
  }
}
