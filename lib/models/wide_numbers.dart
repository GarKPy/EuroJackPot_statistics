import 'dart:math';

class WideNumbers {
  WideNumbers({
    required this.datePlayed,
    required this.generalNumQuantity,
    required this.additionalNumQuantity,
  });

  String? datePlayed;
  List<int>? generalNumQuantity;
  List<int>? additionalNumQuantity;

  List<int> additionalNumbersScaled() => _additionalNumbersScaled;
  List<int> generalNumbersScaled() => _generalNumbersScaled;
  int maxAdditional() => _maxAdditional;
  int maxGeneral() => _maxGeneral;
  int minAdditional() => _minAdditional;
  int minGeneral() => _minGeneral;

  double midAdditiona() =>
      (maxAdditional() - minAdditional()) * 0.5 + minAdditional();
  List<double> simpleRegionsAdditional() => [
        (maxAdditional() - minAdditional()) * 0.75 + minAdditional(),
        (maxAdditional() - minAdditional()) * 0.5 + minAdditional(),
        (maxAdditional() - minAdditional()) * 0.25 + minAdditional()
      ];

  double midGeneral() => (maxGeneral() - minGeneral()) * 0.5 + minGeneral();
  List<double> simpleRegionsGeneral() => [
        (maxGeneral() - minGeneral()) * 0.75 + minGeneral(),
        (maxGeneral() - minGeneral()) * 0.5 + minGeneral(),
        (maxGeneral() - minGeneral()) * 0.25 + minGeneral()
      ];

  List<int> get _additionalNumbersScaled {
    int minAdditional = additionalNumQuantity!.reduce(min);
    List<int> additionalNambersScaled = [
      for (var item in additionalNumQuantity!) item - minAdditional
    ];
    return additionalNambersScaled;
  }

  List<int> get _generalNumbersScaled {
    int minGeneral = generalNumQuantity!.reduce(min);
    List<int> generalNumbersScaled = [
      for (var item in generalNumQuantity!) item - minGeneral
    ];
    return generalNumbersScaled;
  }

  int get _maxAdditional {
    return additionalNumQuantity!.reduce(max);
  }

  int get _maxGeneral {
    return generalNumQuantity!.reduce(max);
  }

  int get _minAdditional {
    return additionalNumQuantity!.reduce(min);
  }

  int get _minGeneral {
    return generalNumQuantity!.reduce(min);
  }

  WideNumbers.fromMap(Map<String, Object?> dataMap) {
    var list = dataMap.values.toList();

    String date = (list[0] ?? 'null').toString();
    List<int> generalNumbers =
        list.getRange(1, 51).map((e) => e != null ? e as int : 0).toList();
    List<int> additionalNumbers =
        list.getRange(51, 63).map((e) => e != null ? e as int : 0).toList();

    this.datePlayed = date;
    this.generalNumQuantity = generalNumbers;
    this.additionalNumQuantity = additionalNumbers;
  }


  WideNumbers.empty(
      {this.datePlayed = '',
      this.generalNumQuantity = const [],
      this.additionalNumQuantity = const []});

  WideNumbers.dummy(
      {this.datePlayed = '2024-05-05',
      this.generalNumQuantity = const [0, 0, 0, 0, 0, 0],
      this.additionalNumQuantity = const [0, 0, 0]});
}
