import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiServiceProvider = Provider((ref) => ApiService());

class ApiService {
  // Using Dhaka coordinates for MVP.
  // TODO: Implement location services in the future.
  final double lat = 23.8103;
  final double lon = 90.4125;

  Future<Map<String, dynamic>> fetchWeather() async {
    final url = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,weather_code');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Weather API Error: $e');
    }
    return {};
  }

  Future<Map<String, dynamic>> fetchPrayerTimes() async {
    final date = DateTime.now();
    final dateStr = '${date.day}-${date.month}-${date.year}';
    final url = Uri.parse('https://api.aladhan.com/v1/timings/$dateStr?latitude=$lat&longitude=$lon&method=1');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Prayer API Error: $e');
    }
    return {};
  }
}
