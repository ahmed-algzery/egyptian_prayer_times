import 'dart:math' as math;
import 'models/calculation_params.dart';
import 'models/prayer_time.dart';
import 'utils/math_utils.dart';

/// Calculator for Islamic prayer times using the Egyptian method
///
/// This calculator works completely offline using astronomical calculations.
/// It uses the Egyptian General Authority of Survey method with:
/// - Fajr: 19.5° angle
/// - Isha: 17.5° angle
/// - Dhuhr: Midday (when sun crosses meridian)
/// - Asr: Shadow length calculation (varies by method)
/// - Maghrib: Sunset + 1 minute
class PrayerCalculator {
  /// Calculation parameters
  final CalculationParams params;

  /// Creates a prayer time calculator
  ///
  /// Example:
  /// ```dart
  /// final calculator = PrayerCalculator(
  ///   latitude: 30.0444,
  ///   longitude: 31.2357,
  ///   timezone: 2.0,
  ///   asrMethod: AsrMethod.standard,
  /// );
  /// ```
  PrayerCalculator({
    required double latitude,
    required double longitude,
    double? timezone,
    AsrMethod? asrMethod,
  }) : params = CalculationParams(
          latitude: latitude,
          longitude: longitude,
          timezone: timezone ?? 0.0,
          asrMethod: asrMethod ?? AsrMethod.standard,
        );

  /// Internal constructor
  PrayerCalculator._internal(this.params);

  /// Creates a calculator with automatic timezone detection
  factory PrayerCalculator.withLocalTimezone({
    required double latitude,
    required double longitude,
    AsrMethod? asrMethod,
  }) {
    return PrayerCalculator._internal(
      CalculationParams.withLocalTimezone(
        latitude: latitude,
        longitude: longitude,
        asrMethod: asrMethod ?? AsrMethod.standard,
      ),
    );
  }

  /// Calculates prayer times for a given date
  ///
  /// [date] - The date to calculate prayer times for (defaults to today)
  ///
  /// Returns a [PrayerTimes] object with all five prayer times
  ///
  /// Example:
  /// ```dart
  /// final times = calculator.calculate(DateTime(2024, 3, 11));
  /// print(times.fajr); // 2024-03-11 04:23:00
  /// ```
  PrayerTimes calculate([DateTime? date]) {
    date ??= DateTime.now();
    final localDate = DateTime(date.year, date.month, date.day);

    // Calculate Julian day
    final jd = julianDay(localDate);
    final jc = julianCentury(jd);

    // Calculate sun position
    final geometricMeanLongitude = sunGeometricMeanLongitude(jc);
    final geometricMeanAnomaly = sunGeometricMeanAnomaly(jc);
    final equationOfCenter =
        sunEquationOfCenter(jc, geometricMeanAnomaly);
    final trueLongitude =
        sunTrueLongitude(geometricMeanLongitude, equationOfCenter);
    final meanObliquity = meanObliquityOfEcliptic(jc);
    final correctedObliquity = obliquityCorrection(meanObliquity, jc);
    final apparentLongitude =
        sunApparentLongitude(trueLongitude, jc);
    final declination = sunDeclination(apparentLongitude, correctedObliquity);
    final eqTime = equationOfTime(
        jc, geometricMeanLongitude, geometricMeanAnomaly, correctedObliquity);

    // Calculate solar noon
    final solarNoon = _calculateSolarNoon(
        jd, params.longitude, params.timezone, eqTime);

    // Calculate prayer times
    final fajr = _calculateFajr(
        jd, params.latitude, params.longitude, params.timezone, declination, eqTime);
    final dhuhr = _calculateDhuhr(solarNoon);
    final asr = _calculateAsr(
        jd, params.latitude, params.longitude, params.timezone, declination, eqTime);
    final maghrib = _calculateMaghrib(
        jd, params.latitude, params.longitude, params.timezone, declination, eqTime);
    final isha = _calculateIsha(
        jd, params.latitude, params.longitude, params.timezone, declination, eqTime);

    return PrayerTimes(
      fajr: fajr,
      dhuhr: dhuhr,
      asr: asr,
      maghrib: maghrib,
      isha: isha,
    );
  }

  /// Calculates solar noon (Dhuhr time)
  DateTime _calculateDhuhr(DateTime solarNoon) {
    return solarNoon;
  }

  /// Calculates solar noon time
  DateTime _calculateSolarNoon(
      double jd, double longitude, double timezone, double eqTime) {
    // Solar noon calculation
    double noon = (720 - 4 * longitude - eqTime + timezone * 60) / 1440.0;

    // Convert to hours and minutes
    double hours = noon * 24;
    int hour = hours.floor();
    double minutes = (hours - hour) * 60;
    int minute = minutes.round();

    // Normalize
    if (minute >= 60) {
      hour += 1;
      minute -= 60;
    }
    if (hour >= 24) {
      hour -= 24;
    }
    if (hour < 0) {
      hour += 24;
    }

    // Get the date from Julian day
    final date = _julianDayToDateTime(jd);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  /// Calculates Fajr prayer time (19.5° angle for Egyptian method)
  DateTime _calculateFajr(double jd, double latitude, double longitude,
      double timezone, double declination, double eqTime) {
    const double angle = 19.5; // Egyptian method
    final ha = hourAngle(latitude, declination, -angle);
    final time = timeAtAltitude(jd, longitude, timezone, eqTime, -ha);

    return _fractionalDayToDateTime(jd, time);
  }

  /// Calculates Asr prayer time
  DateTime _calculateAsr(double jd, double latitude, double longitude,
      double timezone, double declination, double eqTime) {
    // Calculate shadow factor based on Asr method
    double shadowFactor;
    switch (params.asrMethod) {
      case AsrMethod.standard:
        shadowFactor = 1.0;
        break;
      case AsrMethod.shafi:
        shadowFactor = 1.0; // Same as standard
        break;
      case AsrMethod.hanafi:
        shadowFactor = 2.0;
        break;
    }

    // Calculate Asr altitude
    final latRad = degreesToRadians(latitude);
    final decRad = degreesToRadians(declination);
    final cotA = shadowFactor + math.tan(latRad - decRad).abs();
    final altitude = radiansToDegrees(math.atan(1.0 / cotA));

    final ha = hourAngle(latitude, declination, altitude);
    final time = timeAtAltitude(jd, longitude, timezone, eqTime, ha);

    return _fractionalDayToDateTime(jd, time);
  }

  /// Calculates Maghrib prayer time (sunset + 1 minute for Egyptian method)
  DateTime _calculateMaghrib(double jd, double latitude, double longitude,
      double timezone, double declination, double eqTime) {
    const double angle = 0.833; // Standard sunset angle (accounting for refraction)
    final ha = hourAngle(latitude, declination, -angle);
    final time = timeAtAltitude(jd, longitude, timezone, eqTime, ha);

    final maghribTime = _fractionalDayToDateTime(jd, time);
    // Add 1 minute as per Egyptian method
    return maghribTime.add(const Duration(minutes: 1));
  }

  /// Calculates Isha prayer time (17.5° angle for Egyptian method)
  DateTime _calculateIsha(double jd, double latitude, double longitude,
      double timezone, double declination, double eqTime) {
    const double angle = 17.5; // Egyptian method
    final ha = hourAngle(latitude, declination, -angle);
    final time = timeAtAltitude(jd, longitude, timezone, eqTime, ha);

    return _fractionalDayToDateTime(jd, time);
  }

  /// Converts fractional day to DateTime
  DateTime _fractionalDayToDateTime(double jd, double fractionalDay) {
    final baseDate = _julianDayToDateTime(jd);
    
    // Ensure fractionalDay is in [0, 1) range
    double normalizedTime = fractionalDay;
    while (normalizedTime < 0) normalizedTime += 1.0;
    while (normalizedTime >= 1.0) normalizedTime -= 1.0;
    
    final totalSeconds = (normalizedTime * 24 * 3600).round();
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    
    // Ensure hours and minutes are in valid ranges
    hours = hours % 24;
    if (hours < 0) hours += 24;
    if (minutes < 0) minutes = 0;
    if (minutes >= 60) minutes = 59;

    return DateTime(baseDate.year, baseDate.month, baseDate.day, hours, minutes);
  }

  /// Converts Julian day to DateTime
  DateTime _julianDayToDateTime(double jd) {
    final j = jd + 0.5;
    final z = j.floor();
    final f = j - z;

    int a;
    if (z < 2299161) {
      a = z;
    } else {
      final alpha = ((z - 1867216.25) / 36524.25).floor();
      a = z + 1 + alpha - (alpha / 4).floor();
    }

    final b = a + 1524;
    final c = ((b - 122.1) / 365.25).floor();
    final d = (365.25 * c).floor();
    final e = ((b - d) / 30.6001).floor();

    final day = b - d - (30.6001 * e).floor() + f;
    final month = e < 14 ? e - 1 : e - 13;
    final year = month > 2 ? c - 4716 : c - 4715;

    return DateTime(year, month, day.floor());
  }
}

