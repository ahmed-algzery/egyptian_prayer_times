import 'package:flutter/material.dart';
import 'package:egyptian_prayer_times/egyptian_prayer_times.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prayer Times Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Cairo, Egypt coordinates
  final double _latitude = 30.0444;
  final double _longitude = 31.2357;
  final double _timezone = 2.0;

  AsrMethod _asrMethod = AsrMethod.standard;
  DateTime _selectedDate = DateTime.now();
  PrayerTimes? _prayerTimes;
  PrayerName? _nextPrayer;
  Duration? _timeRemaining;

  @override
  void initState() {
    super.initState();
    _calculatePrayerTimes();
    _updateNextPrayer();
    // Update next prayer every minute
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        setState(() {
          _updateNextPrayer();
        });
        _startTimer();
      }
    });
  }

  void _calculatePrayerTimes() {
    setState(() {
      final calculator = PrayerCalculator(
        latitude: _latitude,
        longitude: _longitude,
        timezone: _timezone,
        asrMethod: _asrMethod,
      );
      _prayerTimes = calculator.calculate(_selectedDate);
      _updateNextPrayer();
    });
  }

  void _updateNextPrayer() {
    if (_prayerTimes != null) {
      _nextPrayer = _prayerTimes!.getNextPrayerName();
      _timeRemaining = _prayerTimes!.getTimeRemaining();
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _calculatePrayerTimes();
      });
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '$hours ساعة و $minutes دقيقة';
    }
    return '$minutes دقيقة';
  }

  String _getPrayerNameArabic(PrayerName prayer) {
    switch (prayer) {
      case PrayerName.fajr:
        return 'الفجر';
      case PrayerName.dhuhr:
        return 'الظهر';
      case PrayerName.asr:
        return 'العصر';
      case PrayerName.maghrib:
        return 'المغرب';
      case PrayerName.isha:
        return 'العشاء';
    }
  }

  IconData _getPrayerIcon(PrayerName prayer) {
    switch (prayer) {
      case PrayerName.fajr:
        return Icons.wb_twilight;
      case PrayerName.dhuhr:
        return Icons.wb_sunny;
      case PrayerName.asr:
        return Icons.wb_cloudy;
      case PrayerName.maghrib:
        return Icons.nights_stay; // sunset icon does not exist in Icons
      case PrayerName.isha:
        return Icons.nightlight_round;
    }
  }

  Color _getPrayerColor(PrayerName prayer) {
    switch (prayer) {
      case PrayerName.fajr:
        return Colors.blue;
      case PrayerName.dhuhr:
        return Colors.orange;
      case PrayerName.asr:
        return Colors.amber;
      case PrayerName.maghrib:
        return Colors.red;
      case PrayerName.isha:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أوقات الصلاة'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Location and Settings Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⚙️ الإعدادات',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _selectDate,
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'طريقة حساب العصر:',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<AsrMethod>(
                      segments: const [
                        ButtonSegment<AsrMethod>(
                          value: AsrMethod.standard,
                          label: Text('قياسي'),
                        ),
                        ButtonSegment<AsrMethod>(
                          value: AsrMethod.hanafi,
                          label: Text('حنفي'),
                        ),
                      ],
                      selected: {_asrMethod},
                      onSelectionChanged: (Set<AsrMethod> newSelection) {
                        setState(() {
                          _asrMethod = newSelection.first;
                          _calculatePrayerTimes();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Next Prayer Card
            if (_nextPrayer != null && _timeRemaining != null)
              Card(
                elevation: 4,
                color: _getPrayerColor(_nextPrayer!).withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        _getPrayerIcon(_nextPrayer!),
                        size: 48,
                        color: _getPrayerColor(_nextPrayer!),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'الصلاة القادمة: ${_getPrayerNameArabic(_nextPrayer!)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDuration(_timeRemaining!),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _getPrayerColor(_nextPrayer!),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_nextPrayer != null && _timeRemaining != null)
              const SizedBox(height: 20),

            // Prayer Times List
            if (_prayerTimes != null) ...[
              _buildPrayerTimeCard(
                PrayerName.fajr,
                _prayerTimes!.fajr,
                _nextPrayer == PrayerName.fajr,
              ),
              const SizedBox(height: 12),
              _buildPrayerTimeCard(
                PrayerName.dhuhr,
                _prayerTimes!.dhuhr,
                _nextPrayer == PrayerName.dhuhr,
              ),
              const SizedBox(height: 12),
              _buildPrayerTimeCard(
                PrayerName.asr,
                _prayerTimes!.asr,
                _nextPrayer == PrayerName.asr,
              ),
              const SizedBox(height: 12),
              _buildPrayerTimeCard(
                PrayerName.maghrib,
                _prayerTimes!.maghrib,
                _nextPrayer == PrayerName.maghrib,
              ),
              const SizedBox(height: 12),
              _buildPrayerTimeCard(
                PrayerName.isha,
                _prayerTimes!.isha,
                _nextPrayer == PrayerName.isha,
              ),
            ],

            const SizedBox(height: 20),

            // Location Info Card
            Card(
              elevation: 4,
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 48,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'الموقع',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'القاهرة، مصر',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_latitude.toStringAsFixed(4)}°N, ${_longitude.toStringAsFixed(4)}°E',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimeCard(
    PrayerName prayer,
    DateTime time,
    bool isNext,
  ) {
    final color = _getPrayerColor(prayer);
    final isHighlighted = isNext;

    return Card(
      elevation: isHighlighted ? 6 : 2,
      color: isHighlighted ? color.withOpacity(0.1) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(
            _getPrayerIcon(prayer),
            color: color,
          ),
        ),
        title: Text(
          _getPrayerNameArabic(prayer),
          style: TextStyle(
            fontSize: 18,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
            color: isHighlighted ? color : null,
          ),
        ),
        trailing: Text(
          _formatTime(time),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isHighlighted ? color : null,
          ),
        ),
      ),
    );
  }
}

