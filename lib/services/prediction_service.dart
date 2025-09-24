import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/soil_data.dart';
import '../models/crop_prediction.dart';

class PredictionService {
  // --- IMPORTANT: URL Configuration ---
  // For Android Emulator, use 10.0.2.2 to connect to your computer's localhost.
  // For Web or a physical device on the same Wi-Fi, use your computer's IP address (e.g., http://192.168.1.10:5000/predict).
  final String _baseUrl = "http://10.0.2.2:5000/predict";

  Future<CropPrediction> predictCrop(SoilData soilData) async {
    // ***
    // MOCK IMPLEMENTATION FOR UI TESTING (Remove this block for production)
    // ***
    print("--- Using Mock Prediction Data ---");
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    final mockJson = {
      "crop_family": "Legumes",
      "family_confidence": 0.89,
      "top_crops": [
        {"specific_crop": "Soybean", "confidence": 0.92},
        {"specific_crop": "Mung Bean", "confidence": 0.85},
      ],
    };
    return CropPrediction.fromJson(mockJson);

    /*
    // ***
    // REAL IMPLEMENTATION (Use this when your backend is ready)
    // ***
    print("--- Calling Real Prediction Endpoint ---");
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(soilData.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        return CropPrediction.fromJson(responseBody);
      } else {
        throw Exception('Failed to get prediction: Server responded with status code ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors, timeouts, etc.
      throw Exception('Failed to connect to the prediction service: $e');
    }
    */
  }
}
