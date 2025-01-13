import 'dart:math';

import 'package:eurojackpot/models/wide_numbers.dart';
import 'package:eurojackpot/providers/database_provider.dart';
import 'package:eurojackpot/providers/utils_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

List<List<int>> filterByRegions(List<int> data, List<double> region) {
  List<List<int>> filteredList = [];
  for (int i = 0; i < region.length; i++) {
    if (i == 0) {
      filteredList.add(data
          .asMap()
          .entries
          .where((element) => (element.value <= region[i]))
          .map((e) => e.key)
          .toList());
      filteredList.add(data
          .asMap()
          .entries
          .where((element) =>
              element.value > region[i] && element.value <= region[i + 1])
          .map((e) => e.key)
          .toList());
    } else if (i == region.length - 1) {
      filteredList.add(data
          .asMap()
          .entries
          .where((element) => element.value > region[i])
          .map((e) => e.key)
          .toList());
    } else {
      filteredList.add(data
          .asMap()
          .entries
          .where((element) =>
              element.value > region[i] && element.value <= region[i + 1])
          .map((e) => e.key)
          .toList());
    }
  }

  return filteredList;
}

List<int> randomize(List<List<int>> dataList, List<int> quantityList,
    int takeQuantyti, bool randByRegion) {
  List<int> generatedResult = [];
  if (!randByRegion) {
    List<int> tempData = [for (var list in dataList) ...list];

    generatedResult = [...((tempData..shuffle()).take(takeQuantyti).toList())];
  } else {
    for (var i = 0; i < dataList.length; i++) {
      generatedResult = [
        ...generatedResult,
        ...((dataList[i]..shuffle()).take(quantityList[i]).toList())
      ];
    }
  }
  generatedResult = generatedResult.map((e) => e + 1).toList();
  return generatedResult;
}

List<double> getRegions(List<int> dataList, List<double> regionsKoef) {
  """
  Return regions from dataList. Data being scaled and regions calculated by koeficients
  """;
  int maxValue = dataList.reduce(max);
  int minValue = dataList.reduce(min);
  List<double> regions = [
    (maxValue - minValue) * regionsKoef[2] + minValue,
    (maxValue - minValue) * regionsKoef[1] + minValue,
    (maxValue - minValue) * regionsKoef[0] + minValue
  ];

  return regions;
}

class RandomNumGenerator extends StateNotifier<List<int>> {
  RandomNumGenerator(this.ref) : super([]);
  Ref ref;
  List<int> myNums = List.empty();

  generateRandomNumbers() async {
    List<WideNumbers> dataList = ref.read(dataToDisplayProvider);
    List<double> regionsKoef = ref.read(regions);
    bool allowRepeat = ref.read(allowRepeatNumbers);
    bool allowRegions = ref.read(generateByRegions);
    List<int> generalRegionQuant = ref.read(generalRegionQuantity);
    List<int> additionalRegionQuant = ref.read(additionalRegionQuantity);

    if (dataList[0].generalNumQuantity!.length != 0) {
      List<int> dataGeneral =
          //dataList[0].generalNumQuantity!.map((e) => e.toDouble()).toList();
          dataList[0].generalNumQuantity!;
      List<int> dataAdditional =
          //dataList[0].additionalNumQuantity!.map((e) => e.toDouble()).toList();
          dataList[0].additionalNumQuantity!;
      List<List<int>> filteredGeneral;
      List<List<int>> filteredAdditional;

      if (allowRegions) {
        // Regions allowed
        filteredGeneral =
            filterByRegions(dataGeneral, getRegions(dataGeneral, regionsKoef));
        filteredAdditional = filterByRegions(
            dataAdditional, getRegions(dataAdditional, regionsKoef));
      } else {
        filteredGeneral = [
          [for (var i = 0; i < dataList[0].generalNumQuantity!.length; i++) i]
        ];
        filteredAdditional = [
          [
            for (var i = 0; i < dataList[0].additionalNumQuantity!.length; i++)
              i
          ]
        ];
      }

      List<int> general = [], additional = [];

      // if in Setting alllowed repeated numbers
      if (allowRepeat) {
        general =
            randomize(filteredGeneral, generalRegionQuant, 5, allowRegions);
        additional = randomize(
            filteredAdditional, additionalRegionQuant, 2, allowRegions);
      } else {
        while (true) {
          general =
              randomize(filteredGeneral, generalRegionQuant, 5, allowRegions)
                ..sort();
          additional = randomize(
              filteredAdditional, additionalRegionQuant, 2, allowRegions)
            ..sort();

          final existsInDB =
              await checkIfExistInDB([...general, ...additional]);
          if (existsInDB == 0) {
            break;
          }
        }
      }
      myNums = [...general, ...additional];
      ref.read(myNumsProvider.notifier).state = myNums;
      return myNums;
    }
  }
}

final myRandomNumbersProvider =
    StateNotifierProvider<RandomNumGenerator, List<int>>(
        (ref) => RandomNumGenerator(ref));

final myNumsProvider = StateProvider<List<int>>((ref) => [0, 0, 0, 0, 0, 0, 0]);
