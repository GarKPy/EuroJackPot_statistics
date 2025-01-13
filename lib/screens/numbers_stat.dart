import 'package:eurojackpot/providers/utils_providers.dart';
import 'package:eurojackpot/resources/app_dimens.dart';
import 'package:eurojackpot/utils/app_utils.dart';
import 'package:eurojackpot/widgets/converted_chart_w.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NumbersStat extends ConsumerStatefulWidget {
  const NumbersStat({super.key});

  @override
  ConsumerState<NumbersStat> createState() => _NumbersStatState();
}

class _NumbersStatState extends ConsumerState<NumbersStat> {
  @override
  Widget build(BuildContext context) {
    //print('----- NumbersStat build');

    List<List<int>> wideData = ref.watch(wideTotalDataProvider);

    return Center(
        child: wideData.isEmpty
            ? const Text('No Data Available')
            : ListView.builder(
                key: const PageStorageKey<String>('statistic_charts'),
                itemCount: wideData.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.all(AppDimens.generalPadding),
                    decoration: AppUtils.generalBoxDecoration(),
                    child: ConvertedChart(
                      dataList: wideData[index],
                      number: index + 1,
                    ),
                  );
                },
              ));
  }
}
