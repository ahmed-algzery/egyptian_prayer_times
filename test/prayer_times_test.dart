import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_prayer_times/islamic_prayer_times.dart';

void main() {
  group('PrayerCalculator', () {
    // Cairo, Egypt coordinates
    const double cairoLatitude = 30.0444;
    const double cairoLongitude = 31.2357;
    const double cairoTimezone = 2.0; // EET (UTC+2)

    test('calculates prayer times for Cairo', () {
      final calculator = PrayerCalculator(
        latitude: cairoLatitude,
        longitude: cairoLongitude,
        timezone: cairoTimezone,
        asrMethod: AsrMethod.standard,
      );

      final date = DateTime(2025, 12, 15);
      final times = calculator.calculate(date);

      // Verify all prayer times are set
      expect(times.fajr, isNotNull);
      expect(times.dhuhr, isNotNull);
      expect(times.asr, isNotNull);
      expect(times.maghrib, isNotNull);
      expect(times.isha, isNotNull);

      // Verify prayer times are on the correct date
      expect(times.fajr.year, date.year);
      expect(times.fajr.month, date.month);
      expect(times.fajr.day, date.day);

      // Verify prayer times are in correct order
      expect(times.fajr.isBefore(times.dhuhr), isTrue);
      expect(times.dhuhr.isBefore(times.asr), isTrue);
      expect(times.asr.isBefore(times.maghrib), isTrue);
      expect(times.maghrib.isBefore(times.isha), isTrue);
    });

    test('calculates different Asr times for different methods', () {
      final calculatorStandard = PrayerCalculator(
        latitude: cairoLatitude,
        longitude: cairoLongitude,
        timezone: cairoTimezone,
        asrMethod: AsrMethod.standard,
      );

      final calculatorHanafi = PrayerCalculator(
        latitude: cairoLatitude,
        longitude: cairoLongitude,
        timezone: cairoTimezone,
        asrMethod: AsrMethod.hanafi,
      );

      final date = DateTime(2024, 3, 11);
      final timesStandard = calculatorStandard.calculate(date);
      final timesHanafi = calculatorHanafi.calculate(date);

      // Hanafi Asr should be later than standard Asr
      expect(timesHanafi.asr.isAfter(timesStandard.asr), isTrue);

      // Both should still be between Dhuhr and Maghrib
      expect(timesStandard.asr.isAfter(timesStandard.dhuhr), isTrue);
      expect(timesStandard.asr.isBefore(timesStandard.maghrib), isTrue);
      expect(timesHanafi.asr.isAfter(timesHanafi.dhuhr), isTrue);
      expect(timesHanafi.asr.isBefore(timesHanafi.maghrib), isTrue);
    });

    test('getPrayerTime returns correct prayer time', () {
      final calculator = PrayerCalculator(
        latitude: cairoLatitude,
        longitude: cairoLongitude,
        timezone: cairoTimezone,
      );

      final times = calculator.calculate();

      expect(times.getPrayerTime(PrayerName.fajr), equals(times.fajr));
      expect(times.getPrayerTime(PrayerName.dhuhr), equals(times.dhuhr));
      expect(times.getPrayerTime(PrayerName.asr), equals(times.asr));
      expect(times.getPrayerTime(PrayerName.maghrib), equals(times.maghrib));
      expect(times.getPrayerTime(PrayerName.isha), equals(times.isha));
    });

    test('toMap returns all prayer times', () {
      final calculator = PrayerCalculator(
        latitude: cairoLatitude,
        longitude: cairoLongitude,
        timezone: cairoTimezone,
      );

      final times = calculator.calculate();
      final map = times.toMap();

      expect(map.length, equals(5));
      expect(map[PrayerName.fajr], equals(times.fajr));
      expect(map[PrayerName.dhuhr], equals(times.dhuhr));
      expect(map[PrayerName.asr], equals(times.asr));
      expect(map[PrayerName.maghrib], equals(times.maghrib));
      expect(map[PrayerName.isha], equals(times.isha));
    });

    test('getNextPrayer returns next prayer time', () {
      final calculator = PrayerCalculator(
        latitude: cairoLatitude,
        longitude: cairoLongitude,
        timezone: cairoTimezone,
      );

      final times = calculator.calculate();

      // Test with a time before Fajr (should return Fajr)
      final earlyMorning = DateTime(
        times.fajr.year,
        times.fajr.month,
        times.fajr.day,
        3,
        0,
      );
      final nextPrayer = times.getNextPrayer(earlyMorning);
      expect(nextPrayer, isNotNull);
      expect(nextPrayer, equals(times.fajr));

      // Test with a time between Fajr and Dhuhr (should return Dhuhr)
      final midMorning = times.fajr.add(const Duration(hours: 2));
      final nextPrayer2 = times.getNextPrayer(midMorning);
      expect(nextPrayer2, isNotNull);
      expect(nextPrayer2, equals(times.dhuhr));
    });

    test('getTimeRemaining returns correct duration', () {
      final calculator = PrayerCalculator(
        latitude: cairoLatitude,
        longitude: cairoLongitude,
        timezone: cairoTimezone,
      );

      final times = calculator.calculate();

      // Test with a time before Fajr
      final earlyMorning = DateTime(
        times.fajr.year,
        times.fajr.month,
        times.fajr.day,
        3,
        0,
      );
      final remaining = times.getTimeRemaining(earlyMorning);
      expect(remaining, isNotNull);
      expect(remaining!.inMinutes, greaterThan(0));
    });

    test('getCurrentPrayerName returns current prayer', () {
      final calculator = PrayerCalculator(
        latitude: cairoLatitude,
        longitude: cairoLongitude,
        timezone: cairoTimezone,
      );

      final times = calculator.calculate();

      // Test with a time between Fajr and Dhuhr
      final midMorning = times.fajr.add(const Duration(hours: 2));
      final currentPrayer = times.getCurrentPrayerName(midMorning);
      expect(currentPrayer, equals(PrayerName.fajr));
    });

    test('calculates prayer times for different dates', () {
      final calculator = PrayerCalculator(
        latitude: cairoLatitude,
        longitude: cairoLongitude,
        timezone: cairoTimezone,
      );

      final date1 = DateTime(2024, 1, 1);
      final date2 = DateTime(2024, 6, 15);

      final times1 = calculator.calculate(date1);
      final times2 = calculator.calculate(date2);

      // Prayer times should be different for different dates
      expect(times1.fajr, isNot(equals(times2.fajr)));
      expect(times1.dhuhr, isNot(equals(times2.dhuhr)));
    });

    test('works with different timezones', () {
      final calculator1 = PrayerCalculator(
        latitude: cairoLatitude,
        longitude: cairoLongitude,
        timezone: 2.0,
      );

      final calculator2 = PrayerCalculator(
        latitude: cairoLatitude,
        longitude: cairoLongitude,
        timezone: 3.0,
      );

      final date = DateTime(2024, 3, 11);
      final times1 = calculator1.calculate(date);
      final times2 = calculator2.calculate(date);

      // Times should differ by approximately 1 hour
      final diff = times1.fajr.difference(times2.fajr).inHours.abs();
      expect(diff, closeTo(1, 1));
    });
  });

  group('CalculationParams', () {
    test('validates latitude range', () {
      expect(
        () => CalculationParams(latitude: 91, longitude: 0),
        throwsArgumentError,
      );
      expect(
        () => CalculationParams(latitude: -91, longitude: 0),
        throwsArgumentError,
      );
    });

    test('validates longitude range', () {
      expect(
        () => CalculationParams(latitude: 0, longitude: 181),
        throwsArgumentError,
      );
      expect(
        () => CalculationParams(latitude: 0, longitude: -181),
        throwsArgumentError,
      );
    });

    test('creates params with valid values', () {
      final params = CalculationParams(
        latitude: 30.0,
        longitude: 31.0,
        timezone: 2.0,
        asrMethod: AsrMethod.hanafi,
      );

      expect(params.latitude, equals(30.0));
      expect(params.longitude, equals(31.0));
      expect(params.timezone, equals(2.0));
      expect(params.asrMethod, equals(AsrMethod.hanafi));
    });
  });
}

