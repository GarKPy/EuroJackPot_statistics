import 'package:eurojackpot/providers/my_random_numbers_provider.dart';
import 'package:eurojackpot/resources/app_resources.dart';
import 'package:eurojackpot/utils/app_utils.dart';
import 'package:eurojackpot/widgets/chart_annotation.dart';
import 'package:eurojackpot/widgets/chart_holder.dart';
import 'package:eurojackpot/widgets/my_numbers_holder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChartScreen extends ConsumerWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //print('----- ChartScreen');

    bool isPortret = !AppUtils.isLandscape(context);
    if (ref.read(myRandomNumbersProvider.notifier).myNums.isEmpty) {
      //print('Random isEmpty');
      ref.read(myRandomNumbersProvider.notifier).generateRandomNumbers();
    }

    return Center(
        child: isPortret
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    SizedBox(height: AppDimens.generalPadding),
                    ChartAnnotation(),
                    SizedBox(height: AppDimens.generalPadding),
                    ChartHolder(
                      general: true,
                    ),
                    SizedBox(height: AppDimens.generalPadding),
                    MyNumbersHolder(),
                    SizedBox(height: AppDimens.generalPadding),
                  ])
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: AppDimens.generalPadding),
                  ChartHolder(
                    general: true,
                  ),
                  SizedBox(width: AppDimens.generalPadding),
                  MyNumbersHolder(),
                  SizedBox(width: AppDimens.generalPadding)
                ],
              ));
  }
}
