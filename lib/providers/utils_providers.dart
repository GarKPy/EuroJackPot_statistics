import 'package:eurojackpot/models/history_numbers.dart';
import 'package:eurojackpot/models/wide_numbers.dart';
import 'package:eurojackpot/providers/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IsLandscape extends StateNotifier<bool> {
  IsLandscape() : super(false);

  bool isLandscape() {
    double screenWidth = WidgetsBinding
        .instance.platformDispatcher.views.first.physicalSize.width;
    double screenHeight = WidgetsBinding
        .instance.platformDispatcher.views.first.physicalSize.height;
    bool isLandscape = screenHeight > screenWidth ? false : true;
    state = isLandscape;
    return isLandscape;
  }
}

class BarTouched extends StateNotifier<int> {
  BarTouched(this.ref) : super(-1);
  Ref ref;

  setMyNumbers(int index) {
    state = index;
    //print('BarTouchedProvider ${state}');
    // if (ref.read(myNumberSelectedProvider.notifier).state != -1) {
    //   print(ref.watch(myRandomNumbersProvider.notifier).myNums);
    //   print(ref.read(myNumberSelectedProvider.notifier).state);
    // }
  }
}

reload(WidgetRef ref) {
  ref.read(playedNumbersProvider.notifier).loadNumbers();
  ref.read(historyNumProvider.notifier).loadNumbers(rowsNum: 5);
  ref.read(wideDataProvider.notifier).loadNumbers();
}

final isLandscapeProvider =
    StateNotifierProvider<IsLandscape, bool>((ref) => IsLandscape());

final isGeneralProvider = StateProvider<bool>((ref) => true);

final dataToDisplayProvider =
    StateProvider<List<WideNumbers>>((ref) => [WideNumbers.empty()]);
final historyNumbersProvider = StateProvider<List<HistoryNumbers>>((ref) => []);
final wideTotalDataProvider =
    StateProvider<List<List<int>>>((ref) => List.empty());

final getRandomProvider = StateProvider<bool>((ref) => true);
final pageTitleProvider = StateProvider((ref) => 'General');

final myNumberSelectedProvider = StateProvider<int>((ref) => -1);
final barTouchedProvider =
    StateNotifierProvider<BarTouched, int>((ref) => BarTouched(ref));
final activePageProvider = StateProvider((ref) => 'general');
final reloadMyNumbers = StateProvider((ref) => 0);

//==============================================================
//========= Settings page ======================================
//==============================================================

final allowRepeatNumbers = StateProvider<bool>((ref) => false);
final generateByRegions = StateProvider<bool>((ref) => true);
final regions = StateProvider<List<double>>((ref) => [0.75, 0.5, 0.25]);
final generalRegionQuantity = StateProvider<List<int>>((ref) => [2, 1, 1, 1]);
final additionalRegionQuantity =
    StateProvider<List<int>>((ref) => [0, 0, 1, 1]);

//==============================================================

final pageIndexProvider = StateProvider((ref) => 0);

// https://github.com/rrousselGit/riverpod/discussions/2500
final bottomTabNotifier = StateNotifierProvider<BottomTabNotifier, double>(
  (ref) => BottomTabNotifier(),
);

class BottomTabNotifier extends StateNotifier<double> {
  BottomTabNotifier() : super(0.0) {
    pageController.addListener(() {
      state = pageController.page ?? 0.0;
    });
  }

  late final pageController = PageController(initialPage: state.round());
}
