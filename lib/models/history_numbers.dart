class HistoryNumbers {
  HistoryNumbers({required this.dataMap});

  Map<String, Object?>? dataMap;

  String? datePlayed;
  List<String>? generalNumHistory;
  List<String>? addNumHistory;

  HistoryNumbers.fromMap(Map<String, Object?> dataMap) {
    var list = dataMap.values.toList();

    String date = (list[0] ?? 'null').toString();
    List<String> generalNumbers =
        list.getRange(1, 6).map((e) => e != null ? e.toString() : '0').toList();
    List<String> additionalNumbers =
        list.getRange(6, 8).map((e) => e != null ? e.toString() : '0').toList();

    this.datePlayed = date;
    this.generalNumHistory = generalNumbers;
    this.addNumHistory = additionalNumbers;
  }

  HistoryNumbers.empty({
    this.datePlayed = '',
    this.generalNumHistory = const ['0', '0', '0', '0', '0'],
    this.addNumHistory = const ['0', '0'],
  });

  HistoryNumbers.setUpAll(String date, List<String> numGen, List<String> numAdd){
    this.datePlayed = date;
    this.generalNumHistory = numGen;
    this.addNumHistory = numAdd;
  }
}
