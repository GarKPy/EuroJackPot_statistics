import 'package:eurojackpot/providers/utils_providers.dart';
import 'package:eurojackpot/resources/app_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyNumbersWidget extends ConsumerStatefulWidget {
  const MyNumbersWidget(
      {super.key,
      required this.myNum,
      required this.star,
      required this.index});
  final int myNum;
  final bool star;
  final int index;

  @override
  ConsumerState<MyNumbersWidget> createState() => _MyNumbersState();
}

class _MyNumbersState extends ConsumerState<MyNumbersWidget> {
  @override
  Widget build(BuildContext context) {
    var decoration;

    int selectedNum = ref.watch(myNumberSelectedProvider);

    if (!widget.star) {
      decoration = BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(0.3, -0.2),
            colors: widget.index == selectedNum
                ? const [
                    Color.fromARGB(255, 255, 243, 210),
                    Color.fromARGB(255, 226, 70, 49),
                  ]
                : [
                    const Color.fromARGB(255, 255, 243, 210),
                    AppColors.contentColorAmber,
                  ],
          ));
    } else {
      decoration = ShapeDecoration(
          shape: const StarBorder(points: 8, innerRadiusRatio: .6),
          gradient: RadialGradient(
            center: const Alignment(0.3, -0.2),
            colors: widget.index == selectedNum
                ? const [
                    Color.fromARGB(255, 255, 243, 210),
                    Color.fromARGB(255, 226, 70, 49),
                  ]
                : [
                    const Color.fromARGB(255, 255, 243, 210),
                    AppColors.contentColorAmber,
                  ],
          ));
    }

    return Expanded(
      child: Center(
        child: AnimatedContainer(
          height: double.infinity,
          width: double.infinity,
          margin: const EdgeInsets.all(5),
          decoration: decoration,
          duration: const Duration(milliseconds: 300),
          child: Center(
            child: InkWell(
              onTap: () {
                ref.read(myNumberSelectedProvider.notifier).state = -1;
              },
              onLongPress: () {
                ref.read(myNumberSelectedProvider.notifier).state =
                    widget.index;

                if (widget.index < 5) {
                  ref.read(pageIndexProvider.notifier).state = 0;
                  ref
                      .read(bottomTabNotifier.notifier)
                      .pageController
                      .animateToPage(0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease);
                } else {
                  ref
                      .read(bottomTabNotifier.notifier)
                      .pageController
                      .animateToPage(1,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease);
                }
              },
              child: Text(
                widget.myNum.toString(),
                style: const TextStyle(
                  fontSize: AppDimens.myNumFontSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
