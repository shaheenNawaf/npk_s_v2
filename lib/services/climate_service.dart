import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import for date formatting

class ClimateService {
  final String _apiKey;

  ClimateService(this._apiKey);

  /// Fetches the current device location.
  /// Throws an exception if permissions are denied or service is disabled.
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Fetches climate data from NASA POWER API for the last 365 days.
  /// Returns a map of the parsed climate data.
  Future<Map<String, double>> fetchClimateData(
    double latitude,
    double longitude,
  ) async {
    if (_apiKey.isEmpty) {
      throw Exception("NASA POWER API Key is missing.");
    }

    // A more robust way to calculate the date range: last 365 days from yesterday.
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final oneYearAgo = yesterday.subtract(const Duration(days: 365));

    // Use the intl package to format dates to YYYYMMDD, which is highly compatible.
    final DateFormat formatter = DateFormat('yyyyMMdd');
    final String startDate = formatter.format(oneYearAgo);
    final String endDate = formatter.format(yesterday);

    final parameters = "T2M,RH2M,PRECTOTCORR"; // Temp, Humidity, Precipitation

    final url = Uri.parse(
      'https://power.larc.nasa.gov/api/temporal/daily/point'
      '?parameters=$parameters'
      '&community=AG'
      '&longitude=$longitude'
      '&latitude=$latitude'
      '&start=$startDate'
      '&end=$endDate'
      '&format=JSON'
      '&api_key=$_apiKey',
    );

    // Critical for debugging: This prints the exact URL being requested to the console.
    print('Requesting NASA POWER API URL: $url');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final properties = jsonResponse['properties']['parameter'];

      // When requesting a date range, the API returns daily values.
      // We must calculate the average from this map of daily data.
      return {
        'avgTempC': _calculateAverage(properties['T2M']),
        'avgHumidity': _calculateAverage(properties['RH2M']),
        // Precipitation is mm/day, so we get the daily average and multiply by 365.
        'avgPrecipitation':
            (_calculateAverage(properties['PRECTOTCORR'])) * 365,
      };
    } else {
      // Includes the server's response in the error for better debugging.
      throw Exception(
        'Failed to load climate data from NASA. Status code: ${response.statusCode}. Response: ${response.body}',
      );
    }
  }

  /// Helper function to calculate the average from the API's daily data map.
  double _calculateAverage(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return 0.0;

    double sum = 0;
    int count = 0;

    data.forEach((key, value) {
      // -999 is NASA's code for missing data, so we must exclude it.
      if (value is num && value != -999) {
        sum += value;
        count++;
      }
    });

    return count > 0 ? sum / count : 0.0;
  }
}
