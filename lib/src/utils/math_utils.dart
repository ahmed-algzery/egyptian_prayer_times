import 'dart:math' as math;

/// Mathematical utilities for astronomical calculations used in prayer time computation.

/// Converts degrees to radians
double degreesToRadians(double degrees) {
  return degrees * (math.pi / 180.0);
}

/// Converts radians to degrees
double radiansToDegrees(double radians) {
  return radians * (180.0 / math.pi);
}

/// Calculates the Julian day number for a given date
///
/// The Julian day is the number of days since January 1, 4713 BC at noon UTC.
double julianDay(DateTime date) {
  int year = date.year;
  int month = date.month;
  int day = date.day;

  if (month <= 2) {
    year -= 1;
    month += 12;
  }

  int a = (year / 100).floor();
  int b = 2 - a + (a / 4).floor();

  double jd = (365.25 * (year + 4716)).floor().toDouble() +
      (30.6001 * (month + 1)).floor().toDouble() +
      day +
      b -
      1524.5;

  return jd;
}

/// Calculates the Julian century from Julian day
double julianCentury(double julianDay) {
  return (julianDay - 2451545.0) / 36525.0;
}

/// Calculates the geometric mean longitude of the sun (in degrees)
double sunGeometricMeanLongitude(double julianCentury) {
  double l0 = 280.46646 +
      julianCentury * (36000.76983 + julianCentury * 0.0003032);
  return l0 % 360.0;
}

/// Calculates the geometric mean anomaly of the sun (in degrees)
double sunGeometricMeanAnomaly(double julianCentury) {
  double m = 357.52911 +
      julianCentury * (35999.05029 - 0.0001537 * julianCentury);
  return m % 360.0;
}

/// Calculates the equation of the center of the sun (in degrees)
double sunEquationOfCenter(double julianCentury, double meanAnomaly) {
  double mRad = degreesToRadians(meanAnomaly);
  double sinM = math.sin(mRad);
  double sin2M = math.sin(2 * mRad);
  double sin3M = math.sin(3 * mRad);

  return sinM * (1.914602 - julianCentury * (0.004817 + 0.000014 * julianCentury)) +
      sin2M * (0.019993 - 0.000101 * julianCentury) +
      sin3M * 0.000289;
}

/// Calculates the true longitude of the sun (in degrees)
double sunTrueLongitude(
    double geometricMeanLongitude, double equationOfCenter) {
  return geometricMeanLongitude + equationOfCenter;
}

/// Calculates the apparent longitude of the sun (in degrees)
double sunApparentLongitude(double trueLongitude, double julianCentury) {
  double omega = 125.04 - 1934.136 * julianCentury;
  return trueLongitude - 0.00569 - 0.00478 * math.sin(degreesToRadians(omega));
}

/// Calculates the mean obliquity of the ecliptic (in degrees)
double meanObliquityOfEcliptic(double julianCentury) {
  double seconds = 21.448 -
      julianCentury *
          (46.8150 +
              julianCentury * (0.00059 - julianCentury * 0.001813));
  return 23.0 + (26.0 + (seconds / 60.0)) / 60.0;
}

/// Calculates the corrected obliquity of the ecliptic (in degrees)
double obliquityCorrection(double meanObliquity, double julianCentury) {
  double omega = 125.04 - 1934.136 * julianCentury;
  return meanObliquity + 0.00256 * math.cos(degreesToRadians(omega));
}

/// Calculates the declination of the sun (in degrees)
double sunDeclination(double apparentLongitude, double obliquityCorrection) {
  double lambdaRad = degreesToRadians(apparentLongitude);
  double obliqRad = degreesToRadians(obliquityCorrection);

  double sinDeclination =
      math.sin(obliqRad) * math.sin(lambdaRad);
  double declination = radiansToDegrees(math.asin(sinDeclination));

  return declination;
}

/// Calculates the equation of time (in minutes)
double equationOfTime(double julianCentury, double geometricMeanLongitude,
    double geometricMeanAnomaly, double obliquityCorrection) {
  double l0Rad = degreesToRadians(geometricMeanLongitude);
  double mRad = degreesToRadians(geometricMeanAnomaly);
  double obliqRad = degreesToRadians(obliquityCorrection);

  double e = 0.016708634 - julianCentury * (0.000042037 + 0.0000001267 * julianCentury);

  double y = math.tan(obliqRad / 2);
  y = y * y;

  double sin2l0 = math.sin(2 * l0Rad);
  double sinM = math.sin(mRad);
  double cos2l0 = math.cos(2 * l0Rad);
  double sin4l0 = math.sin(4 * l0Rad);
  double sin2M = math.sin(2 * mRad);

  double equation = y * sin2l0 -
      2 * e * sinM +
      4 * e * y * sinM * cos2l0 -
      0.5 * y * y * sin4l0 -
      1.25 * e * e * sin2M;

  return radiansToDegrees(equation) * 4;
}

/// Calculates the hour angle for a given sun altitude (in degrees)
///
/// [latitude] - Observer's latitude in degrees
/// [declination] - Sun's declination in degrees
/// [altitude] - Sun's altitude angle in degrees
double hourAngle(double latitude, double declination, double altitude) {
  double latRad = degreesToRadians(latitude);
  double decRad = degreesToRadians(declination);
  double altRad = degreesToRadians(altitude);

  double cosHA = (math.sin(altRad) - math.sin(latRad) * math.sin(decRad)) /
      (math.cos(latRad) * math.cos(decRad));

  // Clamp to valid range [-1, 1]
  cosHA = cosHA.clamp(-1.0, 1.0);

  double ha = radiansToDegrees(math.acos(cosHA));
  return ha;
}

/// Calculates the time when the sun reaches a specific altitude
///
/// [julianDay] - Julian day number
/// [longitude] - Observer's longitude in degrees
/// [timezone] - Timezone offset in hours
/// [equationOfTime] - Equation of time in minutes
/// [hourAngle] - Hour angle in degrees
double timeAtAltitude(double julianDay, double longitude, double timezone,
    double equationOfTime, double hourAngle) {
  // Calculate solar noon (when sun crosses meridian)
  double solarNoon = (720 - 4 * longitude - equationOfTime + timezone * 60) / 1440;

  // Calculate time for the given altitude
  double time = solarNoon + (hourAngle * 4) / 1440;

  // Normalize to [0, 1] range
  while (time < 0) time += 1.0;
  while (time > 1) time -= 1.0;

  return time;
}

