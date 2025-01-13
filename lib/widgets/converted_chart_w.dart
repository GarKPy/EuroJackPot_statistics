import 'package:collection/collection.dart';
import 'package:eurojackpot/extensions/color_extensions.dart';
import 'package:eurojackpot/resources/app_colors.dart';
import 'package:eurojackpot/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConvertedChart extends ConsumerStatefulWidget {
  const ConvertedChart(
      {super.key, required this.dataList, required this.number});
  final List<int> dataList;
  final int number;

  @override
  ConsumerState<ConvertedChart> createState() => _ConvertedChartState();
}

class _ConvertedChartState extends ConsumerState<ConvertedChart> {
  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];

  List<double> modifiedArray(List<int> data, int zeroLimit) {
    int zerosCount = 0;
    List<int> newArray = [];
    List<double> normalized = [];
    newArray.add(data[0]);
    for (int i = 1; i < data.length; i++) {
      if (data[i] == 0) {
        zerosCount++;
        if (zerosCount == zeroLimit) {
          newArray.add(newArray[i - 1] - 1);
          zerosCount = 0;
        } else {
          newArray.add(newArray[i - 1]);
        }
      } else {
        newArray.add(newArray[i - 1] + 1);
      }
    }

    int min = newArray.min;
    int max = newArray.max;
    for (int i = 0; i < newArray.length; i++) {
      normalized.add((newArray[i] - min) / (max - min));
    }

    return normalized;
  }

  int zeroCount = 9;

  @override
  Widget build(BuildContext context) {
    List<double> points = modifiedArray(widget.dataList, zeroCount);
    List<FlSpot> pointsData = points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.toDouble());
    }).toList();

    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
          padding: const EdgeInsets.all(5),
          child: Stack(children: [
            LineChart(mainData(pointsData)),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 50,
                decoration:
                    AppUtils.starDecoration(widget.number > 50 ? true : false),
                child: Text(
                  widget.number > 50
                      ? (widget.number - 50).toString()
                      : widget.number.toString(),
                  style: const TextStyle(
                    fontSize: 25,
                    //color: AppColors.contentColorAmber,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                width: 5,
                height: 5,
              ),
              Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: AppColors.contentColorCyan),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.indigo,
                      backgroundBlendMode: BlendMode.overlay),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (zeroCount > 1) {
                            setState(() {
                              zeroCount--;
                            });
                          }
                        },
                        icon: const Icon(Icons.arrow_back_ios),
                        color: Colors.blueAccent.lighten(70),
                        // disabledColor: Colors.red,
                      ),
                      Text(
                        zeroCount.toString(),
                        style: TextStyle(
                            color: AppColors.contentColorCyan.lighten(70),
                            fontSize: 30),
                      ),
                      IconButton(
                        onPressed: () {
                          if (zeroCount < 20) {
                            setState(() {
                              zeroCount++;
                            });
                          }
                        },
                        icon: const Icon(Icons.arrow_forward_ios),
                        color: Colors.blueAccent.lighten(70),
                      )
                    ],
                  )),
            ]),
          ])),
    );
  }

  LineChartData mainData(List<FlSpot> spotsList) {
    List<FlSpot> spots = spotsList;

    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 0.1,
        verticalInterval: 0.1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.mainGridLineColor.withOpacity(0.8),
            strokeWidth: 1,
          );
        },
        // getDrawingVerticalLine: (value) {
        //   return const FlLine(
        //     color: Color.fromARGB(255, 197, 31, 31),
        //     strokeWidth: 1,
        //   );
        // },
      ),
      titlesData: const FlTitlesData(
        show: false,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: spots.length.toDouble() + 20,
      minY: 0,
      maxY: 1,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: false,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
