import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//Other Imports char
import '../models/soil_data.dart';
import '../models/crop_prediction.dart';
import '../models/ai_advice.dart';
import '../services/gemini_service.dart';
import '../services/prediction_service.dart';
import 'widgets/app_bar.dart';
import 'widgets/stat_card.dart';

class ResultsScreen extends StatefulWidget {
  final SoilData soilData;

  const ResultsScreen({super.key, required this.soilData});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late final GeminiService _geminiService;
  late final PredictionService _predictionService;

  bool _isPredicting = false;
  bool _isGettingAdvice = false;
  PredictionResponse? _predictionResponse;
  AiAdvice? _aiAdvice;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Correctly initializes Gemini Service with the API key
    const apiKey = String.fromEnvironment('GEMINI_API_KEY');
    if (apiKey.isEmpty) {
      throw AssertionError(
        'GEMINI_API_KEY is not set. Please create config.json and run with --dart-define-from-file=config.json',
      );
    }
    _geminiService = GeminiService(apiKey);

    _predictionService = PredictionService();
  }

  Future<void> _predictBestCrop() async {
    setState(() {
      _isPredicting = true;
      _errorMessage = null;
      _predictionResponse = null;
    });
    try {
      final result = await _predictionService.predictCrop(widget.soilData);
      setState(() => _predictionResponse = result);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isPredicting = false);
    }
  }

  Future<void> _getGeneralAiAdvice() async {
    setState(() {
      _isGettingAdvice = true;
      _errorMessage = null;
      _aiAdvice = null;
    });
    final result = await _geminiService.getSoilCareAdvice(widget.soilData);
    setState(() {
      _aiAdvice = result;
      _isGettingAdvice = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isAnyActionLoading = _isPredicting || _isGettingAdvice;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Soil Analysis Complete"),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                StatCard(
                  title: "Potassium",
                  value: widget.soilData.kMgKg?.toStringAsFixed(0) ?? 'N/A',
                  unit: "mg/kg",
                  range: "Optimal: 100-200",
                  rangeMin: 100,
                  rangeMax: 200,
                ),
                StatCard(
                  title: "Phosphorus",
                  value: widget.soilData.pMgKg?.toStringAsFixed(0) ?? 'N/A',
                  unit: "mg/kg",
                  range: "Optimal: 30-50",
                  rangeMin: 30,
                  rangeMax: 50,
                ),
                StatCard(
                  title: "Nitrogen",
                  value: widget.soilData.nMgKg?.toStringAsFixed(0) ?? 'N/A',
                  unit: "mg/kg",
                  range: "Optimal: 25-50",
                  rangeMin: 25,
                  rangeMax: 50,
                ),
                StatCard(
                  title: "Moisture",
                  value: widget.soilData.hum?.toStringAsFixed(0) ?? 'N/A',
                  unit: "%",
                  range: "Optimal: 40-60",
                  rangeMin: 40,
                  rangeMax: 60,
                ),
                StatCard(
                  title: "pH Level",
                  value: widget.soilData.ph?.toStringAsFixed(1) ?? 'N/A',
                  unit: "",
                  range: "Optimal: 6.0-7.0",
                  rangeMin: 6.0,
                  rangeMax: 7.0,
                ),
                StatCard(
                  title: "OM",
                  value:
                      widget.soilData.organicMatter?.toStringAsFixed(1) ??
                      'N/A',
                  unit: "%",
                  range: "Optimal: 2-6",
                  rangeMin: 2,
                  rangeMax: 6,
                ),
              ],
            ),
            if (_predictionResponse != null &&
                _predictionResponse!.predictions.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionTitle("Custom Model Prediction"),
              const SizedBox(height: 16),
              ..._predictionResponse!.predictions.map((prediction) {
                return _buildPredictionResultCard(prediction);
              }).toList(),
            ],
            if (_aiAdvice != null) ...[
              const SizedBox(height: 24),
              _buildSectionTitle("General AI Advice"),
              const SizedBox(height: 16),
              _buildAiAdviceCard(_aiAdvice!),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 32),
            if (isAnyActionLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _predictBestCrop,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Predict Best Crop",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _getGeneralAiAdvice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Get General AI Advice",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildPredictionResultCard(CropPrediction prediction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Family: ${prediction.cropFamily}",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Confidence: ${(prediction.familyConfidence * 100).toStringAsFixed(1)}%",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const Divider(height: 24),
            Text(
              "Top Recommendations:",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...prediction.topCrops.map(
              (crop) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.grass, color: Colors.green),
                title: Text(crop.specificCrop, style: GoogleFonts.poppins()),
                trailing: Text(
                  "${(crop.confidence * 100).toStringAsFixed(1)}%",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiAdviceCard(AiAdvice advice) {
    return Card(
      color: Colors.blueGrey.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blueGrey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              advice.title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              advice.summary,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.blueGrey.shade700,
              ),
            ),
            const Divider(height: 24),
            if (advice.actionableSteps.isNotEmpty) ...[
              Text(
                "Actionable Steps:",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...advice.actionableSteps.map(
                (step) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green.shade600,
                  ),
                  title: Text(step, style: GoogleFonts.poppins()),
                ),
              ),
            ],
            if (advice.thingsToAvoid.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                "Things to Avoid:",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...advice.thingsToAvoid.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.highlight_off,
                    color: Colors.red.shade400,
                  ),
                  title: Text(item, style: GoogleFonts.poppins()),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
