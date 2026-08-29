import 'package:eurojackpot/resources/app_colors.dart';
import 'package:eurojackpot/resources/app_dimens.dart';
import 'package:eurojackpot/models/history_numbers.dart';
import 'package:eurojackpot/models/wide_numbers.dart';
import 'package:eurojackpot/providers/data_update.dart';
import 'package:eurojackpot/providers/database_provider.dart';
import 'package:eurojackpot/providers/dates_provider.dart';
import 'package:eurojackpot/providers/my_random_numbers_provider.dart';
import 'package:eurojackpot/providers/utils_providers.dart';
import 'package:eurojackpot/screens/numbers_stat.dart';
import 'package:eurojackpot/screens/settings_screen.dart';
import 'package:eurojackpot/screens/statistic_screen.dart';
import 'package:eurojackpot/utils/app_utils.dart';
import 'package:eurojackpot/widgets/chart_annotation.dart';
import 'package:eurojackpot/widgets/chart_holder.dart';
import 'package:eurojackpot/widgets/main_drawer.dart';
import 'package:eurojackpot/widgets/my_numbers_holder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  var initialized = false;
  late Database db;
  List<Map<String, Object?>> dataDB = List.empty();
  int lengthOfList = 0;
  int lastElement = 0;
  bool dbOk = false;

  //late Future<List<WideNumbers>> playedList;
  //late Future<List<HistoryNumbers>> historyNumList;
  late Future<String> data;
  late Future<List<String>> datesOfYear;
  late Future<List<List<int>>> totalWideTada;

  List<String> dateList = [];

  late double appBarHeight;
  bool isLandscape = false;

  final Key _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    dataUpdater(context, ref);
    reload(ref);

    //ref.read(myRandomNumbersProvider.notifier).generateRandomNumbersByRegions();
  }

// MainDrawer selector
  void _setScreen(String identifier) async {
    Navigator.of(context).pop();
    List<String> datesOfYear = [];
    //print('identifier ${identifier}');
    if (identifier == 'update') {
      //print('inside update');
      String year = ref.read(yearNowProvider.notifier).state;
      datesOfYear =
          await ref.read(datesOfYearProvider.notifier).getDatesFromYear(year);
      //print('Update pressed');

      String latestDate = ref.read(latestDateProvider.notifier).state;
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
        List<WideNumbers> numbersQuantyti =
            await ref.read(dataToDisplayProvider);
        List
            tablesDataToUpdate; // = updateDBList(histNumUpdated, numbersQuantyti);
        // if (histNumUpdated[0].generalNumHistory!.isNotEmpty) {
        tablesDataToUpdate = updateDBList(histNumUpdated, numbersQuantyti);
        ref.read(latestDateProvider.notifier).state = await updateDB(
          ref,
          tablesDataToUpdate,
        );
        reload(ref);
      } else {
        //print('DataBase is upp to date!');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('DataBase is upp to date!'),
          ));
        }
      }
    } else if (identifier == 'read') {
      readDB('history', 15);
    } else if (identifier == 'delete') {
      removeRowDB(ref);
      reload(ref);
    }
  }

// Filtering out dates not in DB
  List<String> filterDates(List<String> datesOfYear, String latestDate) {
    DateTime latestDateParsed = DateTime.parse(latestDate);
    datesOfYear
        .removeWhere((e) => DateTime.parse(e).compareTo(latestDateParsed) <= 0);

    return datesOfYear;
  }

  Future<String> fetchData() async {
    await Future.delayed(const Duration(seconds: 5));
    return 'Fetched Data';
  }

  void refreshData() {
    //print('refresh Entered');
    ref.read(myNumberSelectedProvider.notifier).state = -1;
    setState(() {
      ref.read(myRandomNumbersProvider.notifier).generateRandomNumbers();
    });
  }

  late int currentPageIndex;

// Bottom Navigation Bars Items
  myPages(context) {
    //print('***** myPages');
    return <Widget>[
      Center(
        child: AppUtils.isLandscape(context)
            ? const Column(children: [
                SizedBox(height: AppDimens.generalPadding * 2),
                ChartHolder(general: true),
                SizedBox(height: AppDimens.generalPadding * 2),
              ])
            : const Column(children: [
                ChartAnnotation(),
                ChartHolder(general: true),
                SizedBox(height: AppDimens.generalPadding),
              ]), //Text('BottomBar Gen'),
      ),
      Center(
        child: AppUtils.isLandscape(context)
            ? const Column(children: [
                SizedBox(height: AppDimens.generalPadding * 2),
                ChartHolder(general: false),
                SizedBox(height: AppDimens.generalPadding * 2),
              ])
            : const Column(
                children: [
                  ChartAnnotation(),
                  SizedBox(height: AppDimens.generalPadding),
                  ChartHolder(general: false),
                  SizedBox(height: AppDimens.generalPadding),
                ],
              ),
      ),
      const Center(
        child: StatisticScreen(),
      ),
      const Center(
        child: NumbersStat(),
      ),
      const Center(
        child: SettingsScreen(),
      ),
    ];
  }

  Widget body() {
    //print('***** body()');
    return AppUtils.isLandscape(context)
        ? Row(
            //key: _key,
            //alignment: AlignmentDirectional.bottomEnd,
            children: [
              Flexible(
                child: PageView(
                  key: _key,
                  controller:
                      ref.read(bottomTabNotifier.notifier).pageController,
                  onPageChanged: (newIndex) {
                    // setState(() {
                    //   currentPageIndex = newIndex;
                    // });
                    //print('onPageChange');
                    ref.read(pageIndexProvider.notifier).state = newIndex;
                  },
                  children: myPages(context),
                ),
              ),
              const MyNumbersHolder(),
            ],
          )
        : Column(
            children: [
              Flexible(
                child: PageView(
                  key: _key,
                  controller:
                      ref.read(bottomTabNotifier.notifier).pageController,
                  onPageChanged: (newIndex) {
                    // setState(() {
                    //   currentPageIndex = newIndex;
                    // });
                    //print('onPageChange');
                    ref.read(pageIndexProvider.notifier).state = newIndex;
                  },
                  children: myPages(context),
                ),
              ),
              const MyNumbersHolder(),
            ],
          );
  }

  // final _myPages = const <Widget>[
  //   Center(
  //     child: Column(children: [
  //       ChartAnnotation(),
  //       ChartHolder(general: true)
  //     ]), //Text('BottomBar Gen'),
  //   ),
  //   Center(
  //     child: Column(
  //       children: [
  //         ChartAnnotation(),
  //         ChartHolder(general: false),
  //       ],
  //     ),
  //   ),
  //   Center(
  //     child: StatisticScreen(),
  //   ),
  //   Center(
  //     child: NumbersStat(),
  //   ),
  // ];

  static PageController pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //print('----- Build HomePage');
    currentPageIndex = ref.watch(pageIndexProvider);

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        height: AppDimens.bottomBarHeight,
        onDestinationSelected: (int index) {
          ref.read(pageIndexProvider.notifier).state = index;
          ref.read(bottomTabNotifier.notifier).pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 500),
              curve: Curves.ease);
        },
        selectedIndex: currentPageIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        destinations: <Widget>[
          NavigationDestination(
              selectedIcon: Icon(Icons.circle),
              icon: Icon(
                Icons.circle_outlined,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              label: 'General'),
          NavigationDestination(
              selectedIcon: Icon(Icons.star),
              icon: Icon(
                Icons.star_border_outlined,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              label: 'Additional'),
          NavigationDestination(
              selectedIcon: Icon(Icons.pie_chart),
              icon: Icon(
                Icons.pie_chart_outline,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              label: 'Statistic'),
          NavigationDestination(
              selectedIcon: Icon(Icons.show_chart),
              icon: Icon(
                Icons.show_chart_outlined,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              label: 'Charts'),
          NavigationDestination(
              selectedIcon: Icon(Icons.settings),
              icon: Icon(
                Icons.settings_outlined,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              label: 'Settings'),
        ],
      ),

      // appBar is working but dissabled
      appBar:
          AppUtils.isLandscape(context) ? null : appBar(refreshData, context),
      // drawer: MainDrawer(
      //   onSelectScreen: _setScreen,
      // ),
      backgroundColor: AppColors.contentColorCyan,
      body: body(),
      // Stack(
      //   alignment: AlignmentDirectional.bottomEnd,
      //   children: [
      //     PageView(
      //       controller: ref.read(bottomTabNotifier.notifier).pageController,
      //       onPageChanged: (newIndex) {
      //         // setState(() {
      //         //   currentPageIndex = newIndex;
      //         // });
      //         //print('onPageChange');
      //         ref.read(pageIndexProvider.notifier).state = newIndex;
      //       },
      //       children: myPages(context),
      //     ),
      //     const MyNumbersHolder(),
      //   ],
      // ),
    );
  }
}

appBar(refreshData, context) {
  return AppBar(
    toolbarHeight: AppDimens.appBarHeight,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
            height: 30,
            width: 30,
            child:
                const Image(image: AssetImage('assets/images/gpot_icon.png'))),
        Text(
          'EuroJackPot by GarK',
          style:
              TextStyle(fontSize: MediaQuery.textScalerOf(context).scale(10)),
        ),
        IconButton(
            onPressed: refreshData,
            icon: const Icon(Icons.change_circle_outlined))
      ],
    ),
    backgroundColor: Colors.transparent,
  );
}
