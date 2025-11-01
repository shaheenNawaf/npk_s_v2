import 'dart:convert';

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
  print("--- Calling Detailed Prediction Endpoint (111 Features) ---");
  try {
    // Build the request payload with all 111 features
    final payload = {
      // Primary nutrients
      "pH": soilData.ph,
      "N": soilData.nMgKg,
      "P": soilData.pMgKg,
      "K": soilData.kMgKg,

      // Secondary nutrients - provide defaults for null values
      "Ca": soilData.calcium ?? 0.0,
      "Mg": soilData.magnesium ?? 0.0,
      "Na": soilData.sodium ?? 0.0,
      "ExK": soilData.exchangeableK ?? 0.0,
      "S": soilData.sulfur ?? 0.0, 
      "OM": soilData.organicMatter ?? 0.0,

      // Micronutrients - provide defaults for null values
      "Cu": soilData.copper ?? 0.0,
      "Zn": soilData.zinc ?? 0.0,
      "Fe": soilData.iron ?? 0.0,
      "Mn": soilData.manganese ?? 0.0,
      "B": soilData.boron ?? 0.0, 

      // Location
      "lat": soilData.latitude,
      "lon": soilData.longitude,

      // Soil properties
      "soil_type_std": soilData.soilType ?? "Unknown",
      "soil_texture_group": soilData.soilTextureGroup ?? "Unknown",
      
      // Climate
      "avg_temp": soilData.avgTempC ?? 0.0,
      "avg_humidity": soilData.avgHumidity ?? 0.0,
      "avg_precip": soilData.avgPrecipitation ?? 0.0,

      // Soil content indicators (0-3 scale)
      "sand_content": soilData.sandContent ?? 0,
      "silt_content": soilData.siltContent ?? 0,
      "clay_content": soilData.clayContent ?? 0,
      "loam_indicator": soilData.isLoam == true ? 1 : 0,
    };
    
    // ONLY include optional fields if they have values
    if (soilData.existingCrops != null && soilData.existingCrops!.isNotEmpty) {
      payload["crops"] = soilData.existingCrops;
    }
    if (soilData.primaryCrop != null && soilData.primaryCrop!.isNotEmpty) {
      payload["primary_crop"] = soilData.primaryCrop;
    }

    print("Payload: ${jsonEncode(payload)}");

    final response = await http.post(
      Uri.parse(ApiConfig.predictDetailedUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    ).timeout(ApiConfig.predictionTimeout);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      print("Response: $responseBody");
      return PredictionResponse.fromJson(responseBody);
    } else {
      print("Error response: ${response.body}");
      throw Exception(
        'Failed to get prediction: Server responded with status code ${response.statusCode}',
      );
    }
  } catch (e) {
    throw Exception('Failed to connect to the prediction service: $e');
  }
}
}
