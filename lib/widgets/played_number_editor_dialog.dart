import 'package:eurojackpot/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class PlayedNumberEditorDialog extends StatefulWidget {
  const PlayedNumberEditorDialog({
    super.key,
    required this.rowIndex,
    required this.initialNumbers,
    required this.onSave,
  });

  final int rowIndex;
  final List<int> initialNumbers;
  final Function(List<int>) onSave;

  @override
  State<PlayedNumberEditorDialog> createState() =>
      _PlayedNumberEditorDialogState();
}

class _PlayedNumberEditorDialogState extends State<PlayedNumberEditorDialog> {
  late List<int> currentNumbers;
  int selectedSlotIndex = 0; // 0..4 for general, 5..6 for star

  @override
  void initState() {
    super.initState();
    currentNumbers = List<int>.from(widget.initialNumbers);
    while (currentNumbers.length < 7) {
      currentNumbers.add(0);
    }
  }

  void _selectNumber(int number) {
    setState(() {
      if (selectedSlotIndex < 5) {
        // General number (1..50)
        // If this number is already in another general slot, clear that slot
        for (int i = 0; i < 5; i++) {
          if (i != selectedSlotIndex && currentNumbers[i] == number) {
            currentNumbers[i] = 0;
          }
        }
        currentNumbers[selectedSlotIndex] = number;
        // Auto-advance to next slot
        if (selectedSlotIndex < 6) {
          selectedSlotIndex++;
        }
      } else {
        // Star number (1..12)
        // If this number is already in other star slot, clear it
        for (int i = 5; i < 7; i++) {
          if (i != selectedSlotIndex && currentNumbers[i] == number) {
            currentNumbers[i] = 0;
          }
        }
        currentNumbers[selectedSlotIndex] = number;
        // Auto-advance
        if (selectedSlotIndex < 6) {
          selectedSlotIndex++;
        }
      }
    });
  }

  void _clearAll() {
    setState(() {
      currentNumbers = [0, 0, 0, 0, 0, 0, 0];
      selectedSlotIndex = 0;
    });
  }

  void _randomize() {
    final random = Random();
    final genList = <int>{};
    while (genList.length < 5) {
      genList.add(random.nextInt(50) + 1);
    }
    final sortedGen = genList.toList()..sort();

    final starList = <int>{};
    while (starList.length < 2) {
      starList.add(random.nextInt(12) + 1);
    }
    final sortedStar = starList.toList()..sort();

    setState(() {
      currentNumbers = [...sortedGen, ...sortedStar];
    });
  }

  Widget _buildSlot(int index) {
    bool isStar = index >= 5;
    bool isSelected = selectedSlotIndex == index;
    int num = currentNumbers[index];

    Decoration decoration;
    if (!isStar) {
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(color: Colors.white, width: 2.5)
            : Border.all(color: Colors.white38, width: 1),
        gradient: RadialGradient(
          center: const Alignment(0.3, -0.2),
          colors: isSelected
              ? const [
                  Color.fromARGB(255, 255, 243, 210),
                  Color.fromARGB(255, 226, 70, 49),
                ]
              : const [
                  Color.fromARGB(255, 255, 243, 210),
                  AppColors.contentColorAmber,
                ],
        ),
      );
    } else {
      decoration = ShapeDecoration(
        shape: const StarBorder(points: 8, innerRadiusRatio: .6),
        gradient: RadialGradient(
          center: const Alignment(0.3, -0.2),
          colors: isSelected
              ? const [
                  Color.fromARGB(255, 255, 243, 210),
                  Color.fromARGB(255, 226, 70, 49),
                ]
              : const [
                  Color.fromARGB(255, 255, 243, 210),
                  AppColors.contentColorAmber,
                ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSlotIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 38,
        height: 38,
        margin: const EdgeInsets.symmetric(horizontal: 2.5),
        decoration: decoration,
        child: Center(
          child: Text(
            num > 0 ? num.toString() : '-',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEditingStar = selectedSlotIndex >= 5;
    int maxNumber = isEditingStar ? 12 : 50;

    Set<int> selectedInCurrentCategory = isEditingStar
        ? {currentNumbers[5], currentNumbers[6]}.where((n) => n > 0).toSet()
        : {
            currentNumbers[0],
            currentNumbers[1],
            currentNumbers[2],
            currentNumbers[3],
            currentNumbers[4]
          }.where((n) => n > 0).toSet();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xFF1E1E2C),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Played Row ${widget.rowIndex + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Number Slots (5 Circles + 2 Stars)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [Colors.blueAccent, Colors.indigo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < 5; i++) _buildSlot(i),
                  Container(
                    height: 24,
                    width: 1.5,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: Colors.white38,
                  ),
                  for (int i = 5; i < 7; i++) _buildSlot(i),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Instructions / Current Selection helper
            Text(
              isEditingStar
                  ? 'Pick Euro Star ${selectedSlotIndex - 4} of 2 (1–12)'
                  : 'Pick Circle Number ${selectedSlotIndex + 1} of 5 (1–50)',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.amberAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            // Grid of Available Numbers
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(6),
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: maxNumber,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isEditingStar ? 4 : 7,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, idx) {
                    int numVal = idx + 1;
                    bool isPicked = selectedInCurrentCategory.contains(numVal);
                    bool isCurrentSlot =
                        currentNumbers[selectedSlotIndex] == numVal;

                    return InkWell(
                      onTap: () => _selectNumber(numVal),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isCurrentSlot
                              ? Colors.amber.shade700
                              : isPicked
                                  ? Colors.indigo.shade400
                                  : Colors.white12,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isCurrentSlot
                                ? Colors.amberAccent
                                : Colors.white24,
                            width: isCurrentSlot ? 1.5 : 0.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$numVal',
                            style: TextStyle(
                              color: isPicked || isCurrentSlot
                                  ? Colors.white
                                  : Colors.white70,
                              fontWeight: isPicked || isCurrentSlot
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Action Buttons (Clear, Random, Save)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _clearAll,
                  icon: const Icon(Icons.clear_all,
                      size: 18, color: Colors.redAccent),
                  label: const Text('Clear',
                      style: TextStyle(color: Colors.redAccent)),
                ),
                TextButton.icon(
                  onPressed: _randomize,
                  icon: const Icon(Icons.shuffle,
                      size: 18, color: Colors.cyanAccent),
                  label: const Text('Random',
                      style: TextStyle(color: Colors.cyanAccent)),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                  ),
                  onPressed: () {
                    List<int> gen = currentNumbers.sublist(0, 5);
                    List<int> add = currentNumbers.sublist(5, 7);
                    List<int> nonZeroGen = gen.where((n) => n > 0).toList()
                      ..sort();
                    while (nonZeroGen.length < 5) {
                      nonZeroGen.add(0);
                    }
                    List<int> nonZeroAdd = add.where((n) => n > 0).toList()
                      ..sort();
                    while (nonZeroAdd.length < 2) {
                      nonZeroAdd.add(0);
                    }
                    List<int> finalized = [...nonZeroGen, ...nonZeroAdd];
                    widget.onSave(finalized);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Save',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
