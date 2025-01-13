import 'package:eurojackpot/providers/my_random_numbers_provider.dart';
import 'package:eurojackpot/providers/utils_providers.dart';
import 'package:eurojackpot/resources/app_resources.dart';
import 'package:eurojackpot/utils/app_utils.dart';
import 'package:eurojackpot/widgets/my_numbers_w.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyNumbersHolder extends ConsumerStatefulWidget {
  const MyNumbersHolder({super.key});

  @override
  ConsumerState<MyNumbersHolder> createState() => _MyNumbersHolderState();
}

class _MyNumbersHolderState extends ConsumerState<MyNumbersHolder> {
  myNumWidget(bool isLandscape, double height, double width, List<int> myNums) {
    if (AppUtils.isLandscape(context)) {
      return SingleChildScrollView(
        clipBehavior: Clip.antiAlias,
        scrollDirection: Axis.vertical,
        child: SizedBox(
          height: height + 15, //AppDimens.myNumbersWidth * myNums.length,
          width: AppDimens.myNumbersWidth,
          child: Column(
            children: [
              for (int i = 0; i < myNums.length; i++)
                MyNumbersWidget(
                  myNum: myNums[i],
                  star: (i >= 5) ? true : false,
                  index: i,
                )
            ],
          ),
        ),
      );
    } else {
      return Row(
        children: [
          for (var i = 0; i < myNums.length; i++)
            MyNumbersWidget(
              myNum: myNums[i],
              star: (i >= 5) ? true : false,
              index: i,
            )
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //print('***** MyNumbersHolder entered');

    double numHolderWidth;
    double numHolderHeight;
    int cellNumber;
    bool isLandscape = AppUtils.isLandscape(context);
    List<int> myNums = ref.watch(myNumsProvider);
    ref.watch(reloadMyNumbers);
    cellNumber = 7;

    if (AppUtils.isLandscape(context)) {
      numHolderWidth = AppDimens.myNumbersWidth;
      numHolderHeight = AppDimens.myNumbersWidth * cellNumber;
    } else {
      numHolderWidth = AppDimens.myNumbersWidth * cellNumber;
      numHolderHeight = AppDimens.myNumbersWidth;
    }

    return Container(
      height: numHolderHeight,
      width: numHolderWidth,
      margin: const EdgeInsets.all(AppDimens.generalPadding),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          gradient: const LinearGradient(
            colors: [Colors.blueAccent, Colors.indigo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )),
      child: myNumWidget(isLandscape, numHolderHeight, numHolderWidth, myNums),
    );
  }
}
