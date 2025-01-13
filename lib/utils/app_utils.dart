import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:eurojackpot/resources/app_colors.dart';

class AppUtils {
  static bool isLandscape(BuildContext context) {
    // double screenWidth = WidgetsBinding
    //     .instance.platformDispatcher.views.first.physicalSize.width;
    // double screenHeight = WidgetsBinding
    //     .instance.platformDispatcher.views.first.physicalSize.height;
    // bool isLandscape = screenHeight > screenWidth ? false : true;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isLandscape = screenHeight > screenWidth ? false : true;

    return isLandscape;
  }

  static FlutterView view =
      WidgetsBinding.instance.platformDispatcher.views.first;

  static double get screenWidth {
    Size size = view.physicalSize / view.devicePixelRatio;
    return size.width;
  }

  static double get screenHight {
    Size size = view.physicalSize / view.devicePixelRatio;
    return size.height;
  }

  static Decoration starDecoration(bool isStar) {
    Decoration decoration;

    //isGeneral = !widget.star;
    if (!isStar) {
      decoration = const BoxDecoration(
          shape: BoxShape.circle,
          // border: Border.all(
          //   width: 2,
          //   color: Colors.yellow,
          // ),
          gradient: RadialGradient(
            center: Alignment(0.3, -0.2),
            colors: [
              Color.fromARGB(255, 255, 243, 210),
              AppColors.contentColorAmber,
            ],
          )
          //borderRadius: BorderRadius.circular(20),
          );
    } else {
      decoration = const ShapeDecoration(
          shape: StarBorder(points: 8, innerRadiusRatio: .6),
          // border: Border.all(
          //   width: 2,
          //   color: Colors.yellow,
          // ),
          gradient: RadialGradient(
            center: Alignment(0.3, -0.2),
            colors: [
              Color.fromARGB(255, 255, 243, 210),
              Color.fromARGB(255, 197, 149, 4)
            ],
          )
          //borderRadius: BorderRadius.circular(20),
          );
    }
    return decoration;
  }

  static List<List<int>> filterByRegions(List<int> data, List<double> region) {
    List<List<int>> filteredList = [];
    for (int i = 0; i < region.length; i++) {
      if (i == 0) {
        filteredList.add(data
            .asMap()
            .entries
            .where((element) => (element.value <= region[i]))
            .map((e) => e.key)
            .toList());
        filteredList.add(data
            .asMap()
            .entries
            .where((element) =>
                element.value > region[i] && element.value <= region[i + 1])
            .map((e) => e.key)
            .toList());
      } else if (i == region.length - 1) {
        filteredList.add(data
            .asMap()
            .entries
            .where((element) => element.value > region[i])
            .map((e) => e.key)
            .toList());
      } else {
        filteredList.add(data
            .asMap()
            .entries
            .where((element) =>
                element.value > region[i] && element.value <= region[i + 1])
            .map((e) => e.key)
            .toList());
      }
    }
    return filteredList;
  }

  static Decoration generalBoxDecoration() {
    return BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.indigo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ));
  }
}
