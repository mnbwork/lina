import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';

final weatherProvider = FutureProvider.autoDispose<String>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final data = await api.fetchWeather();
  if (data.isNotEmpty && data['current'] != null) {
    final temp = data['current']['temperature_2m'];
    return '$temp°C';
  }
  return '--°C';
});

final nextPrayerProvider = FutureProvider.autoDispose<String>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final data = await api.fetchPrayerTimes();
  
  if (data.isNotEmpty && data['data'] != null) {
    final timings = data['data']['timings'] as Map<String, dynamic>;
    final now = DateTime.now();
    final timeFormat = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    // Simple logic to find the next prayer (MVP)
    const prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    for (var prayer in prayers) {
      final pTime = timings[prayer] as String;
      if (timeFormat.compareTo(pTime) < 0) {
        return '$prayer at $pTime';
      }
    }
    return 'Fajr at ${timings['Fajr']} (Tomorrow)';
  }
  return 'Loading...';
});
