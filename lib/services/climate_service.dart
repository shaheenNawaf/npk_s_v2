//For AJ

import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class ClimateService {
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

  Future<Map<String, double>> fetchClimateData(
    double latitude,
    double longitude,
  ) async {
    final now = DateTime.now();
    final lastYear = now.year - 1;
    final startDate = "$lastYear-01-01";
    final endDate = "$lastYear-12-31";

    final parameters =
        "T2M,RH2M,PRECTOTCORR"; // Temp at 2m, Humidity at 2m, Precipitation

    final url = Uri.parse(
      'https://power.larc.nasa.gov/api/temporal/daily/point'
      '?parameters=$parameters'
      '&community=AG'
      '&longitude=$longitude'
      '&latitude=$latitude'
      '&start=$startDate'
      '&end=$endDate'
      '&format=JSON',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final properties = jsonResponse['properties']['parameter'];

      // The API returns an average for each parameter over the date range.
      // We are accessing these averages directly.
      return {
        'avgTempC': properties['T2M']['-999'] ?? 0.0,
        'avgHumidity': properties['RH2M']['-999'] ?? 0.0,
        // Precipitation is often given as kg/m^2/day, which is equivalent to mm/day.
        // We multiply by 365 to get an annual estimate.
        'avgPrecipitation': (properties['PRECTOTCORR']['-999'] ?? 0.0) * 365,
      };
    } else {
      throw Exception('Failed to load climate data from NASA POWER API.');
    }
  }
}
