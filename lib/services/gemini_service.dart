import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/soil_data.dart';

class GeminiService {
  final GenerativeModel _model;

  GeminiService(String apiKey)
    : _model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: apiKey,
        generationConfig: GenerationConfig(maxOutputTokens: 2000),
      );

  Future<String> getPlantRecommendations(SoilData data) async {
    final prompt = _buildPlantPrompt(data);
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ??
          "Could not generate a response. Please try again.";
    } catch (e) {
      print("Error calling Gemini API: $e");
      return "An error occurred while getting recommendations. Please check your network and API key.";
    }
  }

  Future<String> getSoilCareAdvice(SoilData data) async {
    final prompt = _buildSoilCarePrompt(data);
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ??
          "Could not generate a response. Please try again.";
    } catch (e) {
      print("Error calling Gemini API: $e");
      return "An error occurred while getting advice. Please check your network and API key.";
    }
  }

  String _buildPlantPrompt(SoilData data) {
    return '''
    Analyze the following soil conditions and recommend suitable plants.

    Soil Data:
    - Temperature: ${data.tempC?.toStringAsFixed(1) ?? 'N/A'} °C
    - Humidity: ${data.hum?.toStringAsFixed(1) ?? 'N/A'} %
    - pH: ${data.ph?.toStringAsFixed(2) ?? 'N/A'}
    - Nitrogen (N): ${data.nMgKg?.toStringAsFixed(1) ?? 'N/A'} mg/kg
    - Phosphorus (P): ${data.pMgKg?.toStringAsFixed(1) ?? 'N/A'} mg/kg
    - Potassium (K): ${data.kMgKg?.toStringAsFixed(1) ?? 'N/A'} mg/kg
    - Conductivity: ${data.conductivityUsCm?.toStringAsFixed(1) ?? 'N/A'} us/cm

    Based on these conditions, what specific plants (vegetables, fruits, flowers) are most suitable for this soil? Please provide a short list with brief reasons for each recommendation.
    ''';
  }

  String _buildSoilCarePrompt(SoilData data) {
    return '''
    Provide soil care advice based on the following data.

    Current Soil State:
    - pH: ${data.ph?.toStringAsFixed(2) ?? 'N/A'}
    - Nitrogen (N): ${data.nMgKg?.toStringAsFixed(1) ?? 'N/A'} mg/kg
    - Phosphorus (P): ${data.pMgKg?.toStringAsFixed(1) ?? 'N/A'} mg/kg
    - Potassium (K): ${data.kMgKg?.toStringAsFixed(1) ?? 'N/A'} mg/kg

    Based on this data, how can I best take care of this soil? Provide actionable steps to improve or maintain its health (e.g., what to add, what to avoid).
    ''';
  }
}
