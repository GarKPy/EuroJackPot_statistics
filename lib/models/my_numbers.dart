import 'package:eurojackpot/models/wide_numbers.dart';

class MyNumbers {
  MyNumbers({
    required this.dataList,
    this.general,
    this.additional,
  });

  final WideNumbers dataList;
  List<int>? general;
  List<int>? additional;

  randomFromRegions() => _randomizeByRegions;

  get _randomizeByRegions {
    // WideNumbers wideNum = WideNumbers(
    //   datePlayed: '2024-06-21',
    //   generalNumQuantity: [
    //     21, 22, 23, 24, 25, 26, 27, 28, 29, 10,
    //     15 //,11,12,13,14,15,16,17,18,19,20
    //   ],
    //   additionalNumQuantity: [100, 101, 102, 103, 104, 105],
    // );

    //List<double> data =
    //    dataList.generalNumQuantity!.map((e) => e.toDouble()).toList();
    //List<int> data = wideNum.generalNumQuantity!;
    //List<double> region = dataList.simpleRegionsGeneral().reversed.toList();
    //List<double> region = wideNum.simpleRegionsGeneral().reversed.toList();

    List<List<int>> tempGeneral = filterByRegions(
      dataList.generalNumQuantity!.map((e) => e.toDouble()).toList(),
      dataList.simpleRegionsGeneral().reversed.toList(),
    );
    List<List<int>> tempAdditional = filterByRegions(
      dataList.additionalNumQuantity!.map((e) => e.toDouble()).toList(),
      dataList.simpleRegionsAdditional().reversed.toList(),
    );

    general = randomize(tempGeneral, [2, 1, 1, 1]);
    additional = randomize(tempAdditional, [0, 0, 1, 1]);
    return [...general!, ...additional!];
  }

  filterByRegions(List<double> data, List<double> region) {
    //print('Original list $data');
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

  List<int> randomize(List<List<int>> dataList, List<int> quantityList) {
    List<int> temp = [];
    for (var i = 0; i < dataList.length; i++) {
      temp = [
        ...temp,
        ...((dataList[i]..shuffle()).take(quantityList[i]).toList())
      ];
    }
    temp = temp.map((e) => e + 1).toList();
    return temp;
  }
}
