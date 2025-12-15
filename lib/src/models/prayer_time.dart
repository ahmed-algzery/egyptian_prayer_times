/// Enumeration of prayer names
enum PrayerName {
  fajr,
  dhuhr,
  asr,
  maghrib,
  isha,
}

/// Represents the five daily prayer times
class PrayerTimes {
  /// Fajr prayer time
  final DateTime fajr;

  /// Dhuhr (noon) prayer time
  final DateTime dhuhr;

  /// Asr (afternoon) prayer time
  final DateTime asr;

  /// Maghrib (sunset) prayer time
  final DateTime maghrib;

  /// Isha (night) prayer time
  final DateTime isha;

  /// Creates a PrayerTimes object with all five prayer times
  PrayerTimes({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  /// Gets the prayer time by name
  DateTime? getPrayerTime(PrayerName prayer) {
    switch (prayer) {
      case PrayerName.fajr:
        return fajr;
      case PrayerName.dhuhr:
        return dhuhr;
      case PrayerName.asr:
        return asr;
      case PrayerName.maghrib:
        return maghrib;
      case PrayerName.isha:
        return isha;
    }
  }

  /// Gets all prayer times as a map
  Map<PrayerName, DateTime> toMap() {
    return {
      PrayerName.fajr: fajr,
      PrayerName.dhuhr: dhuhr,
      PrayerName.asr: asr,
      PrayerName.maghrib: maghrib,
      PrayerName.isha: isha,
    };
  }

  /// Gets the next prayer time from the current time
  ///
  /// Returns null if all prayers for today have passed
  PrayerName? getNextPrayerName([DateTime? currentTime]) {
    currentTime ??= DateTime.now();
    final prayers = [
      PrayerName.fajr,
      PrayerName.dhuhr,
      PrayerName.asr,
      PrayerName.maghrib,
      PrayerName.isha,
    ];

    // Check if we need to look at tomorrow's Fajr
    final tomorrowFajr = fajr.add(const Duration(days: 1));

    for (final prayer in prayers) {
      final prayerTime = getPrayerTime(prayer)!;
      if (prayerTime.isAfter(currentTime)) {
        return prayer;
      }
    }

    // If all prayers have passed, next is tomorrow's Fajr
    if (tomorrowFajr.isAfter(currentTime)) {
      return PrayerName.fajr;
    }

    return null;
  }

  /// Gets the next prayer time from the current time
  ///
  /// Returns null if all prayers for today have passed
  DateTime? getNextPrayer([DateTime? currentTime]) {
    final nextPrayerName = getNextPrayerName(currentTime);
    if (nextPrayerName == null) {
      return null;
    }

    // If it's Fajr and we're past today's Isha, return tomorrow's Fajr
    if (nextPrayerName == PrayerName.fajr) {
      currentTime ??= DateTime.now();
      if (isha.isBefore(currentTime)) {
        return fajr.add(const Duration(days: 1));
      }
    }

    return getPrayerTime(nextPrayerName);
  }

  /// Gets the time remaining until the next prayer
  ///
  /// Returns null if all prayers for today have passed
  Duration? getTimeRemaining([DateTime? currentTime]) {
    final nextPrayer = getNextPrayer(currentTime);
    if (nextPrayer == null) {
      return null;
    }

    currentTime ??= DateTime.now();
    return nextPrayer.difference(currentTime);
  }

  /// Gets the current prayer name (if we're between two prayers)
  ///
  /// Returns null if we're not between any two prayers
  PrayerName? getCurrentPrayerName([DateTime? currentTime]) {
    currentTime ??= DateTime.now();
    final prayers = [
      PrayerName.fajr,
      PrayerName.dhuhr,
      PrayerName.asr,
      PrayerName.maghrib,
      PrayerName.isha,
    ];

    for (int i = 0; i < prayers.length - 1; i++) {
      final currentPrayer = getPrayerTime(prayers[i])!;
      final nextPrayer = getPrayerTime(prayers[i + 1])!;

      if (currentTime.isAfter(currentPrayer) &&
          currentTime.isBefore(nextPrayer)) {
        return prayers[i];
      }
    }

    // Check if we're between Isha and tomorrow's Fajr
    final tomorrowFajr = fajr.add(const Duration(days: 1));
    if (currentTime.isAfter(isha) && currentTime.isBefore(tomorrowFajr)) {
      return PrayerName.isha;
    }

    return null;
  }

  @override
  String toString() {
    return 'PrayerTimes(fajr: $fajr, dhuhr: $dhuhr, asr: $asr, maghrib: $maghrib, isha: $isha)';
  }
}

