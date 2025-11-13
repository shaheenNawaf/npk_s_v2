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
      print(response.body);
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
      // Validate that all required fields are present
      final List<String> missingFields = [];

      if (soilData.ph == null) missingFields.add('pH');
      if (soilData.nMgKg == null) missingFields.add('N');
      if (soilData.pMgKg == null) missingFields.add('P');
      if (soilData.kMgKg == null) missingFields.add('K');
      if (soilData.calcium == null) missingFields.add('Ca');
      if (soilData.magnesium == null) missingFields.add('Mg');
      if (soilData.sodium == null) missingFields.add('Na');
      if (soilData.exchangeableK == null) missingFields.add('Ex. K');
      if (soilData.sulfur == null) missingFields.add('S');
      if (soilData.organicMatter == null) missingFields.add('OM');
      if (soilData.copper == null) missingFields.add('Cu');
      if (soilData.zinc == null) missingFields.add('Zn');
      if (soilData.iron == null) missingFields.add('Fe');
      if (soilData.manganese == null) missingFields.add('Mn');
      if (soilData.boron == null) missingFields.add('B');

      if (missingFields.isNotEmpty) {
        final errorMessage =
            'Missing required soil parameters: ${missingFields.join(', ')}';
        print("✗ Validation Error: $errorMessage");
        throw Exception(errorMessage);
      }

      // Build the request payload - all fields are guaranteed to be non-null
      final payload = {
        "pH": soilData.ph!,
        "N": soilData.nMgKg!,
        "P": soilData.pMgKg!,
        "K": soilData.kMgKg!,
        "Ca": soilData.calcium!,
        "Mg": soilData.magnesium!,
        "Na": soilData.sodium!,
        "Ex. K": soilData.exchangeableK!,
        "S": soilData.sulfur!,
        "OM": soilData.organicMatter!,
        "Cu": soilData.copper!,
        "Zn": soilData.zinc!,
        "Fe": soilData.iron!,
        "Mn": soilData.manganese!,
        "B": soilData.boron!,
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
        print("Recommended Crop: ${responseBody['crop']}");
        print("Confidence: ${(responseBody['confidence'] as num) * 100}%");

        // Parse all_probabilities to get top crops
        final allProbabilities =
            responseBody['all_probabilities'] as Map<String, dynamic>;

        // Sort probabilities in descending order
        final sortedCrops =
            allProbabilities.entries.toList()
              ..sort((a, b) => (b.value as num).compareTo(a.value as num));

        print("Top 3 Predictions:");
        for (var i = 0; i < 3 && i < sortedCrops.length; i++) {
          print(
            "  ${sortedCrops[i].key} - ${((sortedCrops[i].value as num) * 100).toStringAsFixed(2)}%",
          );
        }

        // Get top recommendation
        final topCrop = sortedCrops.first;
        final topConfidence =
            (topCrop.value as num).toDouble() * 100; // Convert to percentage

        final topRec = TopRecommendation(
          crop: topCrop.key,
          family: '', // Family not provided in new API
          overallConfidence: topConfidence,
          suitability: _getSuitabilityFromConfidence(topConfidence),
        );

        // Get alternative recommendations (2nd and 3rd)
        final alternatives =
            sortedCrops.skip(1).take(2).map((entry) {
              final confidence = (entry.value as num).toDouble() * 100;
              return AlternativeRecommendation(
                crop: entry.key,
                family: '', // Family not provided in new API
                overallConfidence: confidence,
                suitability: _getSuitabilityFromConfidence(confidence),
              );
            }).toList();

        return PredictionResponse(
          status: 'success',
          modelType:
              'Machine Learning Model', // Algorithm not provided in new API
          accuracyNote: 'Based on soil nutrient analysis',
          inputFeaturesUsed: payload.length,
          topRecommendation: topRec,
          alternativeRecommendations: alternatives,
        );
      } else if (response.statusCode == 422) {
        final errorBody = json.decode(response.body);
        print(
          "✗ Validation Error: ${errorBody['error'] ?? errorBody['detail']}",
        );

        // Handle new error format
        if (errorBody.containsKey('required_features')) {
          print("Required features: ${errorBody['required_features']}");
        }

        throw Exception(
          'Invalid input: ${errorBody['error'] ?? errorBody['detail']}',
        );
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

  /// Helper method to determine suitability level based on confidence percentage
  String _getSuitabilityFromConfidence(double confidence) {
    if (confidence >= 70) {
      return 'Excellent';
    } else if (confidence >= 50) {
      return 'Good';
    } else if (confidence >= 30) {
      return 'Fair';
    } else {
      return 'Poor';
    }
  }
}
