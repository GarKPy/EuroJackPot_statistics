import 'package:eurojackpot/providers/data_update.dart';
import 'package:eurojackpot/providers/utils_providers.dart';
import 'package:eurojackpot/resources/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreen();
}

class _SettingsScreen extends ConsumerState<SettingsScreen> {
  late Future<List<String>> datesOfYear;

  @override
  Widget build(BuildContext context) {
    bool allowRepeatNum = ref.watch(allowRepeatNumbers);
    bool generateByReg = ref.watch(generateByRegions);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.generalPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            leading: Icon(
              Icons.sync,
              size: 40,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'Update Data',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 24,
                  ),
            ),
            onTap: () {
              dataUpdater(context, ref);

              // Return to first page after presing update
              ref.read(pageIndexProvider.notifier).state = 0;
              ref.read(bottomTabNotifier.notifier).pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease);
            },
          ),
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(AppDimens.generalPadding),
                  child: Text(
                    "Allow generate numbers from past (allow repeated combinations)",
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 20,
                        ),
                  ),
                ),
              ),
              Switch(
                  value: allowRepeatNum,
                  onChanged: (value) {
                    ref.read(allowRepeatNumbers.notifier).state = value;
                  }),
            ],
          ),
          const SizedBox(height: AppDimens.generalPadding),
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(AppDimens.generalPadding),
                  child: Text(
                    "Randomize by region",
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 20,
                        ),
                  ),
                ),
              ),
              Switch(
                  value: generateByReg,
                  onChanged: (value) {
                    ref.read(generateByRegions.notifier).state = value;
                    if (value) {
                      ref.read(generalRegionQuantity.notifier).state = [
                        2,
                        1,
                        1,
                        1
                      ];
                      ref.read(additionalRegionQuantity.notifier).state = [
                        0,
                        0,
                        1,
                        1
                      ];
                    } else {
                      ref.read(generalRegionQuantity.notifier).state = [
                        0,
                        0,
                        0,
                        0
                      ];
                      ref.read(additionalRegionQuantity.notifier).state = [
                        0,
                        0,
                        0,
                        0
                      ];
                    }
                  }),
            ],
          ),
          const SizedBox(height: AppDimens.generalPadding),
          Text(
            'Created by GarK',
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 24,
                ),
          ),
        ],
      ),
    );
  }
}
