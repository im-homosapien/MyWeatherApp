// weatherservice.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'weathermodel.dart';

class WeatherService {
  final String apiKey;
  final String BASE_URL = 'http://api.openweathermap.org/data/2.5/weather';

  WeatherService(this.apiKey);

  Future<String> getCurrentCity() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return 'Permission Denied';
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);

      print(
          'Position: ${position.latitude}, ${position.longitude}'); // Debug print

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        String? mainCity = placemarks[0].locality;
        print('Main City: $mainCity'); // Debug print
        return mainCity ?? "Unknown";
      } else {
        return "Unknown";
      }
    } catch (e) {
      print('Error getting current city: $e');
      return "Unknown";
    }
  }

  Future<Weather> getWeather(String cityName) async {
    final response = await http
        .get(Uri.parse('$BASE_URL?q=$cityName&APPID=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body));
    } else {
      print('Failed to load weather information');
      throw Exception('Failed to load weather information');
    }
  }
}
