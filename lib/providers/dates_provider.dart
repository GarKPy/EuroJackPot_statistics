import 'package:flutter_riverpod/flutter_riverpod.dart';

class LatestDateProvider extends StateNotifier<String> {
  LatestDateProvider() : super('0000-00-00');
}

final latestDateProvider = StateProvider<String>((ref) => '0000-00-00');

final yearNowProvider = StateProvider((ref) {
  String year = DateTime.now().year.toString();
  return year;
});
