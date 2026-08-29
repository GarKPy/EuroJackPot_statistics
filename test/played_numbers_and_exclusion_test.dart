import 'package:eurojackpot/models/wide_numbers.dart';
import 'package:eurojackpot/providers/database_provider.dart';
import 'package:eurojackpot/providers/my_random_numbers_provider.dart';
import 'package:eurojackpot/providers/utils_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserPlayedNumbersNotifier tests', () {
    test('Defaults to 3 rows of 7 zeros', () {
      final container = ProviderContainer();
      final rows = container.read(userPlayedNumbersProvider);

      expect(rows.length, 3);
      for (var row in rows) {
        expect(row, [0, 0, 0, 0, 0, 0, 0]);
      }
    });

    test('Add row up to maximum of 5 rows', () {
      final container = ProviderContainer();
      final notifier = container.read(userPlayedNumbersProvider.notifier);

      expect(container.read(userPlayedNumbersProvider).length, 3);

      notifier.addRow();
      expect(container.read(userPlayedNumbersProvider).length, 4);

      notifier.addRow();
      expect(container.read(userPlayedNumbersProvider).length, 5);

      // Attempting to add 6th row should be ignored
      notifier.addRow();
      expect(container.read(userPlayedNumbersProvider).length, 5);
    });

    test('Remove row down to minimum of 3 rows', () {
      final container = ProviderContainer();
      final notifier = container.read(userPlayedNumbersProvider.notifier);

      notifier.addRow(); // 4
      notifier.addRow(); // 5
      expect(container.read(userPlayedNumbersProvider).length, 5);

      notifier.removeRow(4);
      expect(container.read(userPlayedNumbersProvider).length, 4);

      notifier.removeRow(3);
      expect(container.read(userPlayedNumbersProvider).length, 3);

      // Attempting to remove below 3 rows should be ignored
      notifier.removeRow(2);
      expect(container.read(userPlayedNumbersProvider).length, 3);
    });

    test('Update row numbers', () {
      final container = ProviderContainer();
      final notifier = container.read(userPlayedNumbersProvider.notifier);

      notifier.updateRow(0, [5, 12, 23, 34, 45, 3, 9]);
      final rows = container.read(userPlayedNumbersProvider);

      expect(rows[0], [5, 12, 23, 34, 45, 3, 9]);
      expect(rows[1], [0, 0, 0, 0, 0, 0, 0]);
    });
  });

  group('Exclusion logic tests', () {
    test('filterExcluded filters out excluded indices', () {
      List<List<int>> buckets = [
        [0, 1, 2, 3, 4],
        [5, 6, 7, 8, 9],
        [10, 11, 12, 13, 14],
        [15, 16, 17, 18, 19],
      ];
      Set<int> excluded = {0, 1, 5, 10, 15};

      final filtered = filterExcluded(buckets, excluded, 5, 50);

      for (var bucket in filtered) {
        for (var idx in bucket) {
          expect(excluded.contains(idx), isFalse);
        }
      }
    });

    test('randomize excludes played numbers and produces 5 valid general + 2 valid star', () {
      // 50 general numbers (indices 0..49)
      List<List<int>> bucketsGen = [
        List.generate(50, (i) => i),
      ];
      // Exclude numbers 1, 2, 3, 4, 5 (indices 0..4)
      Set<int> excludedGen = {0, 1, 2, 3, 4};
      final filteredGen = filterExcluded(bucketsGen, excludedGen, 5, 50);

      for (int trial = 0; trial < 20; trial++) {
        final result = randomize(filteredGen, [5], 5, false);
        expect(result.length, 5);
        // Ensure strictly sorted and unique
        expect(result.toSet().length, 5);
        for (var num in result) {
          expect(num >= 6 && num <= 50, isTrue,
              reason: 'Number $num was supposed to be excluded (1..5)');
        }
      }
    });

    test('randomize for star numbers excludes played star numbers', () {
      // 12 star numbers (indices 0..11)
      List<List<int>> bucketsStar = [
        List.generate(12, (i) => i),
      ];
      // Exclude star numbers 1, 2 (indices 0, 1)
      Set<int> excludedStar = {0, 1};
      final filteredStar = filterExcluded(bucketsStar, excludedStar, 2, 12);

      for (int trial = 0; trial < 20; trial++) {
        final result = randomize(filteredStar, [2], 2, false);
        expect(result.length, 2);
        expect(result.toSet().length, 2);
        for (var num in result) {
          expect(num >= 3 && num <= 12, isTrue,
              reason: 'Star number $num was supposed to be excluded (1, 2)');
        }
      }
    });

    test('randomize supplements missing numbers from any region if quantity is 0 or sum < 5', () {
      List<List<int>> fourBuckets = [
        [0, 1, 2, 3, 4], // Bucket 0
        [5, 6, 7, 8, 9], // Bucket 1
        [10, 11, 12, 13, 14], // Bucket 2
        [15, 16, 17, 18, 19], // Bucket 3
      ];
      // Quantity specifies only 1 from Bucket 0, 0 from others -> total 1 < 5
      List<int> quantities = [1, 0, 0, 0];

      for (int trial = 0; trial < 10; trial++) {
        final result = randomize(fourBuckets, quantities, 5, true);
        expect(result.length, 5);
        expect(result.toSet().length, 5);
        // At least 1 should be from bucket 0 (1..5) and the other 4 from other buckets
        int inBucket0 = result.where((n) => n >= 1 && n <= 5).length;
        expect(inBucket0 >= 1, isTrue);
      }
    });
  });

  group('WideNumbers dynamic simpleRegions tests', () {
    test('Calculates regions dynamically based on passed coefficients', () {
      final wideNumbers = WideNumbers(
        datePlayed: '2024-01-01',
        generalNumQuantity: [10, 20, 30, 40, 50], // min=10, max=50, span=40
        additionalNumQuantity: [2, 4, 6, 8, 10], // min=2, max=10, span=8
      );

      // Default [0.75, 0.50, 0.25]
      final defaultGen = wideNumbers.simpleRegionsGeneral();
      expect(defaultGen, [40.0, 30.0, 20.0]); // 40*0.75+10, 40*0.5+10, 40*0.25+10

      final defaultAdd = wideNumbers.simpleRegionsAdditional();
      expect(defaultAdd, [8.0, 6.0, 4.0]); // 8*0.75+2, 8*0.5+2, 8*0.25+2

      // Custom [0.80, 0.60, 0.30]
      final customGen = wideNumbers.simpleRegionsGeneral([0.80, 0.60, 0.30]);
      expect(customGen, [42.0, 34.0, 22.0]);

      final customAdd = wideNumbers.simpleRegionsAdditional([0.80, 0.60, 0.30]);
      expect(customAdd, [8.4, 6.8, 4.4]);
    });

    test('generalRegions and additionalRegions can be customized independently', () {
      final container = ProviderContainer();
      expect(container.read(generalRegions), [0.75, 0.50, 0.25]);
      expect(container.read(additionalRegions), [0.75, 0.50, 0.25]);

      container.read(generalRegions.notifier).state = [0.80, 0.60, 0.40];
      container.read(additionalRegions.notifier).state = [0.70, 0.45, 0.20];

      expect(container.read(generalRegions), [0.80, 0.60, 0.40]);
      expect(container.read(additionalRegions), [0.70, 0.45, 0.20]);
    });
  });
}
