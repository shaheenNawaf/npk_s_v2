import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/soil_data.dart';
import '../models/ai_advice.dart';

class GeminiService {
  final GenerativeModel _model;

  GeminiService(String apiKey)
    : _model = GenerativeModel(
        model: 'gemini-flash-latest',
        apiKey: apiKey,
        generationConfig: GenerationConfig(maxOutputTokens: 2000),
      );

  /*   Future<String> getPlantRecommendations(SoilData data) async {
    final prompt = _buildPlantPrompt(data);
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ??
          "Could not generate a response. Please try again.";
    } catch (e) {
      print("Error calling Gemini API: $e");
      return "An error occurred while getting recommendations. Please check your network and API key.";
    }
  } */

  /* String _buildPlantPrompt(SoilData data) {
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
  } */

  Future<AiAdvice> getSoilCareAdvice(SoilData data) async {
    final prompt = _buildSoilCarePrompt(data);
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text;

      if (responseText == null) {
        throw Exception("Received an empty response from the AI.");
      }

      final startIndex = responseText.indexOf('{');
      final endIndex = responseText.lastIndexOf('}');

      if (startIndex == -1 || endIndex == -1) {
        throw FormatException(
          "Could not find a valid JSON object in the model's response.",
        );
      }

      final jsonString = responseText.substring(startIndex, endIndex + 1);

      return AiAdvice.fromJson(jsonString);
    } catch (e) {
      print("Error parsing Gemini JSON: $e");
      return AiAdvice(
        title: "Error",
        summary:
            "Could not get or parse AI advice. The model's response might not be valid JSON.",
        actionableSteps: [],
        thingsToAvoid: [],
      );
    }
  }

  String _buildSoilCarePrompt(SoilData data) {
    return '''
    RESPOND ONLY WITH a JSON object in the following format:
    {
      "title": "<Creative title for the advice>",
      "summary": "<A two sentence summary>",
      "actionable_steps": ["<Step 1>", "<Step 2>", "..."],
      "things_to_avoid": ["<Thing to avoid 1>", "<Thing to avoid 2>", "..."]
    }

    Provide soil care advice based on the following data.
    Current Soil State:
        - pH: ${data.ph?.toStringAsFixed(2) ?? 'N/A'}
        - Nitrogen (N): ${data.nMgKg?.toStringAsFixed(1) ?? 'N/A'} mg/kg
        - Phosphorus (P): ${data.pMgKg?.toStringAsFixed(1) ?? 'N/A'} mg/kg
        - Potassium (K): ${data.kMgKg?.toStringAsFixed(1) ?? 'N/A'} mg/kg
    ''';
  }
}
