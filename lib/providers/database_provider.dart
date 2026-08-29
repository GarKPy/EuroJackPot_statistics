import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eurojackpot/models/history_numbers.dart';
import 'package:eurojackpot/models/wide_numbers.dart';
import 'package:eurojackpot/providers/dates_provider.dart';
import 'package:eurojackpot/providers/my_random_numbers_provider.dart';
import 'package:eurojackpot/providers/utils_providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

updateDBList(
    List<HistoryNumbers> historyList, List<WideNumbers> lastWideNumbers) {
  WideNumbers lastNumbers = lastWideNumbers[0];
  //print('updateDBList entered');
  // Forming history table rows
  List<List<String>> historyTable = [];
  for (var i = historyList.length - 1; i >= 0; i--) {
    List<String> rowHist = [
      historyList[i].datePlayed!,
      ...historyList[i].generalNumHistory!,
      ...historyList[i].addNumHistory!
    ].toList();
    historyTable.add(rowHist);
  }

  // Forming wide_history table rows
  List<List<String>> wideHistoryTable = [];
  for (var i = historyList.length - 1; i >= 0; i--) {
    List<String> rowWideHist = List.filled(63, '0');

    // Converting general numbers to wide numbers (0, 1)
    for (var j = 0; j < historyList[i].generalNumHistory!.length; j++) {
      // get number from list and convert it to int to use as the index
      int x = int.parse(historyList[i].generalNumHistory![j]);
      rowWideHist[x] = '1';
    }
// Converting additional numbers to wide numbers (0, 1)
    for (var j = 0; j < historyList[i].addNumHistory!.length; j++) {
      // get number from list and convert it to int to use as the index
      int x = int.parse(historyList[i].addNumHistory![j]);
      rowWideHist[x + 50] = '1';
    }
    // Adding date as first element
    rowWideHist[0] = historyList[i].datePlayed!;
    wideHistoryTable.add(rowWideHist);
  }

  // Forming sum_history table rows
  List<List<String>> sumHistoryTable = [];
  List<String> oldRow = [
    lastNumbers.datePlayed!,
    ...lastNumbers.generalNumQuantity!.map((e) => e.toString()),
    ...lastNumbers.additionalNumQuantity!.map((e) => e.toString()),
  ];

  for (var i = 0; i < wideHistoryTable.length; i++) {
    List<String> newRow = List.filled(63, '0');
    for (var j = 0; j < wideHistoryTable[i].length; j++) {
      if (j == 0) {
        newRow[0] = wideHistoryTable[i][j];
      } else {
        newRow[j] = (int.parse(wideHistoryTable[i][j]) + int.parse(oldRow[j]))
            .toString();
      }
    }
    oldRow = newRow;
    sumHistoryTable.add(newRow);
  }

  //print('Table Lists Creation Comlete');

  return [historyTable, sumHistoryTable, wideHistoryTable];
}

Future<Database> _getDatabase() async {
  // Construct a file path to copy database to
  Directory documentsDirectory =
      await syspaths.getApplicationDocumentsDirectory();
  var DBpath = path.join(documentsDirectory.path, "euro_jackpot.db");
  // Only copy if the database doesn't exist
  if (FileSystemEntity.typeSync(DBpath) == FileSystemEntityType.notFound) {
    //print('database doesnt exist');
    // Load database from asset and copy
    ByteData data =
        await rootBundle.load(path.join('assets/database', 'euro_jackpot.db'));
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // Save copied asset to documents
    await File(DBpath).writeAsBytes(bytes);
    //print('database copied');
    Directory appDocDir = await syspaths.getApplicationDocumentsDirectory();
    //print(appDocDir);
    //String databasePath = path.join(appDocDir.path, 'euro_jackpot.db');
    //var initialized = true;
  }
  //print('database exist');
  var db = await sql.openDatabase(DBpath);

  return db;
}

class PlayedNumbersNotifier extends StateNotifier<List<WideNumbers>> {
  PlayedNumbersNotifier(this.ref) : super([WideNumbers.empty()]);
  final Ref ref;

  Future<List<WideNumbers>> loadNumbers() async {
    //print('--- loadNumbers PlayedNumbersNotifier start');
    final db = await _getDatabase();
    final dataDB = await db
        .rawQuery('SELECT * FROM sum_history ORDER BY date DESC LIMIT 1');

    List<WideNumbers> playedList = [];

    playedList.add(WideNumbers.fromMap(dataDB[0]));

    ref.read(dataToDisplayProvider.notifier).state = playedList;

    ref.read(myRandomNumbersProvider.notifier).generateRandomNumbers();
    return playedList;
  }
}

List<List<int>> transpose(List<List<int>> matrix) {
  if (matrix.isEmpty || matrix[0].isEmpty) return [];

  int rowCount = matrix.length;
  int colCount = matrix[0].length;

  List<List<int>> transposedMatrix =
      List.generate(colCount, (_) => List.filled(rowCount, matrix[0][0]));

  for (int i = 0; i < rowCount; i++) {
    for (int j = 0; j < colCount; j++) {
      transposedMatrix[j][i] = matrix[i][j];
    }
  }

  return transposedMatrix;
}

class WideDataNotifier extends StateNotifier<List<List<int>>> {
  WideDataNotifier(this.ref) : super([]);
  final Ref ref;

  Future<List<List<int>>> loadNumbers() async {
    //print('--- loadNumbers WideDataNotifier start');
    final db = await _getDatabase();
    final dataDB = await db.rawQuery('SELECT * FROM wide_history');

    List<List> wideData = [];
    for (int i = 0; i < dataDB.length; i++) {
      wideData.add(dataDB[i].values.skip(1).toList());
    }

    List<List<int>> intData = [];
    for (int i = 0; i < wideData.length; i++) {
      intData.add(wideData[i].map((e) => e != null ? e as int : 0).toList());
    }

    List<List<int>> transposedData = transpose(intData);

    ref.read(wideTotalDataProvider.notifier).state = transposedData;

    return transposedData;
  }
}

class HistoryNumNotifier extends StateNotifier<List<HistoryNumbers>> {
  HistoryNumNotifier(this.ref) : super([HistoryNumbers.empty()]);
  final Ref ref;

  Future<List<HistoryNumbers>> loadNumbers({rowsNum = 5}) async {
    final db = await _getDatabase();

    final recentNumbers = await db
        .rawQuery('SELECT * FROM history ORDER BY date DESC LIMIT ${rowsNum}');

    List<HistoryNumbers> historyNum = [];
    for (var i = 0; i < recentNumbers.length; i++) {
      historyNum.add(HistoryNumbers.fromMap(recentNumbers[i]));
    }

    String? latestDate = historyNum[0].datePlayed;
    if (latestDate != null) {
      ref.read(latestDateProvider.notifier).state = latestDate;
    } else {
      ref.read(latestDateProvider.notifier).state = 'null';
    }

    ref.read(historyNumbersProvider.notifier).state = historyNum;

    return historyNum;
  }
}

Future updateDB(WidgetRef ref, tableData) async {
  final db = await _getDatabase();
  List<String> tableName = ['history', 'sum_history', 'wide_history'];

  String latestDateInDB = '';
  if (tableData[0].isNotEmpty) {
    for (var i = 0; i < tableData.length; i++) {
      String query =
          'INSERT INTO ${tableName[i]} VALUES(${List.filled(tableData[i][0].length, '?').join(',')})';
      for (var j = 0; j < tableData[i].length; j++) {
        await db.rawInsert(query, tableData[i][j]);
        latestDateInDB = tableData[i][j][0];
      }
    }
  }
  //reading DB and updating latest date
  final recentNumbers =
      await db.rawQuery('SELECT * FROM history ORDER BY date DESC LIMIT 1');
  ref.read(latestDateProvider.notifier).state =
      recentNumbers[0]['date'].toString();

  // print('Database Updated');

  return latestDateInDB;
}

Future readDB(String tableName, int rowsNum) async {
  final db = await _getDatabase();

  final dataDB = await db.rawQuery(
      'SELECT * FROM ${tableName} ORDER BY date DESC LIMIT ${rowsNum}');

  //print('----- readDB');
  // for (var i = 0; i < dataDB.length; i++) {
  //   print('${dataDB[i].values}');
  // }
}

Future checkIfExistInDB(List<int> myNums) async {
  final db = await _getDatabase();
  final dataDB = await db.rawQuery(
      'SELECT * FROM history WHERE (num_1=${myNums[0]} and num_2=${myNums[1]} and num_3=${myNums[2]} and num_4=${myNums[3]} and num_5=${myNums[4]} and num_6=${myNums[5]} and num_7=${myNums[6]})');

  return dataDB.length;
}

Future removeRowDB(WidgetRef ref) async {
  final db = await _getDatabase();

  var dataDB;
  dataDB = await db.rawQuery(
      'DELETE FROM history WHERE ROWID = (SELECT MAX(ROWID) FROM history)');
  dataDB = await db.rawQuery(
      'DELETE FROM sum_history WHERE ROWID = (SELECT MAX(ROWID) FROM sum_history)');
  dataDB = await db.rawQuery(
      'DELETE FROM wide_history WHERE ROWID = (SELECT MAX(ROWID) FROM wide_history)');

  //reading DB and updating latest date
  final recentNumbers =
      await db.rawQuery('SELECT * FROM history ORDER BY date DESC LIMIT 1');
  ref.read(latestDateProvider.notifier).state =
      recentNumbers[0]['date'].toString();

  //print('removed');
}

final playedNumbersProvider =
    StateNotifierProvider<PlayedNumbersNotifier, List<WideNumbers>>(
  (ref) => PlayedNumbersNotifier(ref),
);

final historyNumProvider =
    StateNotifierProvider<HistoryNumNotifier, List<HistoryNumbers>>(
  (ref) => HistoryNumNotifier(ref),
);

final historyTableColumnsNamesProvider = StateProvider<List<String>>((ref) {
  List<String> historyColumnsNames = List.filled(8, '0');
  return historyColumnsNames;
});

final wideColumnsNamesProvider = StateProvider((ref) {
  List<String> wideColumnsNames = List.filled(63, '0');
  return wideColumnsNames;
});

final wideDataProvider = StateNotifierProvider(
  (ref) => WideDataNotifier(ref),
);

class UserPlayedNumbersNotifier extends StateNotifier<List<List<int>>> {
  UserPlayedNumbersNotifier(this.ref)
      : super([
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
        ]);
  final Ref ref;

  Future<List<List<int>>> loadNumbers() async {
    final db = await _getDatabase();
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_played_numbers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        row_index INTEGER,
        num_1 INTEGER,
        num_2 INTEGER,
        num_3 INTEGER,
        num_4 INTEGER,
        num_5 INTEGER,
        num_6 INTEGER,
        num_7 INTEGER
      )
    ''');

    final dataDB = await db.rawQuery(
        'SELECT * FROM user_played_numbers ORDER BY row_index ASC');
    if (dataDB.isEmpty) {
      List<List<int>> defaultRows = [
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
      ];
      state = defaultRows;
      return defaultRows;
    }

    List<List<int>> loaded = [];
    for (var row in dataDB) {
      loaded.add([
        (row['num_1'] as int?) ?? 0,
        (row['num_2'] as int?) ?? 0,
        (row['num_3'] as int?) ?? 0,
        (row['num_4'] as int?) ?? 0,
        (row['num_5'] as int?) ?? 0,
        (row['num_6'] as int?) ?? 0,
        (row['num_7'] as int?) ?? 0,
      ]);
    }

    while (loaded.length < 3) {
      loaded.add([0, 0, 0, 0, 0, 0, 0]);
    }
    if (loaded.length > 5) {
      loaded = loaded.sublist(0, 5);
    }

    state = loaded;
    return loaded;
  }

  Future<void> saveNumbers(List<List<int>> rows) async {
    final db = await _getDatabase();
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_played_numbers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        row_index INTEGER,
        num_1 INTEGER,
        num_2 INTEGER,
        num_3 INTEGER,
        num_4 INTEGER,
        num_5 INTEGER,
        num_6 INTEGER,
        num_7 INTEGER
      )
    ''');

    await db.transaction((txn) async {
      await txn.rawDelete('DELETE FROM user_played_numbers');
      for (int i = 0; i < rows.length; i++) {
        final r = rows[i];
        await txn.rawInsert(
          'INSERT INTO user_played_numbers (row_index, num_1, num_2, num_3, num_4, num_5, num_6, num_7) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
          [i, r[0], r[1], r[2], r[3], r[4], r[5], r[6]],
        );
      }
    });
    state = List<List<int>>.from(rows.map((row) => List<int>.from(row)));
  }

  void updateRow(int index, List<int> newRow) {
    if (index >= 0 && index < state.length) {
      final updated = List<List<int>>.from(state.map((r) => List<int>.from(r)));
      updated[index] = List<int>.from(newRow);
      state = updated;
    }
  }

  void addRow() {
    if (state.length < 5) {
      state = [...state, [0, 0, 0, 0, 0, 0, 0]];
    }
  }

  void removeRow(int index) {
    if (state.length > 3 && index >= 0 && index < state.length) {
      final updated = List<List<int>>.from(state.map((r) => List<int>.from(r)));
      updated.removeAt(index);
      state = updated;
    }
  }
}

final userPlayedNumbersProvider =
    StateNotifierProvider<UserPlayedNumbersNotifier, List<List<int>>>(
  (ref) => UserPlayedNumbersNotifier(ref),
);

Future<void> saveAppSetting(String key, String value) async {
  final db = await _getDatabase();
  await db.execute('''
    CREATE TABLE IF NOT EXISTS app_settings (
      key TEXT PRIMARY KEY,
      value TEXT
    )
  ''');
  await db.rawInsert(
    'INSERT OR REPLACE INTO app_settings (key, value) VALUES (?, ?)',
    [key, value],
  );
}

Future<String?> getAppSetting(String key) async {
  final db = await _getDatabase();
  await db.execute('''
    CREATE TABLE IF NOT EXISTS app_settings (
      key TEXT PRIMARY KEY,
      value TEXT
    )
  ''');
  final result = await db.query(
    'app_settings',
    where: 'key = ?',
    whereArgs: [key],
    limit: 1,
  );
  if (result.isNotEmpty) {
    return result.first['value'] as String?;
  }
  return null;
}

Future<void> loadAllSettings(dynamic ref) async {
  final db = await _getDatabase();
  await db.execute('''
    CREATE TABLE IF NOT EXISTS app_settings (
      key TEXT PRIMARY KEY,
      value TEXT
    )
  ''');
  final result = await db.query('app_settings');
  final map = {for (var r in result) r['key'] as String: r['value'] as String};

  if (map.containsKey('generalRegions')) {
    try {
      List<dynamic> list = jsonDecode(map['generalRegions']!);
      ref.read(generalRegions.notifier).state =
          list.map((e) => (e as num).toDouble()).toList();
    } catch (_) {}
  } else if (map.containsKey('regions')) {
    try {
      List<dynamic> list = jsonDecode(map['regions']!);
      ref.read(generalRegions.notifier).state =
          list.map((e) => (e as num).toDouble()).toList();
    } catch (_) {}
  }
  if (map.containsKey('additionalRegions')) {
    try {
      List<dynamic> list = jsonDecode(map['additionalRegions']!);
      ref.read(additionalRegions.notifier).state =
          list.map((e) => (e as num).toDouble()).toList();
    } catch (_) {}
  } else if (map.containsKey('regions')) {
    try {
      List<dynamic> list = jsonDecode(map['regions']!);
      ref.read(additionalRegions.notifier).state =
          list.map((e) => (e as num).toDouble()).toList();
    } catch (_) {}
  }
  if (map.containsKey('generalRegionQuantity')) {
    try {
      List<dynamic> list = jsonDecode(map['generalRegionQuantity']!);
      ref.read(generalRegionQuantity.notifier).state =
          list.map((e) => (e as num).toInt()).toList();
    } catch (_) {}
  }
  if (map.containsKey('additionalRegionQuantity')) {
    try {
      List<dynamic> list = jsonDecode(map['additionalRegionQuantity']!);
      ref.read(additionalRegionQuantity.notifier).state =
          list.map((e) => (e as num).toInt()).toList();
    } catch (_) {}
  }
  if (map.containsKey('allowRepeatNumbers')) {
    ref.read(allowRepeatNumbers.notifier).state =
        map['allowRepeatNumbers'] == 'true';
  }
  if (map.containsKey('generateByRegions')) {
    ref.read(generateByRegions.notifier).state =
        map['generateByRegions'] == 'true';
  }
  if (map.containsKey('excludePlayedNumbers')) {
    ref.read(excludePlayedNumbers.notifier).state =
        map['excludePlayedNumbers'] == 'true';
  }
}


