import "dart:convert";
import "package:eurojackpot/models/wide_numbers.dart";
import "package:eurojackpot/providers/database_provider.dart";
import "package:eurojackpot/providers/dates_provider.dart";
import "package:eurojackpot/providers/utils_providers.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:http/http.dart" as http;

import "package:eurojackpot/models/history_numbers.dart";

void dataUpdater(BuildContext context, WidgetRef ref) async {
  List<String> datesOfYear = [];

  String year = ref.read(yearNowProvider.notifier).state;
  datesOfYear =
      await ref.read(datesOfYearProvider.notifier).getDatesFromYear(year);
  //print('Update pressed');

  String latestDate = ref.read(latestDateProvider);
  List<String> filteredDates = filterDates(datesOfYear, latestDate);

  if (filteredDates.length > 0) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Uppdating Data!'),
      ));
    }
    List<HistoryNumbers> histNumUpdated = await ref
        .read(datesListToHistoryNumProvider.notifier)
        .getHistoryNumbersFromDates(filteredDates);
    List<WideNumbers> numbersQuantyti = await ref.read(dataToDisplayProvider);

    List tablesDataToUpdate = updateDBList(histNumUpdated, numbersQuantyti);
    ref.read(latestDateProvider.notifier).state =
        await updateDB(ref, tablesDataToUpdate);
  } else {
    //print('DataBase is upp to date!');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('DataBase is upp to date!'),
      ));
    }
  }
  reload(ref);
}

// Filtering out dates not in DB
List<String> filterDates(List<String> datesOfYear, String latestDate) {
  DateTime latestDateParsed = DateTime.parse(latestDate);
  datesOfYear
      .removeWhere((e) => DateTime.parse(e).compareTo(latestDateParsed) <= 0);

  return datesOfYear;
}

class DatesOfYearNotifier extends StateNotifier<List<String>> {
  DatesOfYearNotifier(this.ref) : super([]);
  final Ref ref;

  Future<List<String>> getDatesFromYear(String dates) async {
    //print('dates $dates');
    String uri =
        "https://www.eurojackpot.com/wlinfo/WL_InfoService?client=jsn&gruppe=ZahlenUndQuoten&ewGewsum=ja&historie=ja&spielart=EJ&adg=ja&lang=en&jahre=${dates}";

    http.Response response = await http.get(Uri.parse(uri));
    List<String> datesList;

    if (response.statusCode == 200) {
      //String data = response.body;
      var json = jsonDecode(response.body);
      datesList = List<String>.from(json['history']['tage']);
      //print('----- DatesOfYearNotifier');
      //print(datesList);
      //getHistoryNumbersFromDates(datesList);
      //return datesList;
    } else {
      throw Exception('Failed to load dates ${response.statusCode.toString()}');
    }
    return datesList;
  }
}

class DatesListToHistoryNum extends StateNotifier {
  DatesListToHistoryNum(this.ref) : super([]);
  final Ref ref;

  Future getHistoryNumbersFromDates(List<String> dates) async {
    HistoryNumbers histNum = HistoryNumbers.empty();
    List<HistoryNumbers> histList = [];
    //print("getHistoryNumbersFromDates");
    // print('dates.length ${dates.length}');
    // print(dates);
    String uri =
        "https://www.eurojackpot.com/wlinfo/WL_InfoService?client=jsn&gruppe=ZahlenUndQuoten&ewGewsum=ja&historie=ja&spielart=EJ&adg=ja&lang=en&datum=";

    for (var i = 0; i < dates.length; i++) {
      http.Response response = await http.get(Uri.parse(uri + dates[i]));

      if (response.statusCode == 200) {
        //String data = response.body;
        var json = jsonDecode(response.body);
        List<String> numListGen = List<String>.from(
            json['zahlen']['hauptlotterie']['ziehungen'][0]['zahlenSortiert']);
        List<String> numListAdd = List<String>.from(
            json['zahlen']['hauptlotterie']['ziehungen'][1]['zahlenSortiert']);
        histNum = HistoryNumbers.setUpAll(dates[i], numListGen, numListAdd);

        histList.add(histNum);
      } else {
        throw Exception(
            'Failed to load dates ${response.statusCode.toString()}');
      }
    }
    return histList;
  }
}

final datesOfYearProvider =
    StateNotifierProvider<DatesOfYearNotifier, List<String>>(
        (ref) => DatesOfYearNotifier(ref));

final datesListToHistoryNumProvider =
    StateNotifierProvider((ref) => DatesListToHistoryNum(ref));
