import 'package:eurojackpot/models/history_numbers.dart';
import 'package:eurojackpot/models/wide_numbers.dart';
import 'package:eurojackpot/providers/my_random_numbers_provider.dart';
import 'package:eurojackpot/providers/utils_providers.dart';
import 'package:eurojackpot/resources/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eurojackpot/resources/app_colors.dart';
import 'package:collection/collection.dart';
import 'package:eurojackpot/extensions/color_extensions.dart';

class Chart extends ConsumerStatefulWidget {
  const Chart({super.key, required this.general});
  final bool general;

  @override
  ConsumerState<Chart> createState() => _ChartState();
}

class _ChartState extends ConsumerState<Chart> {
  @override
  Widget build(BuildContext context) {
    //print('****** Chart Build');
    bool isGeneralNum = widget.general;
    List<WideNumbers> dataList = ref.watch(dataToDisplayProvider);
    List<HistoryNumbers> histNums = ref.watch(historyNumbersProvider);
    List<int> myNumbers = ref.watch(myNumsProvider);

    List<List<int>> historyGeneral = [];
    List<List<int>> historyAdditional = [];
    if (dataList[0].generalNumQuantity!.isNotEmpty) {
      for (int i = 0; i < histNums.length; i++) {
        historyGeneral.add(
            histNums[i].generalNumHistory!.map((e) => int.parse(e)).toList());
        historyAdditional
            .add(histNums[i].addNumHistory!.map((e) => int.parse(e)).toList());
      }
      List<List<int>> historyNums;

      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;

      List<int> numbersOriginal = [];
      double min, max;
      List<double> extraLines = [];
      double fontSize, chartWidth, yOffset;

      bool isLandscape = screenHeight > screenWidth ? false : true;

      double barWidth = 25;
      double mainPadding = 5;
      double barPadding = 5;

      int koefBar;

// Setting variables for different charts
      if (isGeneralNum) {
        List<double> generalRegionsKoef = ref.watch(generalRegions);
        numbersOriginal = dataList[0].generalNumQuantity!;
        historyNums = historyGeneral;
        max = dataList[0].maxGeneral().toDouble();
        min = dataList[0].minGeneral().toDouble();
        extraLines = dataList[0].simpleRegionsGeneral(generalRegionsKoef);
        barWidth = AppDimens.barWidthGenerar;
        fontSize = AppDimens.myNumFontSize;

        barPadding = 10;
        chartWidth = isLandscape
            ? (barWidth + barPadding) * numbersOriginal.length +
                barPadding -
                AppDimens.myNumbersWidth
            : (barWidth + barPadding) * numbersOriginal.length + barPadding;

        yOffset = 7;
        koefBar = 1;
      } else {
        List<double> additionalRegionsKoef = ref.watch(additionalRegions);
        numbersOriginal = dataList[0].additionalNumQuantity!;
        historyNums = historyAdditional;
        max = dataList[0].maxAdditional().toDouble();
        min = dataList[0].minAdditional().toDouble();
        extraLines = dataList[0].simpleRegionsAdditional(additionalRegionsKoef);
        barWidth = AppDimens.barWidthAdditional;
        fontSize = 15;
        barPadding = isLandscape
            ? 15
            : (screenWidth -
                    2 * mainPadding -
                    barWidth * dataList[0].additionalNumQuantity!.length) /
                (dataList[0].additionalNumQuantity!.length + 1);
        chartWidth =
            (barWidth + barPadding) * numbersOriginal.length + barPadding;
        yOffset = 23;
        koefBar = 5;
      }
      const BorderRadius barRadius = BorderRadius.only(
          topLeft: Radius.circular(5), topRight: Radius.circular(5));

      return SingleChildScrollView(
        clipBehavior: Clip.hardEdge,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: chartWidth,
          //height: charHeight,
          child: numbersOriginal.isEmpty || historyNums.isEmpty
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Data not yet available! Loading...'),
                    CircularProgressIndicator(),
                  ],
                )
              : BarChart(
                  BarChartData(
                      barTouchData: barTouchData(
                          context, ref, fontSize, myNumbers, isGeneralNum),
                      titlesData: titlesData(isGeneralNum, myNumbers),
                      borderData: borderData,
                      barGroups: chartGroups(numbersOriginal, barRadius, min,
                          barWidth, historyNums, koefBar),
                      gridData: const FlGridData(show: false),
                      alignment: BarChartAlignment.spaceEvenly,
                      maxY: max + yOffset,
                      minY: min - 6 * koefBar,
                      extraLinesData: ExtraLinesData(horizontalLines: [
                        for (var i = 0; i < extraLines.length; i++)
                          HorizontalLine(
                              y: extraLines[i],
                              color: AppColors.contentColorGreen,
                              label: HorizontalLineLabel(
                                show: true,
                                labelResolver: (p0) => '${extraLines[i]}',
                              )),
                      ])),
                ),
        ),
      );
    } else {
      return const Center(
          child: SizedBox(
        height: 30,
        width: 30,
        child: CircularProgressIndicator(),
      ));
    }
  }
}

// Check if selected number is already in MyNumbers list
bool validateNumber(int index, List<int> myList, bool isGeneral) {
  List<int> tempList =
      isGeneral ? myList.take(5).toList() : myList.skip(5).toList();
  bool validate = tempList.contains(index + 1) ? false : true;

  return validate;
}

BarTouchData barTouchData(BuildContext context, WidgetRef ref, double fontSize,
    List<int> myNums, bool isGeneral) {
  return BarTouchData(
    touchCallback: (FlTouchEvent? event, BarTouchResponse? touchResponse) {
      if (event is FlLongPressStart) {
        int barIndex = touchResponse!.spot!.touchedBarGroupIndex;

        int selectedMyNumIndex = ref.read(myNumberSelectedProvider);
        int currentPage = ref.read(pageIndexProvider);
        int selectedNumber = -1;

        // if MyNumber selected to change
        if (selectedMyNumIndex != -1) {
          // If selected MyNumber and screen are corrent
          if ((selectedMyNumIndex < 5 && currentPage == 0) ||
              (selectedMyNumIndex > 4 && currentPage == 1)) {
            selectedNumber = selectedMyNumIndex;
          }

          if (selectedNumber != -1) {
            if (validateNumber(barIndex, myNums, isGeneral)) {
              myNums[selectedNumber] = barIndex + 1;

              ref.read(myNumberSelectedProvider.notifier).state = -1;

              //if number succesfully changed, reload myNumbersHolder
              ref.read(reloadMyNumbers.notifier).state++;
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Number already selected!'),
                ));
              }
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Select Number from Correct Screen!'),
              ));
            }
          }
        }
      }
    },
    enabled: true,
    touchTooltipData: BarTouchTooltipData(
      getTooltipColor: (group) => Colors.transparent,
      tooltipPadding: EdgeInsets.zero,
      tooltipMargin: 5,
      getTooltipItem: (
        BarChartGroupData group,
        int groupIndex,
        BarChartRodData rod,
        int rodIndex,
      ) {
        return BarTooltipItem(
          rod.toY.round().toString(),
          TextStyle(
            color: AppColors.contentColorCyan,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        );
      },
    ),
  );
}

Widget getTitles(
    double value, TitleMeta meta, bool isGeneral, List<int> myNums) {
  List<int> tempList =
      isGeneral ? myNums.take(5).toList() : myNums.skip(5).toList();

  Color color = tempList.contains(value.toInt())
      ? AppColors.contentColorAmber.lighten(30)
      : AppColors.contentColorCyan;

  FontWeight fontWeight =
      tempList.contains(value.toInt()) ? FontWeight.bold : FontWeight.normal;

  var style = TextStyle(
    color: color, //AppColors.contentColorCyan,
    fontWeight: fontWeight,
    fontSize: AppDimens.myNumFontSize,
  );

  return SideTitleWidget(
    axisSide: meta.axisSide,
    space: 4,
    child: Text(value.toInt().toString(), style: style),
  );
}

FlTitlesData titlesData(bool isGeneral, List<int> myNums) {
  return FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        getTitlesWidget: (value, meta) =>
            getTitles(value, meta, isGeneral, myNums),
      ),
    ),
    leftTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    topTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false, reservedSize: 20),
    ),
    rightTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
  );
}

List<BarChartGroupData> chartGroups(List<int> points, BorderRadius barRadius,
    double minY, double barWidth, List<List<int>> historyNums, int koefBar) {
  double newMinY = minY - 7 * koefBar;
  //print('***** ChartGroup Chart screen');

  return points.mapIndexed((index, value) {
    return BarChartGroupData(
      x: index + 1,
      barRods: [
        BarChartRodData(
          fromY: newMinY - koefBar,
          toY: value.toDouble(),
          rodStackItems: [
            BarChartRodStackItem(
                newMinY + 1 * koefBar,
                newMinY + 2 * koefBar,
                historyNums[0].contains(index + 1)
                    ? AppColors.chartLatestColor
                    : Colors.transparent,
                BorderSide(strokeAlign: 0.1, color: Colors.cyan.darken(20))),
            BarChartRodStackItem(
                newMinY + 2 * koefBar,
                newMinY + 3 * koefBar,
                historyNums[1].contains(index + 1)
                    ? AppColors.chart1DayBeforeColor
                    : Colors.transparent,
                BorderSide(strokeAlign: 0.1, color: Colors.cyan.darken(20))),
            BarChartRodStackItem(
                newMinY + 3 * koefBar,
                newMinY + 4 * koefBar,
                historyNums[2].contains(index + 1)
                    ? AppColors.chart2DayBeforeColor
                    : Colors.transparent,
                BorderSide(strokeAlign: 0.1, color: Colors.cyan.darken(20))),
            BarChartRodStackItem(
                newMinY + 4 * koefBar,
                newMinY + 5 * koefBar,
                historyNums[3].contains(index + 1)
                    ? AppColors.chart3DayBeforeColor
                    : Colors.transparent,
                BorderSide(strokeAlign: 0.1, color: Colors.cyan.darken(20))),
            BarChartRodStackItem(
                newMinY + 5 * koefBar,
                newMinY + 6 * koefBar,
                historyNums[4].contains(index + 1)
                    ? AppColors.chart4DayBeforeColor
                    : Colors.transparent,
                BorderSide(strokeAlign: 0.1, color: Colors.cyan.darken(20))),
            BarChartRodStackItem(newMinY + 6 * koefBar, newMinY + 7 * koefBar,
                Colors.transparent), //to eliminate rounded border
          ],
          width: barWidth,
          borderRadius: barRadius,
          color: Colors.cyan,
        )
      ],
      showingTooltipIndicators: [0],
    );
  }).toList();
}

FlBorderData get borderData => FlBorderData(
      show: false,
    );
