# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2025-01-XX

### Added
- Initial release
- Prayer time calculation using Egyptian General Authority of Survey method
- Support for all 5 daily prayers: Fajr, Dhuhr, Asr, Maghrib, Isha
- Multiple Asr calculation methods: Standard, Shafi, and Hanafi
- Offline calculation (no internet required)
- Astronomical calculations for accurate prayer times
- Helper methods to get next prayer time and time remaining
- Support for calculating prayer times for any date
- Automatic timezone detection
- Complete documentation and examples
- Comprehensive test suite
- Example Flutter application demonstrating all features

### Features
#### Prayer Calculator
- Calculate prayer times for any location using latitude and longitude
- Support for custom timezone or automatic timezone detection
- Calculate prayer times for any date
- Egyptian method with Fajr at 19.5° and Isha at 17.5°

#### Prayer Times Model
- Access individual prayer times
- Get next prayer time and time remaining
- Get current prayer name
- Convert prayer times to map format
- Helper methods for prayer time queries

#### Calculation Methods
- Egyptian General Authority of Survey method
- Standard Asr method (shadow length = object height)
- Shafi Asr method (same as standard)
- Hanafi Asr method (shadow length = object height * 2)

