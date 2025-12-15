# Prayer Times 🕌

A Flutter package for calculating Islamic prayer times offline using astronomical calculations with the Egyptian method.

## Features ✨

- 🕐 Calculate all 5 daily prayers: Fajr, Dhuhr, Asr, Maghrib, Isha
- 🇪🇬 Uses Egyptian General Authority of Survey method
- 📐 Supports multiple Asr calculation methods (Standard, Shafi, Hanafi)
- 🌍 Works completely offline (no internet required)
- 📅 Calculate prayer times for any date
- ⏰ Get next prayer time and time remaining
- 🎯 Accurate astronomical calculations

## Installation 📦

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  egyptian_prayer_times: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Usage 🚀

### Basic Usage

```dart
import 'package:egyptian_prayer_times/egyptian_prayer_times.dart';

// Create a calculator for Cairo, Egypt
final calculator = PrayerCalculator(
  latitude: 30.0444,
  longitude: 31.2357,
  timezone: 2.0, // EET (UTC+2)
  asrMethod: AsrMethod.standard,
);

// Calculate prayer times for today
final times = calculator.calculate();

// Access individual prayer times
print('Fajr: ${times.fajr}');
print('Dhuhr: ${times.dhuhr}');
print('Asr: ${times.asr}');
print('Maghrib: ${times.maghrib}');
print('Isha: ${times.isha}');
```

### Calculate for a Specific Date

```dart
final date = DateTime(2024, 3, 11);
final times = calculator.calculate(date);
```

### Using Automatic Timezone Detection

```dart
final calculator = PrayerCalculator.withLocalTimezone(
  latitude: 30.0444,
  longitude: 31.2357,
  asrMethod: AsrMethod.standard,
);
```

### Different Asr Methods

```dart
// Standard method (shadow length = object height)
final calculatorStandard = PrayerCalculator(
  latitude: 30.0444,
  longitude: 31.2357,
  timezone: 2.0,
  asrMethod: AsrMethod.standard,
);

// Hanafi method (shadow length = object height * 2)
final calculatorHanafi = PrayerCalculator(
  latitude: 30.0444,
  longitude: 31.2357,
  timezone: 2.0,
  asrMethod: AsrMethod.hanafi,
);
```

### Get Next Prayer Time

```dart
final times = calculator.calculate();

// Get next prayer name
final nextPrayer = times.getNextPrayerName();
print('Next prayer: $nextPrayer'); // PrayerName.fajr, etc.

// Get next prayer DateTime
final nextPrayerTime = times.getNextPrayer();
print('Next prayer at: $nextPrayerTime');

// Get time remaining until next prayer
final timeRemaining = times.getTimeRemaining();
print('Time remaining: $timeRemaining'); // Duration object
```

### Get Current Prayer

```dart
final currentPrayer = times.getCurrentPrayerName();
if (currentPrayer != null) {
  print('Currently between: $currentPrayer and next prayer');
}
```

### Format Prayer Times

```dart
String formatTime(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

print('Fajr: ${formatTime(times.fajr)}'); // Fajr: 04:23
```

## API Reference 📚

### PrayerCalculator

Main class for calculating prayer times.

#### Constructors

- `PrayerCalculator({required double latitude, required double longitude, double? timezone, AsrMethod? asrMethod})`
  - Creates a calculator with specified parameters
  - `latitude`: Observer's latitude in degrees (-90 to 90)
  - `longitude`: Observer's longitude in degrees (-180 to 180)
  - `timezone`: Timezone offset in hours from UTC (defaults to 0)
  - `asrMethod`: Asr calculation method (defaults to `AsrMethod.standard`)

- `PrayerCalculator.withLocalTimezone({required double latitude, required double longitude, AsrMethod? asrMethod})`
  - Creates a calculator with automatic timezone detection

#### Methods

- `PrayerTimes calculate([DateTime? date])`
  - Calculates prayer times for the given date
  - If `date` is null, uses today's date
  - Returns a `PrayerTimes` object

### PrayerTimes

Represents the five daily prayer times.

#### Properties

- `DateTime fajr` - Fajr prayer time
- `DateTime dhuhr` - Dhuhr (noon) prayer time
- `DateTime asr` - Asr (afternoon) prayer time
- `DateTime maghrib` - Maghrib (sunset) prayer time
- `DateTime isha` - Isha (night) prayer time

#### Methods

- `DateTime? getPrayerTime(PrayerName prayer)` - Gets prayer time by name
- `Map<PrayerName, DateTime> toMap()` - Returns all prayer times as a map
- `PrayerName? getNextPrayerName([DateTime? currentTime])` - Gets next prayer name
- `DateTime? getNextPrayer([DateTime? currentTime])` - Gets next prayer DateTime
- `Duration? getTimeRemaining([DateTime? currentTime])` - Gets time remaining until next prayer
- `PrayerName? getCurrentPrayerName([DateTime? currentTime])` - Gets current prayer name

### CalculationParams

Parameters for prayer time calculation.

#### Properties

- `double latitude` - Observer's latitude in degrees
- `double longitude` - Observer's longitude in degrees
- `double timezone` - Timezone offset in hours
- `AsrMethod asrMethod` - Asr calculation method

### Enums

#### PrayerName

- `PrayerName.fajr`
- `PrayerName.dhuhr`
- `PrayerName.asr`
- `PrayerName.maghrib`
- `PrayerName.isha`

#### AsrMethod

- `AsrMethod.standard` - Standard method (shadow length = object height)
- `AsrMethod.shafi` - Shafi method (same as standard)
- `AsrMethod.hanafi` - Hanafi method (shadow length = object height * 2)

## Calculation Method 📐

This package uses the **Egyptian General Authority of Survey** method with the following parameters:

- **Fajr**: 19.5° angle below horizon
- **Dhuhr**: Midday (when sun crosses meridian)
- **Asr**: Shadow length calculation (varies by method)
  - Standard/Shafi: Shadow length = object height
  - Hanafi: Shadow length = object height * 2
- **Maghrib**: Sunset + 1 minute
- **Isha**: 17.5° angle below horizon

All calculations are performed using astronomical formulas for:
- Solar declination
- Equation of time
- Sun altitude angle
- Hour angle calculations

## Example App 📱

Check out the [example](example) directory for a complete sample application demonstrating all features.

## Notes 📝

- The calculations are based on astronomical formulas and work completely offline
- Prayer times are calculated for the local date/timezone you specify
- The Egyptian method is widely used in Egypt and many other countries
- Actual prayer times may vary slightly based on local moon sighting and Islamic authorities
- For polar regions (above 66.5° latitude), some prayer times may not be calculable during certain periods

## Contributing 🤝

Contributions are welcome! Please feel free to submit a Pull Request.

## License 📄

This project is licensed under the MIT License - see the LICENSE file for details.

## Author ✍️

Created with ❤️ by Ahmed Algzery

## Support 💬

For issues, questions, or suggestions, please file an issue on the [GitHub repository](https://github.com/ahmed-algzery/egyptian_prayer_times).

