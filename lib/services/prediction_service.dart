import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../models/soil_data.dart';
import '../models/crop_prediction.dart';
import '../config/api_config.dart';

class PredictionService {
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.healthUrl))
          .timeout(ApiConfig.healthCheckTimeout);

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
      return {'status': false, 'message': 'Cannot connect to backend: $e'};
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
        "soil_type_std": soilData.soilType ?? "Unknown",
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
        final Map<String, dynamic> responseBody = json.decode(response.body);

        print("✓ Crop Prediction Success!");
        print("Algorithm: ${responseBody['algorithm']}");
        print("Recommended Crop: ${responseBody['recommended_crop']}");
        print("Top 3 Predictions:");
        for (var item in responseBody['top_3_predictions']) {
          print(
            "  ${item['crop']} (${item['family']}) - ${item['confidence']}%",
          );
        }

        final top = responseBody['top_3_predictions'].first;
        final topRec = TopRecommendation(
          crop: top['crop'] ?? 'Unknown',
          family: top['family'] ?? 'Unknown',
          overallConfidence: (top['confidence'] as num?)?.toDouble() ?? 0.0,
          suitability: 'Highly Suitable',
        );

        final alternatives =
            (responseBody['top_3_predictions'] as List)
                .skip(1)
                .map(
                  (item) => AlternativeRecommendation(
                    crop: item['crop'] ?? 'Unknown',
                    family: item['family'] ?? 'Unknown',
                    overallConfidence:
                        (item['confidence'] as num?)?.toDouble() ?? 0.0,
                    suitability: 'Moderately Suitable',
                  ),
                )
                .toList();

        return PredictionResponse(
          status: 'success',
          modelType: responseBody['algorithm'] ?? 'Unknown',
          accuracyNote:
              'Algorithm accuracy: ${responseBody['algorithm_accuracy'] ?? 0.0}%',
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
          'Failed to get prediction: ${response.statusCode} ${response.body}',
        );
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
