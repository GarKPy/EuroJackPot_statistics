import 'dart:convert';

import 'package:eurojackpot/providers/data_update.dart';
import 'package:eurojackpot/providers/database_provider.dart';
import 'package:eurojackpot/providers/utils_providers.dart';
import 'package:eurojackpot/resources/app_dimens.dart';
import 'package:eurojackpot/widgets/played_numbers_row_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreen();
}

class _SettingsScreen extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      loadAllSettings(ref);
      ref.read(userPlayedNumbersProvider.notifier).loadNumbers();
    });
  }

  void _savePlayedNumbers(List<List<int>> rows) async {
    await ref.read(userPlayedNumbersProvider.notifier).saveNumbers(rows);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Played numbers saved to database!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _updateGeneralQuantity(int index, int delta, List<int> current) {
    int newVal = current[index] + delta;
    if (newVal < 0 || newVal > 5) return;

    List<int> updated = List<int>.from(current);
    updated[index] = newVal;
    ref.read(generalRegionQuantity.notifier).state = updated;

    int sum = updated.fold(0, (a, b) => a + b);
    if (sum == 5) {
      saveAppSetting('generalRegionQuantity', jsonEncode(updated));
    }
  }

  void _updateAdditionalQuantity(int index, int delta, List<int> current) {
    int newVal = current[index] + delta;
    if (newVal < 0 || newVal > 2) return;

    List<int> updated = List<int>.from(current);
    updated[index] = newVal;
    ref.read(additionalRegionQuantity.notifier).state = updated;

    int sum = updated.fold(0, (a, b) => a + b);
    if (sum == 2) {
      saveAppSetting('additionalRegionQuantity', jsonEncode(updated));
    }
  }

  void _updateGeneralRegionThreshold(
      int index, double delta, List<double> current) {
    double newVal = double.parse((current[index] + delta).toStringAsFixed(2));
    if (newVal < 0.05 || newVal > 0.95) return;

    List<double> updated = List<double>.from(current);
    updated[index] = newVal;
    ref.read(generalRegions.notifier).state = updated;
    saveAppSetting('generalRegions', jsonEncode(updated));
  }

  void _updateAdditionalRegionThreshold(
      int index, double delta, List<double> current) {
    double newVal = double.parse((current[index] + delta).toStringAsFixed(2));
    if (newVal < 0.05 || newVal > 0.95) return;

    List<double> updated = List<double>.from(current);
    updated[index] = newVal;
    ref.read(additionalRegions.notifier).state = updated;
    saveAppSetting('additionalRegions', jsonEncode(updated));
  }

  Widget _buildThresholdControl({
    required String label,
    required double value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.white70),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: onMinus,
                child: const Icon(Icons.remove,
                    size: 16, color: Colors.cyanAccent),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '${(value * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              InkWell(
                onTap: onPlus,
                child:
                    const Icon(Icons.add, size: 16, color: Colors.cyanAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl({
    required String label,
    required int value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: onMinus,
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child:
                      Icon(Icons.remove, size: 16, color: Colors.amberAccent),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              InkWell(
                onTap: onPlus,
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(Icons.add, size: 16, color: Colors.amberAccent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool allowRepeatNum = ref.watch(allowRepeatNumbers);
    bool generateByReg = ref.watch(generateByRegions);
    bool excludePlayed = ref.watch(excludePlayedNumbers);
    List<List<int>> playedRows = ref.watch(userPlayedNumbersProvider);

    List<double> genRegionsList = ref.watch(generalRegions);
    List<double> addRegionsList = ref.watch(additionalRegions);
    List<int> genRegionQuant = ref.watch(generalRegionQuantity);
    List<int> addRegionQuant = ref.watch(additionalRegionQuantity);

    int genSum = genRegionQuant.fold(0, (a, b) => a + b);
    int addSum = addRegionQuant.fold(0, (a, b) => a + b);

    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final regionNames = ['Min', 'Mid 1', 'Mid 2', 'Max'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.generalPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(
              Icons.sync,
              size: 40,
              color: onSurfaceColor,
            ),
            title: Text(
              'Update Data',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: onSurfaceColor,
                    fontSize: 24,
                  ),
            ),
            onTap: () {
              dataUpdater(context, ref);

              // Return to first page after pressing update
              ref.read(pageIndexProvider.notifier).state = 0;
              ref.read(bottomTabNotifier.notifier).pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease);
            },
          ),
          const Divider(color: Colors.white24),
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(AppDimens.generalPadding),
                  child: Text(
                    "Allow generate numbers from past (allow repeated combinations)",
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: onSurfaceColor,
                          fontSize: 18,
                        ),
                  ),
                ),
              ),
              Switch(
                  value: allowRepeatNum,
                  onChanged: (value) {
                    ref.read(allowRepeatNumbers.notifier).state = value;
                    saveAppSetting('allowRepeatNumbers', value.toString());
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
                          color: onSurfaceColor,
                          fontSize: 18,
                        ),
                  ),
                ),
              ),
              Switch(
                  value: generateByReg,
                  onChanged: (value) {
                    ref.read(generateByRegions.notifier).state = value;
                    saveAppSetting('generateByRegions', value.toString());
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
                      saveAppSetting(
                          'generalRegionQuantity', jsonEncode([2, 1, 1, 1]));
                      saveAppSetting(
                          'additionalRegionQuantity', jsonEncode([0, 0, 1, 1]));
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
                      saveAppSetting(
                          'generalRegionQuantity', jsonEncode([0, 0, 0, 0]));
                      saveAppSetting(
                          'additionalRegionQuantity', jsonEncode([0, 0, 0, 0]));
                    }
                  }),
            ],
          ),

          // Region Configuration Section
          if (generateByReg) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // General Region Cutoffs
                  Text(
                    "General Region Cutoffs (Thresholds)",
                    style: TextStyle(
                      color: onSurfaceColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildThresholdControl(
                        label: 'Max / Mid1',
                        value: genRegionsList[0],
                        onMinus: () => _updateGeneralRegionThreshold(
                            0, -0.05, genRegionsList),
                        onPlus: () => _updateGeneralRegionThreshold(
                            0, 0.05, genRegionsList),
                      ),
                      _buildThresholdControl(
                        label: 'Mid1 / Mid2',
                        value: genRegionsList[1],
                        onMinus: () => _updateGeneralRegionThreshold(
                            1, -0.05, genRegionsList),
                        onPlus: () => _updateGeneralRegionThreshold(
                            1, 0.05, genRegionsList),
                      ),
                      _buildThresholdControl(
                        label: 'Mid2 / Min',
                        value: genRegionsList[2],
                        onMinus: () => _updateGeneralRegionThreshold(
                            2, -0.05, genRegionsList),
                        onPlus: () => _updateGeneralRegionThreshold(
                            2, 0.05, genRegionsList),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // General Region Quantities (must equal 5)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "General Numbers per Region",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        genSum == 5 ? "Total: 5 / 5" : "Total: $genSum / 5",
                        style: TextStyle(
                          color: genSum == 5
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  if (genSum != 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 4),
                      child: Text(
                        genSum < 5
                            ? "Sum is less than 5 ($genSum) — not saved. Remaining will randomize from any region."
                            : "Sum exceeds 5 ($genSum) — not saved.",
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (int i = 0; i < 4; i++)
                        _buildQuantityControl(
                          label: regionNames[i],
                          value:
                              i < genRegionQuant.length ? genRegionQuant[i] : 0,
                          onMinus: () =>
                              _updateGeneralQuantity(i, -1, genRegionQuant),
                          onPlus: () =>
                              _updateGeneralQuantity(i, 1, genRegionQuant),
                        ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 24),

                  // Euro Star Region Cutoffs
                  Text(
                    "Euro Star Region Cutoffs (Thresholds)",
                    style: TextStyle(
                      color: onSurfaceColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildThresholdControl(
                        label: 'Max / Mid1',
                        value: addRegionsList[0],
                        onMinus: () => _updateAdditionalRegionThreshold(
                            0, -0.05, addRegionsList),
                        onPlus: () => _updateAdditionalRegionThreshold(
                            0, 0.05, addRegionsList),
                      ),
                      _buildThresholdControl(
                        label: 'Mid1 / Mid2',
                        value: addRegionsList[1],
                        onMinus: () => _updateAdditionalRegionThreshold(
                            1, -0.05, addRegionsList),
                        onPlus: () => _updateAdditionalRegionThreshold(
                            1, 0.05, addRegionsList),
                      ),
                      _buildThresholdControl(
                        label: 'Mid2 / Min',
                        value: addRegionsList[2],
                        onMinus: () => _updateAdditionalRegionThreshold(
                            2, -0.05, addRegionsList),
                        onPlus: () => _updateAdditionalRegionThreshold(
                            2, 0.05, addRegionsList),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Additional Region Quantities (must equal 2)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Euro Star Numbers per Region",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        addSum == 2 ? "Total: 2 / 2" : "Total: $addSum / 2",
                        style: TextStyle(
                          color: addSum == 2
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  if (addSum != 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 4),
                      child: Text(
                        addSum < 2
                            ? "Sum is less than 2 ($addSum) — not saved. Remaining will randomize from any region."
                            : "Sum exceeds 2 ($addSum) — not saved.",
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (int i = 0; i < 4; i++)
                        _buildQuantityControl(
                          label: regionNames[i],
                          value:
                              i < addRegionQuant.length ? addRegionQuant[i] : 0,
                          onMinus: () =>
                              _updateAdditionalQuantity(i, -1, addRegionQuant),
                          onPlus: () =>
                              _updateAdditionalQuantity(i, 1, addRegionQuant),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const Divider(color: Colors.white24),
          // Exclude Played Numbers Switch
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(AppDimens.generalPadding),
                  child: Text(
                    "Exclude played numbers from random generation",
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: onSurfaceColor,
                          fontSize: 18,
                        ),
                  ),
                ),
              ),
              Switch(
                  value: excludePlayed,
                  onChanged: (value) {
                    ref.read(excludePlayedNumbers.notifier).state = value;
                  }),
            ],
          ),
          const SizedBox(height: AppDimens.generalPadding),

          // Played Numbers Header
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.generalPadding, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "My Played Numbers (${playedRows.length} rows)",
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: onSurfaceColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (playedRows.length < 5)
                  TextButton.icon(
                    onPressed: () {
                      ref.read(userPlayedNumbersProvider.notifier).addRow();
                      _savePlayedNumbers(ref.read(userPlayedNumbersProvider));
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: const Text("Add Row"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.amberAccent,
                    ),
                  ),
              ],
            ),
          ),

          // Played Numbers List (3 to 5 rows)
          for (int i = 0; i < playedRows.length; i++)
            PlayedNumbersRowWidget(
              rowIndex: i,
              numbers: playedRows[i],
              onSaveRow: (newRow) {
                ref
                    .read(userPlayedNumbersProvider.notifier)
                    .updateRow(i, newRow);
                _savePlayedNumbers(ref.read(userPlayedNumbersProvider));
              },
              onDeleteRow: playedRows.length > 3
                  ? () {
                      ref.read(userPlayedNumbersProvider.notifier).removeRow(i);
                      _savePlayedNumbers(ref.read(userPlayedNumbersProvider));
                    }
                  : null,
            ),

          const SizedBox(height: 12),

          // Save All Button
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _savePlayedNumbers(playedRows);
              },
              icon: const Icon(Icons.save),
              label: const Text(
                'Save Played Numbers to DB',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: AppDimens.generalPadding * 3),
          Center(
            child: Text(
              'Created by GarK',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: onSurfaceColor,
                    fontSize: 22,
                  ),
            ),
          ),
          const SizedBox(height: AppDimens.generalPadding * 2),
        ],
      ),
    );
  }
}
