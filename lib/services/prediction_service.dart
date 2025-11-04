import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../models/soil_data.dart';
import '../models/crop_prediction.dart';
import '../config/api_config.dart';

class PredictionService {
  /// Check if the backend server is reachable and healthy
  /// Returns a map with 'status' (bool) and 'message' (String)
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.healthUrl),
      ).timeout(ApiConfig.healthCheckTimeout);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return {
          'status': true,
          'message': body['message'] ?? 'Backend is healthy',
          'details': body,
        };
      } else {
        return {
          'status': false,
          'message': 'Backend responded with status ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Cannot connect to backend: $e',
      };
    }
  }
  Future<PredictionResponse> predictCrop(SoilData soilData) async {
  print("--- Calling Crop Prediction Endpoint (/predict) ---");
  try {
    // Build the request payload
    final payload = {
    "pH": soilData.ph,
    "N": soilData.nMgKg,
    "P": soilData.pMgKg,
    "K": soilData.kMgKg,
    "Ca": soilData.calcium ?? 0.0,
    "Mg": soilData.magnesium ?? 0.0,
    "Na": soilData.sodium ?? 0.0,
    "ExK": soilData.exchangeableK ?? 0.0,
    "S": soilData.sulfur ?? 0.0,
    "OM": soilData.organicMatter ?? 0.0,
    "Cu": soilData.copper ?? 0.0,
    "Zn": soilData.zinc ?? 0.0,
    "Fe": soilData.iron ?? 0.0,
    "Mn": soilData.manganese ?? 0.0,
    "B": soilData.boron ?? 0.0,
    "lat": soilData.latitude,
    "lon": soilData.longitude,
    "soil_type_std": soilData.soilType ?? "Unknown",
    "soil_texture_group": soilData.soilTextureGroup ?? "Unknown",
    "avg_temp": soilData.avgTempC ?? 0.0,
    "avg_humidity": soilData.avgHumidity ?? 0.0,
    "avg_precip": soilData.avgPrecipitation ?? 0.0,
    "sand_content": soilData.sandContent ?? 0,
    "silt_content": soilData.siltContent ?? 0,
    "clay_content": soilData.clayContent ?? 0,
    "loam_indicator": soilData.isLoam == true ? 1 : 0,
    };

    print("Payload (${payload.length} fields): ${jsonEncode(payload)}");

    final response = await http
        .post(
          Uri.parse(ApiConfig.predictUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(ApiConfig.predictionTimeout);

    if (response.statusCode == 200) {
      final List<dynamic> responseBody = json.decode(response.body);

      print("✓ Crop Prediction Success!");
      for (var item in responseBody) {
        print("  ${item['crop']} (${item['family']}) - ${item['confidence']}%");
      }

      if (responseBody.isEmpty) {
        throw Exception("Empty response list");
      }

      // First item = top recommendation
      final top = responseBody.first;
      final topRec = TopRecommendation(
        crop: top['crop'] ?? 'Unknown',
        family: top['family'] ?? 'Unknown',
        overallConfidence: (top['confidence'] as num?)?.toDouble() ?? 0.0,
        suitability: 'Highly Suitable',
      );

      // Remaining items = alternatives
      final alternatives = responseBody.skip(1).map((item) {
        return AlternativeRecommendation(
          crop: item['crop'] ?? 'Unknown',
          family: item['family'] ?? 'Unknown',
          overallConfidence: (item['confidence'] as num?)?.toDouble() ?? 0.0,
          suitability: 'Moderately Suitable',
        );
      }).toList();

      // Build final response object
      return PredictionResponse(
        status: 'success',
        modelType: 'Hybrid ANN Classifier',
        accuracyNote: 'Model outputs top 3 ranked crops by confidence.',
        inputFeaturesUsed: payload.length,
        topRecommendation: topRec,
        alternativeRecommendations: alternatives,
      );
    } else if (response.statusCode == 422) {
      final errorBody = json.decode(response.body);
      print("✗ Validation Error: ${errorBody['detail']}");
      throw Exception('Invalid input: ${errorBody['detail']}');
    } else {
      print("✗ Server Error (${response.statusCode}): ${response.body}");
      throw Exception(
          'Failed to get prediction: ${response.statusCode} ${response.body}');
    }

  } on TimeoutException {
    print("✗ Request Timeout");
  throw Exception('Request timed out. Please check your connection.');
  } on SocketException {
    print("✗ No Internet Connection");
  throw Exception('No internet connection.');
  } on FormatException catch (e) {
    print("✗ Invalid Response Format: $e");
  throw Exception('Invalid response from server.');
  } catch (e) {
    print("✗ Exception: $e");
  throw Exception('Failed to connect to prediction service: $e');
  }
}
}