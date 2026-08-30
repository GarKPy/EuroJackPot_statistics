import 'package:eurojackpot/models/wide_numbers.dart';
import 'package:eurojackpot/providers/utils_providers.dart';
import 'package:eurojackpot/utils/app_utils.dart';
import 'package:eurojackpot/widgets/number_w.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eurojackpot/resources/app_dimens.dart';

class StatisticScreen extends ConsumerWidget {
  const StatisticScreen({super.key});

  List<List<int>> filterByRegions(List<int> data, List<double> regions) {
    List<List<int>> filtered =
        List.generate(regions.length + 1, (index) => List.empty());

    filtered[0] = data
        .asMap()
        .entries
        .where((element) => (element.value > regions[0]))
        .map((e) => e.key + 1)
        .toList();
    filtered[1] = data
        .asMap()
        .entries
        .where((element) =>
            element.value <= regions[0] && element.value > regions[1])
        .map((e) => e.key + 1)
        .toList();
    filtered[2] = data
        .asMap()
        .entries
        .where((element) =>
            element.value <= regions[1] && element.value > regions[2])
        .map((e) => e.key + 1)
        .toList();
    filtered[3] = data
        .asMap()
        .entries
        .where((element) => element.value <= regions[2])
        .map((e) => e.key + 1)
        .toList();

    return filtered;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //print('----- Statistic Build');

    List<WideNumbers> dataList = ref.watch(dataToDisplayProvider);
    List<double> genRegionsKoef = ref.watch(generalRegions);
    List<double> addRegionsKoef = ref.watch(additionalRegions);
    List<int> genNum = dataList[0].generalNumQuantity ?? [0];
    List<int> addNum = dataList[0].additionalNumQuantity ?? [0];
    List<double> regionsGen = dataList[0].simpleRegionsGeneral(genRegionsKoef);
    List<double> regionsAdd =
        dataList[0].simpleRegionsAdditional(addRegionsKoef);

    List<List<int>> genByRegion = filterByRegions(genNum, regionsGen);
    List<List<int>> addByRegion = filterByRegions(addNum, regionsAdd);

    List<String> regionsNames = ['Max', 'Mid 1', 'Mid2', 'Min'];
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.generalPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 0; i < genByRegion.length; i++) ...[
            const SizedBox(
              height: AppDimens.generalPadding,
              width: AppDimens.generalPadding,
            ),
            Text(
              regionsNames[i],
              style: TextStyle(
                color: onSurfaceColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppDimens.generalPadding),
              decoration: AppUtils.generalBoxDecoration(),
              child: Wrap(
                children: [
                  for (int j = 0; j < genByRegion[i].length; j++) ...[
                    NumberWidget(number: genByRegion[i][j], isStar: false)
                  ]
                ],
              ),
            ),
          ],
          for (int i = 0; i < addByRegion.length; i++) ...[
            const SizedBox(
              height: AppDimens.generalPadding,
              width: AppDimens.generalPadding,
            ),
            Text(
              regionsNames[i],
              style: TextStyle(
                color: onSurfaceColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppDimens.generalPadding),
              decoration: AppUtils.generalBoxDecoration(),
              child: Wrap(
                children: [
                  for (int j = 0; j < addByRegion[i].length; j++) ...[
                    NumberWidget(number: addByRegion[i][j], isStar: true)
                  ]
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
