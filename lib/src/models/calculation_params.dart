/// Enumeration of Asr calculation methods
enum AsrMethod {
  /// Standard method (shadow length = object height)
  standard,

  /// Shafi method (shadow length = object height + object height)
  shafi,

  /// Hanafi method (shadow length = object height * 2)
  hanafi,
}

/// Parameters for prayer time calculation
class CalculationParams {
  /// Observer's latitude in degrees (-90 to 90)
  final double latitude;

  /// Observer's longitude in degrees (-180 to 180)
  final double longitude;

  /// Timezone offset in hours from UTC
  final double timezone;

  /// Asr calculation method
  final AsrMethod asrMethod;

  /// Creates calculation parameters
  ///
  /// [latitude] - Observer's latitude in degrees
  /// [longitude] - Observer's longitude in degrees
  /// [timezone] - Timezone offset in hours (defaults to 0)
  /// [asrMethod] - Asr calculation method (defaults to standard)
  CalculationParams({
    required this.latitude,
    required this.longitude,
    this.timezone = 0.0,
    this.asrMethod = AsrMethod.standard,
  }) {
    if (latitude < -90 || latitude > 90) {
      throw ArgumentError('Latitude must be between -90 and 90 degrees');
    }
    if (longitude < -180 || longitude > 180) {
      throw ArgumentError('Longitude must be between -180 and 180 degrees');
    }
  }

  /// Creates calculation parameters with automatic timezone detection
  ///
  /// Uses the system's local timezone offset
  factory CalculationParams.withLocalTimezone({
    required double latitude,
    required double longitude,
    AsrMethod asrMethod = AsrMethod.standard,
  }) {
    final now = DateTime.now();
    final timezoneOffset = now.timeZoneOffset.inHours.toDouble();
    return CalculationParams(
      latitude: latitude,
      longitude: longitude,
      timezone: timezoneOffset,
      asrMethod: asrMethod,
    );
  }
}

