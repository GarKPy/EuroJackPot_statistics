import 'package:eurojackpot/resources/app_dimens.dart';
import 'package:eurojackpot/utils/app_utils.dart' show AppUtils;
import 'package:eurojackpot/widgets/played_number_editor_dialog.dart';
import 'package:flutter/material.dart';

class PlayedNumbersRowWidget extends StatelessWidget {
  const PlayedNumbersRowWidget({
    super.key,
    required this.rowIndex,
    required this.numbers,
    required this.onSaveRow,
    this.onDeleteRow,
  });

  final int rowIndex;
  final List<int> numbers;
  final Function(List<int>) onSaveRow;
  final VoidCallback? onDeleteRow;

  Widget _buildBall({required int num, required bool isStar}) {
    Decoration decoration = AppUtils.starDecoration(isStar);

    return Container(
      width: 34,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: decoration,
      child: Center(
        child: Text(
          num > 0 ? num.toString() : '-',
          style: const TextStyle(
            fontSize: AppDimens.myNumFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _openEditor(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => PlayedNumberEditorDialog(
        rowIndex: rowIndex,
        initialNumbers: numbers,
        onSave: onSaveRow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<int> currentNums = List<int>.from(numbers);
    while (currentNums.length < 7) {
      currentNums.add(0);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: AppUtils.generalBoxDecoration(),
      child: Row(
        children: [
          // Row label
          Text(
            '#${rowIndex + 1}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(width: 6),

          // 5 Circle numbers + 2 Star numbers
          Expanded(
            child: InkWell(
              onTap: () => _openEditor(context),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < 5; i++)
                        _buildBall(num: currentNums[i], isStar: false),
                      const SizedBox(width: 4),
                      for (int i = 5; i < 7; i++)
                        _buildBall(num: currentNums[i], isStar: true),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Edit button
          IconButton(
            icon: const Icon(Icons.edit, size: 20, color: Colors.white),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
            tooltip: 'Edit Row',
            onPressed: () => _openEditor(context),
          ),

          // Delete button (optional if rows > 3)
          if (onDeleteRow != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 20, color: Colors.redAccent),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              tooltip: 'Delete Row',
              onPressed: onDeleteRow,
            ),
          ],
        ],
      ),
    );
  }
}
