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
    int takeQuantity, bool randByRegion) {
  List<int> generatedResult = [];
  if (!randByRegion) {
    List<int> tempData = [for (var list in dataList) ...list];
    tempData.shuffle();
    generatedResult = tempData.take(takeQuantity).toList();
  } else {
    for (var i = 0; i < dataList.length; i++) {
      if (i < quantityList.length && quantityList[i] > 0) {
        var shuffled = List<int>.from(dataList[i])..shuffle();
        generatedResult.addAll(shuffled.take(quantityList[i]));
      }
    }
    // If not enough numbers selected from regions, supplement from remaining pool
    if (generatedResult.length < takeQuantity) {
      Set<int> alreadySelected = generatedResult.toSet();
      List<int> remainingPool = [
        for (var list in dataList)
          for (var item in list)
            if (!alreadySelected.contains(item)) item
      ]..shuffle();

      int needed = takeQuantity - generatedResult.length;
      generatedResult.addAll(remainingPool.take(needed));
    }
  }
  generatedResult = generatedResult.map((e) => e + 1).toList();
  return generatedResult;
}

List<List<int>> filterExcluded(
  List<List<int>> buckets,
  Set<int> excludedIndices,
  int totalNeeded,
  int maxPossibleCount,
) {
  List<List<int>> cleaned = [];
  for (var bucket in buckets) {
    cleaned.add(bucket.where((idx) => !excludedIndices.contains(idx)).toList());
  }

  int totalAvailable = cleaned.fold(0, (sum, b) => sum + b.length);
  if (totalAvailable >= totalNeeded) {
    return cleaned;
  }

  // If exclusions leave fewer than totalNeeded, backfill from excluded
  List<int> fallbackIndices = [
    for (int i = 0; i < maxPossibleCount; i++)
      if (excludedIndices.contains(i)) i
  ]..shuffle();

  int neededExtra = totalNeeded - totalAvailable;
  if (cleaned.isNotEmpty) {
    cleaned[0] = [...cleaned[0], ...fallbackIndices.take(neededExtra)];
  } else {
    cleaned.add(fallbackIndices.take(neededExtra).toList());
  }
  return cleaned;
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
    List<double> generalRegionsKoef = ref.read(generalRegions);
    List<double> additionalRegionsKoef = ref.read(additionalRegions);
    bool allowRepeat = ref.read(allowRepeatNumbers);
    bool allowRegions = ref.read(generateByRegions);
    bool excludePlayed = ref.read(excludePlayedNumbers);
    List<List<int>> userPlayedRows = ref.read(userPlayedNumbersProvider);
    List<int> generalRegionQuant = ref.read(generalRegionQuantity);
    List<int> additionalRegionQuant = ref.read(additionalRegionQuantity);

    if (dataList.isNotEmpty &&
        dataList[0].generalNumQuantity != null &&
        dataList[0].generalNumQuantity!.isNotEmpty) {
      List<int> dataGeneral = dataList[0].generalNumQuantity!;
      List<int> dataAdditional = dataList[0].additionalNumQuantity!;
      List<List<int>> filteredGeneral;
      List<List<int>> filteredAdditional;

      if (allowRegions) {
        // Regions allowed
        filteredGeneral = filterByRegions(
            dataGeneral, getRegions(dataGeneral, generalRegionsKoef));
        filteredAdditional = filterByRegions(
            dataAdditional, getRegions(dataAdditional, additionalRegionsKoef));
      } else {
        filteredGeneral = [
          [for (var i = 0; i < dataGeneral.length; i++) i]
        ];
        filteredAdditional = [
          [for (var i = 0; i < dataAdditional.length; i++) i]
        ];
      }

      // Exclude played numbers if enabled
      if (excludePlayed) {
        Set<int> excludedGen = {};
        Set<int> excludedAdd = {};
        for (var row in userPlayedRows) {
          for (int i = 0; i < 5 && i < row.length; i++) {
            if (row[i] >= 1 && row[i] <= 50) {
              excludedGen.add(row[i] - 1);
            }
          }
          for (int i = 5; i < 7 && i < row.length; i++) {
            if (row[i] >= 1 && row[i] <= 12) {
              excludedAdd.add(row[i] - 1);
            }
          }
        }
        filteredGeneral =
            filterExcluded(filteredGeneral, excludedGen, 5, dataGeneral.length);
        filteredAdditional = filterExcluded(
            filteredAdditional, excludedAdd, 2, dataAdditional.length);
      }

      List<int> general = [], additional = [];

      // if in Setting allowed repeated numbers
      if (allowRepeat) {
        general =
            randomize(filteredGeneral, generalRegionQuant, 5, allowRegions)
              ..sort();
        additional = randomize(
            filteredAdditional, additionalRegionQuant, 2, allowRegions)
          ..sort();
      } else {
        int attempts = 0;
        while (attempts < 100) {
          attempts++;
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
